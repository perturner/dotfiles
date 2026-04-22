return {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    keys = {
        { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find TODOs" },
        { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "TODOs in Trouble" },
    },
    opts = {},
}
