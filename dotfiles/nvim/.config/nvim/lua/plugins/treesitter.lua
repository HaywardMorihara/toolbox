-- Tree-sitter configuration
-- Provides better syntax highlighting and code parsing

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",  -- Auto-update parsers on install/update
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        -- List of language parsers to install
        ensure_installed = {
          "bash",
          "c",
          "javascript",
          "json",
          "lua",
          "markdown",
          "python",
          "typescript",
          "vim",
          "yaml",
        },
        -- Enable syntax highlighting
        highlight = {
          enable = true,
          -- Disable for very large files
          disable = function(lang, buf)
            local max_filesize = 100 * 1024  -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
        },
        -- Enable indentation detection
        indent = {
          enable = true,
        },
      })
    end,
  },
}
