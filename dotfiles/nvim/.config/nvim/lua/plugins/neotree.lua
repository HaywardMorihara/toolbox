-- Neo-tree file explorer
-- Browse and manage files in a tree view

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle File Explorer" },
      { "<leader>o", "<cmd>Neotree reveal<cr>", desc = "Reveal Current File" },
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        window = {
          width = 30,
          mapping_options = {
            noremap = true,
            nowait = true,
          },
        },
        filesystem = {
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = false,
          },
          follow_current_file = {
            enabled = true,
          },
        },
      })
    end,
  },
}
