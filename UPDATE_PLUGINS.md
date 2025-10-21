# Plugin Update Instructions

## Fix Neovim 0.11 Deprecation Warnings

If you're seeing warnings like:
```
The `require('lspconfig')` "framework" is deprecated, use vim.lsp.config instead.
vim.lsp.buf_get_clients() is deprecated.
```

Follow these steps:

### 1. Update All Plugins

In Neovim, run:
```vim
:Lazy sync
```

This will update all plugins to their latest versions, including nvim-lspconfig which has been updated for Neovim 0.11+ compatibility.

### 2. Restart Neovim

After the sync completes, restart Neovim:
```vim
:qa
```
Then reopen Neovim.

### 3. Verify No Warnings

The deprecation warnings should be gone. If they persist:

1. Check Neovim version (should be 0.11+):
   ```vim
   :version
   ```

2. Run health check:
   ```vim
   :checkhealth vim.deprecated
   :checkhealth lsp
   ```

3. Ensure nvim-lspconfig is updated:
   ```vim
   :Lazy
   ```
   Look for nvim-lspconfig and verify it's on the latest commit.

## What Changed

- **nvim-lspconfig**: Updated to use new `vim.lsp.config` API internally (Neovim 0.11+)
- **lazy-lock.json**: Removed to allow fresh plugin version resolution
- **tier1.lua**: Added `version = false` to nvim-lspconfig to always use latest commit

## Automatic Updates

The lazy-lock.json file will be regenerated automatically when you run `:Lazy sync`. This locks plugin versions for reproducibility while staying compatible with Neovim updates.

---

**Last Updated**: September 30, 2025
**Neovim Version**: 0.11.4+
**Required Action**: Run `:Lazy sync` in Neovim
