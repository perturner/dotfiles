return {
    "stevearc/conform.nvim",
    opts = {
        formatters_by_ft = {
            cpp = { "clang-format" },
            python = { "ruff_format" },
            proto = { "buf" },
            bash = { "shfmt", "shellharden" },
            sh = { "shfmt", "shellharden" },
            lua = { "stylua" },
            toml = { "taplo" },
            json = { "prettierd" },
            jsonc = { "prettierd" },
            yaml = { "prettierd" },
            markdown = { "prettierd" },
            -- Fallback for any filetype without a dedicated formatter above:
            -- just strip trailing whitespace (covers text, misc config, etc.)
            ["_"] = { "trim_whitespace" },
        },
        format_on_save = { lsp_fallback = true }
    }
}
