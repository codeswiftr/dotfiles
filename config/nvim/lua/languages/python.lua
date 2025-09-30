-- Python language settings

local M = {}

-- Indentation and basic options
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    vim.opt_local.softtabstop = 4
  end,
})

-- Format on save if a formatter is available (null-ls, ruff, black)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
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

