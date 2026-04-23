return {
    "lewis6991/gitsigns.nvim",
    opts = {
        signs = { add = { text = '┃' }, change = { text = '┃' } },
        on_attach = function()
            vim.schedule(function() pcall(require("lualine").refresh) end)
        end,
    }
}
