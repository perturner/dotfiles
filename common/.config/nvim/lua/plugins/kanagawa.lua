-- ~/.config/nvim/lua/plugins/kanagawa.lua
return {
  "rebelot/kanagawa.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require('kanagawa').setup({
      compile = true, -- Improves startup time
      undercurl = true,
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = false },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = false,
      dimInactive = true, -- Great for large monitors to focus on active pane
      terminalColors = true,
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none" -- Keeps the gutter clean for satellite.nvim
            }
          }
        }
      },
      overrides = function(colors)
        return {
          -- Use boolean keys instead of 'style'
          ["@variable.member"] = { fg = colors.theme.syn.identifier, italic = true }, 
          ["@type"] = { fg = colors.theme.syn.type, bold = true },
          ["@constant"] = { fg = colors.theme.syn.constant, bold = true },
          
          -- Cleaner diagnostics
          DiagnosticUnderlineError = { undercurl = true, sp = colors.theme.diag.error },
          DiagnosticUnderlineWarn = { undercurl = true, sp = colors.theme.diag.warning },
        }
      end,
    })
    vim.cmd("colorscheme kanagawa-wave")
  end,
}
