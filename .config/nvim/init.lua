-- ============================================================================
-- Modern Neovim Configuration - 2025 Edition
-- ============================================================================

-- Set leader key early
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable netrw for nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Disable optional providers to reduce startup warnings
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Configure Python provider (if available)
local python3_path = vim.fn.exepath('python3')
if python3_path ~= '' then
  vim.g.python3_host_prog = python3_path
else
  vim.g.loaded_python3_provider = 0
end

-- ============================================================================
-- Core Settings
-- ============================================================================

local opt = vim.opt

-- General
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.backup = false
opt.swapfile = false
opt.undofile = true

-- UI
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true
opt.showmode = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false

-- Editing
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.smartindent = true
opt.autoindent = true
opt.backspace = "indent,eol,start"

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Clipboard
opt.clipboard = "unnamedplus"

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300

-- ============================================================================
-- Plugin Manager - Lazy.nvim
-- ============================================================================

-- Bootstrap lazy.nvim
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
opt.rtp:prepend(lazypath)

-- ============================================================================
-- Plugin Specifications
-- ============================================================================

require("lazy").setup({
  -- Disable luarocks to avoid warnings
  rocks = {
    enabled = false,
  },
  -- Modern color scheme - Catppuccin (2025 trending theme)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        background = {
          light = "latte",
          dark = "mocha",
        },
        transparent_background = false,
        show_end_of_buffer = false,
        term_colors = true,
        dim_inactive = {
          enabled = false,
          shade = "dark",
          percentage = 0.15,
        },
        no_italic = false,
        no_bold = false,
        no_underline = false,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        color_overrides = {},
        custom_highlights = {},
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          notify = false,
          mini = {
            enabled = true,
            indentscope_color = "",
          },
          -- AI plugins integration
          codecompanion = true,
          -- Modern plugins
          telescope = {
            enabled = true,
          },
          lsp_trouble = true,
          which_key = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- File explorer
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
      })
    end,
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git", "__pycache__", "*.pyc" },
          layout_config = {
            horizontal = {
              preview_width = 0.6,
            },
          },
        },
      })
    end,
  },

  -- Treesitter for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "python", "javascript", "typescript", "swift", "lua", "vim", "vimdoc",
          "html", "css", "json", "yaml", "toml", "markdown", "bash", "dockerfile"
        },
        auto_install = true,
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
  },

  -- Mason for LSP management
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "pyright",      -- Python
          "ruff",         -- Python linting/formatting (updated from ruff_lsp)
          "ts_ls",        -- TypeScript/JavaScript (updated from tsserver)
          "eslint",       -- JavaScript linting
          "sourcekit",    -- Swift
          "lua_ls",       -- Lua
        },
        automatic_installation = true,
      })
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
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
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.close(),
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
        }),
      })
    end,
  },

  -- GitHub Copilot
  {
    "github/copilot.vim",
    config = function()
      -- Enable copilot for specific filetypes
      vim.g.copilot_filetypes = {
        ["*"] = false,
        ["python"] = true,
        ["javascript"] = true,
        ["typescript"] = true,
        ["lua"] = true,
        ["swift"] = true,
        ["go"] = true,
        ["rust"] = true,
      }
    end,
  },

  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
      })
    end,
  },

  -- Enhanced Git commands
  {
    "tpope/vim-fugitive",
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin",
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- Code formatting
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          python = { "ruff_format", "ruff_organize_imports" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          lua = { "stylua" },
          swift = { "swift_format" },
          json = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          markdown = { "prettier" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
    end,
  },

  -- Which-key for keybinding help
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    config = function()
      require("which-key").setup()
    end,
  },

  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  -- Commenting
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- Surround text objects
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  -- Indentation guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup()
    end,
  },

  -- Terminal integration
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_terminals = true,
        direction = "float",
        float_opts = {
          border = "curved",
        },
      })
    end,
  },

  -- ============================================================================
  -- AI Coding Agents Integration
  -- ============================================================================

  -- Advanced AI coding assistant with multi-agent support
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "hrsh7th/nvim-cmp",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("codecompanion").setup({
        strategies = {
          chat = {
            adapter = "anthropic",
          },
          inline = {
            adapter = "anthropic",
          },
        },
        adapters = {
          anthropic = function()
            return require("codecompanion.adapters").extend("anthropic", {
              env = {
                api_key = "cmd:echo $ANTHROPIC_API_KEY",
              },
            })
          end,
        },
        display = {
          chat = {
            window = {
              layout = "vertical",
              width = 0.45,
            },
          },
        },
        opts = {
          log_level = "ERROR",
          send_code = true,
        },
      })
    end,
  },

  -- AI-powered code generation
  {
    "David-Kunz/gen.nvim",
    config = function()
      require('gen').setup({
        model = "claude-3-5-sonnet-20241022",
        display_mode = "split",
        show_prompt = true,
        show_model = false,
        no_auto_close = false,
        debug = false,
        init = function(options) end,
        command = function(options)
          -- Use external CLI tools if available
          if vim.fn.executable("claude") == 1 then
            return "claude \"" .. options.prompt .. "\""
          elseif vim.fn.executable("gemini") == 1 then
            return "gemini \"" .. options.prompt .. "\""
          else
            return "echo 'Please install Claude Code CLI or Gemini CLI for AI integration'"
          end
        end,
      })
    end,
  },

  -- Enhanced terminal for AI integration (using existing toggleterm)
  -- Custom AI terminal functions are defined in keymaps below

  -- AI code assistant
  {
    "Bryley/neoai.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    cmd = {
      "NeoAI",
      "NeoAIOpen",
      "NeoAIClose",
      "NeoAIToggle",
      "NeoAIContext",
      "NeoAIContextOpen",
      "NeoAIContextClose",
      "NeoAIInject",
      "NeoAIInjectCode",
      "NeoAIInjectContext",
      "NeoAIInjectContextCode",
    },
    keys = {
      { "<leader>as", desc = "Summarize text" },
      { "<leader>ag", desc = "Generate git message" },
    },
    config = function()
      require("neoai").setup({
        -- Using external CLI instead of API
        model = "claude-3-5-sonnet-20241022",
        register = "+",
        open_ai = {
          api_key = {
            env = "ANTHROPIC_API_KEY",
            value = nil,
          },
        },
        shortcuts = {
          {
            name = "textify",
            key = "<leader>as",
            desc = "Fix text with AI",
            use_context = true,
            prompt = [[Please rewrite the text to make it more readable, clear,
            concise, and fix any grammar, spelling, or punctuation errors.
            Keep the same general length.
            
            ## Text
            ]],
            modes = { "v" },
            strip_function = nil,
          },
          {
            name = "gitcommit", 
            key = "<leader>ag",
            desc = "Generate git commit message",
            use_context = false,
            prompt = function()
              return 'Using the following git diff generate a concise and'
                .. ' clear git commit message, with a short title summary'
                .. ' that is 75 characters or less:\n```\n'
                .. vim.fn.system('git diff --cached')
                .. '\n```'
            end,
            modes = { "n" },
            strip_function = nil,
          },
        },
      })
    end,
  },
})

-- ============================================================================
-- LSP Configuration
-- ============================================================================

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Python LSP
lspconfig.pyright.setup({
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
})

-- Ruff LSP for Python linting/formatting (updated from ruff_lsp)
lspconfig.ruff.setup({
  capabilities = capabilities,
})

-- TypeScript/JavaScript LSP (updated from tsserver)
lspconfig.ts_ls.setup({
  capabilities = capabilities,
})

-- Swift LSP
lspconfig.sourcekit.setup({
  capabilities = capabilities,
})

-- Lua LSP
lspconfig.lua_ls.setup({
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

-- ============================================================================
-- Key Mappings
-- ============================================================================

local keymap = vim.keymap.set

-- General
keymap("i", "jk", "<ESC>", { desc = "Exit insert mode" })
keymap("n", "<leader>w", ":w<CR>", { desc = "Save file" })
keymap("n", "<leader>wq", ":wq<CR>", { desc = "Save and quit" })
keymap("n", "<leader>q", ":q<CR>", { desc = "Quit" })

-- File explorer  
keymap("n", "<leader>n", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
keymap("n", "<leader>nf", ":NvimTreeFindFile<CR>", { desc = "Find current file in explorer" })

-- Telescope
keymap("n", "<leader>f", ":Telescope find_files<CR>", { desc = "Find files" })
keymap("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live grep" })
keymap("n", "<leader>fb", ":Telescope buffers<CR>", { desc = "Find buffers" })
keymap("n", "<leader>fh", ":Telescope help_tags<CR>", { desc = "Help tags" })

-- LSP
keymap("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
keymap("n", "gr", vim.lsp.buf.references, { desc = "Find references" })
keymap("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
keymap("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
keymap("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- Git
keymap("n", "<leader>gs", ":Git<CR>", { desc = "Git status" })
keymap("n", "<leader>gc", ":Git commit<CR>", { desc = "Git commit" })
keymap("n", "<leader>gp", ":Git push<CR>", { desc = "Git push" })
keymap("n", "<leader>gl", ":Git pull<CR>", { desc = "Git pull" })

-- Formatting
keymap("n", "<leader>fm", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format file" })

-- ============================================================================
-- Enhanced Window/Pane Management
-- ============================================================================

-- Window navigation (seamless with tmux)
keymap("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Alternative navigation using arrow keys
keymap("n", "<C-Left>", "<C-w>h", { desc = "Move to left window" })
keymap("n", "<C-Down>", "<C-w>j", { desc = "Move to bottom window" })
keymap("n", "<C-Up>", "<C-w>k", { desc = "Move to top window" })
keymap("n", "<C-Right>", "<C-w>l", { desc = "Move to right window" })

-- Window splits
keymap("n", "<leader>sv", ":vsplit<CR>", { desc = "Split vertically" })
keymap("n", "<leader>sh", ":split<CR>", { desc = "Split horizontally" })
keymap("n", "<leader>se", "<C-w>=", { desc = "Equalize window sizes" })
keymap("n", "<leader>sc", "<C-w>c", { desc = "Close current window" })
keymap("n", "<leader>so", "<C-w>o", { desc = "Close all other windows" })

-- Window resizing
keymap("n", "<C-w>+", ":resize +5<CR>", { desc = "Increase window height" })
keymap("n", "<C-w>-", ":resize -5<CR>", { desc = "Decrease window height" })
keymap("n", "<C-w>>", ":vertical resize +5<CR>", { desc = "Increase window width" })
keymap("n", "<C-w><", ":vertical resize -5<CR>", { desc = "Decrease window width" })

-- Smart window resizing with leader key
keymap("n", "<leader>rh", ":resize +10<CR>", { desc = "Resize window height +10" })
keymap("n", "<leader>rH", ":resize -10<CR>", { desc = "Resize window height -10" })
keymap("n", "<leader>rw", ":vertical resize +10<CR>", { desc = "Resize window width +10" })
keymap("n", "<leader>rW", ":vertical resize -10<CR>", { desc = "Resize window width -10" })

-- Window rotation and movement
keymap("n", "<leader>wr", "<C-w>r", { desc = "Rotate windows right" })
keymap("n", "<leader>wR", "<C-w>R", { desc = "Rotate windows left" })
keymap("n", "<leader>wx", "<C-w>x", { desc = "Exchange windows" })
keymap("n", "<leader>wH", "<C-w>H", { desc = "Move window to far left" })
keymap("n", "<leader>wJ", "<C-w>J", { desc = "Move window to bottom" })
keymap("n", "<leader>wK", "<C-w>K", { desc = "Move window to top" })
keymap("n", "<leader>wL", "<C-w>L", { desc = "Move window to far right" })

-- Tab management
keymap("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab" })
keymap("n", "<leader>tc", ":tabclose<CR>", { desc = "Close tab" })
keymap("n", "<leader>to", ":tabonly<CR>", { desc = "Close all other tabs" })
keymap("n", "<leader>tr", ":tabnext<CR>", { desc = "Next tab" })
keymap("n", "<leader>tl", ":tabprevious<CR>", { desc = "Previous tab" })
keymap("n", "<leader>tf", ":tabfirst<CR>", { desc = "First tab" })
keymap("n", "<leader>tL", ":tablast<CR>", { desc = "Last tab" })

-- Quick tab navigation with numbers
for i = 1, 9 do
  keymap("n", "<leader>" .. i, i .. "gt", { desc = "Go to tab " .. i })
end

-- Buffer navigation
keymap("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
keymap("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })
keymap("n", "<leader>bD", ":bdelete!<CR>", { desc = "Force delete buffer" })
keymap("n", "<leader>ba", ":bufdo bd<CR>", { desc = "Delete all buffers" })
keymap("n", "<leader>bo", ":%bd|e#<CR>", { desc = "Close all buffers except current" })

-- Quick buffer switching
keymap("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer" })
keymap("n", "<S-Tab>", ":bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "<leader>bb", ":Telescope buffers<CR>", { desc = "List all buffers" })

-- Split navigation shortcuts
keymap("n", "<leader>||", ":vsplit<CR>", { desc = "Quick vertical split" })
keymap("n", "<leader>--", ":split<CR>", { desc = "Quick horizontal split" })

-- Close all splits except current
keymap("n", "<leader>oo", "<C-w>o", { desc = "Close all other windows" })

-- Window focus indicators (visual feedback)
keymap("n", "<leader>wf", ":set cursorline! cursorcolumn!<CR>", { desc = "Toggle focus indicators" })

-- Terminal in split
keymap("n", "<leader>tt", ":split | terminal<CR>", { desc = "Terminal in horizontal split" })
keymap("n", "<leader>tv", ":vsplit | terminal<CR>", { desc = "Terminal in vertical split" })

-- Quick pane layouts
keymap("n", "<leader>L1", ":only<CR>", { desc = "Layout: Single pane" })
keymap("n", "<leader>L2", ":only | vsplit<CR>", { desc = "Layout: Two vertical panes" })
keymap("n", "<leader>L3", ":only | vsplit | split<CR>", { desc = "Layout: Three panes" })
keymap("n", "<leader>L4", ":only | vsplit | split | wincmd h | split<CR>", { desc = "Layout: Four panes" })

-- Clear search highlighting
keymap("n", "<leader>/", ":noh<CR>", { desc = "Clear search highlighting" })

-- Python-specific mappings
keymap("n", "<leader>pr", ":!python %<CR>", { desc = "Run Python file" })
keymap("n", "<leader>pt", ":!python -m pytest<CR>", { desc = "Run Python tests" })

-- ============================================================================
-- Advanced AI Coding Agents Integration
-- ============================================================================

-- CodeCompanion AI assistant
keymap({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "AI Actions" })
keymap({ "n", "v" }, "<leader>ac", "<cmd>CodeCompanionChat<cr>", { desc = "AI Chat" })
keymap("v", "<leader>ai", "<cmd>CodeCompanionAdd<cr>", { desc = "AI Inline" })

-- Custom AI workflows from prompt library
keymap("v", "<leader>acr", function()
  vim.cmd("CodeCompanion Custom Code Review")
end, { desc = "AI Code Review" })

keymap("v", "<leader>ace", function()
  vim.cmd("CodeCompanion Explain Code")
end, { desc = "AI Explain Code" })

keymap("v", "<leader>act", function()
  vim.cmd("CodeCompanion Generate Tests")
end, { desc = "AI Generate Tests" })

keymap("v", "<leader>aco", function()
  vim.cmd("CodeCompanion Optimize Code")
end, { desc = "AI Optimize Code" })

keymap("v", "<leader>acc", function()
  vim.cmd("CodeCompanion Add Comments")
end, { desc = "AI Add Comments" })

-- Gen.nvim AI generation
keymap({ "n", "v" }, "<leader>ag", ":Gen<CR>", { desc = "AI Generate" })
keymap({ "n", "v" }, "<leader>agc", ":Gen Chat<CR>", { desc = "AI Chat" })
keymap({ "n", "v" }, "<leader>age", ":Gen Enhance_Code<CR>", { desc = "AI Enhance Code" })
keymap({ "n", "v" }, "<leader>agr", ":Gen Review_Code<CR>", { desc = "AI Review Code" })

-- AI Terminal integration using ToggleTerm
keymap("v", "<leader>av", function()
  local lines = vim.fn.getline(vim.fn.line("'<"), vim.fn.line("'>"))
  local text = table.concat(lines, '\n')
  local escaped_text = vim.fn.shellescape(text)
  vim.cmd('TermExec cmd="claude ' .. escaped_text .. '"')
end, { desc = "AI Send Visual to Claude" })

keymap("n", "<leader>al", function()
  local line = vim.fn.getline('.')
  local escaped_line = vim.fn.shellescape(line)
  vim.cmd('TermExec cmd="claude ' .. escaped_line .. '"')
end, { desc = "AI Send Line to Claude" })

keymap("n", "<leader>ab", function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local text = table.concat(lines, '\n')
  local escaped_text = vim.fn.shellescape(text)
  vim.cmd('TermExec cmd="claude ' .. escaped_text .. '"')
end, { desc = "AI Send Buffer to Claude" })

keymap("n", "<leader>at", ":ToggleTerm<CR>", { desc = "Toggle AI Terminal" })

-- NeoAI shortcuts (already configured in plugin)
keymap("v", "<leader>as", ":NeoAIContext<CR>", { desc = "AI Summarize/Fix Text" })
keymap("n", "<leader>agm", ":NeoAI<CR>", { desc = "AI Generate Git Message" })

-- Direct CLI integration (fallback)
keymap("n", "<leader>afc", ":!claude %<CR>", { desc = "Claude CLI: Send file" })
keymap("n", "<leader>afg", ":!gemini %<CR>", { desc = "Gemini CLI: Send file" })
keymap("n", "<leader>afr", ":!claude --review %<CR>", { desc = "Claude CLI: Review" })
keymap("n", "<leader>afd", ":!claude --doc %<CR>", { desc = "Claude CLI: Document" })

-- Quick AI prompts with context
keymap("n", "<leader>aqc", function()
  vim.ui.input({prompt='Ask Claude: '}, function(input)
    if input then
      local file_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
      local prompt = string.format('Context: %s\n\nQuestion: %s', file_content, input)
      vim.cmd('!claude "' .. prompt .. '"')
    end
  end)
end, { desc = "Quick Claude with context" })

keymap("n", "<leader>aqg", function()
  vim.ui.input({prompt='Ask Gemini: '}, function(input)
    if input then
      local file_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
      local prompt = string.format('Context: %s\n\nQuestion: %s', file_content, input)
      vim.cmd('!gemini "' .. prompt .. '"')
    end
  end)
end, { desc = "Quick Gemini with context" })

-- AI workflow helpers
keymap("n", "<leader>awr", function()
  -- AI code review workflow
  vim.cmd('Git')
  vim.defer_fn(function()
    vim.cmd('CodeCompanionChat Review the staged changes and suggest improvements')
  end, 500)
end, { desc = "AI Review Workflow" })

keymap("n", "<leader>awt", function()
  -- AI test generation workflow
  local ft = vim.bo.filetype
  local filename = vim.fn.expand('%:t')
  vim.cmd('CodeCompanionChat Generate comprehensive unit tests for the current ' .. ft .. ' file: ' .. filename)
end, { desc = "AI Test Workflow" })

keymap("n", "<leader>awd", function()
  -- AI documentation workflow
  local ft = vim.bo.filetype
  vim.cmd('CodeCompanionChat Generate comprehensive documentation for this ' .. ft .. ' code, including usage examples')
end, { desc = "AI Documentation Workflow" })

-- ============================================================================
-- Enhanced Navigation Features
-- ============================================================================

-- Window Picker Navigation
keymap("n", "<leader>wp", function()
  local window_picker_ok, window_picker = pcall(require, 'window-picker')
  if window_picker_ok then
    local win_id = window_picker.pick_window()
    if win_id then
      vim.api.nvim_set_current_win(win_id)
    end
  else
    print("Window picker not available")
  end
end, { desc = "Pick window to navigate to" })

-- Enhanced Buffer Navigation with Bufferline
keymap("n", "<leader>bc", function()
  local bufferline_ok, bufferline = pcall(require, 'bufferline')
  if bufferline_ok then
    vim.cmd('BufferLinePickClose')
  else
    vim.cmd('bdelete')
  end
end, { desc = "Pick buffer to close" })

keymap("n", "<leader>bpi", function()
  local bufferline_ok, bufferline = pcall(require, 'bufferline')
  if bufferline_ok then
    vim.cmd('BufferLinePick')
  else
    vim.cmd('Telescope buffers')
  end
end, { desc = "Pick buffer to navigate" })

-- Session Management
keymap("n", "<leader>ss", function()
  local persistence_ok, persistence = pcall(require, 'persistence')
  if persistence_ok then
    persistence.load()
  else
    print("Session management not available")
  end
end, { desc = "Restore session" })

keymap("n", "<leader>sl", function()
  local persistence_ok, persistence = pcall(require, 'persistence')
  if persistence_ok then
    persistence.load({ last = true })
  else
    print("Session management not available")
  end
end, { desc = "Restore last session" })

keymap("n", "<leader>sd", function()
  local persistence_ok, persistence = pcall(require, 'persistence')
  if persistence_ok then
    persistence.stop()
  else
    print("Session management not available")
  end
end, { desc = "Stop session recording" })

-- Multi-pane layout helpers
keymap("n", "<leader>mh", function()
  -- Create horizontal multi-pane layout
  vim.cmd('only')
  vim.cmd('split')
  vim.cmd('split')
  vim.cmd('wincmd k')
  vim.cmd('wincmd =')
end, { desc = "Multi-pane: 3 horizontal splits" })

keymap("n", "<leader>mv", function()
  -- Create vertical multi-pane layout  
  vim.cmd('only')
  vim.cmd('vsplit')
  vim.cmd('vsplit')
  vim.cmd('wincmd h')
  vim.cmd('wincmd =')
end, { desc = "Multi-pane: 3 vertical splits" })

keymap("n", "<leader>mg", function()
  -- Create grid layout (2x2)
  vim.cmd('only')
  vim.cmd('vsplit')
  vim.cmd('split')
  vim.cmd('wincmd h')
  vim.cmd('split')
  vim.cmd('wincmd =')
end, { desc = "Multi-pane: 2x2 grid layout" })

keymap("n", "<leader>mc", function()
  -- Create coding layout (main + sidebar + terminal)
  vim.cmd('only')
  vim.cmd('vsplit')
  vim.cmd('split')
  vim.cmd('wincmd j')
  vim.cmd('terminal')
  vim.cmd('resize 15')
  vim.cmd('wincmd h')
  vim.cmd('wincmd h')
end, { desc = "Multi-pane: Coding layout" })

-- Smart pane navigation with awareness
keymap("n", "<leader>ww", function()
  local current_win = vim.api.nvim_get_current_win()
  local wins = vim.api.nvim_list_wins()
  local next_win = nil
  
  for i, win in ipairs(wins) do
    if win == current_win then
      next_win = wins[i + 1] or wins[1]
      break
    end
  end
  
  if next_win then
    vim.api.nvim_set_current_win(next_win)
  end
end, { desc = "Cycle through windows" })

-- Pane information display
keymap("n", "<leader>wi", function()
  local wins = vim.api.nvim_list_wins()
  local current_win = vim.api.nvim_get_current_win()
  
  print("Window info:")
  for i, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    local filename = vim.fn.fnamemodify(name, ':t')
    if filename == '' then filename = '[No Name]' end
    
    local marker = (win == current_win) and ">>> " or "    "
    print(string.format("%s%d: %s", marker, i, filename))
  end
end, { desc = "Show window information" })

-- ============================================================================
-- Autocommands
-- ============================================================================

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", {}),
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 300 })
  end,
})

-- Python-specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})

-- JavaScript/TypeScript settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

-- ============================================================================
-- Startup Message
-- ============================================================================

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    print("🚀 Modern Neovim Configuration Loaded - " .. os.date("%Y-%m-%d %H:%M"))
    print("🔧 LSP: Python (pyright+ruff), JS/TS (ts_ls), Swift (sourcekit)")
    print("🤖 AI: GitHub Copilot enabled for select filetypes")
    print("🪟 Multi-pane: <leader>m* for layouts, <leader>w* for navigation")
    print("🎯 Navigation: <C-h/j/k/l> for panes, <leader>wp for window picker")
    print("⌨️  Leader key: <Space> | Type <leader> to see available commands")
  end,
})