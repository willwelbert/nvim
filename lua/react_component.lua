-- Scaffold a React component: <Name>.tsx + <Name>.test.tsx in one go.
local function component_template(name)
  return string.format(
    [[type %sProps = {};

export function %s({}: %sProps) {
  return <div></div>;
}
]],
    name, name, name
  )
end

local function test_template(name)
  return string.format(
    [[import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { %s } from './%s';

describe('%s', () => {
  it('renders', () => {
    render(<%s />);
  });
});
]],
    name, name, name, name
  )
end

local function write_file(path, content)
  local file = io.open(path, 'w')
  if not file then
    error('Could not open ' .. path .. ' for writing')
  end
  file:write(content)
  file:close()
end

local function new_component(input)
  if not input or input == '' then
    return
  end

  local dir = vim.fn.fnamemodify(input, ':h')
  local name = vim.fn.fnamemodify(input, ':t')

  if dir == '.' then
    dir = vim.fn.getcwd()
  end

  if not name:match('^[A-Z][A-Za-z0-9]*$') then
    vim.notify('Component name should be PascalCase, e.g. Button', vim.log.levels.WARN)
    return
  end

  vim.fn.mkdir(dir, 'p')

  local component_path = dir .. '/' .. name .. '.tsx'
  local test_path = dir .. '/' .. name .. '.test.tsx'

  if vim.fn.filereadable(component_path) == 1 or vim.fn.filereadable(test_path) == 1 then
    vim.notify(name .. ' already exists in ' .. dir, vim.log.levels.ERROR)
    return
  end

  write_file(component_path, component_template(name))
  write_file(test_path, test_template(name))

  vim.cmd.edit(component_path)
  vim.notify('Created ' .. name .. '.tsx and ' .. name .. '.test.tsx')
end

vim.api.nvim_create_user_command('NewComponent', function(opts)
  if opts.args and opts.args ~= '' then
    new_component(opts.args)
  else
    vim.ui.input({ prompt = 'New component path (e.g. src/components/Button): ' }, new_component)
  end
end, { nargs = '?', desc = 'Scaffold a React component + test file' })

vim.keymap.set('n', '<leader>nc', function()
  vim.ui.input({ prompt = 'New component path (e.g. src/components/Button): ' }, new_component)
end, { desc = 'New React component' })
