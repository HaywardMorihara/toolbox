-- Neovim editor options and settings
-- These are loaded early in the configuration process

-- Line numbers
vim.opt.number = true           -- Show absolute line numbers
vim.opt.relativenumber = true   -- Show relative line numbers

-- Indentation
vim.opt.expandtab = true        -- Convert tabs to spaces
vim.opt.shiftwidth = 2          -- Number of spaces for indentation
vim.opt.tabstop = 2             -- Width of a tab character
vim.opt.softtabstop = 2         -- Tab width in insert mode

-- Search
vim.opt.ignorecase = true       -- Case-insensitive search
vim.opt.smartcase = true        -- But case-sensitive if pattern contains uppercase

-- Visual
vim.opt.termguicolors = true    -- Enable true color support
vim.opt.mouse = "a"             -- Enable mouse in all modes
vim.opt.signcolumn = "yes"      -- Always show sign column (LSP signs, git signs, etc)

-- Behavior
vim.opt.scrolloff = 8           -- Keep 8 lines visible above/below cursor
vim.opt.sidescrolloff = 8       -- Keep 8 columns visible left/right of cursor
vim.opt.splitbelow = true       -- Open horizontal splits below current window
vim.opt.splitright = true       -- Open vertical splits to the right
vim.opt.undofile = true         -- Persist undo history across sessions

-- Performance
vim.opt.updatetime = 200        -- Faster update time for e.g. git signs

-- Set leader key (for keybindings)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
