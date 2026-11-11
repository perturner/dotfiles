#!/usr/bin/env python3

import warnings
# Suppress the 'pynvml package is deprecated' warning from nvidia-ml-py
warnings.filterwarnings("ignore", message="The pynvml package is deprecated")

import pynvml
import sys
import json
import glob
import os
import time

def get_corsair_psu_stats():
    """
    Reads power and temp from Corsair PSU via sysfs.
    Searches for the hwmon directory named 'corsairpsu'.
    """
    psu_watts = 0
    psu_temp = 0
    
    try:
        # Find the hwmon path for corsairpsu
        hwmon_path = None
        for path in glob.glob("/sys/class/hwmon/hwmon*"):
            try:
                with open(os.path.join(path, "name"), "r") as f:
                    name = f.read().strip()
                    if "corsairpsu" in name:
                        hwmon_path = path
                        break
            except:
                continue
        
        if hwmon_path:
            # power1_input is usually total DC power in microWatts
            try:
                # On HX1500i, power1_input is often total power
                # power2_input might be the 12V rail
                p_path = os.path.join(hwmon_path, "power1_input")
                if os.path.exists(p_path):
                    with open(p_path, "r") as f:
                        psu_watts = int(int(f.read().strip()) / 1000000)
            except:
                pass

            # Try to read temp (usually temp1_input in millidegrees)
            try:
                t_path = os.path.join(hwmon_path, "temp1_input")
                if os.path.exists(t_path):
                    with open(t_path, "r") as f:
                        # millidegrees to degrees
                        psu_temp = int(int(f.read().strip()) / 1000)
            except:
                pass
            
            # If we successfully read both, return immediately to avoid subprocess
            if psu_watts > 0 and psu_temp > 0:
                return psu_watts, psu_temp

    except Exception:
        pass

    # Fallback to subprocess sensors if we want to be 100% sure matching previous logic
    # It's still lighter than nvidia-smi
    import subprocess
    try:
        out = subprocess.check_output(["sensors", "corsairpsu-hid-3-6"], text=True)
        for line in out.splitlines():
            if "power total" in line:
                # format: power total: 370.00 W
                parts = line.split()
                if len(parts) >= 3:
                    psu_watts = int(float(parts[2]))
            if "case temp" in line:
                # format: case temp:    +54.8°C
                parts = line.split()
                if len(parts) >= 3:
                    temp_str = parts[2].lstrip('+').rstrip('°C')
                    psu_temp = int(float(temp_str))
    except:
        pass

    return psu_watts, psu_temp

def get_cpu_package_power():
    """
    Calculates Intel RAPL package power from the package energy counter.
    The counter reports cumulative microjoules, so watts require a delta over time.
    """
    energy_path = "/sys/class/powercap/intel-rapl:0/energy_uj"
    max_range_path = "/sys/class/powercap/intel-rapl:0/max_energy_range_uj"
    state_dir = os.environ.get("XDG_RUNTIME_DIR", "/tmp")
    state_path = os.path.join(state_dir, "waybar_cpu_rapl.state")

    try:
        with open(energy_path, "r") as f:
            energy = int(f.read().strip())

        max_range = None
        try:
            with open(max_range_path, "r") as f:
                max_range = int(f.read().strip())
        except Exception:
            pass

        now = time.monotonic()
        previous_energy = None
        previous_time = None

        try:
            with open(state_path, "r") as f:
                previous_energy_s, previous_time_s = f.read().strip().split()
                previous_energy = int(previous_energy_s)
                previous_time = float(previous_time_s)
        except Exception:
            pass

        with open(state_path, "w") as f:
            f.write(f"{energy} {now}")

        if previous_energy is None or previous_time is None:
            return None

        elapsed = now - previous_time
        if elapsed <= 0:
            return None

        delta = energy - previous_energy
        if delta < 0 and max_range:
            delta += max_range

        if delta < 0:
            return None

        return int(round((delta / 1_000_000) / elapsed))
    except Exception:
        return None

def get_temp_color(temp, thresholds):
    """
    Returns theme hex color for temperature based on (normal, warm, hot) thresholds.
    """
    cool, normal, warm, hot = "#7E9CD8", "#98BB6C", "#E6C384", "#E82424"
    try:
        wal_path = os.path.expanduser("~/.cache/wal/colors.json")
        with open(wal_path, "r") as f:
            c = json.load(f).get("colors", {})
            cool = c.get("color4", cool)
            normal = c.get("color10", normal)
            warm = c.get("color11", warm)
            hot = c.get("color9", hot)
    except Exception:
        pass

    t_normal, t_warm, t_hot = thresholds
    if temp >= t_hot:
        return hot
    if temp >= t_warm:
        return warm
    if temp >= t_normal:
        return normal
    return cool

def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "gpu"

    try:
        pynvml.nvmlInit()
        handle = pynvml.nvmlDeviceGetHandleByIndex(0)

        # Get Stats
        util = pynvml.nvmlDeviceGetUtilizationRates(handle).gpu
        temp = pynvml.nvmlDeviceGetTemperature(handle, pynvml.NVML_TEMPERATURE_GPU)
        
        mem_info = pynvml.nvmlDeviceGetMemoryInfo(handle)
        mem_used = mem_info.used / 1024**2 # MB
        mem_total = mem_info.total / 1024**2 # MB
        mem_gb = mem_info.used / 1024**3 # GB
        mem_perc = int((mem_used / mem_total) * 100)

        power_mW = pynvml.nvmlDeviceGetPowerUsage(handle)
        power_W = int(power_mW / 1000)

        if mode == "gpu":
            # Text: Util% Temp°C VRAM_GiB
            t_color = get_temp_color(temp, (40, 60, 75))
            text = f"{util:>3}% <span color='{t_color}'>{temp:>3}°C</span> {mem_gb:>4.1f}GiB"
            tooltip = f"GPU Usage: {util}%\nTemp: {temp}°C\nVRAM: {int(mem_used)}MB / {int(mem_total)}MB ({mem_perc}%)\nPower: {power_W}W"
            
            out = {
                "text": text,
                "tooltip": tooltip,
                "class": "custom-gpu",
                "percentage": util
            }

        elif mode == "power":
            # Get PSU stats
            psu_watts, psu_temp = get_corsair_psu_stats()
            cpu_watts = get_cpu_package_power()
            cpu_text = f"{cpu_watts:>3}W" if cpu_watts is not None else "N/A"
            psu_color = get_temp_color(psu_temp, (38, 50, 62))
            
            text = f"CPU: {cpu_text} | GPU: {power_W:>3}W | Total: {psu_watts:>3}W | <span color='{psu_color}'> {psu_temp:>2}°C</span>"
            tooltip = f"CPU Package Power: {cpu_text}\nGPU Power Draw: {power_W}W\nPSU Power Draw: {psu_watts}W\nPSU Temp: {psu_temp}°C"

            out = {
                "text": text,
                "tooltip": tooltip,
                "class": "custom-wattage"
            }
            
        print(json.dumps(out))

    except pynvml.NVMLError as error:
        # Fallback/Error output
        err_text = "GPU Err"
        print(json.dumps({"text": err_text, "tooltip": str(error), "class": "custom-gpu"}))
    except Exception as e:
        # General error
        print(json.dumps({"text": "Err", "tooltip": str(e), "class": "custom-gpu"}))
    finally:
        try:
            pynvml.nvmlShutdown()
        except:
            pass

if __name__ == "__main__":
    main()
