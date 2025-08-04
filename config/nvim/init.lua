-- ============================================================================
-- Neovim Configuration Entry Point - Progressive Tier System
-- Links to streamlined configuration with tier management
-- ============================================================================

-- Load tier manager first
require("core.tier-manager").setup()

-- Load main configuration
require("tiers.tier1")

-- Load enhanced tiers based on current tier setting
local current_tier = require("core.tier-manager").get_current_tier()

if current_tier >= 2 then
  -- Load Tier 2 plugins as additional lazy specs
  local lazy = require("lazy")
  local tier2_specs = require("tiers.tier2")
  
  -- Add Tier 2 plugins to lazy setup
  for _, spec in ipairs(tier2_specs) do
    lazy.register(spec)
  end
end

if current_tier >= 3 then
  -- Load Tier 3 plugins as additional lazy specs
  local lazy = require("lazy")
  local tier3_specs = require("tiers.tier3")
  
  -- Add Tier 3 plugins to lazy setup
  for _, spec in ipairs(tier3_specs) do
    lazy.register(spec)
  end
end

-- Load core configuration modules
require("core.options")
require("core.keymaps")
require("core.split-navigation")

-- Set tier indicator
vim.g.nvim_tier_loaded = current_tier

-- Performance tracking
if vim.env.NVIM_PROFILE then
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      local ms = (vim.loop.hrtime() - (vim.g.start_time or 0)) / 1000000
      local tier_info = require("core.tier-manager").get_current_tier()
      local targets = { [1] = 200, [2] = 400, [3] = 600 }
      local target = targets[tier_info] or 400
      local status = ms <= target and "✅" or "⚠️"
      print(string.format("%s Tier %d startup: %.1fms (target: %dms)", status, tier_info, ms, target))
    end,
  })
end
