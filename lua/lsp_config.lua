local on_attach = function(_, bufnr)
  -- function to help define lsp remaps
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  local builtin = require('telescope.builtin')

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', builtin.lsp_definitions, '[G]o to [d]efinition')
  nmap('gr', builtin.lsp_references, '[G]o to [R]eferences')
  nmap('gI', builtin.lsp_implementations, '[G]o to [I]mplementations')

  nmap('<leader>D', builtin.lsp_type_definitions, 'Type [D]efinitions')
  nmap('<leader>ds', builtin.lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', builtin.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature documentation')

  -- lesser used
  nmap('gD', vim.lsp.buf.declaration, '[G]o to [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist folders')

  -- Create a command :Format local to the lsp buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- document existing key chains
require("which-key").add {
  { '<leader>c', group = '[C]ode' },
  { '<leader>d', group = '[D]ocument' },
  { '<leader>g', group = '[G]it' },
  { '<leader>h', group = 'Git [H]unk' },
  { '<leader>r', group = '[R]ename' },
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
}

-- nvim-cmp additional completion capabilities, broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Shared client config applied to every LSP server, plus per-server settings
vim.lsp.config('*', {
  capabilities = capabilities,
  on_attach = on_attach,
})

for server_name, settings in pairs(servers) do
  vim.lsp.config(server_name, { settings = settings })
end

-- Ensure servers above are installed, then automatically enable
-- (vim.lsp.enable) whatever mason has installed
require("mason-lspconfig").setup {
  ensure_installed = vim.tbl_keys(servers),
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
