-- JavaScript/TypeScript language settings

local M = {}

-- Indentation defaults for JS/TS/JSX/TSX
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
    vim.opt_local.softtabstop = 2
  end,
})

-- Format on save if a formatter is available (prettier via null-ls or LSP)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.js", "*.ts", "*.jsx", "*.tsx" },
  callback = function()
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
    for _, client in ipairs(clients) do
      if client.server_capabilities and client.server_capabilities.documentFormattingProvider then
        vim.lsp.buf.format({ async = false })
        break
      end
    end
  end,
})

return M

