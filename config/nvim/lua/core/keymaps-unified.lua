-- ============================================================================
-- Unified Key Mappings System - Single Source of Truth
-- Consolidates all key bindings with tier-aware loading
-- ============================================================================

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ============================================================================
-- Tier-Aware Key Binding System
-- ============================================================================

local M = {}

-- Get current tier
local function get_tier()
  return vim.g.nvim_tier or 1
end

-- ============================================================================
-- TIER 1: ESSENTIAL KEY BINDINGS (12 plugins, <250ms startup)
-- ============================================================================

M.tier1_keymaps = function()
  -- File Operations (most critical)
  keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
  keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Find text (grep)" })
  keymap("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffer list" })
  keymap("n", "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Search in file" })
  
  -- File explorer (fallback to Telescope if NvimTree not available)
  keymap("n", "<leader>e", function()
    if pcall(require, "nvim-tree") then
      vim.cmd("NvimTreeToggle")
    else
      vim.cmd("Telescope find_files")
    end
  end, { desc = "File explorer" })
  
  -- Essential file operations
  keymap("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
  keymap("n", "<leader>q", "<cmd>confirm q<cr>", { desc = "Quit" })

  -- Window maximizer toggle (RESTORED from legacy .vimrc MaximizerToggle)
  keymap("n", "<leader>m", function()
    -- Simple window zoom/restore using window commands
    if vim.t.maximized then
      vim.cmd("wincmd =")
      vim.t.maximized = false
    else
      vim.cmd("wincmd |")
      vim.cmd("wincmd _")
      vim.t.maximized = true
    end
  end, { desc = "Maximize/restore window" })

  -- Reveal file in tree (RESTORED from legacy .vimrc NERDTreeFind)
  keymap("n", "<leader>t", function()
    if pcall(require, "nvim-tree") then
      vim.cmd("NvimTreeFindFile")
    else
      print("nvim-tree not available")
    end
  end, { desc = "Reveal file in tree" })
  
  -- Navigation (vim muscle memory)
  keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
  keymap("n", "<C-j>", "<C-w>j", { desc = "Go to bottom window" })
  keymap("n", "<C-k>", "<C-w>k", { desc = "Go to top window" })
  keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
  
  -- Code navigation (LSP essentials)
  keymap("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
  keymap("n", "K", vim.lsp.buf.hover, { desc = "Show documentation" })
  keymap("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
  keymap("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true })
  end, { desc = "Format code" })

  -- Git review workflow (TIER 1 - using vim-fugitive)
  keymap("n", "<leader>gd", "<cmd>Git diff<cr>", { desc = "Git diff (review changes)" })
  keymap("n", "<leader>g", "<cmd>Git<cr>", { desc = "Git status (review files)" })
  
  -- Essential utilities
  keymap("n", "<Esc>", "<cmd>nohlsearch<cr>", opts)
  keymap("i", "jk", "<ESC>", opts)
  keymap("i", "jj", "<ESC>", opts)
  
  -- Help and discovery
  keymap("n", "<leader>?", "<cmd>WhichKey<cr>", { desc = "Show all key bindings" })
  keymap("n", "<leader>h", function()
    print("🚀 Neovim Tier 1 - Essential Commands:")
    print("FILES: <leader>ff (find), <leader>e (explorer), <leader>w (save)")
    print("GIT: <leader>g (status), <leader>gd (diff/review changes)")
    print("CODE: gd (definition), K (hover), <leader>ca (actions)")
    print("HELP: <leader>? (all shortcuts) | Ready for more? Enable Tier 2!")
  end, { desc = "Show essential commands" })
  
  -- Emergency commands
  keymap("n", "<leader>Q", "<cmd>qa!<cr>", { desc = "Force quit all" })
  keymap("n", "<leader>W", "<cmd>wa<cr>", { desc = "Save all" })

  -- Config management (RESTORED from legacy .vimrc)
  keymap("n", "<leader>I", "<cmd>Lazy sync<cr>", { desc = "Install/update plugins (Lazy)" })
  keymap("n", "<leader>E", "<cmd>edit $MYVIMRC<cr>", { desc = "Edit config" })
  keymap("n", "<leader>R", "<cmd>source $MYVIMRC<cr>", { desc = "Reload config" })
end

-- ============================================================================
-- TIER 2: FULL DEVELOPMENT KEY BINDINGS (~39 plugins, <600ms startup)
-- ============================================================================

M.tier2_keymaps = function()
  -- Git integration
  keymap("n", "<leader>g", "<cmd>Git<cr>", { desc = "Git status" })
  keymap("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git status (legacy)" })

  -- Git merge conflict resolution (RESTORED from legacy .vimrc)
  keymap("n", "<leader>gh", "<cmd>diffget //3<cr>", { desc = "Get from right (theirs) in merge" })
  keymap("n", "<leader>gu", "<cmd>diffget //2<cr>", { desc = "Get from left (ours) in merge" })

  -- Git workflow commands
  keymap("n", "<leader>ga", "<cmd>Git fetch --all<cr>", { desc = "Git fetch all (legacy)" })
  keymap("n", "<leader>gc", "<cmd>Git commit<cr>", { desc = "Git commit" })
  keymap("n", "<leader>gp", "<cmd>Git push<cr>", { desc = "Git push" })
  keymap("n", "<leader>gl", "<cmd>Git log --oneline<cr>", { desc = "Git log" })
  keymap("n", "<leader>gd", "<cmd>Gitsigns diffthis<cr>", { desc = "Git diff" })

  -- Git branch operations (RESTORED from legacy .vimrc)
  keymap("n", "<leader>gb", function()
    -- Try to use vim-fugitive GBranches if available, otherwise use built-in
    local ok = pcall(vim.cmd, "GBranches")
    if not ok then
      vim.cmd("Git branch -a")
    end
  end, { desc = "Git branches (legacy)" })

  -- Advanced Git Features
  keymap("n", "<leader>gv", "<cmd>DiffviewOpen<cr>", { desc = "Git diffview" })
  keymap("n", "<leader>gV", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" })
  keymap("n", "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", { desc = "Current file history" })

  -- Terminal integration
  keymap("n", "<leader>tt", function()
    if pcall(require, "toggleterm") then
      require("toggleterm").toggle()
    else
      vim.cmd("terminal")
    end
  end, { desc = "Toggle terminal" })
  keymap("n", "<leader>tf", function()
    if pcall(require, "toggleterm") then
      vim.cmd("ToggleTerm direction=float")
    else
      vim.cmd("terminal")
    end
  end, { desc = "Terminal float" })
  keymap("n", "<leader>th", function()
    if pcall(require, "toggleterm") then
      vim.cmd("ToggleTerm direction=horizontal")
    else
      vim.cmd("terminal")
    end
  end, { desc = "Terminal horizontal" })
  keymap("n", "<leader>tv", function()
    if pcall(require, "toggleterm") then
      vim.cmd("ToggleTerm direction=vertical size=80")
    else
      vim.cmd("terminal")
    end
  end, { desc = "Terminal vertical" })

  -- Enhanced code actions
  keymap("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Code rename" })
  keymap("n", "<leader>cd", vim.lsp.buf.hover, { desc = "Code documentation" })
  keymap("n", "gr", "<cmd>Telescope lsp_references<cr>", { desc = "Go to references" })
  keymap("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
  keymap("n", "gt", vim.lsp.buf.type_definition, { desc = "Go to type definition" })

  -- Debugging
  keymap("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "Toggle breakpoint" })
  keymap("n", "<leader>dc", function() require("dap").continue() end, { desc = "Debug continue" })
  keymap("n", "<leader>do", function() require("dap").step_over() end, { desc = "Debug step over" })
  keymap("n", "<leader>di", function() require("dap").step_into() end, { desc = "Debug step into" })
  keymap("n", "<leader>dr", function() require("dap").repl.open() end, { desc = "Debug REPL" })
  keymap("n", "<leader>du", function() require("dapui").toggle() end, { desc = "Debug UI toggle" })

  -- AI Code Completion
  keymap("i", "<C-J>", 'copilot#Accept("\\<CR>")', {
    expr = true,
    replace_keycodes = false,
    desc = "Accept Copilot suggestion"
  })
  keymap("i", "<C-H>", "<Plug>(copilot-dismiss)", { desc = "Dismiss Copilot" })
  keymap("i", "<C-L>", "<Plug>(copilot-next)", { desc = "Next Copilot suggestion" })
  keymap("i", "<C-K>", "<Plug>(copilot-previous)", { desc = "Previous Copilot suggestion" })
  keymap("n", "<leader>ct", "<cmd>Copilot toggle<cr>", { desc = "Toggle Copilot" })

  -- AI Chat Integration
  keymap("n", "<leader>cc", "<cmd>ChatGPT<cr>", { desc = "ChatGPT" })
  keymap("n", "<leader>ce", "<cmd>ChatGPTEditWithInstruction<cr>", { desc = "Edit with instruction" })
  keymap("v", "<leader>ce", "<cmd>ChatGPTEditWithInstruction<cr>", { desc = "Edit with instruction" })
  keymap("n", "<leader>cg", "<cmd>ChatGPTRun grammar_correction<cr>", { desc = "Grammar correction" })
  keymap("n", "<leader>cv", "<cmd>ChatGPTRun code_readability_analysis<cr>", { desc = "Code analysis" })
  keymap("n", "<leader>co", "<cmd>ChatGPTRun optimize_code<cr>", { desc = "Optimize code" })
  keymap("n", "<leader>cs", "<cmd>ChatGPTRun summarize<cr>", { desc = "Summarize" })
  keymap("n", "<leader>cf", "<cmd>ChatGPTRun fix_bugs<cr>", { desc = "Fix bugs" })
  keymap("n", "<leader>cx", "<cmd>ChatGPTRun explain_code<cr>", { desc = "Explain code" })

  -- Advanced Telescope Features
  keymap("n", "<leader>fb", "<cmd>Telescope file_browser<cr>", { desc = "File browser" })

  -- Code Outline
  keymap("n", "<leader>a", "<cmd>AerialToggle!<cr>", { desc = "Aerial (symbols)" })

  -- Sessions
  keymap("n", "<leader>qs", function() require("persistence").load() end, { desc = "Restore session" })
  keymap("n", "<leader>ql", function() require("persistence").load({ last = true }) end, { desc = "Restore last session" })
  keymap("n", "<leader>qd", function() require("persistence").stop() end, { desc = "Don't save current session" })

  -- Troubleshooting
  keymap("n", "<leader>xx", "<cmd>TroubleToggle<cr>", { desc = "Toggle trouble" })
  keymap("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", { desc = "Workspace diagnostics" })
  keymap("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", { desc = "Document diagnostics" })
  keymap("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>", { desc = "Location list" })
  keymap("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", { desc = "Quickfix" })
  keymap("n", "gR", "<cmd>TroubleToggle lsp_references<cr>", { desc = "LSP references" })

  -- REST Client
  keymap("n", "<leader>rr", "<Plug>RestNvim", { desc = "Run REST request" })
  keymap("n", "<leader>rp", "<Plug>RestNvimPreview", { desc = "Preview REST request" })
  keymap("n", "<leader>rl", "<Plug>RestNvimLast", { desc = "Re-run last request" })

  -- Enhanced help
  keymap("n", "<leader>h", function()
    print("Neovim Tier 2 - Full Development Commands:")
    print("GIT: <leader>g (status), <leader>gc (commit), <leader>gv (diffview)")
    print("TERMINAL: <leader>tt (toggle), <leader>tf (float)")
    print("DEBUG: <leader>db (breakpoint), <leader>dc (continue)")
    print("AI: <leader>cc (ChatGPT), <leader>ct (Copilot toggle)")
    print("CODE: gr (references), <leader>a (aerial), <leader>xx (trouble)")
    print("SESSIONS: <leader>qs (restore), <leader>ql (last)")
    print("HELP: <leader>? (all shortcuts)")
  end, { desc = "Show full commands" })
end

-- ============================================================================
-- Split Navigation (Available in all tiers)
-- ============================================================================

M.split_navigation = function()
  -- Navigate between splits using s + hjkl
  keymap("n", "sh", "<C-w>h", { desc = "Go to left split", silent = true })
  keymap("n", "sj", "<C-w>j", { desc = "Go to bottom split", silent = true })
  keymap("n", "sk", "<C-w>k", { desc = "Go to top split", silent = true })
  keymap("n", "sl", "<C-w>l", { desc = "Go to right split", silent = true })
  
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
  
  -- Quick layouts
  keymap("n", "s2v", function()
    vim.cmd("only | vsplit | wincmd =")
  end, { desc = "Two vertical splits", silent = true })
  
  keymap("n", "s2h", function()
    vim.cmd("only | split | wincmd =")
  end, { desc = "Two horizontal splits", silent = true })
  
  -- Development layout
  keymap("n", "sdev", function()
    vim.cmd("only | vsplit | wincmd l | split | terminal | resize 10 | wincmd k | wincmd h | vertical resize 30 | wincmd l")
  end, { desc = "Development layout", silent = true })
  
  -- Help
  keymap("n", "s?", function()
    print("🚀 Split Navigation (s + key):")
    print("NAVIGATION: sh/sj/sk/sl (← ↓ ↑ →)")
    print("CREATE: sv/ss (vertical/horizontal)")
    print("CLOSE: sq/so (current/others)")
    print("SIZE: s=/s+/s- (equalize/grow/shrink)")
    print("LAYOUTS: s2v/s2h/sdev (quick layouts)")
  end, { desc = "Show split navigation help" })
end

-- ============================================================================
-- Modern Text Editing Enhancements (Available in all tiers)
-- ============================================================================

M.modern_editing = function()
  -- Better line navigation for wrapped text
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
  
  -- Center screen after jumping
  keymap("n", "<C-d>", "<C-d>zz", opts)
  keymap("n", "<C-u>", "<C-u>zz", opts)
  keymap("n", "n", "nzzzv", opts)
  keymap("n", "N", "Nzzzv", opts)
  
  -- Command line editing
  keymap("c", "<C-h>", "<Left>", { desc = "Move left" })
  keymap("c", "<C-l>", "<Right>", { desc = "Move right" })
  keymap("c", "<C-a>", "<Home>", { desc = "Move to start" })
  keymap("c", "<C-e>", "<End>", { desc = "Move to end" })
end

-- ============================================================================
-- Main Setup Function
-- ============================================================================

M.setup = function()
  local tier = get_tier()
  
  -- Always load modern editing enhancements
  M.modern_editing()
  
  -- Always load split navigation
  M.split_navigation()
  
  -- Load tier-specific keymaps
  if tier >= 1 then
    M.tier1_keymaps()
  end

  if tier >= 2 then
    M.tier2_keymaps()
  end
  
  -- Show tier-specific startup message
  if tier == 1 then
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        if vim.fn.argc() == 0 then
          print("Neovim Tier 1 - Ultra-Fast Essential Editor")
          print("~12 plugins | <250ms startup | Essentials + UI")
          print("<leader>ff (files) | <leader>fb (buffers) | gcc (comment)")
          print("LSP: gd (def) | K (hover) | <leader>ca (actions)")
          print("Use <leader>h for help | :TierUp for full IDE + AI features!")
        end
      end,
    })
  elseif tier == 2 then
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        if vim.fn.argc() == 0 then
          print("Neovim Tier 2 - Full Development Environment")
          print("~39 plugins | <600ms startup | Complete IDE + AI")
          print("Git: <leader>g (status) | Debug: <leader>db (breakpoint)")
          print("AI: <leader>cc (ChatGPT) | Copilot: Ctrl+J (accept)")
          print("Use <leader>h for help | Full AI-powered development!")
        end
      end,
    })
  end
end

return M
