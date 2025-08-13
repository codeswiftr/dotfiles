-- =============================================================================
-- Neovim Configuration - Modular Tier-based System
-- =============================================================================

-- Set leader key early
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load core configurations
require("core.options")
require("core.keymaps")
require("core.split-navigation")

-- Initialize tier manager
require("core.tier-manager")

-- Load language-specific configurations
require("languages.swift")
require("languages.web")

-- Load plugins based on current tier
-- The tier manager will handle plugin loading dynamically