-- installs plugin manager - lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", --latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  require("plugins/git_config"),

  require("plugins/theme"),
  require("plugins/misc"),

  require("plugins/treesitter_config"),

  require("plugins/fuzzy"),
  require("plugins/harpoon"),

  require("plugins/formatting"),

  {
    -- LSP Configuration & plugins
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim", config = true },
      "williamboman/mason-lspconfig.nvim",

      -- Status updates for LSP
      { "j-hui/fidget.nvim",       opts = {} },

      { "folke/lazydev.nvim", ft = "lua", opts = {} },
    },
  },
  {
    -- Auto complete
    "hrsh7th/nvim-cmp",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",

      -- Adds LSP completion capabilities
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",

      -- Adds a number of user-friendly snippets
      "rafamadriz/friendly-snippets",
    },
  },
  {
    "github/copilot.vim",
  },
})
