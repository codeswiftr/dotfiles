-- Snippet loader for LuaSnip

local function safe_require(mod)
  local ok, m = pcall(require, mod)
  if ok then return m end
  return nil
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local ls = safe_require("luasnip")
    if not ls then return end
    local from_lua = safe_require("luasnip.loaders.from_lua")
    if from_lua then
      -- Load repo snippets
      from_lua.load({ paths = vim.fn.stdpath("config") .. "/lua/snippets" })
    end
  end,
})

