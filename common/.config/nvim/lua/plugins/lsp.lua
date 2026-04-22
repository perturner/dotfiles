return {
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

        vim.lsp.config('clangd', {
            cmd = {
                "clangd", "--background-index", "--header-insertion=never",
                "--query-driver=/opt/iudc_toolchain/sysroots/x86_64-pokysdk-linux/usr/bin/aarch64-poky-linux/aarch64-poky-linux-g*",
            }
        })
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
        vim.lsp.enable('omnisharp')
    end
}
