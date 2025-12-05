-- Custom keybindings
-- These are defined separately from plugins for easy management

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Better window navigation
map("n", "<C-h>", "<C-w>h", opts)  -- Navigate to left window
map("n", "<C-j>", "<C-w>j", opts)  -- Navigate to bottom window
map("n", "<C-k>", "<C-w>k", opts)  -- Navigate to top window
map("n", "<C-l>", "<C-w>l", opts)  -- Navigate to right window

-- Better indentation
map("v", "<", "<gv", opts)          -- Maintain selection when indenting left
map("v", ">", ">gv", opts)          -- Maintain selection when indenting right

-- Move lines
map("n", "<A-j>", ":m .+1<CR>==", opts)    -- Move line down
map("n", "<A-k>", ":m .-2<CR>==", opts)    -- Move line up
map("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)  -- Move selection down
map("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)  -- Move selection up

-- Clear search highlight
map("n", "<Esc>", ":nohlsearch<CR>", opts)

-- Better escape in terminal
map("t", "<Esc>", "<C-\\><C-n>", opts)

-- Note: Telescope and Neo-tree keybindings are defined in their plugin specs
-- See lua/plugins/telescope.lua and lua/plugins/neotree.lua
-- Key features:
--   <leader>e   - Toggle file explorer (Neo-tree)
--   <leader>ff  - Find files (Telescope)
--   <leader>fg  - Search text in files (Telescope)
--   <leader>fb  - Search open buffers (Telescope)
