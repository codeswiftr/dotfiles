-- ============================================================================
-- Neovim Tier 1 Configuration - Essential Plugins Only
-- 12 carefully chosen plugins for maximum productivity with minimal complexity
-- Target: Professional editor ready in 30 minutes, <250ms startup
-- Performance optimized: lazy loading, minimal config, essential only
-- ============================================================================

-- NOTE: lazy.nvim bootstrap and setup are handled centrally in init.lua

-- ============================================================================
-- Plugin Specifications - Tier 1 (12 Essential Plugins)
-- ============================================================================

return {
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
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then
        vim.notify("nvim-treesitter not available. Run :Lazy sync", vim.log.levels.WARN)
        return
      end
      configs.setup({
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
  -- 3. FILE EXPLORER - Essential tree viewer
  -- ============================================================================
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file explorer" },
      { "<leader>t", "<cmd>NvimTreeFindFile<cr>", desc = "Reveal file in tree" },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    opts = {
      disable_netrw = true,
      hijack_netrw = true,
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = { enable = true, update_root = false },
      renderer = {
        highlight_git = true,
        highlight_opened_files = "icon",
        icons = { show = { file = true, folder = true, folder_arrow = true, git = true } },
      },
      view = { width = 32, side = "left" },
      git = { enable = true, ignore = false },
      filters = { dotfiles = false },
    },
    config = function(_, opts)
      require("nvim-tree").setup(opts)

      -- Auto-open nvim-tree when opening a directory
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function(data)
          local directory = vim.fn.isdirectory(data.file) == 1
          if directory then
            vim.cmd.cd(data.file)
            require("nvim-tree.api").tree.open()
          end
        end,
      })
    end,
  },

  -- ============================================================================
  -- 4. FUZZY FINDER - Essential for file/text navigation
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
  -- 5. LSP CONFIGURATION - Lazy-loaded language server support
  -- ============================================================================
  {
    "neovim/nvim-lspconfig",
    version = false, -- Use latest commit (required for Neovim 0.11+ compatibility)
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

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local lspconfig = require("lspconfig")

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
  -- 6. AUTOCOMPLETION - Minimal completion setup
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
  -- 7. GIT INTEGRATION - Essential version control
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
  -- 8. KEY BINDING DISCOVERY - Essential for learning
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
  -- 9. ESSENTIAL UTILITIES - Comments only (autopairs removed for performance)
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

  -- ============================================================================
  -- 10. GIT SIGNS - Essential git integration in the gutter
  -- ============================================================================
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" }, -- Lazy load on file open
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "" },
          topdelete = { text = "" },
          changedelete = { text = "▎" },
          untracked = { text = "▎" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map("n", "]c", function()
            if vim.wo.diff then return "]c" end
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
          end, { expr = true, desc = "Next git hunk" })

          map("n", "[c", function()
            if vim.wo.diff then return "[c" end
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
          end, { expr = true, desc = "Previous git hunk" })

          -- Actions
          map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", { desc = "Stage hunk" })
          map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
          map("n", "<leader>gS", gs.stage_buffer, { desc = "Stage buffer" })
          map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
          map("n", "<leader>gR", gs.reset_buffer, { desc = "Reset buffer" })
          map("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk" })
          map("n", "<leader>gb", function() gs.blame_line{ full = true } end, { desc = "Blame line" })
          map("n", "<leader>gd", gs.diffthis, { desc = "Diff this" })
        end,
      })
    end,
  },

  -- ============================================================================
  -- 11. STATUS LINE - Enhanced UI feedback
  -- ============================================================================
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy", -- Load after startup for performance
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin",
          section_separators = { left = "", right = "" },
          component_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
      })
    end,
  },

  -- ============================================================================
  -- 12. BUFFER LINE (TAB-LIKE INTERFACE) - lazy loaded
  -- ============================================================================
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy", -- Load after startup for performance
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          numbers = "none",
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          left_mouse_command = "buffer %d",
          middle_mouse_command = nil,
          indicator = {
            icon = "▎",
            style = "icon",
          },
          buffer_close_icon = "",
          modified_icon = "●",
          close_icon = "",
          left_trunc_marker = "",
          right_trunc_marker = "",
          max_name_length = 30,
          max_prefix_length = 30,
          tab_size = 21,
          diagnostics = "nvim_lsp",
          diagnostics_update_in_insert = false,
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              text_align = "left",
              separator = true,
            },
          },
          show_buffer_icons = true,
          show_buffer_close_icons = true,
          show_close_icon = true,
          show_tab_indicators = true,
          persist_buffer_sort = true,
          separator_style = "slant",
          enforce_regular_tabs = true,
          always_show_bufferline = true,
        },
      })

      -- Key mappings
      vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { desc = "Toggle pin" })
      vim.keymap.set("n", "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", { desc = "Delete non-pinned buffers" })
      vim.keymap.set("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
      vim.keymap.set("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
    end,
  },

}
