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
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local harpoon = require("harpoon")
            harpoon:setup()

            local map = vim.keymap.set
            -- Add current file to the list / toggle the quick menu.
            -- Menu is <leader>H (capital) to avoid the <leader>h* git-hunk
            -- namespace used by gitsigns (<leader>hr/<leader>hp).
            map("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon Add File" })
            map("n", "<leader>H", function()
                harpoon.ui:toggle_quick_menu(harpoon:list())
            end, { desc = "Harpoon Menu" })

            -- Jump to pinned files: <leader>1..<leader>0 -> slots 1..10
            local slots = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }
            for i, key in ipairs(slots) do
                map("n", "<leader>" .. key, function()
                    harpoon:list():select(i)
                end, { desc = "Harpoon → slot " .. i })
            end

            -- Cycle through the list without the menu
            map("n", "<leader>[", function() harpoon:list():prev() end, { desc = "Harpoon Prev" })
            map("n", "<leader>]", function() harpoon:list():next() end, { desc = "Harpoon Next" })
        end,
    },
    {
        -- rainbow-delimiters auto-attaches via its own plugin/ file on FileType;
        -- it must load eagerly (not behind a lazy event) so that loader runs.
        -- No setup() call is needed; configure via vim.g.rainbow_delimiters if desired.
        "HiPhish/rainbow-delimiters.nvim",
        lazy = false,
    },
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
