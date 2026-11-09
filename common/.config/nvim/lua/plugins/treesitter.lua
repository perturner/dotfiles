-- nvim-treesitter is on the `main` branch (the rewrite). Its API differs from
-- the old `master` branch: `setup()` no longer takes ensure_installed/highlight/
-- indent, parsers are installed via `install()`, and highlighting must be
-- started per-buffer with `vim.treesitter.start()` (usually a FileType autocmd).
return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local ts = require("nvim-treesitter")
        ts.setup({})

        local parsers = {
            "cpp", "c", "python", "lua", "cmake", "markdown", "markdown_inline",
            "vimdoc", "proto", "bash", "json", "yaml", "toml",
            "c_sharp", "bitbake",
        }

        -- Install any missing parsers (async; no-op for already-installed ones).
        ts.install(parsers)

        -- Enable treesitter highlighting + indentation per buffer. On the main
        -- branch this is not auto-enabled by a config flag — we start it on
        -- FileType for the languages we have parsers for.
        vim.api.nvim_create_autocmd("FileType", {
            callback = function(args)
                local ft = vim.bo[args.buf].filetype
                local lang = vim.treesitter.language.get_lang(ft) or ft
                -- Only start if a parser is actually available for this language.
                if not pcall(vim.treesitter.get_parser, args.buf, lang) then
                    return
                end
                pcall(vim.treesitter.start, args.buf, lang)
                -- Treesitter-based indentation (expr indentexpr).
                vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end,
}
