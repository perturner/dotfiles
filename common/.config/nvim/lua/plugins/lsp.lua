return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "SmiteshP/nvim-navic",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "clangd", "basedpyright", "ruff", "buf_ls", "bashls", "omnisharp",
                "neocmake", "lua_ls", "taplo", "yamlls", "jsonls"
            }
        })

        -- Formatters / tools (not LSP servers). These use mason package names.
        require("mason-tool-installer").setup({
            ensure_installed = {
                "clang-format", "shfmt", "shellharden", "stylua", "prettierd",
            }
        })

        local navic = require('nvim-navic')

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

                map('n', 'gd', vim.lsp.buf.definition, "Go to Definition")
                map('n', 'gr', "<cmd>Telescope lsp_references<cr>", "Go to References")

                -- Ctrl-click: position the cursor at the click, then jump via LSP
                -- (the built-in <C-LeftMouse> does a tag jump, which does nothing
                -- without a tags file). <LeftMouse> first moves the cursor to the
                -- click position, then we run the LSP definition request.
                map('n', '<C-LeftMouse>', '<LeftMouse>', "Ctrl-click: Go to Definition")
                map('n', '<C-LeftRelease>', function()
                    vim.lsp.buf.definition()
                end, "Ctrl-click: Go to Definition")
                map('n', 'K',  vim.lsp.buf.hover, "Hover Documentation")
                map('n', '<leader>rn', vim.lsp.buf.rename, "Rename Symbol")
                map('n', '<leader>ca', vim.lsp.buf.code_action, "Code Action")

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

        -- Cross toolchain bin dir (Yocto/OE SDK sysroot bin). Project-specific,
        -- so it's read from $CROSS_TOOLCHAIN_BIN; when unset, clangd runs without
        -- a --query-driver (native builds only).
        local clangd_cmd = { "clangd", "--background-index", "--header-insertion=never" }
        local toolchain_bin = vim.env.CROSS_TOOLCHAIN_BIN
        if toolchain_bin then
            table.insert(clangd_cmd, "--query-driver=" .. toolchain_bin .. "/aarch64-poky-linux-g*")
        end

        vim.lsp.config('clangd', { cmd = clangd_cmd })
        vim.lsp.enable('clangd')
        vim.lsp.enable('basedpyright')
        vim.lsp.enable('ruff')
        vim.lsp.enable('buf_ls')
        vim.lsp.config('bashls', {
            cmd = { 'bash-language-server', 'start' },
            filetypes = { 'sh', 'bash' },
            settings = {
                bashIde = {
                    shellcheckPath = 'shellcheck',
                    globPattern = "*@(.sh|.inc|.bash|.command)",
                },
            },
            root_markers = { '.git', 'install.sh', 'requirements.txt' },
        })
        vim.lsp.enable('bashls')
        vim.lsp.enable('omnisharp')

        vim.lsp.config('lua_ls', {
            settings = {
                Lua = {
                    runtime = { version = 'LuaJIT' },
                    diagnostics = { globals = { 'vim' } },
                    workspace = { checkThirdParty = false },
                },
            },
        })
        vim.lsp.enable('lua_ls')
        vim.lsp.enable('neocmake')
        vim.lsp.enable('taplo')
        vim.lsp.enable('yamlls')
        vim.lsp.enable('jsonls')
    end
}
