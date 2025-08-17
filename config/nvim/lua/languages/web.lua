-- Web Development Language Configuration
-- Specific settings for HTML, CSS, JavaScript, TypeScript, React, Vue, etc.

local M = {}

-- TypeScript and JavaScript settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
    vim.opt_local.softtabstop = 2
  end,
})

-- HTML settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "html",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
    vim.opt_local.softtabstop = 2
  end,
})

-- CSS and SCSS settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "css", "scss", "sass", "less" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
    vim.opt_local.softtabstop = 2
  end,
})

-- JSON settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "json",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
    vim.opt_local.softtabstop = 2
    vim.opt_local.conceallevel = 0
  end,
})

-- Web development specific keymaps
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "html", "css", "javascript", "typescript", "typescriptreact", "javascriptreact" },
  callback = function()
    local opts = { buffer = true, silent = true }
    
    -- Console.log shortcut for JS/TS files
    if vim.bo.filetype:match("javascript") or vim.bo.filetype:match("typescript") then
      vim.keymap.set("n", "<leader>cl", "oconsole.log();<Esc>hi", opts)
      vim.keymap.set("i", "clog", "console.log();<Esc>hi", opts)
    end
    
    -- HTML tag completion helpers
    if vim.bo.filetype == "html" then
      vim.keymap.set("i", "<leader>div", "<div></div><Esc>5hi", opts)
      vim.keymap.set("i", "<leader>span", "<span></span><Esc>6hi", opts)
    end
  end,
})

-- Web development file detection
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.jsx", "*.tsx" },
  callback = function()
    vim.bo.filetype = vim.bo.filetype:gsub("javascript", "javascriptreact"):gsub("typescript", "typescriptreact")
  end,
})

-- Auto-format on save for web files (if formatter is available)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.js", "*.ts", "*.jsx", "*.tsx", "*.html", "*.css", "*.scss", "*.json" },
  callback = function()
    -- Only format if a formatter is configured
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
    for _, client in ipairs(clients) do
      if client.server_capabilities.documentFormattingProvider then
        vim.lsp.buf.format({ async = false })
        break
      end
    end
  end,
})

return M