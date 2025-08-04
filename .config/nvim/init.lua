-- ============================================================================
-- Modern Neovim Configuration - Progressive Tier System
-- Transforms complex 1100+ line config into discoverable, performance-first tiers
-- ============================================================================

-- Set leader keys early (essential for all tiers)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable netrw early for performance
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Disable unnecessary providers for faster startup
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- Python provider (if available)
local python3_path = vim.fn.exepath('python3')
if python3_path ~= '' then
  vim.g.python3_host_prog = python3_path
else
  vim.g.loaded_python3_provider = 0
end

-- Performance tracking (optional)
if vim.env.NVIM_PROFILE then
  vim.g.start_time = vim.loop.hrtime()
end

-- ============================================================================
-- Core Settings (Applied to all tiers)
-- ============================================================================

local opt = vim.opt

-- Performance settings
opt.updatetime = 250
opt.timeoutlen = 300
opt.laststatus = 3  -- Global statusline
opt.cmdheight = 1
opt.showtabline = 0 -- Hide tabline by default

-- General
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.backup = false
opt.swapfile = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("cache") .. "/undo"

-- UI
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true
opt.showmode = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.list = false -- Disable by default for performance

-- Editing
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.smartindent = true
opt.autoindent = true
opt.backspace = "indent,eol,start"

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Clipboard (with fallback)
if vim.fn.has('unnamedplus') == 1 then
  opt.clipboard = "unnamedplus"
else
  opt.clipboard = "unnamed"
end

-- ============================================================================
-- Essential Keymaps (Available in all tiers)
-- ============================================================================

local keymap = vim.keymap.set

-- General essentials
keymap("i", "jk", "<ESC>", { desc = "Exit insert mode" })
keymap("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
keymap("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
keymap("n", "<leader>/", "<cmd>nohlsearch<CR>", { desc = "Clear search highlighting" })

-- Window navigation (essential for all tiers)
keymap("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Essential splits
keymap("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split vertically" })
keymap("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split horizontally" })
keymap("n", "<leader>sc", "<C-w>c", { desc = "Close current window" })

-- Buffer navigation
keymap("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })
keymap("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })

-- ============================================================================
-- Core Configuration - Always Loaded
-- ============================================================================

-- Load essential options (create if doesn't exist)
pcall(require, "core.options")

-- Load essential keymaps (create if doesn't exist) 
pcall(require, "core.keymaps")

-- Load enhanced split navigation (create if doesn't exist)
pcall(require, "core.split-navigation")

-- Initialize tier management system
require("core.tier-manager").setup()

-- ============================================================================
-- Progressive Tier Loading
-- ============================================================================

-- Get current tier from tier manager
local current_tier = require("core.tier-manager").get_current_tier()

-- Load the appropriate tier configuration
local tier_files = {
  [1] = "tiers.tier1",
  [2] = "tiers.tier2", 
  [3] = "tiers.tier3"
}

local tier_file = tier_files[current_tier]
if tier_file then
  local ok, err = pcall(require, tier_file)
  if not ok then
    vim.notify("Failed to load " .. tier_file .. ": " .. err, vim.log.levels.ERROR)
    vim.notify("Falling back to Tier 1", vim.log.levels.WARN)
    require("tiers.tier1")
  end
else
  vim.notify("Invalid tier: " .. current_tier, vim.log.levels.ERROR)
  vim.notify("Loading Tier 1 as fallback", vim.log.levels.WARN)
  require("tiers.tier1")
end

-- ============================================================================
-- Auto Commands & Language-Specific Settings
-- ============================================================================

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})

-- File type specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "lua" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

-- Auto-resize splits when terminal is resized
vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Enhanced language-specific configurations (Tier 2+)
if current_tier >= 2 then
  -- Load advanced web development configuration
  pcall(require, "languages.web")
  
  -- Load Swift/iOS development configuration
  pcall(require, "languages.swift")
end

-- Note: Tier management commands are now handled by core.tier-manager

-- ============================================================================
-- Performance Report (if enabled)
-- ============================================================================
if vim.env.NVIM_PROFILE then
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      local end_time = vim.loop.hrtime()
      local startup_time = (end_time - vim.g.start_time) / 1000000
      
      -- Updated performance targets
      local tier_targets = { [1] = 200, [2] = 400, [3] = 600 }
      local target = tier_targets[current_tier] or 200
      local status = startup_time <= target and "✅" or "⚠️"
      
      print(string.format("%s Tier %d startup: %.1fms (target: <%dms)", 
            status, current_tier, startup_time, target))
      
      if startup_time > target then
        print("💡 Try :TierBench for detailed performance analysis")
      end
    end,
  })
end

-- ============================================================================
-- Welcome Message & Quick Help
-- ============================================================================
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    -- Only show on empty startup
    if vim.fn.argc() == 0 and not vim.g.started_by_firenvim then
      local tier_names = {
        [1] = "Essential",
        [2] = "Enhanced", 
        [3] = "Advanced"
      }
      
      print("🚀 " .. tier_names[current_tier] .. " Neovim Ready! (Tier " .. current_tier .. "/3)")
      
      if current_tier == 1 then
        print("⚡ Ultra-fast startup | 📖 Press <Space> to discover | 🔄 :TierUp to upgrade")
        print("💡 Essential: <leader>ff (files), gcc (comment), gd (definition)")
      elseif current_tier == 2 then
        print("🛠️ Full IDE features | 📖 Press <Space> to discover | 🔄 :TierUp/:TierDown to change")
      else
        print("🤖 AI-powered workflows | 📖 Press <Space> to discover | 🔄 :TierDown to simplify")
      end
      
      print("❓ Run :TierHelp for tier system | 📊 :TierInfo for current status")
    end
  end,
})

-- ============================================================================
-- User Customization Hook
-- ============================================================================

-- Load user-specific configuration if it exists
local user_config = vim.fn.stdpath("config") .. "/lua/user/init.lua"
if vim.loop.fs_stat(user_config) then
  require("user")
end

-- Final tier confirmation
vim.g.nvim_tier_loaded = current_tier

-- ============================================================================
-- Final Configuration
-- ============================================================================

-- Ensure LSP is configured properly for all tiers
vim.diagnostic.config({
  virtual_text = false, -- Disable virtual text for performance
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Set up diagnostic signs
local signs = { Error = "✗", Warn = "⚠", Hint = "💡", Info = "ℹ" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Set completion menu height
vim.opt.pumheight = 10

-- Ensure proper terminal colors
if vim.env.TERM_PROGRAM == "iTerm.app" or vim.env.COLORTERM == "truecolor" then
  vim.opt.termguicolors = true
end