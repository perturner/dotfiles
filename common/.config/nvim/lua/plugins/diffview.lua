return {
  "sindrets/diffview.nvim",
  -- Keybindings to trigger the plugin
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
    { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview File History" },
  },
  opts = {
    enhanced_diff_hl = true, -- Better for your shape-based scanning
    use_icons = false,       -- Stick to clean text UI
    view = {
      default = {
        layout = "diff2_horizontal",
        winbar_info = true,
      },
    },
  },
}
