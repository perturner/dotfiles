return {
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
            view = "cmdline",
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
}
