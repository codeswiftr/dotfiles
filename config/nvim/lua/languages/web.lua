-- ============================================================================
-- Web Development Configuration for Neovim
-- Enhanced support for TypeScript, JavaScript, HTML, CSS, and PWA development
-- ============================================================================

return {
  -- Enhanced TypeScript/JavaScript LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- TypeScript/JavaScript
        tsserver = {
          settings = {
            typescript = {
              preferences = {
                importModuleSpecifier = "relative",
                includePackageJsonAutoImports = "auto",
              },
              suggest = {
                autoImports = true,
              },
            },
            javascript = {
              preferences = {
                importModuleSpecifier = "relative",
                includePackageJsonAutoImports = "auto",
              },
              suggest = {
                autoImports = true,
              },
            },
          },
        },
        
        -- HTML LSP with enhanced support
        html = {
          settings = {
            html = {
              format = {
                templating = true,
                wrapLineLength = 120,
                wrapAttributes = "auto",
              },
              hover = {
                documentation = true,
                references = true,
              },
            },
          },
        },
        
        -- CSS LSP
        cssls = {
          settings = {
            css = {
              validate = true,
              lint = {
                unknownAtRules = "ignore", -- For CSS-in-JS and modern CSS
              },
            },
            scss = {
              validate = true,
            },
            less = {
              validate = true,
            },
          },
        },
        
        -- JSON LSP for manifest files and configurations
        jsonls = {
          settings = {
            json = {
              schemas = {
                {
                  fileMatch = { "manifest.json" },
                  url = "https://json.schemastore.org/web-manifest",
                },
                {
                  fileMatch = { "package.json" },
                  url = "https://json.schemastore.org/package",
                },
                {
                  fileMatch = { "*.config.json" },
                  url = "https://json.schemastore.org/config",
                },
              },
            },
          },
        },
      },
    },
  },

  -- Lit/LitElement support
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "typescript",
        "javascript", 
        "html",
        "css",
        "json",
        "tsx",
        "jsx",
      },
    },
  },

  -- Enhanced web development tools
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascript", "typescript", "javascriptreact", "typescriptreact" },
    config = true,
  },

  -- Live server for web development
  {
    "barrett-ruth/live-server.nvim",
    build = "bun install -g live-server",
    cmd = { "LiveServerStart", "LiveServerStop" },
    config = function()
      require("live-server").setup({
        args = { "--port=8080", "--browser=chrome" },
      })
      
      -- Key mappings
      vim.keymap.set("n", "<leader>ls", "<cmd>LiveServerStart<cr>", { desc = "Start Live Server" })
      vim.keymap.set("n", "<leader>lS", "<cmd>LiveServerStop<cr>", { desc = "Stop Live Server" })
    end,
  },

  -- Web development snippets
  {
    "L3MON4D3/LuaSnip",
    config = function()
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node
      local f = ls.function_node

      -- TypeScript/JavaScript snippets
      ls.add_snippets("typescript", {
        -- LitElement component
        s("lit-component", {
          t("import { LitElement, html, css } from 'lit';"), 
          t({"", "import { customElement, property } from 'lit/decorators.js';"}),
          t({"", "", "@customElement('"}), i(1, "my-element"), t("')"),
          t({"", "export class "}), i(2, "MyElement"), t(" extends LitElement {"),
          t({"", "  @property({ type: String })"}),
          t({"", "  "}), i(3, "name"), t(" = '"), i(4, "World"), t("';"),
          t({"", "", "  static styles = css`"}),
          t({"", "    :host {"}),
          t({"", "      display: block;"}),
          t({"", "      padding: 16px;"}),
          t({"", "    }"}),
          t({"", "  `;"}),
          t({"", "", "  render() {"}),
          t({"", "    return html`"}),
          t({"", "      <h1>Hello, ${this."}), f(function(args) return args[1][1] end, {3}), t("}!</h1>"),
          t({"", "    `;"}),
          t({"", "  }"}),
          t({"", "}"}),
        }),

        -- FastAPI client function
        s("fastapi-client", {
          t("async function "), i(1, "apiCall"), t("("), i(2), t("): Promise<"), i(3, "any"), t("> {"),
          t({"", "  try {"}),
          t({"", "    const response = await fetch('"), i(4, "http://localhost:8000/api"), t("', {"),
          t({"", "      method: '"), i(5, "GET"), t("',"),
          t({"", "      headers: {"}),
          t({"", "        'Content-Type': 'application/json',"}),
          t({"", "      },"}),
          i(6, "      // body: JSON.stringify(data),"),
          t({"", "    });"}),
          t({"", "", "    if (!response.ok) {"}),
          t({"", "      throw new Error(`HTTP error! status: ${response.status}`);"}),
          t({"", "    }"}),
          t({"", "", "    return await response.json();"}),
          t({"", "  } catch (error) {"}),
          t({"", "    console.error('API call failed:', error);"}),
          t({"", "    throw error;"}),
          t({"", "  }"}),
          t({"", "}"}),
        }),

        -- PWA Service Worker
        s("pwa-sw", {
          t("const CACHE_NAME = '"), i(1, "my-app"), t("-v"), i(2, "1"), t("';"),
          t({"", "const urlsToCache = ["}),
          t({"", "  '/',"}),
          t({"", "  '/index.html',"}),
          t({"", "  '/manifest.json',"}),
          i(3, "  // Add your assets here"),
          t({"", "];"}),
          t({"", "", "self.addEventListener('install', (event) => {"}),
          t({"", "  event.waitUntil("}),
          t({"", "    caches.open(CACHE_NAME)"}),
          t({"", "      .then((cache) => cache.addAll(urlsToCache))"}),
          t({"", "  );"}),
          t({"", "});"}),
          t({"", "", "self.addEventListener('fetch', (event) => {"}),
          t({"", "  event.respondWith("}),
          t({"", "    caches.match(event.request)"}),
          t({"", "      .then((response) => response || fetch(event.request))"}),
          t({"", "  );"}),
          t({"", "});"}),
        }),
      })

      -- HTML snippets
      ls.add_snippets("html", {
        -- PWA manifest
        s("pwa-manifest", {
          t({"{",
             '  "name": "'}), i(1, "My Progressive Web App"), t('",'),
          t({'',
             '  "short_name": "'}), i(2, "MyPWA"), t('",'),
          t({'',
             '  "description": "'}), i(3, "A progressive web application"), t('",'),
          t({'',
             '  "start_url": "/",',
             '  "display": "standalone",',
             '  "background_color": "#ffffff",',
             '  "theme_color": "#000000",',
             '  "icons": [',
             '    {',
             '      "src": "icon-192.png",',
             '      "sizes": "192x192",',
             '      "type": "image/png"',
             '    },',
             '    {',
             '      "src": "icon-512.png",',
             '      "sizes": "512x512",',
             '      "type": "image/png"',
             '    }',
             '  ]',
             '}'}),
        }),

        -- LitElement HTML template
        s("lit-html", {
          t("<"), i(1, "my-element"), i(2), t(">"),
          t({"", "  "}), i(3),
          t({"", "</"}), f(function(args) return args[1][1] end, {1}), t(">"),
        }),
      })
    end,
  },

  -- REST client for API testing
  {
    "rest-nvim/rest.nvim",
    ft = { "http" },
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
          show_http_info = true,
          show_headers = true,
          formatters = {
            json = "jq",
            html = function(body)
              return vim.fn.system("tidy -i -q -", body)
            end,
          },
        },
      })

      -- Key mappings
      vim.keymap.set("n", "<leader>rr", "<cmd>RestNvim<cr>", { desc = "Run REST request" })
      vim.keymap.set("n", "<leader>rp", "<cmd>RestNvimPreview<cr>", { desc = "Preview REST request" })
      vim.keymap.set("n", "<leader>rl", "<cmd>RestNvimLast<cr>", { desc = "Run last REST request" })
    end,
  },

  -- Browser integration
  {
    "nvim-lua/plenary.nvim",
    config = function()
      -- Browser control functions
      local browser = {}

      browser.open_in_browser = function(url)
        url = url or "http://localhost:8080"
        local Job = require("plenary.job")
        Job:new({
          command = "open",
          args = { url },
          on_exit = function(j, return_val)
            if return_val == 0 then
              vim.notify("Opened in browser: " .. url, vim.log.levels.INFO)
            else
              vim.notify("Failed to open browser", vim.log.levels.ERROR)
            end
          end,
        }):start()
      end

      browser.open_localhost = function(port)
        port = port or 8080
        browser.open_in_browser("http://localhost:" .. port)
      end

      browser.open_api_docs = function(port)
        port = port or 8000
        browser.open_in_browser("http://localhost:" .. port .. "/docs")
      end

      -- Create user commands
      vim.api.nvim_create_user_command("BrowserOpen", function(opts)
        browser.open_in_browser(opts.args)
      end, { nargs = "?", desc = "Open URL in browser" })
      
      vim.api.nvim_create_user_command("BrowserLocalhost", function(opts)
        local port = tonumber(opts.args) or 8080
        browser.open_localhost(port)
      end, { nargs = "?", desc = "Open localhost in browser" })

      vim.api.nvim_create_user_command("BrowserAPIDocs", function(opts)
        local port = tonumber(opts.args) or 8000
        browser.open_api_docs(port)
      end, { nargs = "?", desc = "Open FastAPI docs in browser" })

      -- Key mappings for web development
      vim.keymap.set("n", "<leader>wo", browser.open_localhost, { desc = "Open localhost" })
      vim.keymap.set("n", "<leader>wd", browser.open_api_docs, { desc = "Open API docs" })
      vim.keymap.set("n", "<leader>wb", function()
        vim.ui.input({ prompt = "Enter URL: " }, function(url)
          if url then browser.open_in_browser(url) end
        end)
      end, { desc = "Open URL in browser" })
    end,
  },
}