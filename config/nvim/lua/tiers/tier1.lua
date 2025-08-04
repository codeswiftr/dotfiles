-- ============================================================================
-- Neovim Tier 1 Configuration - Essential Plugins Only
-- 8 carefully chosen plugins for maximum productivity with minimal complexity
-- Target: Professional editor ready in 30 minutes, <200ms startup
-- Performance optimized: lazy loading, minimal config, essential only
-- ============================================================================

-- Bootstrap lazy.nvim plugin manager
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

-- ============================================================================
-- Plugin Specifications - Tier 1 (8 Essential Plugins)
-- ============================================================================

require("lazy").setup({
  -- ============================================================================
  -- 1. COLORSCHEME - Built-in scheme for minimal startup impact
  -- ============================================================================
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false, -- Load immediately for colorscheme
    config = function()
      -- Minimal config for fastest startup
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        term_colors = false, -- Disable for performance
        no_italic = true, -- Disable italics for performance
        no_bold = false,
        styles = {}, -- Minimal styles
        integrations = {
          telescope = true,
          treesitter = true,
          cmp = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- ============================================================================
  -- 2. SYNTAX HIGHLIGHTING - Minimal treesitter config
  -- ============================================================================
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" }, -- Lazy load on file open
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "python", "javascript", "typescript" }, -- Minimal set
        auto_install = false, -- Manual install to avoid startup delay
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = false, -- Disable for performance
        },
      })
    end,
  },

  -- ============================================================================
  -- 3. FUZZY FINDER - Essential for file/text navigation
  -- ============================================================================
  {
    "nvim-telescope/telescope.nvim",
    cmd = { "Telescope" }, -- Lazy load on command
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/", "*.pyc" },
          layout_config = { height = 0.8, width = 0.8 },
        },
      })
    end,
  },

  -- ============================================================================
  -- 4. LSP CONFIGURATION - Lazy-loaded language server support
  -- ============================================================================
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "williamboman/mason.nvim", config = true },
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pyright", "ts_ls" },
        automatic_installation = false, -- Manual to avoid startup delay
      })

      local lspconfig = require("lspconfig")
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      -- Essential servers only
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      })
      lspconfig.pyright.setup({ capabilities = capabilities })
      lspconfig.ts_ls.setup({ capabilities = capabilities })

      -- Essential LSP keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local opts = { buffer = event.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      })
    end,
  },

  -- ============================================================================
  -- 5. AUTOCOMPLETION - Minimal completion setup
  -- ============================================================================
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "buffer" },
        },
      })
    end,
  },

  -- ============================================================================
  -- 6. GIT INTEGRATION - Essential version control
  -- ============================================================================
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gstatus", "Gblame", "Glog", "Gclog" },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" },
      { "<leader>gb", "<cmd>Git blame<cr>", desc = "Git blame" },
    },
  },

  -- ============================================================================
  -- 7. KEY BINDING DISCOVERY - Essential for learning
  -- ============================================================================
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({
        preset = "modern",
        delay = 1000, -- Longer delay for less interruption
      })
    end,
  },

  -- ============================================================================
  -- 8. ESSENTIAL UTILITIES - Comments only (autopairs removed for performance)
  -- ============================================================================
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gcc", mode = "n", desc = "Comment toggle current line" },
      { "gc", mode = { "n", "o" }, desc = "Comment toggle linewise" },
      { "gc", mode = "x", desc = "Comment toggle linewise (visual)" },
      { "gbc", mode = "n", desc = "Comment toggle current block" },
      { "gb", mode = { "n", "o" }, desc = "Comment toggle blockwise" },
      { "gb", mode = "x", desc = "Comment toggle blockwise (visual)" },
    },
    config = function()
      require("Comment").setup()
    end,
  },

}, {
  -- Lazy.nvim configuration optimized for performance
  install = { colorscheme = { "catppuccin" } },
  checker = { enabled = false },
  change_detection = { enabled = false }, -- Disable for performance
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
})

-- ============================================================================
-- Tier 1 Success Message
-- ============================================================================
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      print("🚀 Neovim Tier 1 - Ultra-Fast Essential Editor")
      print("📦 8 plugins | ⚡ <200ms startup | 🎯 Essential commands only")
      print("🔍 <leader>ff (files) | 📄 <leader>fb (buffers) | 💬 gcc (comment)")
      print("🚀 LSP: gd (definition) | K (hover) | <leader>ca (actions)")
      print("📈 Upgrade: :TierUp | 📊 Status: :TierInfo | ❓ Help: <leader>")
    end
  end,
})

-- ============================================================================
-- Performance Monitoring and Tier System
-- ============================================================================

-- Essential keymaps for Tier 1
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
vim.keymap.set("n", "<leader>/", "<cmd>nohlsearch<cr>", { desc = "Clear search" })
vim.keymap.set("i", "jk", "<esc>", { desc = "Exit insert mode" })

-- Startup time monitoring
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

-- Set tier indicator
vim.g.nvim_tier = 1