-- Theme configuration
-- Provides the color scheme and appearance settings

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,           -- Load immediately
    priority = 1000,        -- Load before other plugins
    config = function()
      -- Set the colorscheme
      vim.cmd([[colorscheme tokyonight-night]])
    end,
  },
}
