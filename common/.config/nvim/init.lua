-- ~/.config/nvim/init.lua

-- =============================================================================
-- 1. CORE OPTIONS
-- =============================================================================
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = "unnamedplus"
vim.opt.list = true
vim.opt.listchars = {
    tab = '» ',       -- Show tabs as »
    trail = '·',      -- Show trailing spaces as dots
    nbsp = '␣',       -- Show non-breaking spaces
    extends = '→',    -- Show if line extends off-screen
    precedes = '←',   -- Show if line precedes off-screen
    multispace = '·', -- Show a dot for every space in indentation
    leadmultispace = '· ',
}
-- =============================================================================
-- 2. BOOTSTRAP LAZY.NVIM
-- =============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- =============================================================================
-- 3. PLUGIN SETUP
-- =============================================================================
require("lazy").setup({
    -- AESTHETICS
    {
        "EdenEast/nightfox.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("nightfox").setup({
                options = {
                    styles = {
                        comments = "italic",
                        keywords = "bold",
                        types = "bold",
                    }
                }
            })
            vim.cmd.colorscheme("terafox") -- Fixed: Added quotes
        end,
    },
    -- TREESITTER: Syntax Highlighting (0.11+ Fixed)
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup({
                ensure_installed = { "cpp", "python", "lua", "cmake", "markdown", "vimdoc", "proto" },
                highlight = { enable = true },
                indent = { enable = true }
            })
        end
    },
    {
      "nvim-tree/nvim-web-devicons",
      lazy = false, -- Ensure it's available immediately for Lualine/Navic
      config = function()
        require('nvim-web-devicons').setup({
          default = true, -- Use default icon if one isn't found
      })
    end
    },
    -- LSP: The Intelligence (Using Native 0.11 API)
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "SmiteshP/nvim-navic",
            "hrsh7th/cmp-nvim-lsp",
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({ ensure_installed = { "clangd", "basedpyright", "ruff", "buf_ls" } })

            local navic = require('nvim-navic')
            local caps = require('cmp_nvim_lsp').default_capabilities()

            -- Unified on_attach for all LSPs
            local on_attach = function(client, bufnr)
                local function map(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
                end

                if client.server_capabilities.documentSymbolProvider then
                    navic.attach(client, bufnr)
                end

                -- Code Navigation
                map('n', 'gd', vim.lsp.buf.definition, "Go to Definition")
                map('n', 'gr', "<cmd>Telescope lsp_references<cr>", "Go to References")
                map('n', 'K',  vim.lsp.buf.hover, "Hover Documentation")
                map('n', '<leader>rn', vim.lsp.buf.rename, "Rename Symbol")
                map('n', '<leader>ca', vim.lsp.buf.code_action, "Code Action")

                -- Smart Split (gv): Logic for your 57" monitor
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
                end, "Go to Definition (Split)")
            end

            -- Native 0.11+ Clangd Configuration
            vim.lsp.config('clangd', {
                on_attach = on_attach,
                capabilities = caps,
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--header-insertion=never",
                    "--completion-style=detailed",
                    "--function-arg-placeholders=true",
                },
            })
            vim.lsp.enable('clangd')

            -- Python Configuration
            vim.lsp.config('basedpyright', { on_attach = on_attach, capabilities = caps })
            vim.lsp.enable('basedpyright')
            vim.lsp.config('ruff', { on_attach = on_attach, capabilities = caps })
            vim.lsp.enable('ruff')

            -- Protobuf support
            vim.lsp.config('buf_ls', {
                on_attach = on_attach,
                capabilities = caps,
            })
            vim.lsp.enable('buf_ls')
        end
    },

    -- AUTOCOMPLETION (CMP)
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
                snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
                mapping = cmp.mapping.preset.insert({
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
                        else fallback() end
                    end, { 'i', 's' }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                }, {
                    { name = 'buffer' },
                })
            })
        end
    },

    -- TELESCOPE: Search (Wide Layout)
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
            defaults = {
                layout_strategy = "horizontal",
                layout_config = { width = 0.95, preview_width = 0.5 },
            }
        }
    },

    -- CMAKE TOOLS
    {
        "Civitasv/cmake-tools.nvim",
        opts = {
            cmake_build_directory = "build/${variant:buildType}",
        }
    },

    -- GIT: Gitsigns & Diffview
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            signs = { add = { text = '┃' }, change = { text = '┃' }, delete = { text = '_' } },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local function map(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
                end
                map('n', '<leader>hp', gs.preview_hunk, "Preview Hunk")
                map('n', '<leader>hr', gs.reset_hunk, "Reset Hunk")
                map('n', '<leader>hb', function() gs.blame_line{full=true} end, "Full Blame Popup")
                map('n', '<leader>hi', gs.preview_hunk_inline, "Preview Hunk Inline")
            end
        }
    },
    {
        "sindrets/diffview.nvim",
        keys = {
            { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git Diffview" },
            { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File History" },
            { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
        }
    },

    -- UI & NAVIGATION EXTRAS
    { "ThePrimeagen/harpoon", branch = "harpoon2", config = function() require("harpoon"):setup() end },
    {
        "HiPhish/rainbow-delimiters.nvim",
        config = function()
            local rb = require('rainbow-delimiters')
            vim.g.rainbow_delimiters = {
                strategy = {
                    [''] = rb.strategy['global'],
                },
                query = {
                    [''] = 'rainbow-delimiters',
                },
                highlight = {
                    'RainbowDelimiterRed',
                    'RainbowDelimiterYellow',
                    'RainbowDelimiterBlue',
                    'RainbowDelimiterOrange',
                    'RainbowDelimiterGreen',
                    'RainbowDelimiterViolet',
                    'RainbowDelimiterCyan',
                },
            }
        end
    },
    { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = { scope = { enabled = true } } },
    { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
    {
        "tpope/vim-obsession",
        cmd = "Obsession", -- Lazy loads when you start a session manually
    },
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                cpp = { "clang-format" },
                python = { "ruff_format" },
                proto = { "buf" },
            },
            format_on_save = {
                lsp_fallback = true,
                timeout_ms = 500
            }
        }
    },
    {
        "folke/trouble.nvim",
        opts = {}, -- for default options, refer to the configuration section for custom setup.
        cmd = "Trouble",
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",desc = "Diagnostics (Trouble)" },
            { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
            { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
            { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions / references / ... (Trouble)" },
            { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
            { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        config = function()
            require('lualine').setup({
                options = { theme = 'auto', icons_enabled = true, globalstatus = true },
                sections = {
                    lualine_c = { { 'filename', path = 1 } },
                    lualine_x = {
                        {
                            function() return vim.lsp.status() end,
                            color = { fg = "#CE9178" }
                        },
                        {
                            function()
                                local cmake = require("cmake-tools")
                                local preset = cmake.get_configure_preset()
                                local build_type = cmake.get_build_type()
                                return string.format("󱁤 %s (%s)", preset or "No Preset", build_type or "None")
                            end,
                            color = { fg = "#4EC9B0" }
                        },
                        'encoding', 'filetype'
                    }
                }
            })
        end
    },
})

-- =============================================================================
-- 4. GLOBAL UI & BREADCRUMBS
-- =============================================================================
-- Helper function to manage the Winbar content
_G.get_winbar = function()
    local navic = require("nvim-navic")
    if navic.is_available() then
        return " " .. navic.get_location()
    end
    return ""
end

-- Set the winbar to evaluate our function
vim.o.winbar = "%{%v:lua.get_winbar()%}"

vim.diagnostic.config({
    virtual_text = { prefix = '●' },
    float = { border = "rounded" },
    severity_sort = true,
})

-- Hover/Signature Borders
local _border = "rounded"
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = _border })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signatureHelp, { border = _border })

-- =============================================================================
-- 5. AUTOCOMMANDS & KEYMAPS
-- =============================================================================

-- Split Navigation (Alt + hjkl)
vim.keymap.set('n', '<M-h>', '<C-w>h')
vim.keymap.set('n', '<M-j>', '<C-w>j')
vim.keymap.set('n', '<M-k>', '<C-w>k')
vim.keymap.set('n', '<M-l>', '<C-w>l')

-- Escape Hatch
vim.keymap.set('i', 'jk', '<ESC>')
vim.keymap.set('n', '<leader>ev', ":edit $MYVIMRC<CR>", { desc = "Edit Config" })

-- C++ Switch Header/Source
vim.keymap.set('n', '<M-o>', function()
vim.lsp.buf.execute_command({
    command = "clangd.switchSourceHeader",
        arguments = { vim.uri_from_bufnr(0) },
        })
    end, { desc = "Switch Source/Header" })

-- Auto-cleanup whitespace
vim.api.nvim_create_autocmd("BufWritePre", { pattern = "*", command = [[%s/\s\+$//e]] })

-- CMake Symlink Sync
vim.api.nvim_create_autocmd("User", {
    pattern = "CMakeGenerateSucceeded",
    callback = function()
        local build_dir = require("cmake-tools").get_build_directory()
        if build_dir then
            os.execute("ln -sf " .. build_dir .. "/compile_commands.json .")
            vim.cmd("LspRestart clangd")
        end
    end,
})

-- CMake Selection & Generation
vim.keymap.set('n', '<leader>cp', '<cmd>CMakeSelectConfigurePreset<cr>', { desc = "Select Configure Preset" })
vim.keymap.set('n', '<leader>cg', '<cmd>CMakeGenerate<cr>', { desc = "CMake Generate (re-configure)" })
-- Build & Test
vim.keymap.set('n', '<leader>b', '<cmd>CMakeBuild<cr>', { desc = "CMake Build" })
vim.keymap.set('n', '<leader>t', '<cmd>CMakeRunTest<cr>', { desc = "CMake Test" })
-- Clean & Stop
vim.keymap.set('n', '<leader>cc', '<cmd>CMakeClean<cr>', { desc = "CMake Clean" })
vim.keymap.set('n', '<leader>cs', '<cmd>CMakeStop<cr>', { desc = "Stop Active Build" })
-- CMake Console
vim.keymap.set('n', '<leader>ci', '<cmd>CMakeStepOut<cr>', { desc = "Toggle CMake Console" })

-- Auto-Save Logic
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertLeave" }, {
    callback = function()
        if vim.bo.modified and vim.bo.buftype == "" then
            vim.cmd("silent! update")
        end
    end,
})

-- Auto-session management
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        -- Only trigger if nvim is opened without specific file arguments
        if vim.fn.argc() == 0 then
            if vim.fn.filereadable("Session.vim") == 1 then
                vim.cmd("source Session.vim")
                vim.schedule(function()
                    vim.cmd("bufdo if &buftype == '' | doautocmd FileType | endif")
                end)
            else
                -- Automatically start tracking a session in the current directory
                vim.cmd("Obsession")
            end
        end
    end,
})

vim.g.loaded_python3_provider = 0
