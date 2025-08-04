-- ============================================================================
-- Neovim Tier 2 Configuration - Enhanced Development
-- +15 plugins for full IDE experience (23 total)
-- Target: Complete development environment, <400ms startup
-- Performance optimized: aggressive lazy loading, minimal startup impact
-- ============================================================================

-- Tier 2 plugins extend Tier 1 with enhanced development features
return {
  -- ============================================================================
  -- GIT INTEGRATION - Essential for development workflow
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
  -- STATUS LINE - Enhanced UI feedback
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
  -- DEBUGGING SUPPORT - DAP integration (lazy loaded)
  -- ============================================================================
  {
    "mfussenegger/nvim-dap",
    cmd = { "DapToggleBreakpoint", "DapContinue", "DapStepOver", "DapStepInto" },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Debug continue" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Debug step over" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Debug step into" },
    },
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "williamboman/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Setup Mason DAP
      require("mason-nvim-dap").setup({
        ensure_installed = { "python", "node2" },
        automatic_installation = true,
      })

      -- Setup DAP UI
      dapui.setup()
      require("nvim-dap-virtual-text").setup()

      -- Auto-open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Key mappings (already defined in keys spec above for lazy loading)
      vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debug REPL" })
      vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Debug UI toggle" })
    end,
  },

  -- ============================================================================
  -- TERMINAL INTEGRATION (lazy loaded)
  -- ============================================================================
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm" },
    keys = {
      { "<c-\>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal float" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal horizontal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<cr>", desc = "Terminal vertical" },
    },
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = "float",
        close_on_exit = true,
        shell = vim.o.shell,
        float_opts = {
          border = "curved",
          winblend = 0,
          highlights = {
            border = "Normal",
            background = "Normal",
          },
        },
      })

      -- Key mappings defined above in keys spec for lazy loading
    end,
  },

  -- ============================================================================
  -- ENHANCED FILE NAVIGATION (lazy loaded)
  -- ============================================================================
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    keys = {
      { "<leader>ha", function() require("harpoon"):list():append() end, desc = "Harpoon add" },
      { "<leader>hh", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Harpoon menu" },
      { "<leader>h1", function() require("harpoon"):list():select(1) end, desc = "Harpoon 1" },
      { "<leader>h2", function() require("harpoon"):list():select(2) end, desc = "Harpoon 2" },
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      -- Keymaps defined above in keys spec for lazy loading
      -- Additional keymaps for h3 and h4
      vim.keymap.set("n", "<leader>h3", function() harpoon:list():select(3) end, { desc = "Harpoon 3" })
      vim.keymap.set("n", "<leader>h4", function() harpoon:list():select(4) end, { desc = "Harpoon 4" })
    end,
  },

  -- ============================================================================
  -- ENHANCED TEXT OBJECTS (lazy loaded)
  -- ============================================================================
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter.configs").setup({
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
            },
          },
        },
      })
    end,
  },

  -- ============================================================================
  -- ENHANCED COMMENTING (replace Tier 1 Comment.nvim with better config)
  -- ============================================================================
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gcc", mode = "n", desc = "Comment toggle current line" },
      { "gc", mode = { "n", "o" }, desc = "Comment toggle linewise" },
      { "gc", mode = "x", desc = "Comment toggle linewise (visual)" },
      { "gbc", mode = "n", desc = "Comment toggle current block" },
      { "gb", mode = { "n", "o" }, desc = "Comment toggle blockwise" },
    },
    config = function()
      require("Comment").setup({
        padding = true,
        sticky = true,
        ignore = nil,
        toggler = {
          line = "gcc",
          block = "gbc",
        },
        opleader = {
          line = "gc",
          block = "gb",
        },
        extra = {
          above = "gcO",
          below = "gco",
          eol = "gcA",
        },
        mappings = {
          basic = true,
          extra = true,
        },
      })
    end,
  },

  -- ============================================================================
  -- ENHANCED SEARCH AND REPLACE (lazy loaded)
  -- ============================================================================
  {
    "nvim-pack/nvim-spectre",
    cmd = { "Spectre" },
    keys = {
      { "<leader>S", function() require("spectre").toggle() end, desc = "Toggle Spectre" },
      { "<leader>sw", function() require("spectre").open_visual({select_word=true}) end, desc = "Search current word" },
      { "<leader>sw", function() require("spectre").open_visual() end, mode = "v", desc = "Search current word" },
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("spectre").setup()
      -- Keymaps defined above in keys spec for lazy loading
    end,
  },

  -- ============================================================================
  -- BUFFER LINE (TAB-LIKE INTERFACE) - lazy loaded
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

  -- ============================================================================
  -- ENHANCED LSP FEATURES (lazy loaded)
  -- ============================================================================
  {
    "glepnir/lspsaga.nvim",
    event = "LspAttach", -- Load when LSP attaches
    config = function()
      require("lspsaga").setup({
        ui = {
          border = "rounded",
          code_action = "",
        },
        lightbulb = {
          enable = false,
        },
      })

      -- Key mappings
      vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<cr>", { desc = "Hover documentation" })
      vim.keymap.set("n", "<leader>cd", "<cmd>Lspsaga show_line_diagnostics<cr>", { desc = "Line diagnostics" })
      vim.keymap.set("n", "<leader>cr", "<cmd>Lspsaga rename<cr>", { desc = "Rename symbol" })
      vim.keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<cr>", { desc = "Previous diagnostic" })
      vim.keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<cr>", { desc = "Next diagnostic" })
    end,
  },

  -- ============================================================================
  -- MARKDOWN PREVIEW (already optimized)
  -- ============================================================================
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    config = function()
      vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Markdown preview" })
    end,
  },

  -- ============================================================================
  -- INDENT GUIDES (lazy loaded)
  -- ============================================================================
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = {
          char = "│",
          tab_char = "│",
        },
        scope = {
          enabled = true,
          show_start = true,
          show_end = false,
        },
        exclude = {
          filetypes = {
            "help",
            "alpha",
            "dashboard",
            "neo-tree",
            "Trouble",
            "lazy",
            "mason",
            "notify",
            "toggleterm",
            "lazyterm",
          },
        },
      })
    end,
  },

  -- ============================================================================
  -- PROJECT MANAGEMENT (lazy loaded)
  -- ============================================================================
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    config = function()
      require("project_nvim").setup({
        detection_methods = { "lsp", "pattern" },
        patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
        ignore_lsp = {},
        exclude_dirs = {},
        show_hidden = false,
        silent_chdir = true,
        scope_chdir = "global",
      })

      -- Telescope integration (loaded lazily)
      vim.defer_fn(function()
        pcall(require("telescope").load_extension, "projects")
        vim.keymap.set("n", "<leader>fp", "<cmd>Telescope projects<cr>", { desc = "Find projects" })
      end, 100)
    end,
  },

  -- ============================================================================
  -- BETTER QUICKFIX
  -- ============================================================================
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    config = function()
      require("bqf").setup({
        auto_enable = true,
        preview = {
          win_height = 12,
          win_vheight = 12,
          delay_syntax = 80,
          border_chars = { "┃", "━", "┏", "┓", "┗", "┛", "┃", "━", "━" },
        },
        func_map = {
          vsplit = "",
          ptogglemode = "z,",
          stoggleup = "",
        },
        filter = {
          fzf = {
            action_for = { ["ctrl-s"] = "split" },
            extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
          },
        },
      })
    end,
  },

  -- ============================================================================
  -- TIER 2 SUCCESS MESSAGE AND PERFORMANCE MONITORING
  -- ============================================================================
  {
    "folke/lazy.nvim",
    config = function()
      -- Only show message on tier 2 startup
      if vim.g.nvim_tier == 2 then
        vim.api.nvim_create_autocmd("VimEnter", {
          callback = function()
            if vim.fn.argc() == 0 then
              vim.defer_fn(function()
                print("🚀 Neovim Tier 2 - Enhanced Development Environment")
                print("📦 23 plugins | ⚡ <400ms startup | 🎯 Full IDE features")
                print("🔍 <leader>ff (files) | 📁 <leader>fp (projects) | 🔍 <leader>S (search/replace)")
                print("🚀 LSP: gd (definition) | K (hover) | <leader>cr (rename)")
                print("🐛 Debug: <leader>db (breakpoint) | <leader>dc (continue)")
                print("🌊 Harpoon: <leader>ha (add) | <leader>hh (menu) | <leader>h[1-4] (jump)")
                print("📈 Upgrade: :TierUp | 📊 Status: :TierInfo | ❓ Help: <leader>")
              end, 50) -- Small delay to avoid startup message clutter
            end
          end,
        })
      end
      
      -- Performance monitoring for Tier 2
      if vim.env.NVIM_PROFILE and vim.g.nvim_tier == 2 then
        local started = vim.loop.hrtime()
        vim.api.nvim_create_autocmd("VimEnter", {
          callback = function()
            vim.defer_fn(function()
              local ms = (vim.loop.hrtime() - started) / 1000000
              local target = 400
              local status = ms <= target and "✅" or "⚠️"
              print(string.format("%s Tier 2 startup: %.1fms (target: %dms)", status, ms, target))
              if ms > target then
                print("💡 Consider using :TierDown for faster startup or optimizing plugin loading")
              end
            end, 100)
          end,
        })
      end
    end,
  },
}