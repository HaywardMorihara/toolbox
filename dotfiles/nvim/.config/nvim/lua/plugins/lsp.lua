-- Language Server Protocol (LSP) configuration
-- Provides code intelligence features like go-to-definition, hover, etc.

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },  -- Load when opening a file
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",  -- LSP completion source
    },
    config = function()
      local lspconfig = require("lspconfig")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      -- Capabilities from completion plugin
      local capabilities = cmp_nvim_lsp.default_capabilities()

      -- Keymaps for when LSP attaches to a buffer
      local on_attach = function(client, bufnr)
        local opts = { noremap = true, silent = true, buffer = bufnr }
        local map = vim.keymap.set

        -- Go to definition
        map("n", "gd", vim.lsp.buf.definition, opts)
        -- Hover documentation
        map("n", "K", vim.lsp.buf.hover, opts)
        -- Go to implementation
        map("n", "gi", vim.lsp.buf.implementation, opts)
        -- Go to references
        map("n", "gr", vim.lsp.buf.references, opts)
        -- Show diagnostics
        map("n", "<leader>e", vim.diagnostic.open_float, opts)
        -- Rename symbol
        map("n", "<leader>rn", vim.lsp.buf.rename, opts)
        -- Code actions
        map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      end

      -- Lua Language Server configuration
      -- Uncomment and configure to use Lua LSP
      -- lspconfig.lua_ls.setup({
      --   on_attach = on_attach,
      --   capabilities = capabilities,
      --   settings = {
      --     Lua = {
      --       diagnostics = {
      --         globals = { "vim" },
      --       },
      --     },
      --   },
      -- })

      -- To add more language servers:
      -- 1. Uncomment the appropriate block below
      -- 2. Install the server: :Mason (interactive UI) or :MasonInstall <server-name>
      -- 3. Restart Neovim

      -- Example: Python
      -- lspconfig.pylsp.setup({
      --   on_attach = on_attach,
      --   capabilities = capabilities,
      -- })

      -- Example: JavaScript/TypeScript
      -- lspconfig.ts_ls.setup({
      --   on_attach = on_attach,
      --   capabilities = capabilities,
      -- })

      -- Example: Go
      -- lspconfig.gopls.setup({
      --   on_attach = on_attach,
      --   capabilities = capabilities,
      -- })

      -- Diagnostics keymaps
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { noremap = true, silent = true })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { noremap = true, silent = true })
    end,
  },
}
