return {
    "lewis6991/gitsigns.nvim",
    opts = {
        signs = { add = { text = '┃' }, change = { text = '┃' } },
        on_attach = function(bufnr)
            local gs = require("gitsigns")
            local function map(lhs, rhs, desc)
                vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
            end

            -- Hunk actions: <leader>gh* (h = hunk)
            map("<leader>ghs", gs.stage_hunk, "Stage Hunk")
            map("<leader>ghr", gs.reset_hunk, "Reset Hunk")
            map("<leader>ghp", gs.preview_hunk, "Preview Hunk")
            map("<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
            map("<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")

            -- Buffer-wide
            map("<leader>gR", gs.reset_buffer, "Reset Buffer")
            map("<leader>gB", gs.toggle_current_line_blame, "Toggle Line Blame")

            -- Navigation (bracket motions, not a leader menu)
            map("]h", gs.next_hunk, "Next Hunk")
            map("[h", gs.prev_hunk, "Prev Hunk")

            vim.schedule(function() pcall(require("lualine").refresh) end)
        end,
    }
}
