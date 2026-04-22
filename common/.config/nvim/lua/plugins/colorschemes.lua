return {
    {
        "EdenEast/nightfox.nvim",
        lazy = true,
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
        config = function()
            vim.o.termguicolors = true
            vim.cmd.colorscheme('solarized')
        end,
    },
    { "folke/tokyonight.nvim", lazy = true },
    {
        "neanias/everforest-nvim",
        lazy = true,
        config = function()
            require("everforest").setup({
                background = "soft",
                ui_contrast = "low",
            })
            vim.cmd("colorscheme everforest")
        end,
    },
    { "catppuccin/nvim", name = "catppuccin", lazy = true },
}
