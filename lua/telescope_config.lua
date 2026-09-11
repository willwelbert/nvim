-- Configure Telescope
require('telescope').setup {
  defaults = {
    file_ignore_patterns = { 'node_modules', '%.git/' },
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    }
  }
}

-- Enable Telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')


-- Telescope live_grep in git root
-- Find git root based on current buffer's path
local function find_git_root()
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- if buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- extract dir from current file's path
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

-- Find git root dir from current file's path
local git_root = vim.fn.systemlist('git -C' ..vim.fn.escape(current_dir, ' ') .. 'rev-parse --show-toplevel')[1]
if vim.v.shell_error ~= 0 then
  print 'Not a git repository. Searching on current working directory'
  return cwd
end
return git_root

end

-- Custom live-grep function to search in git root

local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep {
      search_dirs = { git_root },
    }
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- built in keymaps
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  --change theme on local fuzzy find
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

local function telescope_live_grep_open_files()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live grep in Open files',
  }
end

-- search keymaps
local builtin = require('telescope.builtin');

vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] Open files' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elected telescope' })
vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = 'Search in [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sa', function()
  builtin.find_files { hidden = true, no_ignore = true }
end, { desc = '[S]earch [A]ll files (incl. hidden/gitignored)' })
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep in Git root' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
