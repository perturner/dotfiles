return {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
        { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
        { "<leader>tt", "<cmd>ToggleTerm<cr>", mode = "t", desc = "Toggle Terminal" },
    },
    opts = {
        size = function(term)
            if term.direction == "float" then return nil end
            return 20
        end,
        shade_terminals = true,
        direction = "float",
        float_opts = {
            border = "rounded",
            width = function() return math.floor(vim.o.columns * 0.85) end,
            height = function() return math.floor(vim.o.lines * 0.8) end,
        },
    },
}
