-- Bootstrap lazy.nvim plugin manager
-- This file handles lazy.nvim installation and plugin loading

-- Install lazy.nvim if not already present
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load configuration files first
require("config.options")

-- Setup lazy.nvim with plugins
require("lazy").setup({
  spec = {
    -- Import user plugins from lua/plugins/
    { import = "plugins" },
  },
  defaults = {
    -- All user plugins are loaded at startup (not lazy by default)
    lazy = false,
    -- Always use latest git version
    version = false,
  },
  install = {
    -- Use colorscheme from user plugins
    colorscheme = { "tokyonight" },
  },
  -- Check for plugin updates
  checker = {
    enabled = true,
    notify = false,
  },
  -- Improve performance
  performance = {
    rtp = {
      -- Disable unused default plugins
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- Load keymaps and autocommands after plugins are loaded
require("config.keymaps")
require("config.autocmds")
