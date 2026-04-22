return {
    { "nvim-tree/nvim-web-devicons", lazy = false },
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
    { "ThePrimeagen/harpoon", branch = "harpoon2", config = true },
    { "HiPhish/rainbow-delimiters.nvim" },
    { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
    { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
    { "tpope/vim-obsession", cmd = "Obsession" },
    { "karb94/neoscroll.nvim", config = true },
    { "stevearc/dressing.nvim", opts = {} },
    {
        "folke/trouble.nvim",
        opts = {},
        cmd = "Trouble",
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace Diagnostics" },
            { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Document Diagnostics" },
            { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" },
            { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },
        },
    },
    { "Civitasv/cmake-tools.nvim", opts = { cmake_build_directory = "build/${variant:buildType}" } },
}
