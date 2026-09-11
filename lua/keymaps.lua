-- Basic keymaps
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostics keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostics messsage' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostics message' })
local diag_float_winid = nil
local function toggle_diagnostic_float()
  if diag_float_winid and vim.api.nvim_win_is_valid(diag_float_winid) then
    vim.api.nvim_win_close(diag_float_winid, true)
    diag_float_winid = nil
    return
  end
  local _, winid = vim.diagnostic.open_float()
  diag_float_winid = winid
end
vim.keymap.set('n', '<leader>e', toggle_diagnostic_float, { desc = 'Toggle floating diagnostics message' })

local function toggle_loclist()
  local winid = vim.fn.getloclist(0, { winid = 0 }).winid
  if winid ~= 0 then
    vim.cmd.lclose()
  else
    vim.diagnostic.setloclist()
  end
end
vim.keymap.set('n', '<leader>q', toggle_loclist, { desc = 'Toggle diagnostics list' })

-- Jump to entry and close the location list in one keystroke
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'qf',
  callback = function(args)
    local is_loclist = vim.fn.getwininfo(vim.fn.win_getid())[1].loclist == 1
    if not is_loclist then
      return
    end
    vim.keymap.set('n', '<CR>', function()
      local line = vim.fn.line('.')
      vim.cmd(line .. 'll')
      vim.cmd.lclose()
    end, { buffer = args.buf, desc = 'Jump to diagnostic and close list' })
  end,
})

-- Move selected text
vim.keymap.set('n', '<s-j>', ':m .+1<CR>==')
vim.keymap.set('n', '<s-k>', ':m .-2<CR>==')
vim.keymap.set('v', '<s-j>', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', '<s-k>', ":m '<-2<CR>gv=gv")
