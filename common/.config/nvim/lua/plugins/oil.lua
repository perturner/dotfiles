return {
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
}
