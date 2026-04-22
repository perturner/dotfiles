-- lua/config/autocmds.lua

local autocmd = vim.api.nvim_create_autocmd

-- Auto-cleanup whitespace on save
autocmd("BufWritePre", { pattern = "*", command = [[%s/\s\+$//e]] })

-- CMake Symlink Sync (Fixes LSP detection)
autocmd("User", {
    pattern = "CMakeGenerateSucceeded",
    callback = function()
        local build_dir = require("cmake-tools").get_build_directory()
        if build_dir then
            os.execute("ln -sf " .. build_dir .. "/compile_commands.json .")
            vim.cmd("LspRestart clangd")
        end
    end,
})

-- Auto-Save Logic (Safe mode)
autocmd({ "BufLeave", "FocusLost", "InsertLeave" }, {
    callback = function()
        if vim.bo.modified and vim.bo.buftype == "" then
            vim.cmd("silent! update")
        end
        -- Keep session file fresh if Obsession is tracking
        if vim.g.this_obsession then
            vim.cmd("silent! Obsession " .. vim.g.this_obsession)
        end
    end,
})

-- Auto-session management
autocmd("VimEnter", {
    callback = function()
        if vim.fn.argc() == 0 then
            if vim.fn.filereadable("Session.vim") == 1 then
                vim.cmd("source Session.vim")
                -- Re-trigger filetype detection after session restore + plugin load
                vim.defer_fn(function()
                    vim.cmd("doautoall BufRead")
                end, 100)
            else
                vim.cmd("Obsession")
            end
        end
    end,
})
