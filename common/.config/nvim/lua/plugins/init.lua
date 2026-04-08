-- lua/plugins/init.lua

return {
    -- AESTHETICS
    {
        "EdenEast/nightfox.nvim",
        lazy = true,
        -- priority = 1000,
        config = function()
            require("nightfox").setup({
                options = {
                    styles = { comments = "italic", keywords = "bold", types = "bold" }
                }
            })
            vim.cmd.colorscheme("terafox")
        end,
    },
    {
        "maxmx03/solarized.nvim",
        lazy = true,
        -- priority = 1000,
        config = function()
            vim.o.termguicolors = true
            vim.cmd.colorscheme('solarized')
        end,
    },
    { "folke/tokyonight.nvim", lazy = true },
    { "rebelot/kanagawa.nvim", lazy = true },
    {
        "neanias/everforest-nvim",
        lazy = true,
        -- priority = 1000,
        config = function()
            require("everforest").setup({
                background = "soft", -- Best for eye strain and G9 panels
                ui_contrast = "low",
            })
        vim.cmd("colorscheme everforest")
        end,
    },
    { "catppuccin/nvim", name = "catppuccin", lazy = true },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup({
                ensure_installed = {
                    "cpp", "python", "lua", "cmake", "markdown", "vimdoc",
                    "proto", "bash", "json", "toml", "c_sharp", "bitbake"
                },
                highlight = { enable = true },
                indent = { enable = true }
            })
        end
    },
    { "nvim-tree/nvim-web-devicons", lazy = false },
    { "echasnovski/mini.completion", version = false, config = true },
    {
        "stevearc/oil.nvim",
        opts = {
            view_options = {
                show_hidden = true,
                is_hidden_file = function(name, bufnr)
                    return name == ".. " or name == ".git"
                end,
            },
        },
        dependencies = { "nvim-tree/nvim-web-devicons" },
        lazy = false
    },
    { "numToStr/Comment.nvim", opts = {}, lazy = false },
    {
        "lewis6991/satellite.nvim",
        opts = {
            current_win_only = false,
            winblend = 50,
            zindex = 40,
            handlers = {
                search = { enable = true },
                diagnostic = { enable = true },
                gitsigns = { enable = true },
                marks = { enable = true },
            },
        },
    },

    -- LSP: The Intelligence
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "SmiteshP/nvim-navic",
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "clangd", "basedpyright", "ruff", "buf_ls", "bashls", "omnisharp"
                }
            })

            local navic = require('nvim-navic')

            -- Use LspAttach autocommand for unified mapping
            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    local bufnr = args.buf
                    local function map(mode, l, r, desc)
                        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
                    end

                    if client and client.server_capabilities.documentSymbolProvider then
                        navic.attach(client, bufnr)
                    end

                    -- Navigation (The "Reviewer" Tools)
                    map('n', 'gd', vim.lsp.buf.definition, "Go to Definition")
                    map('n', 'gr', "<cmd>Telescope lsp_references<cr>", "Go to References")
                    map('n', 'K',  vim.lsp.buf.hover, "Hover Documentation")
                    map('n', '<leader>rn', vim.lsp.buf.rename, "Rename Symbol")
                    map('n', '<leader>ca', vim.lsp.buf.code_action, "Code Action")

                    -- G9 Smart Split Logic (gv)
                    map('n', 'gv', function()
                        local wins = vim.api.nvim_tabpage_list_wins(0)
                        local code_wins = {}
                        for _, win in ipairs(wins) do
                            if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "" then
                                table.insert(code_wins, win)
                            end
                        end
                        if #code_wins == 1 then vim.cmd("vsplit") else vim.cmd("wincmd w") end
                        vim.lsp.buf.definition()
                    end, "Go to Definition (Smart Split)")
                end,
            })

            -- Native 0.11+ Server Enablement (No CMP capabilities needed)
            vim.lsp.enable('clangd', {
                cmd = { "clangd", "--background-index", "--header-insertion=never" }
            })
            vim.lsp.enable('basedpyright')
            vim.lsp.enable('ruff')
            vim.lsp.enable('buf_ls')
            vim.lsp.config('bashls', {
                cmd = { 'bash-language-server', 'start' },
               filetypes = { 'sh', 'bash' },
               settings = {
                   bashIde = {
                       -- Ensure shellcheck is installed (via Mason or apt)
                       shellcheckPath = 'shellcheck',
      -- Optional: filter which files are analyzed
      globPattern = "*@(.sh|.inc|.bash|.command)",
    },
  },
  -- Define how Neovim finds the root of your script project
  root_markers = { '.git', 'install.sh', 'requirements.txt' },
})
            vim.lsp.enable('omnisharp')
        end
    },

    -- TELESCOPE & CMAKE
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
            { "<leader><leader>", "<cmd>Telescope buffers<cr>", desc = "Switch Buffers" },
            { "<C-e>", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
        },
        opts = {
            pickers = {
                find_files = {
                    hidden = true, -- Show hidden files (dotfiles)
                },
            },
        }
    },
    { "Civitasv/cmake-tools.nvim", opts = { cmake_build_directory = "build/${variant:buildType}" } },

    -- GIT & UI EXTRAS
    { "lewis6991/gitsigns.nvim", opts = { signs = { add = { text = '┃' }, change = { text = '┃' } } } },
    { "ThePrimeagen/harpoon", branch = "harpoon2", config = true },
    { "HiPhish/rainbow-delimiters.nvim" },
    { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
    { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
    { "tpope/vim-obsession", cmd = "Obsession" },
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                cpp = { "clang-format" },
                python = { "ruff_format" },
                proto = { "buf" },
                bash = { "shfmt" },
            },
            format_on_save = { lsp_fallback = true }
        }
    },
    { "folke/trouble.nvim", opts = {}, cmd = "Trouble" },
    { "karb94/neoscroll.nvim", config = true },
    { "stevearc/dressing.nvim", opts = {} },
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.set_autocmds"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                },
            },
            cmdline = {
                view = "cmdline", -- Force the cmdline to the bottom
            },
            presets = {
                bottom_search = true,
                command_palette = false,
                long_message_to_split = true,
                inc_rename = false,
                lsp_doc_border = true,
            },
        },
        dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" }
    },
    {
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
    },
}
