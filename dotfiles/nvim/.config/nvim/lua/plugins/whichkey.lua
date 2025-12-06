return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        icons = {
          breadcrumb = "»",
          separator = "➜",
          group = "+",
        },
        window = {
          border = "rounded",
        },
      })

      -- Register keybinding groups for better documentation
      wk.register({
        ["<leader>f"] = { name = "+find" },
        ["<leader>c"] = { name = "+code" },
        ["<leader>r"] = { name = "+refactor" },
      })
    end,
  },
}
