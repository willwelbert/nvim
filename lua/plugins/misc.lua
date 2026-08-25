return {
  {
    -- Status bar
    'nvim-lualine/lualine.nvim',
    opts = {
      theme = 'kanagawa',
      component_separators = "|",
      section_separators = "",
    },
  },
  {
    -- Show pending keybinds
    'folke/which-key.nvim', opts = {},
  },
}
