-- lua/config/options.lua

vim.g.mapleader = " "

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.shiftwidth = 4
opt.expandtab = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 10
opt.ignorecase = true
opt.smartcase = true
opt.clipboard = "unnamedplus"
opt.list = true
opt.listchars = {
    tab = '» ',
    trail = '·',
    nbsp = '␣',
    extends = '→',
    precedes = '←',
    multispace = '·',
    leadmultispace = '· ',
}

-- Refined cursor: thin bar in insert, blinking block in normal
opt.guicursor = "n-v-c:block-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100,i-ci-ve:ver25-Cursor/lCursor-blinkwait1000-blinkon100-blinkoff100,r-cr:hor20,o:hor50"

