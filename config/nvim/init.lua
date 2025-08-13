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
local tier_manager = require("core.tier-manager")
tier_manager.setup()

-- Load language-specific configurations
require("languages.swift")
require("languages.web")

-- Load plugins based on current tier (single lazy.setup)
local function bootstrap_lazy()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
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
end

local function compose_specs_for_tier(tier)
  -- Base (Tier 1) essential specs
  local tier1_specs = require("tiers.tier1")
  local specs = {}
  for _, s in ipairs(tier1_specs) do table.insert(specs, s) end

  if tier >= 2 then
    local tier2_specs = require("tiers.tier2")
    for _, s in ipairs(tier2_specs) do table.insert(specs, s) end
  end
  if tier >= 3 then
    local tier3_specs = require("tiers.tier3")
    for _, s in ipairs(tier3_specs) do table.insert(specs, s) end
  end

  return specs
end

local current_tier = tier_manager.get_current_tier()
bootstrap_lazy()

require("lazy").setup(
  compose_specs_for_tier(current_tier),
  {
    install = { colorscheme = { "catppuccin" } },
    checker = { enabled = false },
    change_detection = { enabled = false },
    performance = {
      cache = { enabled = true },
      reset_packpath = true,
      rtp = {
        reset = true,
        disabled_plugins = {
          "gzip", "matchit", "matchparen", "netrwPlugin", "tarPlugin",
          "tohtml", "tutor", "zipPlugin", "rplugin", "synmenu", "optwin",
          "compiler", "bugreport", "ftplugin",
        },
      },
    },
  }
)

-- Tier 1 success message and optional profiling
if current_tier == 1 then
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      if vim.fn.argc() == 0 then
        print("🚀 Neovim Tier 1 - Ultra-Fast Essential Editor")
        print("📦 ~8 plugins | ⚡ <200ms startup | 🎯 Essentials only")
        print("🔍 <leader>ff (files) | 📄 <leader>fb (buffers) | 💬 gcc (comment)")
        print("🚀 LSP: gd (def) | K (hover) | <leader>ca (actions)")
      end
    end,
  })

  if vim.env.NVIM_PROFILE then
    local started = vim.loop.hrtime()
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        local ms = (vim.loop.hrtime() - started) / 1000000
        local target = 200
        local status = ms <= target and "✅" or "⚠️"
        print(string.format("%s Tier 1 startup: %.1fms (target: %dms)", status, ms, target))
      end,
    })
  end
end