local lsp_shared = require('lsp_shared')

-- document existing key chains
require("which-key").add {
  { '<leader>c', group = '[C]ode' },
  { '<leader>d', group = '[D]ocument' },
  { '<leader>g', group = '[G]it' },
  { '<leader>h', group = 'Git [H]unk' },
  { '<leader>r', group = '[R]ename / [R]ust' },
  { '<leader>s', group = '[S]earch' },
  { '<leader>t', group = '[T]oggle' },
  { '<leader>w', group = '[W]orkspace' },
}

-- register which-key VISUAL mode
-- required for visual <leader>hs (hunk stage) to work

require("which-key").add {
  { '<leader>', group = 'VISUAL <leader>', mode = 'v' },
  { '<leader>h', group = 'Git [H]unk', mode = 'v' },
}

-- mason-lspconfig requires these setup functions in this order
-- before setting up the servers
require("mason").setup()

-- Enable language servers
local servers = {
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      diagnostics = { disable = { 'missing-fields' } },
    },
  },
  gopls = {},
  svelte = {},
}

-- Shared client config applied to every LSP server, plus per-server settings
vim.lsp.config('*', {
  capabilities = lsp_shared.capabilities(),
  on_attach = lsp_shared.on_attach,
})

for server_name, settings in pairs(servers) do
  vim.lsp.config(server_name, { settings = settings })
end

-- Ensure servers above are installed, then automatically enable
-- (vim.lsp.enable) whatever mason has installed.
-- rust_analyzer is excluded: rustaceanvim (see plugins/rust.lua) owns its
-- entire lifecycle, so it must never also be started here.
require("mason-lspconfig").setup {
  ensure_installed = vim.tbl_keys(servers),
  automatic_enable = { exclude = { "rust_analyzer" } },
}

-- [[ Configure nvim-cmp ]]
local cmp = require "cmp"
local luasnip = require "luasnip"
require("luasnip.loaders.from_vscode").lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  },
}

-- vim: ts=2 sts=2 sw=2 et
