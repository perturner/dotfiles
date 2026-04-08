return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- This helps you see the "shape" of your leader commands
    preset = "modern", 
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
