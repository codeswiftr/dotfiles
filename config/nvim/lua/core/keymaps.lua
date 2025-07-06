-- ============================================================================
-- Essential Key Mappings - Tier 1
-- Only the 15 most critical shortcuts every developer needs
-- ============================================================================

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ============================================================================
-- File Operations (5 commands) - Most Used Daily
-- ============================================================================

-- Find files (most important command)
keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })

-- Find text in files (second most important)
keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Find text (grep)" })

-- File explorer toggle
keymap("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "File explorer" })

-- Save file (essential)
keymap("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })

-- Quit (with protection)
keymap("n", "<leader>q", "<cmd>confirm q<cr>", { desc = "Quit" })

-- ============================================================================
-- Navigation (5 commands) - Essential Movement
-- ============================================================================

-- Window navigation (vim-like, works everywhere)
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to bottom window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to top window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Buffer list (essential for file switching)
keymap("n", "<leader>b", "<cmd>Telescope buffers<cr>", { desc = "Buffer list" })

-- Search in current file
keymap("n", "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Search in file" })

-- ============================================================================
-- Code Actions (5 commands) - Development Essentials
-- ============================================================================

-- Go to definition (most important code navigation)
keymap("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })

-- Go to references (second most important)
keymap("n", "gr", "<cmd>Telescope lsp_references<cr>", { desc = "Go to references" })

-- Code actions (essential for LSP)
keymap("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })

-- Format code (essential)
keymap("n", "<leader>f", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format code" })

-- Show all available key bindings (discovery!)
keymap("n", "<leader>?", "<cmd>WhichKey<cr>", { desc = "Show all key bindings" })

-- ============================================================================
-- Quick Access Commands (Essential but less frequent)
-- ============================================================================

-- Clear search highlighting
keymap("n", "<Esc>", "<cmd>nohlsearch<cr>", opts)

-- Better up/down for wrapped lines
keymap({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
keymap({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Stay in visual mode when indenting
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down in visual mode
keymap("v", "J", ":m '>+1<CR>gv=gv", opts)
keymap("v", "K", ":m '<-2<CR>gv=gv", opts)

-- Better paste (don't lose clipboard content)
keymap("v", "p", '"_dP', opts)

-- ============================================================================
-- Insert Mode Essentials
-- ============================================================================

-- Exit insert mode quickly
keymap("i", "jk", "<ESC>", opts)
keymap("i", "jj", "<ESC>", opts)

-- ============================================================================
-- Command Mode Helpers
-- ============================================================================

-- Better command line editing
keymap("c", "<C-h>", "<Left>", { desc = "Move left" })
keymap("c", "<C-l>", "<Right>", { desc = "Move right" })
keymap("c", "<C-a>", "<Home>", { desc = "Move to start" })
keymap("c", "<C-e>", "<End>", { desc = "Move to end" })

-- ============================================================================
-- Emergency Commands (Always Available)
-- ============================================================================

-- Force quit all
keymap("n", "<leader>Q", "<cmd>qa!<cr>", { desc = "Force quit all" })

-- Save all buffers
keymap("n", "<leader>W", "<cmd>wa<cr>", { desc = "Save all" })

-- Reload Neovim configuration
keymap("n", "<leader>R", "<cmd>source $MYVIMRC<cr>", { desc = "Reload config" })

-- ============================================================================
-- Quick Help (Always Visible)
-- ============================================================================

-- Show startup help
keymap("n", "<leader>h", function()
  print("🚀 Essential Neovim Commands (Tier 1):")
  print("FILES: <leader>ff (find), <leader>e (explorer), <leader>w (save)")
  print("NAVIGATION: <C-h/j/k/l> (windows), <leader>b (buffers)")
  print("CODE: gd (definition), gr (references), <leader>ca (actions)")
  print("HELP: <leader>? (all shortcuts) | Ready for more? Enable Tier 2!")
end, { desc = "Show essential commands" })

-- ============================================================================
-- Note About Key Binding Philosophy
-- ============================================================================
--[[
TIER 1 KEY BINDING PRINCIPLES:

1. MUSCLE MEMORY: Use familiar patterns (C-h/j/k/l, gd, gr)
2. FREQUENCY: Most used commands get the shortest shortcuts
3. DISCOVERY: <leader>? shows all available commands
4. SAFETY: Confirm destructive actions (quit, etc.)
5. CONSISTENCY: Similar actions use similar patterns

NEXT TIER PREVIEW:
- Enable Tier 2 for git integration, debugging, and advanced navigation
- Enable Tier 3 for AI features and power-user workflows

Total shortcuts in Tier 1: 15 essential commands
Learning time: ~30 minutes to muscle memory
--]]