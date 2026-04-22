return {
    "mfussenegger/nvim-dap",
    dependencies = {
        {
            "rcarriga/nvim-dap-ui",
            dependencies = { "nvim-neotest/nvim-nio" },
            opts = {},
        },
    },
    keys = {
        { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
        { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Conditional Breakpoint" },
        { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
        { "<leader>do", function() require("dap").step_over() end, desc = "Step Over" },
        { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
        { "<leader>dO", function() require("dap").step_out() end, desc = "Step Out" },
        { "<leader>dr", function() require("dap").repl.open() end, desc = "REPL" },
        { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
        { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
        { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
    },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        -- Auto open/close UI
        dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
        dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
        dap.listeners.before.event_exited["dapui"] = function() dapui.close() end

        -- GDB adapter for host (x86)
        dap.adapters.gdb = {
            type = "executable",
            command = "gdb",
            args = { "--interpreter=dap", "--quiet" },
        }

        -- GDB adapter for CM4 remote (Yocto toolchain)
        dap.adapters.gdb_remote = {
            type = "executable",
            command = "/opt/iudc_toolchain/sysroots/x86_64-pokysdk-linux/usr/bin/aarch64-poky-linux/aarch64-poky-linux-gdb",
            args = { "--interpreter=dap", "--quiet", "-x", "/tmp/iudc_gdbinit" },
        }

        dap.configurations.cpp = {
            {
                name = "Host (x86) - Launch",
                type = "gdb",
                request = "launch",
                program = function()
                    return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/build/linux-debug/", "file")
                end,
                cwd = "${workspaceFolder}",
            },
            {
                name = "CM4 Remote - Attach (gdbserver)",
                type = "gdb_remote",
                request = "attach",
                target = function()
                    return vim.fn.input("Target (host:port): ", "192.168.1.100:2345")
                end,
                program = function()
                    return vim.fn.input("Local binary: ", vim.fn.getcwd() .. "/build/cm4-debug/", "file")
                end,
                cwd = "${workspaceFolder}",
            },
        }
        dap.configurations.c = dap.configurations.cpp
    end,
}
