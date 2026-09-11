vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.showmode = false
vim.opt.signcolumn = "yes"

vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.inccommand = "split"

vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.virtualedit = "block"
vim.opt.breakindent = true

vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.hlsearch = false

vim.opt.scrolloff = 999

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.termguicolors = true

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.updatecount = 250
vim.opt.timeoutlen = 300

vim.opt.completeopt = "menuone,noselect"

-- highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', {clear = true})
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
