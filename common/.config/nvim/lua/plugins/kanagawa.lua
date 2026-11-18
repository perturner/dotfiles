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

          -- Rainbow delimiter levels (see rainbow-delimiters spec in editor.lua).
          -- Deliberately no red/pink so the outermost scope never looks like an error.
          RainbowLvl1 = { fg = colors.theme.syn.fun },        -- blue
          RainbowLvl2 = { fg = colors.theme.syn.identifier }, -- yellow
          RainbowLvl3 = { fg = colors.theme.syn.string },     -- green
          RainbowLvl4 = { fg = colors.theme.syn.keyword },    -- violet
          RainbowLvl5 = { fg = colors.theme.syn.type },       -- aqua
          RainbowLvl6 = { fg = colors.theme.syn.constant },   -- orange
        }
      end,
    })
    vim.cmd("colorscheme kanagawa-wave")
  end,
}
