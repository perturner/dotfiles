-- ~/.config/nvim/init.lua

-- Load Core Settings
require("config.options")

-- Bootstrap Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Initialize Plugins
require("lazy").setup("plugins")

-- Load Keymaps & Autocmds
require("config.keymaps")
require("config.autocmds")

-- Global UI (Winbar / Navic)
_G.get_winbar = function()
    local ok, navic = pcall(require, "nvim-navic")
    if ok and navic.is_available() then
        return " " .. navic.get_location()
    end
    return ""
end
vim.o.winbar = "%{%v:lua.get_winbar()%}"

-- Diagnostic Styling
vim.diagnostic.config({
    virtual_text = { prefix = '●' },
    float = { border = "rounded" },
    severity_sort = true,
})
