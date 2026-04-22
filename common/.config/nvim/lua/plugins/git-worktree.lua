return {
    "polarmutex/git-worktree.nvim",
    version = "^2",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    keys = {
        { "<leader>gw", function() require("telescope").extensions.git_worktree.git_worktree() end, desc = "Switch Worktree" },
        { "<leader>gW", function() require("telescope").extensions.git_worktree.create_git_worktree() end, desc = "Create Worktree" },
    },
    config = function()
        require("telescope").load_extension("git_worktree")
    end,
}
