#!/home/per/.config/waybar/venv/bin/python3

import pynvml
import sys
import json
import glob
import os

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
                    if "corsairpsu" in f.read().strip():
                        hwmon_path = path
                        break
            except:
                continue
        
        if hwmon_path:
            # Try to read power (usually power1_input in microWatts)
            try:
                p_path = os.path.join(hwmon_path, "power1_input")
                if os.path.exists(p_path):
                    with open(p_path, "r") as f:
                        # microWatts to Watts
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
            text = f"{util:>3}% {temp:>3}°C {mem_gb:>4.1f}GiB"
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
            
            # Text: ⚡ GPU: 123W | Total: 456W |  50°C
            text = f"⚡ GPU: {power_W:>3}W | Total: {psu_watts:>3}W |  {psu_temp:>2}°C"
            tooltip = f"PSU Power Draw: {psu_watts}W\nGPU Power Draw: {power_W}W\nPSU Temp: {psu_temp}°C"

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
