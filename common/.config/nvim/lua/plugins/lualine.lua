return {
    "nvim-lualine/lualine.nvim",
    config = function()
        require('lualine').setup({
            options = { theme = 'auto', globalstatus = true },
            sections = {
                lualine_c = { { 'filename', path = 1 } },
                lualine_x = {
                    {
                        function()
                            local cmake = require("cmake-tools")
                            local preset = cmake.get_configure_preset()
                            local build_type = cmake.get_build_type()
                            return string.format("󱁤 %s (%s)", preset or "No Preset", build_type or "None")
                        end,
                        cond = function()
                            local ok, cmake = pcall(require, "cmake-tools")
                            return ok and cmake.is_cmake_project()
                        end,
                        color = { fg = "#4EC9B0" }
                    },
                    'encoding', 'filetype'
                }
            }
        })
    end
}
