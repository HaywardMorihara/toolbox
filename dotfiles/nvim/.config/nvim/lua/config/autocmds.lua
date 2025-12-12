-- Auto commands - automatically triggered actions
-- These run based on specific events in Neovim

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank (copy)
-- Briefly highlight text when copying it
augroup("highlight_yank", { clear = true })
autocmd("TextYankPost", {
  group = "highlight_yank",
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Auto-format on save (optional - requires conform.nvim)
-- Uncomment if you want to auto-format files on save
-- augroup("auto_format", { clear = true })
-- autocmd("BufWritePre", {
--   group = "auto_format",
--   callback = function()
--     require("conform").format({ async = false })
--   end,
-- })

-- Resize splits when window is resized
augroup("resize_splits", { clear = true })
autocmd("VimResized", {
  group = "resize_splits",
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Open neo-tree by default when opening a file
augroup("neo_tree_startup", { clear = true })
autocmd("VimEnter", {
  group = "neo_tree_startup",
  callback = function(event)
    -- Only open for regular files, not for special buffers
    if vim.fn.argc() == 0 or (vim.fn.argc() == 1 and event.file == "") then
      require("neo-tree.command").execute({ action = "show" })
    end
  end,
})
