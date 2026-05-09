-- ============================================================================
-- Neovim Tier 2 Configuration - Full Development Environment
-- ~27 plugins for complete IDE experience with AI-powered workflows
-- Target: Full development environment, <600ms startup
-- Performance optimized: aggressive lazy loading, minimal startup impact
-- ============================================================================

-- Tier 2 plugins extend Tier 1 with enhanced development, AI, and advanced features
return {
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
    keys = {
      { "<c-\\>", function() require("toggleterm").toggle() end, desc = "Toggle terminal" },
      { "<leader>tf", function() vim.cmd("ToggleTerm direction=float") end, desc = "Terminal float" },
      { "<leader>th", function() vim.cmd("ToggleTerm direction=horizontal") end, desc = "Terminal horizontal" },
      { "<leader>tv", function() vim.cmd("ToggleTerm direction=vertical size=80") end, desc = "Terminal vertical" },
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
  -- Uses nvim-treesitter-textobjects v1.x API (no longer goes through
  -- nvim-treesitter.configs — that module was removed in TS v1).
  -- ============================================================================
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      local ok, tso = pcall(require, "nvim-treesitter-textobjects")
      if not ok then return end
      tso.setup({
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
  -- AI CODE COMPLETION - GitHub Copilot
  -- ============================================================================
  {
    "github/copilot.vim",
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      vim.g.copilot_tab_fallback = ""

      -- Key mappings
      vim.keymap.set("i", "<C-J>", 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
        desc = "Accept Copilot suggestion"
      })
      vim.keymap.set("i", "<C-H>", "<Plug>(copilot-dismiss)", { desc = "Dismiss Copilot" })
      vim.keymap.set("i", "<C-L>", "<Plug>(copilot-next)", { desc = "Next Copilot suggestion" })
      vim.keymap.set("i", "<C-K>", "<Plug>(copilot-previous)", { desc = "Previous Copilot suggestion" })

      -- Toggle Copilot
      vim.keymap.set("n", "<leader>ct", "<cmd>Copilot toggle<cr>", { desc = "Toggle Copilot" })
    end,
  },

  -- ============================================================================
  -- AI CHAT INTEGRATION - ChatGPT
  -- ============================================================================
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim"
    },
    config = function()
      require("chatgpt").setup({
        api_key_cmd = "echo $OPENAI_API_KEY",
        yank_register = "+",
        edit_with_instructions = {
          diff = false,
          keymaps = {
            close = "<C-c>",
            accept = "<C-y>",
            toggle_diff = "<C-d>",
            toggle_settings = "<C-o>",
            cycle_windows = "<Tab>",
            use_output_as_input = "<C-i>",
          },
        },
        chat = {
          welcome_message = "Welcome to ChatGPT! Ask me anything about code.",
          loading_text = "Loading, please wait ...",
          question_sign = "",
          answer_sign = "ﮧ",
          max_line_length = 120,
          sessions_window = {
            border = {
              style = "rounded",
              text = {
                top = " Sessions ",
              },
            },
            win_config = {
              height = "50%",
              width = "50%",
            },
          },
        },
        popup_layout = {
          default = "center",
          center = {
            width = "80%",
            height = "80%",
          },
        },
      })

      -- Key mappings
      vim.keymap.set("n", "<leader>cc", "<cmd>ChatGPT<cr>", { desc = "ChatGPT" })
      vim.keymap.set("n", "<leader>ce", "<cmd>ChatGPTEditWithInstruction<cr>", { desc = "Edit with instruction" })
      vim.keymap.set("v", "<leader>ce", "<cmd>ChatGPTEditWithInstruction<cr>", { desc = "Edit with instruction" })
      vim.keymap.set("n", "<leader>cg", "<cmd>ChatGPTRun grammar_correction<cr>", { desc = "Grammar correction" })
      vim.keymap.set("n", "<leader>cv", "<cmd>ChatGPTRun code_readability_analysis<cr>", { desc = "Code analysis" })
      vim.keymap.set("n", "<leader>co", "<cmd>ChatGPTRun optimize_code<cr>", { desc = "Optimize code" })
      vim.keymap.set("n", "<leader>cs", "<cmd>ChatGPTRun summarize<cr>", { desc = "Summarize" })
      vim.keymap.set("n", "<leader>cf", "<cmd>ChatGPTRun fix_bugs<cr>", { desc = "Fix bugs" })
      vim.keymap.set("n", "<leader>cx", "<cmd>ChatGPTRun explain_code<cr>", { desc = "Explain code" })
      vim.keymap.set("n", "<leader>cr", "<cmd>ChatGPTRun roxygen_edit<cr>", { desc = "Roxygen edit" })
      vim.keymap.set("n", "<leader>cl", "<cmd>ChatGPTRun add_tests<cr>", { desc = "Add tests" })
    end,
  },

  -- ============================================================================
  -- ADVANCED GIT FEATURES
  -- ============================================================================
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      require("diffview").setup({
        diff_binaries = false,
        enhanced_diff_hl = false,
        git_cmd = { "git" },
        use_icons = true,
        icons = {
          folder_closed = "",
          folder_open = "",
        },
        signs = {
          fold_closed = "",
          fold_open = "",
          done = "✓",
        },
      })

      vim.keymap.set("n", "<leader>gv", "<cmd>DiffviewOpen<cr>", { desc = "Git diffview" })
      vim.keymap.set("n", "<leader>gV", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" })
      vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory<cr>", { desc = "File history" })
      vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", { desc = "Current file history" })
    end,
  },

  -- ============================================================================
  -- ADVANCED TELESCOPE EXTENSIONS
  -- ============================================================================
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    config = function()
      require("telescope").load_extension("fzf")
    end,
  },

  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").load_extension("file_browser")
      vim.keymap.set("n", "<leader>fb", "<cmd>Telescope file_browser<cr>", { desc = "File browser" })
    end,
  },

  -- ============================================================================
  -- CODE OUTLINE AND STRUCTURE
  -- ============================================================================
  {
    "stevearc/aerial.nvim",
    opts = {},
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
    config = function()
      require("aerial").setup({
        backends = { "treesitter", "lsp", "markdown", "man" },
        layout = {
          max_width = { 40, 0.2 },
          width = nil,
          min_width = 10,
          win_opts = {},
          default_direction = "prefer_right",
          placement = "window",
        },
        attach_mode = "window",
        close_automatic_events = {},
        keymaps = {
          ["?"] = "actions.show_help",
          ["g?"] = "actions.show_help",
          ["<CR>"] = "actions.jump",
          ["<2-LeftMouse>"] = "actions.jump",
          ["<C-v>"] = "actions.jump_vsplit",
          ["<C-s>"] = "actions.jump_split",
          ["p"] = "actions.scroll",
          ["<C-j>"] = "actions.down_and_scroll",
          ["<C-k>"] = "actions.up_and_scroll",
          ["{"] = "actions.prev",
          ["}"] = "actions.next",
          ["[["] = "actions.prev_up",
          ["]]"] = "actions.next_up",
          ["q"] = "actions.close",
          ["o"] = "actions.tree_toggle",
          ["za"] = "actions.tree_toggle",
          ["O"] = "actions.tree_toggle_recursive",
          ["zA"] = "actions.tree_toggle_recursive",
          ["l"] = "actions.tree_open",
          ["zo"] = "actions.tree_open",
          ["L"] = "actions.tree_open_recursive",
          ["zO"] = "actions.tree_open_recursive",
          ["h"] = "actions.tree_close",
          ["zc"] = "actions.tree_close",
          ["H"] = "actions.tree_close_recursive",
          ["zC"] = "actions.tree_close_recursive",
          ["zr"] = "actions.tree_increase_fold_level",
          ["zR"] = "actions.tree_open_all",
          ["zm"] = "actions.tree_decrease_fold_level",
          ["zM"] = "actions.tree_close_all",
          ["zx"] = "actions.tree_sync_folds",
          ["zX"] = "actions.tree_sync_folds",
        },
        lazy_load = true,
        disable_max_lines = 10000,
        disable_max_size = 2000000,
        filter_kind = {
          "Class",
          "Constructor",
          "Enum",
          "Function",
          "Interface",
          "Module",
          "Method",
          "Struct",
        },
      })

      vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<cr>", { desc = "Aerial (symbols)" })
    end,
  },

  -- ============================================================================
  -- ADVANCED TREESITTER FEATURES
  -- ============================================================================
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("treesitter-context").setup({
        enable = true,
        max_lines = 0,
        min_window_height = 0,
        line_numbers = true,
        multiline_threshold = 20,
        trim_scope = "outer",
        mode = "cursor",
        separator = nil,
        zindex = 20,
        on_attach = nil,
      })

      vim.keymap.set("n", "[x", function()
        require("treesitter-context").go_to_context()
      end, { desc = "Go to context" })
    end,
  },

  -- ============================================================================
  -- SESSIONS AND WORKSPACE MANAGEMENT
  -- ============================================================================
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
      options = { "buffers", "curdir", "tabpages", "winsize" }
    },
    config = function()
      require("persistence").setup()

      vim.keymap.set("n", "<leader>qs", function() require("persistence").load() end, { desc = "Restore session" })
      vim.keymap.set("n", "<leader>ql", function() require("persistence").load({ last = true }) end, { desc = "Restore last session" })
      vim.keymap.set("n", "<leader>qd", function() require("persistence").stop() end, { desc = "Don't save current session" })
    end,
  },

  -- ============================================================================
  -- TROUBLE - BETTER DIAGNOSTICS (v3.x API)
  -- ============================================================================
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics (Trouble)" },
      { "<leader>xw", "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace diagnostics (Trouble)" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location list (Trouble)" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix (Trouble)" },
      { "gR", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP references (Trouble)" },
    },
    opts = {},
  },

  -- ============================================================================
  -- ADVANCED FORMATTING AND LINTING
  -- none-ls.nvim: maintained fork of null-ls.nvim (Nvim 0.12+ compatible).
  -- none-ls-extras.nvim: provides eslint_d, flake8, shellcheck which were
  --   removed from the main none-ls.nvim repo.
  -- Sources are registered conditionally: if the binary is absent, the source
  -- is silently skipped — no startup errors on machines without all tools.
  -- ============================================================================
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvimtools/none-ls-extras.nvim",
    },
    config = function()
      local null_ls = require("null-ls")

      -- Helper: return source only when its binary is on PATH
      local function guarded(source, cmd)
        if type(source) == "function" then
          -- extras sources are returned by a factory function
          if vim.fn.executable(cmd or "") == 1 then
            return source()
          end
        else
          if vim.fn.executable(cmd or "") == 1 then
            return source
          end
        end
      end

      local sources = {}

      -- Formatting (all in core none-ls.nvim)
      if vim.fn.executable("prettier") == 1 then
        table.insert(sources, null_ls.builtins.formatting.prettier.with({
          extra_filetypes = { "toml" },
        }))
      end
      for _, s in ipairs({
        guarded(null_ls.builtins.formatting.black,   "black"),
        guarded(null_ls.builtins.formatting.isort,   "isort"),
        guarded(null_ls.builtins.formatting.shfmt,   "shfmt"),
        guarded(null_ls.builtins.formatting.stylua,  "stylua"),
        -- Diagnostics available in core none-ls
        guarded(null_ls.builtins.diagnostics.markdownlint, "markdownlint"),
        guarded(null_ls.builtins.diagnostics.hadolint,     "hadolint"),
        guarded(null_ls.builtins.diagnostics.yamllint,     "yamllint"),
      }) do
        if s then table.insert(sources, s) end
      end

      -- Diagnostics from none-ls-extras (eslint_d, flake8, shellcheck)
      local ok_extras, none_extras = pcall(require, "none-ls.diagnostics.eslint_d")
      if ok_extras and vim.fn.executable("eslint_d") == 1 then
        table.insert(sources, none_extras)
      end
      local ok_flake, flake_src = pcall(require, "none-ls.diagnostics.flake8")
      if ok_flake and vim.fn.executable("flake8") == 1 then
        table.insert(sources, flake_src)
      end
      local ok_shell_diag, shell_diag = pcall(require, "none-ls.diagnostics.shellcheck")
      if ok_shell_diag and vim.fn.executable("shellcheck") == 1 then
        table.insert(sources, shell_diag)
      end

      -- Code actions from none-ls-extras
      local ok_eslint_ca, eslint_ca = pcall(require, "none-ls.code_actions.eslint_d")
      if ok_eslint_ca and vim.fn.executable("eslint_d") == 1 then
        table.insert(sources, eslint_ca)
      end

      local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
      null_ls.setup({
        sources = sources,
        on_attach = function(client, bufnr)
          -- vim.lsp.buf_get_clients()[].supports_method was deprecated in Nvim 0.11;
          -- use vim.lsp.client.supports_method or check server_capabilities directly.
          local fmt_supported = vim.tbl_get(client, "server_capabilities", "documentFormattingProvider")
            or vim.tbl_get(client, "server_capabilities", "documentRangeFormattingProvider")
          if fmt_supported then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = augroup,
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ async = false })
              end,
            })
          end
        end,
      })
    end,
  },
}
