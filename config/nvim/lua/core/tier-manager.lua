-- ============================================================================
-- Neovim Tier Management System
-- Dynamic tier switching with performance monitoring
-- ============================================================================

local M = {}

-- Auto-detect tier based on environment or system resources
local function auto_detect_tier()
  -- 1) Explicit override via env
  local env_tier = tonumber(vim.env.NVIM_TIER or "")
  if env_tier and env_tier >= 1 and env_tier <= 3 then
    return env_tier
  end

  -- 2) Agent mode prefers minimal footprint unless overridden
  if (vim.env.DOTFILES_MODE or "") == "agent" then
    return 1
  end

  -- 3) Heuristic based on CPU cores and total memory
  local cores = 1
  local ok_cpu, cpu_info = pcall(vim.uv.cpu_info)
  if ok_cpu and type(cpu_info) == "table" then
    cores = #cpu_info
  end

  local total_mem_bytes = 0
  local ok_mem, total_mem = pcall(vim.uv.get_total_memory)
  if ok_mem and type(total_mem) == "number" then
    total_mem_bytes = total_mem
  end

  local total_mem_gb = total_mem_bytes > 0 and (total_mem_bytes / (1024 * 1024 * 1024)) or 0

  -- Conservative defaults
  if cores <= 2 or total_mem_gb > 0 and total_mem_gb < 4 then
    return 1
  elseif cores >= 4 and total_mem_gb >= 8 then
    return 2
  else
    return 2
  end
end

-- Tier definitions
local TIERS = {
  [1] = {
    name = "Essential",
    description = "8 plugins, core editing functionality",
    target_startup = 200,
    plugins = 8,
    keybindings = 15,
    features = { "LSP", "Completion", "Fuzzy Find", "Git", "Comments", "Syntax Highlighting" }
  },
  [2] = {
    name = "Enhanced",
    description = "23 plugins, full development environment",
    target_startup = 400,
    plugins = 23,
    keybindings = 35,
    features = { "All Tier 1", "File Explorer", "Status Line", "Git Signs", "Formatting", "Auto-pairs", "Terminal" }
  },
  [3] = {
    name = "Advanced",
    description = "37+ plugins, AI-powered workflows",
    target_startup = 600,
    plugins = 37,
    keybindings = 55,
    features = { "All Tier 2", "GitHub Copilot", "AI Assistants", "Advanced Git", "Debugging", "Complex Workflows" }
  }
}

-- Get current tier from global variable or auto-detection
function M.get_current_tier()
  return vim.g.nvim_tier or auto_detect_tier()
end

-- Set tier and reload configuration
function M.set_tier(tier)
  if not TIERS[tier] then
    vim.notify("Invalid tier: " .. tier, vim.log.levels.ERROR)
    return false
  end

  -- Create tier preference file
  local tier_file = vim.fn.stdpath("config") .. "/.nvim-tier"
  local file = io.open(tier_file, "w")
  if file then
    file:write(tostring(tier))
    file:close()
  end

  vim.g.nvim_tier = tier
  vim.notify("Tier set to " .. tier .. " (" .. TIERS[tier].name .. ")", vim.log.levels.INFO)
  vim.notify("Restart Neovim to apply changes", vim.log.levels.WARN)
  return true
end

-- Load tier preference from file, else use auto-detection
function M.load_tier_preference()
  local tier_file = vim.fn.stdpath("config") .. "/.nvim-tier"
  local file = io.open(tier_file, "r")
  if file then
    local content = file:read("*a"):gsub("%s+", "")
    file:close()
    if content and content ~= "" then
      local tier = tonumber(content)
      if tier and TIERS[tier] then
        vim.g.nvim_tier = tier
        return tier
      end
    end
  end
  local detected = auto_detect_tier()
  vim.g.nvim_tier = detected
  return detected
end

-- Tier up command
function M.tier_up()
  local current = M.get_current_tier()
  if current >= 3 then
    vim.notify("Already at maximum tier (3)", vim.log.levels.WARN)
    return
  end
  M.set_tier(current + 1)
end

-- Tier down command
function M.tier_down()
  local current = M.get_current_tier()
  if current <= 1 then
    vim.notify("Already at minimum tier (1)", vim.log.levels.WARN)
    return
  end
  M.set_tier(current - 1)
end

-- Show tier information
function M.show_tier_info()
  local current = M.get_current_tier()
  local tier_info = TIERS[current]
  
  print("╭──────────────────────────────────────╮")
  print("│       Neovim Tier System Status     │")
  print("├──────────────────────────────────────┤")
  print(string.format("│ Current Tier: %d (%s)%s│", current, tier_info.name, string.rep(" ", 15 - #tier_info.name)))
  print(string.format("│ Plugins: %d%s│", tier_info.plugins, string.rep(" ", 28 - #tostring(tier_info.plugins))))
  print(string.format("│ Keybindings: %d%s│", tier_info.keybindings, string.rep(" ", 23 - #tostring(tier_info.keybindings))))
  print(string.format("│ Target Startup: <%dms%s│", tier_info.target_startup, string.rep(" ", 17 - #tostring(tier_info.target_startup))))
  print("│                                      │")
  print("│ Features:                            │")
  for _, feature in ipairs(tier_info.features) do
    print(string.format("│ • %s%s│", feature, string.rep(" ", 33 - #feature)))
  end
  print("│                                      │")
  print("│ Commands:                            │")
  print("│ :TierUp    - Upgrade to next tier   │")
  print("│ :TierDown  - Downgrade to prev tier │")
  print("│ :TierSet N - Set specific tier      │")
  print("│ :TierHelp  - Show detailed help     │")
  print("╰──────────────────────────────────────╯")
end

-- Show comprehensive tier help
function M.show_tier_help()
  print("╭───────────────────────────────────────────────────────────────╮")
  print("│                    Neovim Progressive Tier System             │")
  print("├───────────────────────────────────────────────────────────────┤")
  print("│                                                               │")
  
  for tier_num, tier_data in pairs(TIERS) do
    local marker = tier_num == M.get_current_tier() and "► " or "  "
    print(string.format("│ %sTIER %d: %s%s│", marker, tier_num, tier_data.name, string.rep(" ", 40 - #tier_data.name)))
    print(string.format("│   Description: %s%s│", tier_data.description, string.rep(" ", 35 - #tier_data.description)))  
    print(string.format("│   Plugins: %d | Keybindings: %d | Startup: <%dms%s│", 
          tier_data.plugins, tier_data.keybindings, tier_data.target_startup,
          string.rep(" ", 13 - #tostring(tier_data.target_startup))))
    print("│                                                               │")
  end
  
  print("│ PHILOSOPHY:                                                   │")
  print("│ • Start simple, grow complexity as needed                    │")
  print("│ • Visual discovery system (which-key)                       │")
  print("│ • Performance-first approach                                 │")
  print("│ • No overwhelming complexity                                 │")
  print("│                                                               │")
  print("│ WORKFLOW:                                                     │")
  print("│ 1. Master Tier 1 (essential editing)                        │")
  print("│ 2. Upgrade to Tier 2 when ready for IDE features           │")
  print("│ 3. Add Tier 3 for AI and advanced workflows                 │")
  print("│                                                               │")
  print("│ COMMANDS:                                                     │")
  print("│ :TierUp      - Upgrade to next tier                         │")
  print("│ :TierDown    - Downgrade to previous tier                   │")
  print("│ :TierSet N   - Jump to specific tier (1-3)                  │")
  print("│ :TierInfo    - Show current tier status                     │")
  print("│ :TierBench   - Benchmark startup performance                │")
  print("│                                                               │")
  print("╰───────────────────────────────────────────────────────────────╯")
end

-- Benchmark startup performance
function M.benchmark_startup()
  print("🚀 Benchmarking Neovim startup performance...")
  print("This will restart Neovim multiple times to measure startup time.")
  
  local cmd = [[
    total=0
    count=5
    for i in $(seq 1 $count); do
      time_ms=$(nvim --headless --startuptime /tmp/nvim-startup.log -c 'qa' 2>&1 | grep -o '[0-9.]*ms' | tail -1 | sed 's/ms//')
      total=$(echo "$total + $time_ms" | bc -l 2>/dev/null || echo "$total")
    done
    avg=$(echo "scale=1; $total / $count" | bc -l 2>/dev/null || echo "0")
    echo "Average startup time: ${avg}ms"
  ]]
  
  vim.fn.system(cmd)
end

-- Set up tier management commands
function M.setup_commands()
  vim.api.nvim_create_user_command("TierUp", M.tier_up, { desc = "Upgrade to next tier" })
  vim.api.nvim_create_user_command("TierDown", M.tier_down, { desc = "Downgrade to previous tier" })
  vim.api.nvim_create_user_command("TierInfo", M.show_tier_info, { desc = "Show tier information" })
  vim.api.nvim_create_user_command("TierHelp", M.show_tier_help, { desc = "Show tier system help" })
  vim.api.nvim_create_user_command("TierBench", M.benchmark_startup, { desc = "Benchmark startup performance" })
  
  vim.api.nvim_create_user_command("TierSet", function(args)
    local tier = tonumber(args.args)
    if tier then
      M.set_tier(tier)
    else
      vim.notify("Usage: :TierSet <1-3>", vim.log.levels.ERROR)
    end
  end, { 
    nargs = 1, 
    desc = "Set specific tier",
    complete = function() return {"1", "2", "3"} end
  })
end

-- Initialize tier system
function M.setup()
  M.load_tier_preference()
  M.setup_commands()
end

return M