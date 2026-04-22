return {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
        { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
        { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
        { "<leader><leader>", "<cmd>Telescope buffers<cr>", desc = "Switch Buffers" },
        { "<C-e>", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
    },
    opts = {
        pickers = {
            find_files = {
                hidden = true,
            },
        },
    }
}
