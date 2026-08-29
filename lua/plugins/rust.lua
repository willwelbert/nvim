-- rustaceanvim discards vim.g.rustaceanvim.server.on_attach in favor of the
-- global vim.lsp.config('*', {on_attach = ...}) from lsp_config.lua, so
-- rust-analyzer-specific extra keymaps are registered here instead, on the
-- generic LspAttach event, filtered to just the rust-analyzer client.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= "rust-analyzer" then
      return
    end

    local bufnr = args.buf
    local nmap = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "Rust: " .. desc })
    end

    nmap("<leader>rr", function()
      vim.cmd.RustLsp("runnables")
    end, "[R]unnables")
    nmap("<leader>rd", function()
      vim.cmd.RustLsp("debuggables")
    end, "[D]ebuggables")
    nmap("<leader>rt", function()
      vim.cmd.RustLsp("testables")
    end, "[T]estables")
  end,
})

return {
  {
    "mrcjkb/rustaceanvim",
    -- v9+ requires Neovim >= 0.12; this machine is on 0.11.1, so pin to
    -- the last major that supports Neovim >= 0.11
    version = "^8",
    lazy = false,
    ft = { "rust" },
    dependencies = { "mfussenegger/nvim-dap" },
    -- rustaceanvim reads vim.g.rustaceanvim once, at its own plugin-load
    -- time (module-level in config/internal.lua) — it must be set via
    -- `init`, which lazy.nvim runs *before* loading the plugin. Setting it
    -- in `config` (which runs *after* load) is too late and gets ignored.
    init = function()
      -- the value itself is a function so it's only evaluated once a .rs
      -- buffer opens, after every other startup plugin (cmp-nvim-lsp,
      -- telescope, nvim-dap, ...) has already loaded
      vim.g.rustaceanvim = function()
        local lsp_shared = require("lsp_shared")

        return {
          server = {
            -- NOTE: rustaceanvim merges the global vim.lsp.config('*', ...)
            -- on_attach/capabilities (set in lsp_config.lua) into this
            -- table, taking precedence over what's set here — so
            -- rust-specific *additional* on_attach behavior (below) is
            -- wired up separately via an LspAttach autocmd instead of
            -- nesting it here, where it would silently never run.
            capabilities = lsp_shared.capabilities(),
            default_settings = {
              ["rust-analyzer"] = {
                -- run clippy (instead of `cargo check`) as rust-analyzer's
                -- own diagnostics source
                check = { command = "clippy" },
              },
            },
          },
        }
      end
    end,
  },
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    config = function()
      require("crates").setup()

      local function setup_cmp_source()
        require("cmp").setup.buffer({
          sources = {
            { name = "crates" },
            { name = "nvim_lsp" },
            { name = "path" },
          },
        })
      end

      setup_cmp_source()

      vim.api.nvim_create_autocmd("BufRead", {
        pattern = "Cargo.toml",
        callback = setup_cmp_source,
      })
    end,
  },
}
