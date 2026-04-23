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
require("lazy").setup({
  spec = {
    -- This loads lua/plugins/init.lua AND lua/plugins/diffview.lua, etc.
    { import = "plugins" },
  },
})

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
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "✘",
            [vim.diagnostic.severity.WARN]  = "▲",
            [vim.diagnostic.severity.HINT]  = "⚑",
            [vim.diagnostic.severity.INFO]  = "»",
        },
    },
})

local function switch_source_header()
  local bufnr = vim.api.nvim_get_current_buf()
  -- Use the modern 0.11 API
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })

  if #clients == 0 then
    print("clangd not attached to this buffer")
    return
  end

  -- This is the raw LSP call clangd expects
  vim.lsp.buf_request(bufnr, "textDocument/switchSourceHeader", { uri = vim.uri_from_bufnr(bufnr) }, function(err, result)
    if err then
      vim.notify("Clangd Error: " .. err.message, vim.log.levels.ERROR)
      return
    end
    if not result then
      vim.notify("No peer header/source found", vim.log.levels.WARN)
      return
    end
    -- result is a URI string like "file:///path/to/file.cpp"
    vim.api.nvim_command("edit " .. vim.uri_to_fname(result))
  end)
end

-- Bind it to a key
vim.keymap.set("n", "<A-o>", switch_source_header, { desc = "Switch Header/Source" })
