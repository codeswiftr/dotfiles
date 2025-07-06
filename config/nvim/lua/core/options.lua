-- ============================================================================
-- Core Neovim Options
-- Essential settings that every user needs
-- ============================================================================

local opt = vim.opt

-- ============================================================================
-- Performance & Startup
-- ============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable unused providers for faster startup
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python_provider = 0

-- Configure Python3 provider if available
local python3_path = vim.fn.exepath('python3')
if python3_path ~= '' then
  vim.g.python3_host_prog = python3_path
else
  vim.g.loaded_python3_provider = 0
end

-- ============================================================================
-- File Handling
-- ============================================================================
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.backup = false           -- Don't create backup files
opt.swapfile = false         -- Don't create swap files
opt.undofile = true          -- Enable persistent undo
opt.undodir = vim.fn.stdpath("data") .. "/undo"
opt.updatetime = 300         -- Faster completion (default 4000ms)
opt.timeoutlen = 500         -- Faster key sequence completion

-- ============================================================================
-- User Interface
-- ============================================================================
opt.number = true            -- Show line numbers
opt.relativenumber = true    -- Show relative line numbers
opt.signcolumn = "yes"       -- Always show sign column
opt.cursorline = true        -- Highlight current line
opt.termguicolors = true     -- Enable 24-bit RGB colors
opt.showmode = false         -- Don't show mode (we'll use statusline)
opt.scrolloff = 8            -- Keep 8 lines above/below cursor
opt.sidescrolloff = 8        -- Keep 8 columns left/right of cursor
opt.wrap = false             -- Don't wrap long lines
opt.linebreak = true         -- Break lines at word boundaries
opt.pumheight = 10           -- Maximum height of completion menu
opt.conceallevel = 0         -- Show concealed text
opt.cmdheight = 1            -- Height of command line
opt.showtabline = 2          -- Always show tab line
opt.laststatus = 3           -- Global statusline

-- ============================================================================
-- Editing Behavior
-- ============================================================================
opt.expandtab = true         -- Use spaces instead of tabs
opt.tabstop = 2              -- Number of spaces for a tab
opt.shiftwidth = 2           -- Number of spaces for indentation
opt.softtabstop = 2          -- Number of spaces for a soft tab
opt.smartindent = true       -- Smart indentation
opt.autoindent = true        -- Auto indentation
opt.smartcase = true         -- Smart case sensitivity
opt.ignorecase = true        -- Ignore case in search patterns
opt.hlsearch = true          -- Highlight search results
opt.incsearch = true         -- Incremental search
opt.inccommand = "split"     -- Preview substitutions

-- ============================================================================
-- Window Behavior
-- ============================================================================
opt.splitbelow = true        -- Split new windows below current
opt.splitright = true        -- Split new windows to the right
opt.equalalways = false      -- Don't automatically resize windows

-- ============================================================================
-- Completion & Wildmenu
-- ============================================================================
opt.completeopt = { "menu", "menuone", "noselect" }
opt.wildmode = "longest:full,full"
opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", ".git/*", "node_modules/*" })

-- ============================================================================
-- Mouse & Clipboard
-- ============================================================================
opt.mouse = "a"              -- Enable mouse in all modes
opt.mousefocus = true        -- Focus follows mouse
opt.clipboard = "unnamedplus" -- Use system clipboard

-- ============================================================================
-- Appearance
-- ============================================================================
opt.background = "dark"      -- Dark background by default
opt.fillchars = {
  fold = " ",
  foldopen = "",
  foldclose = "",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

-- ============================================================================
-- Performance
-- ============================================================================
opt.hidden = true            -- Enable background buffers
opt.history = 100            -- Limit command history
opt.lazyredraw = false       -- Don't redraw during macros (can cause issues)
opt.synmaxcol = 240          -- Max column for syntax highlight
opt.updatetime = 250         -- Decrease update time

-- ============================================================================
-- Auto-create directories
-- ============================================================================
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("auto_create_dir", { clear = true }),
  callback = function(event)
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- ============================================================================
-- Disable builtin plugins for faster startup
-- ============================================================================
local disabled_built_ins = {
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "gzip",
  "zip",
  "zipPlugin",
  "tar",
  "tarPlugin",
  "getscript",
  "getscriptPlugin",
  "vimball",
  "vimballPlugin",
  "2html_plugin",
  "logipat",
  "rrhelper",
  "spellfile_plugin",
  "matchit"
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end