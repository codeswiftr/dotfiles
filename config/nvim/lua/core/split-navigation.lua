-- ============================================================================
-- Enhanced Split Navigation - s + hjkl for seamless split management
-- Optimized for fast split navigation without conflicts
-- ============================================================================

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ============================================================================
-- Split Navigation with 's' prefix (s + h,j,k,l)
-- ============================================================================

-- Navigate between splits using s + hjkl
keymap("n", "sh", "<C-w>h", { desc = "Go to left split", silent = true })
keymap("n", "sj", "<C-w>j", { desc = "Go to bottom split", silent = true })
keymap("n", "sk", "<C-w>k", { desc = "Go to top split", silent = true })
keymap("n", "sl", "<C-w>l", { desc = "Go to right split", silent = true })

-- ============================================================================
-- Advanced Split Management (s + other keys)
-- ============================================================================

-- Create splits
keymap("n", "sv", "<C-w>v", { desc = "Split vertically", silent = true })
keymap("n", "ss", "<C-w>s", { desc = "Split horizontally", silent = true })

-- Close splits
keymap("n", "sq", "<C-w>q", { desc = "Close current split", silent = true })
keymap("n", "so", "<C-w>o", { desc = "Close other splits", silent = true })

-- Resize splits
keymap("n", "s=", "<C-w>=", { desc = "Equalize splits", silent = true })
keymap("n", "s+", "<C-w>+", { desc = "Increase height", silent = true })
keymap("n", "s-", "<C-w>-", { desc = "Decrease height", silent = true })
keymap("n", "s>", "<C-w>>", { desc = "Increase width", silent = true })
keymap("n", "s<", "<C-w><", { desc = "Decrease width", silent = true })

-- Move splits
keymap("n", "sH", "<C-w>H", { desc = "Move split to far left", silent = true })
keymap("n", "sJ", "<C-w>J", { desc = "Move split to bottom", silent = true })
keymap("n", "sK", "<C-w>K", { desc = "Move split to top", silent = true })
keymap("n", "sL", "<C-w>L", { desc = "Move split to far right", silent = true })

-- Rotate splits
keymap("n", "sr", "<C-w>r", { desc = "Rotate splits downward", silent = true })
keymap("n", "sR", "<C-w>R", { desc = "Rotate splits upward", silent = true })

-- Exchange splits
keymap("n", "sx", "<C-w>x", { desc = "Exchange with next split", silent = true })

-- ============================================================================
-- Smart Split Sizing (s + number keys)
-- ============================================================================

-- Quick resize to specific ratios
keymap("n", "s1", "<cmd>vertical resize 20<cr>", { desc = "Narrow split", silent = true })
keymap("n", "s2", "<cmd>vertical resize 40<cr>", { desc = "Medium split", silent = true })
keymap("n", "s3", "<cmd>vertical resize 60<cr>", { desc = "Wide split", silent = true })
keymap("n", "s4", "<cmd>vertical resize 80<cr>", { desc = "Very wide split", silent = true })
keymap("n", "s0", "<cmd>vertical resize 100<cr>", { desc = "Full width split", silent = true })

-- ============================================================================
-- Terminal Integration (s + t)
-- ============================================================================

-- Open terminal in splits
keymap("n", "st", "<cmd>split | terminal<cr>", { desc = "Terminal in horizontal split", silent = true })
keymap("n", "sT", "<cmd>vsplit | terminal<cr>", { desc = "Terminal in vertical split", silent = true })

-- ============================================================================
-- Buffer Management in Splits (s + b)
-- ============================================================================

-- Open buffer in new split
keymap("n", "sb", "<cmd>split | Telescope buffers<cr>", { desc = "Open buffer in horizontal split", silent = true })
keymap("n", "sB", "<cmd>vsplit | Telescope buffers<cr>", { desc = "Open buffer in vertical split", silent = true })

-- ============================================================================
-- File Operations in Splits (s + f)
-- ============================================================================

-- Open file in new split
keymap("n", "sf", "<cmd>split | Telescope find_files<cr>", { desc = "Open file in horizontal split", silent = true })
keymap("n", "sF", "<cmd>vsplit | Telescope find_files<cr>", { desc = "Open file in vertical split", silent = true })

-- ============================================================================
-- Quick Split Layouts (s + layout keys)
-- ============================================================================

-- Predefined useful layouts
keymap("n", "s2v", function()
  vim.cmd("only")          -- Close all other splits
  vim.cmd("vsplit")        -- Create vertical split
  vim.cmd("wincmd =")      -- Equalize
end, { desc = "Two vertical splits", silent = true })

keymap("n", "s2h", function()
  vim.cmd("only")          -- Close all other splits  
  vim.cmd("split")         -- Create horizontal split
  vim.cmd("wincmd =")      -- Equalize
end, { desc = "Two horizontal splits", silent = true })

keymap("n", "s3v", function()
  vim.cmd("only")          -- Close all other splits
  vim.cmd("vsplit")        -- First vertical split
  vim.cmd("vsplit")        -- Second vertical split
  vim.cmd("wincmd =")      -- Equalize all
end, { desc = "Three vertical splits", silent = true })

-- Development layout: main + terminal + sidebar
keymap("n", "sdev", function()
  vim.cmd("only")                    -- Start clean
  vim.cmd("vsplit")                  -- Create sidebar
  vim.cmd("wincmd l")                -- Move to main area
  vim.cmd("split")                   -- Create terminal area
  vim.cmd("terminal")                -- Open terminal
  vim.cmd("resize 10")               -- Make terminal smaller
  vim.cmd("wincmd k")                -- Back to main editing area
  vim.cmd("wincmd h")                -- Go to sidebar
  vim.cmd("vertical resize 30")       -- Size sidebar
  vim.cmd("wincmd l")                -- Back to main
end, { desc = "Development layout (main + terminal + sidebar)", silent = true })

-- ============================================================================
-- Split Information and Help
-- ============================================================================

-- Show split information
keymap("n", "si", function()
  local wins = vim.api.nvim_list_wins()
  local current_win = vim.api.nvim_get_current_win()
  
  print("🔧 Split Information:")
  print("   Total splits: " .. #wins)
  print("   Current split: " .. current_win)
  print("   Window dimensions: " .. vim.o.columns .. "x" .. vim.o.lines)
  
  for i, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_name = vim.api.nvim_buf_get_name(buf)
    local is_current = win == current_win and " (current)" or ""
    print("   Split " .. i .. ": " .. (buf_name ~= "" and vim.fn.fnamemodify(buf_name, ":t") or "[No Name]") .. is_current)
  end
end, { desc = "Show split information", silent = true })

-- Show split navigation help
keymap("n", "s?", function()
  print("🚀 Enhanced Split Navigation (s + key):")
  print("")
  print("NAVIGATION:")
  print("  sh/sj/sk/sl     Navigate splits (← ↓ ↑ →)")
  print("  sv/ss           Create vertical/horizontal split") 
  print("  sq/so           Close current/Close others")
  print("")
  print("SIZING:")
  print("  s=/s+/s-        Equalize/Grow/Shrink height")
  print("  s>/s<           Grow/Shrink width")
  print("  s1/s2/s3/s4/s0  Quick width presets")
  print("")
  print("ADVANCED:")
  print("  sH/sJ/sK/sL     Move split to edge")
  print("  sr/sR/sx        Rotate/Exchange splits")
  print("  st/sT           Terminal in split")
  print("  sf/sF/sb/sB     File/Buffer in split")
  print("")
  print("LAYOUTS:")
  print("  s2v/s2h/s3v     Quick 2/3 split layouts")
  print("  sdev            Development layout")
  print("  si              Split information")
  print("")
  print("💡 Also available: <C-h/j/k/l> for navigation")
end, { desc = "Show split navigation help", silent = true })

-- ============================================================================
-- Integration with Existing Keymaps
-- ============================================================================

-- Ensure compatibility with existing <C-h/j/k/l> navigation
-- The existing Ctrl+hjkl mappings are preserved and work alongside s+hjkl
-- This gives users two ways to navigate: 
-- - <C-hjkl> for quick navigation (existing)
-- - s+hjkl for when Ctrl keys conflict with terminal or other tools

-- ============================================================================
-- Auto-commands for Split Behavior
-- ============================================================================

-- Auto-equalize splits when Neovim is resized
vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("SplitResize", { clear = true }),
  callback = function()
    vim.cmd("wincmd =")
  end,
})

-- Auto-focus new splits
vim.api.nvim_create_autocmd("WinNew", {
  group = vim.api.nvim_create_augroup("SplitFocus", { clear = true }),
  callback = function()
    vim.schedule(function()
      vim.cmd("wincmd p")  -- Go back to previous window, then to new one
      vim.cmd("wincmd w")  -- This ensures proper focus
    end)
  end,
})

-- ============================================================================
-- Performance Notes
-- ============================================================================

--[[
SPLIT NAVIGATION PERFORMANCE NOTES:

1. 's' key remapping:
   - Overrides default 's' (substitute character)
   - 's' is rarely used compared to 'c' (change)
   - If you need substitute, use 'cl' instead

2. Integration:
   - Works alongside existing <C-h/j/k/l> mappings
   - Provides alternative when Ctrl keys are needed elsewhere
   - No conflicts with existing functionality

3. Discoverability:
   - 's?' shows complete help
   - WhichKey integration shows all 's' mappings
   - Consistent naming pattern for easy memory

4. Efficiency:
   - All mappings are silent to avoid command line noise
   - Uses direct window commands for speed
   - Auto-equalization on resize for better UX
--]]

return {
  -- Return module for potential future extensions
  navigate = {
    left = function() vim.cmd("wincmd h") end,
    down = function() vim.cmd("wincmd j") end,
    up = function() vim.cmd("wincmd k") end,
    right = function() vim.cmd("wincmd l") end,
  },
  layouts = {
    two_vertical = function()
      vim.cmd("only | vsplit | wincmd =")
    end,
    development = function()
      vim.cmd("only | vsplit | wincmd l | split | terminal | resize 10 | wincmd k | wincmd h | vertical resize 30 | wincmd l")
    end,
  },
}