-- ============================================================================
-- Vim Keymaps Migration Plan
-- Gradual migration from current to optimized keybindings
-- ============================================================================

-- MIGRATION STRATEGY: Progressive rollout to avoid breaking muscle memory

local M = {}

-- ============================================================================
-- Migration Phases
-- ============================================================================

M.migration_phases = {
  -- Phase 1: Add modern shortcuts alongside existing ones (no conflicts)
  phase1_additions = {
    { "n", "<C-p>", "<cmd>Telescope find_files<cr>", { desc = "Find files (modern)" } },
    { "n", "<C-s>", "<cmd>w<cr>", { desc = "Save file (OS-native)" } },
    { "n", "<C-f>", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Find in file" } },
    { "n", "<C-g>", "<cmd>Telescope live_grep<cr>", { desc = "Find in project" } },
  },
  
  -- Phase 2: Optimize existing leader bindings (gradual replacement)
  phase2_optimizations = {
    -- Enhanced git workflow (additive, no conflicts)
    { "n", "<leader>ga", "<cmd>Gitsigns stage_hunk<cr>", { desc = "Git add hunk" } },
    { "n", "<leader>gc", "<cmd>Git commit<cr>", { desc = "Git commit" } },
    { "n", "<leader>gp", "<cmd>Git push<cr>", { desc = "Git push" } },
    { "n", "<leader>gl", "<cmd>Git log --oneline<cr>", { desc = "Git log" } },
    { "n", "<leader>gb", "<cmd>Gitsigns blame_line<cr>", { desc = "Git blame" } },
    
    -- Enhanced code actions (prefix consistency)
    { "n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, { desc = "Code format" } },
    { "n", "<leader>cr", "vim.lsp.buf.rename", { desc = "Code rename" } },
    { "n", "<leader>cd", "vim.lsp.buf.hover", { desc = "Code documentation" } },
  },
  
  -- Phase 3: Context-aware enhancements (new functionality)
  phase3_enhancements = {
    { "n", "<leader>r", function()
        local filetype = vim.bo.filetype
        if filetype == "python" then vim.cmd("!python %")
        elseif filetype == "javascript" or filetype == "typescript" then vim.cmd("!node %")
        elseif filetype == "rust" then vim.cmd("!cargo run")
        elseif filetype == "go" then vim.cmd("!go run %")
        else vim.cmd("make") end
      end, { desc = "Run/compile (context-aware)" }
    },
  }
}

-- ============================================================================
-- Migration Functions
-- ============================================================================

-- Apply migration phase
M.apply_phase = function(phase_name)
  local phase = M.migration_phases[phase_name]
  if not phase then
    print("Unknown migration phase: " .. phase_name)
    return
  end
  
  for _, binding in ipairs(phase) do
    vim.keymap.set(binding[1], binding[2], binding[3], binding[4])
  end
  
  print("Applied keymaps migration phase: " .. phase_name)
end

-- Get current migration status
M.get_migration_status = function()
  return {
    current_phase = vim.g.keymap_migration_phase or "none",
    available_phases = vim.tbl_keys(M.migration_phases),
    recommendation = "Start with phase1_additions for immediate modern shortcuts"
  }
end

-- Set migration phase in environment
M.set_migration_phase = function(phase)
  vim.g.keymap_migration_phase = phase
  M.apply_phase(phase)
end

-- ============================================================================
-- Integration with Existing System
-- ============================================================================

-- Check if we should use optimized keymaps
M.should_use_optimized = function()
  -- Check environment variable
  if vim.env.NVIM_USE_OPTIMIZED_KEYMAPS == "1" then
    return true
  end
  
  -- Check if user has explicitly enabled optimization
  if vim.g.dotfiles_keymaps_optimized == true then
    return true
  end
  
  -- Default: use existing keymaps with gradual migration
  return false
end

-- Load appropriate keymap set
M.load_keymaps = function()
  if M.should_use_optimized() then
    -- Load fully optimized keymaps
    require("core.keymaps-optimized")
    print("🚀 Loaded optimized keymaps - modern & efficient!")
  else
    -- Load existing keymaps with optional migration phase
    require("core.keymaps")
    
    local migration_phase = vim.env.NVIM_KEYMAPS_MIGRATION_PHASE
    if migration_phase and M.migration_phases[migration_phase] then
      M.apply_phase(migration_phase)
      print("🔄 Applied keymaps migration: " .. migration_phase)
    end
  end
end

return M