-- ============================================================================
-- Neovim Tier 3 Configuration - AI-Powered Workflows
-- +10 plugins for cutting-edge development (33 total)
-- Target: Advanced AI-powered development environment, <1200ms startup
-- ============================================================================

-- Tier 3 plugins add AI features and advanced power-user tools
return {
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
  -- REST CLIENT - API Testing
  -- ============================================================================
  {
    "rest-nvim/rest.nvim",
    ft = "http",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("rest-nvim").setup({
        result_split_horizontal = false,
        result_split_in_place = false,
        skip_ssl_verification = false,
        encode_url = true,
        highlight = {
          enabled = true,
          timeout = 150,
        },
        result = {
          show_url = true,
          show_curl_command = false,
          show_http_info = true,
          show_headers = true,
          formatters = {
            json = "jq",
            html = function(body)
              return vim.fn.system({"tidy", "-i", "-q", "-"}, body)
            end
          },
        },
        jump_to_request = false,
        env_file = '.env',
        custom_dynamic_variables = {},
        yank_dry_run = true,
      })

      vim.keymap.set("n", "<leader>rr", "<Plug>RestNvim", { desc = "Run REST request" })
      vim.keymap.set("n", "<leader>rp", "<Plug>RestNvimPreview", { desc = "Preview REST request" })
      vim.keymap.set("n", "<leader>rl", "<Plug>RestNvimLast", { desc = "Re-run last request" })
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
  -- TROUBLE - BETTER DIAGNOSTICS
  -- ============================================================================
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("trouble").setup({
        position = "bottom",
        height = 10,
        width = 50,
        icons = true,
        mode = "workspace_diagnostics",
        fold_open = "",
        fold_closed = "",
        group = true,
        padding = true,
        action_keys = {
          close = "q",
          cancel = "<esc>",
          refresh = "r",
          jump = { "<cr>", "<tab>" },
          open_split = { "<c-x>" },
          open_vsplit = { "<c-v>" },
          open_tab = { "<c-t>" },
          jump_close = { "o" },
          toggle_mode = "m",
          toggle_preview = "P",
          hover = "K",
          preview = "p",
          close_folds = { "zM", "zm" },
          open_folds = { "zR", "zr" },
          toggle_fold = { "zA", "za" },
          previous = "k",
          next = "j"
        },
        indent_lines = true,
        auto_open = false,
        auto_close = false,
        auto_preview = true,
        auto_fold = false,
        auto_jump = { "lsp_definitions" },
        signs = {
          error = "",
          warning = "",
          hint = "",
          information = "",
          other = "﫠"
        },
        use_diagnostic_signs = false
      })

      vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>", { desc = "Toggle trouble" })
      vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", { desc = "Workspace diagnostics" })
      vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", { desc = "Document diagnostics" })
      vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>", { desc = "Location list" })
      vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", { desc = "Quickfix" })
      vim.keymap.set("n", "gR", "<cmd>TroubleToggle lsp_references<cr>", { desc = "LSP references" })
    end,
  },

  -- ============================================================================
  -- ADVANCED FORMATTING AND LINTING
  -- ============================================================================
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")

      null_ls.setup({
        sources = {
          -- Formatting
          null_ls.builtins.formatting.prettier.with({
            extra_filetypes = { "toml" },
          }),
          null_ls.builtins.formatting.black,
          null_ls.builtins.formatting.isort,
          null_ls.builtins.formatting.shfmt,
          null_ls.builtins.formatting.stylua,

          -- Diagnostics
          null_ls.builtins.diagnostics.eslint_d,
          null_ls.builtins.diagnostics.flake8,
          null_ls.builtins.diagnostics.shellcheck,
          null_ls.builtins.diagnostics.markdownlint,

          -- Code actions
          null_ls.builtins.code_actions.eslint_d,
          null_ls.builtins.code_actions.shellcheck,
        },
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
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