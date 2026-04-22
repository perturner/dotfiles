return {
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
}
