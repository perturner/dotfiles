return {
    "nvim-lualine/lualine.nvim",
    config = function()
        -- Pull accent colors from the active kanagawa palette so the statusline
        -- stays in sync with the theme (works across wave/dragon/lotus variants)
        -- rather than hardcoding tokyonight hexes. Falls back gracefully if
        -- kanagawa isn't available for some reason.
        local palette = {}
        local ok, kanagawa_colors = pcall(require, "kanagawa.colors")
        if ok then
            local theme = kanagawa_colors.setup().theme
            palette = {
                yellow = theme.syn.identifier,  -- carpYellow-ish
                red    = theme.diag.error,      -- samuraiRed
                teal   = theme.syn.type,        -- waveAqua2 (teal)
            }
        end
        local c_yellow = palette.yellow or "#e0af68"
        local c_red    = palette.red    or "#f7768e"
        local c_teal   = palette.teal   or "#4EC9B0"

        require('lualine').setup({
            options = { theme = 'auto', globalstatus = true },
            sections = {
                lualine_b = {
                    'branch',
                    {
                        'diff',
                        source = function()
                            local gs = vim.b.gitsigns_status_dict
                            if gs then
                                return { added = gs.added, modified = gs.changed, removed = gs.removed }
                            end
                        end,
                    },
                },
                lualine_c = {
                    {
                        function()
                            local cwd = vim.fn.getcwd()
                            local wt = cwd:match(".*/([^/]+)$")
                            return " " .. (wt or "")
                        end,
                        color = { fg = c_yellow }
                    },
                    { 'filename', path = 1 },
                },
                lualine_x = {
                    {
                        function()
                            local status = require("dap").status()
                            return status ~= "" and (" " .. status) or ""
                        end,
                        cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
                        color = { fg = c_red }
                    },
                    { 'diagnostics', sources = { 'nvim_diagnostic' } },
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
                        color = { fg = c_teal }
                    },
                    {
                        function()
                            local clients = vim.lsp.get_clients({ bufnr = 0 })
                            if #clients == 0 then return "" end
                            return "󰒍 " .. clients[1].name
                        end,
                    },
                    'filetype'
                }
            }
        })
    end
}
