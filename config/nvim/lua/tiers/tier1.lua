-- ============================================================================
-- Neovim Tier 1 Configuration - Essential Plugins Only
-- 8 carefully chosen plugins for maximum productivity with minimal complexity
-- Target: Professional editor ready in 30 minutes, <500ms startup
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
  -- 1. COLORSCHEME - Modern, comfortable theme
  -- ============================================================================
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- mocha, macchiato, frappe, latte
        background = {
          light = "latte",
          dark = "mocha",
        },
        transparent_background = false,
        term_colors = true,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
        },
        integrations = {
          cmp = true,
          telescope = true,
          treesitter = true,
          nvimtree = true,
          which_key = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- ============================================================================
  -- 2. SYNTAX HIGHLIGHTING - Modern, fast syntax highlighting
  -- ============================================================================
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "python", "javascript", "typescript", "html", "css",
          "json", "yaml", "toml", "markdown", "bash", "vim", "vimdoc"
        },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },

  -- ============================================================================
  -- 3. FUZZY FINDER - Essential for file/text navigation
  -- ============================================================================
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<C-h>"] = "which_key",
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
            },
          },
          file_ignore_patterns = {
            "node_modules",
            ".git/",
            "*.pyc",
            "__pycache__",
          },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
        },
      })
    end,
  },

  -- ============================================================================
  -- 4. LSP CONFIGURATION - Language server support
  -- ============================================================================
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- Setup Mason for automatic LSP installation
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",      -- Lua
          "pyright",     -- Python
          "tsserver",    -- TypeScript/JavaScript
        },
        automatic_installation = true,
      })

      -- LSP settings
      local lspconfig = require("lspconfig")
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      -- Configure each language server
      local servers = { "lua_ls", "pyright", "tsserver" }
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup({
          capabilities = capabilities,
        })
      end

      -- LSP keymaps (already defined in core/keymaps.lua)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local opts = { buffer = event.buf }
          -- Additional LSP-specific keymaps can be added here
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        end,
      })
    end,
  },

  -- ============================================================================
  -- 5. AUTOCOMPLETION - Essential for productivity
  -- ============================================================================
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- ============================================================================
  -- 6. FILE EXPLORER - Visual file navigation
  -- ============================================================================
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        view = {
          width = 30,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
        },
        git = {
          enable = true,
          ignore = false,
        },
      })
    end,
  },

  -- ============================================================================
  -- 7. KEY BINDING DISCOVERY - Essential for learning
  -- ============================================================================
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        delay = 500,
        preset = "modern",
      })
      
      -- Define key groups for better organization
      wk.add({
        { "<leader>f", group = "File/Find" },
        { "<leader>c", group = "Code" },
        { "<leader>g", group = "Git" },
        { "<leader>w", desc = "Save file" },
        { "<leader>q", desc = "Quit" },
        { "<leader>e", desc = "File explorer" },
        { "<leader>b", desc = "Buffers" },
        { "<leader>/", desc = "Search in file" },
        { "<leader>?", desc = "All key bindings" },
        { "<leader>h", desc = "Help" },
      })
    end,
  },

  -- ============================================================================
  -- 8. ESSENTIAL UTILITIES - Auto-pairs and comments
  -- ============================================================================
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true,
        disable_filetype = { "TelescopePrompt", "vim" },
      })
      
      -- Integration with nvim-cmp
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

}, {
  -- Lazy.nvim configuration
  install = {
    colorscheme = { "catppuccin" },
  },
  checker = {
    enabled = false, -- Don't check for updates automatically
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- ============================================================================
-- Tier 1 Success Message
-- ============================================================================
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Show welcome message only once
    if vim.fn.argc() == 0 then
      print("🚀 Neovim Tier 1 Loaded - Essential Editor Ready!")
      print("📚 Press <Space>? to see all 15 key bindings")
      print("🎯 Press <Space>h for quick command reference")
      print("⚡ Ready for more? Enable Tier 2 in init.lua")
    end
  end,
})

-- ============================================================================
-- Performance Monitoring (Optional)
-- ============================================================================
if vim.env.NVIM_PROFILE then
  local started = vim.loop.hrtime()
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      local ms = (vim.loop.hrtime() - started) / 1000000
      print(string.format("🚀 Neovim startup time: %.2fms", ms))
    end,
  })
end