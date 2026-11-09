-- lua/config/autocmds.lua

local autocmd = vim.api.nvim_create_autocmd

-- Trailing-whitespace cleanup is handled by conform.nvim:
-- real formatters (clang-format, stylua, prettierd, ...) strip it themselves,
-- and the "_" fallback runs trim_whitespace for any other filetype.

-- CMake Symlink Sync (Fixes LSP detection)
-- Symlinks the generated compile_commands.json into the project root so clangd
-- finds it. Uses libuv (no shell) to avoid word-splitting on paths with spaces,
-- and resolves the project root rather than relying on the current working dir.
autocmd("User", {
    pattern = "CMakeGenerateSucceeded",
    callback = function()
        local cmake = require("cmake-tools")
        local build_dir = cmake.get_build_directory()
        if not build_dir then return end

        -- Project root: prefer the directory containing CMakeLists.txt, else cwd.
        local root = vim.fs.root(0, "CMakeLists.txt") or vim.uv.cwd()

        -- build_dir may be relative (e.g. "build/Debug"); make the symlink target
        -- absolute so the link is valid regardless of where it's resolved from.
        local abs_build = vim.fs.abspath and vim.fs.abspath(build_dir)
            or (build_dir:match("^/") and build_dir or (root .. "/" .. build_dir))
        local src = abs_build .. "/compile_commands.json"
        local dest = root .. "/compile_commands.json"

        if vim.uv.fs_stat(src) then
            -- Replace any existing link/file at dest, then create the symlink.
            vim.uv.fs_unlink(dest)
            local ok, err = vim.uv.fs_symlink(src, dest)
            if not ok then
                vim.notify("compile_commands symlink failed: " .. tostring(err), vim.log.levels.WARN)
                return
            end
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
