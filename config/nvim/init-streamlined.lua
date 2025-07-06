-- ============================================================================
-- Streamlined Neovim Configuration - Progressive Enhancement System
-- From overwhelming complexity to discoverable simplicity
-- ============================================================================

-- Performance tracking (optional)
if vim.env.NVIM_PROFILE then
  vim.g.start_time = vim.loop.hrtime()
end

-- ============================================================================
-- User Configuration - Choose Your Experience Level
-- ============================================================================

-- Set your tier level (1, 2, or 3)
-- Tier 1: Essential editor (8 plugins, 15 keybindings, <500ms startup)
-- Tier 2: Enhanced development (23 plugins, 35 keybindings, <800ms startup)  
-- Tier 3: AI-powered workflows (33 plugins, 55 keybindings, <1200ms startup)
vim.g.nvim_tier = vim.g.nvim_tier or 1

-- ============================================================================
-- Core Configuration - Always Loaded
-- ============================================================================

-- Load essential options
require("core.options")

-- Load essential keymaps
require("core.keymaps")

-- ============================================================================
-- Progressive Tier Loading
-- ============================================================================

-- Always load Tier 1 (essential plugins)
require("tiers.tier1")

-- Load Tier 2 if enabled (enhanced development)
if vim.g.nvim_tier >= 2 then
  require("tiers.tier2")
end

-- Load Tier 3 if enabled (AI and advanced features)
if vim.g.nvim_tier >= 3 then
  require("tiers.tier3")
end

-- ============================================================================
-- Auto Commands & Language-Specific Settings
-- ============================================================================

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", {}),
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})

-- Language-specific settings
local language_configs = {
  python = { tabstop = 4, shiftwidth = 4, expandtab = true },
  javascript = { tabstop = 2, shiftwidth = 2, expandtab = true },
  typescript = { tabstop = 2, shiftwidth = 2, expandtab = true },
  lua = { tabstop = 2, shiftwidth = 2, expandtab = true },
  html = { tabstop = 2, shiftwidth = 2, expandtab = true },
  css = { tabstop = 2, shiftwidth = 2, expandtab = true },
  json = { tabstop = 2, shiftwidth = 2, expandtab = true },
  yaml = { tabstop = 2, shiftwidth = 2, expandtab = true },
}

for filetype, config in pairs(language_configs) do
  vim.api.nvim_create_autocmd("FileType", {
    pattern = filetype,
    callback = function()
      for option, value in pairs(config) do
        vim.opt_local[option] = value
      end
    end,
  })
end

-- ============================================================================
-- Quick Tier Management Commands
-- ============================================================================

-- Command to upgrade to next tier
vim.api.nvim_create_user_command("TierUp", function()
  if vim.g.nvim_tier < 3 then
    vim.g.nvim_tier = vim.g.nvim_tier + 1
    print("🚀 Upgraded to Tier " .. vim.g.nvim_tier .. "! Restart Neovim to load new features.")
    print("💡 Edit init.lua and update vim.g.nvim_tier = " .. vim.g.nvim_tier .. " to persist.")
  else
    print("🎯 Already at maximum tier (3)!")
  end
end, { desc = "Upgrade to next tier" })

-- Command to downgrade to previous tier
vim.api.nvim_create_user_command("TierDown", function()
  if vim.g.nvim_tier > 1 then
    vim.g.nvim_tier = vim.g.nvim_tier - 1
    print("⬇️  Downgraded to Tier " .. vim.g.nvim_tier .. ". Restart Neovim to apply changes.")
    print("💡 Edit init.lua and update vim.g.nvim_tier = " .. vim.g.nvim_tier .. " to persist.")
  else
    print("📦 Already at minimum tier (1)!")
  end
end, { desc = "Downgrade to previous tier" })

-- Command to show current tier status
vim.api.nvim_create_user_command("TierStatus", function()
  print("📊 Current Neovim Configuration:")
  print("   Tier Level: " .. vim.g.nvim_tier .. "/3")
  
  local tier_descriptions = {
    [1] = "Essential Editor (8 plugins, 15 keybindings)",
    [2] = "Enhanced Development (23 plugins, 35 keybindings)",
    [3] = "AI-Powered Workflows (33 plugins, 55 keybindings)"
  }
  
  print("   Description: " .. tier_descriptions[vim.g.nvim_tier])
  print("   Commands: :TierUp, :TierDown, :TierHelp")
end, { desc = "Show tier status" })

-- Command to show tier help
vim.api.nvim_create_user_command("TierHelp", function()
  print("🎓 Neovim Progressive Configuration Help")
  print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  print("")
  print("TIER 1 - Essential Editor:")
  print("  • 8 essential plugins for core editing")
  print("  • 15 key bindings (30-minute learning curve)")
  print("  • <500ms startup time")
  print("  • Perfect for beginners and focused development")
  print("")
  print("TIER 2 - Enhanced Development:")
  print("  • +15 plugins for git, debugging, status line")
  print("  • +20 additional key bindings")
  print("  • <800ms startup time")
  print("  • Full IDE experience")
  print("")
  print("TIER 3 - AI-Powered Workflows:")
  print("  • +10 plugins for AI integration and advanced tools")
  print("  • +20 power-user key bindings")
  print("  • <1200ms startup time")
  print("  • Cutting-edge development environment")
  print("")
  print("COMMANDS:")
  print("  :TierUp     - Upgrade to next tier")
  print("  :TierDown   - Downgrade to previous tier")
  print("  :TierStatus - Show current tier info")
  print("")
  print("To persist tier changes, edit init.lua:")
  print("  vim.g.nvim_tier = " .. vim.g.nvim_tier)
end, { desc = "Show tier help" })

-- ============================================================================
-- Performance Report (if enabled)
-- ============================================================================
if vim.env.NVIM_PROFILE then
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      local end_time = vim.loop.hrtime()
      local startup_time = (end_time - vim.g.start_time) / 1000000
      print(string.format("⚡ Startup time: %.1fms (Tier %d)", startup_time, vim.g.nvim_tier))
      
      -- Performance expectations
      local expected_times = { [1] = 500, [2] = 800, [3] = 1200 }
      local expected = expected_times[vim.g.nvim_tier]
      
      if startup_time <= expected then
        print("✅ Performance target met!")
      else
        print("⚠️  Startup slower than expected (" .. expected .. "ms target)")
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
        [3] = "AI-Powered"
      }
      
      print("🚀 " .. tier_names[vim.g.nvim_tier] .. " Neovim Ready! (Tier " .. vim.g.nvim_tier .. "/3)")
      print("📚 Press <Space>? to see available commands")
      print("🆙 Try :TierUp to unlock more features")
      print("❓ Run :TierHelp for configuration options")
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