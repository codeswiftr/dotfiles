-- ============================================================================
-- Swift and iOS Development Configuration for Neovim
-- Language-specific settings, LSP, and development tools
-- ============================================================================

return {
  -- Swift Language Server
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {
          cmd = { "sourcekit-lsp" },
          filetypes = { "swift", "objective-c", "objective-cpp" },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern("Package.swift", ".git")(fname)
          end,
          settings = {
            swift = {
              -- Enable completion snippets
              completion = {
                enableSnippets = true,
              },
              -- Enable index-while-building for better performance
              indexWhileBuilding = true,
            },
          },
        },
      },
    },
  },

  -- Swift syntax highlighting
  {
    "keith/swift.vim",
    ft = { "swift" },
  },

  -- Xcode integration
  {
    "wojciech-kulik/xcodebuild.nvim",
    ft = { "swift", "objective-c" },
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("xcodebuild").setup({
        -- Automatically show build logs
        logs = {
          auto_open_on_success_tests = false,
          auto_open_on_failed_tests = true,
          auto_open_on_success_build = false,
          auto_open_on_failed_build = true,
          only_summary = false,
        },
        -- iOS Simulator configuration
        simulator = {
          -- Automatically install app after successful build
          auto_install_app = true,
          -- Automatically launch app after install
          auto_launch_app = true,
        },
        -- Code coverage
        code_coverage = {
          enabled = true,
        },
      })

      -- Key mappings for Xcode integration
      local keymap = vim.keymap.set
      keymap("n", "<leader>xb", "<cmd>XcodebuildBuild<cr>", { desc = "Build Project" })
      keymap("n", "<leader>xr", "<cmd>XcodebuildBuildRun<cr>", { desc = "Build & Run" })
      keymap("n", "<leader>xt", "<cmd>XcodebuildTest<cr>", { desc = "Run Tests" })
      keymap("n", "<leader>xT", "<cmd>XcodebuildTestClass<cr>", { desc = "Test Current Class" })
      keymap("n", "<leader>x.", "<cmd>XcodebuildTestSelected<cr>", { desc = "Test Selected" })
      keymap("n", "<leader>xc", "<cmd>XcodebuildClean<cr>", { desc = "Clean Build" })
      keymap("n", "<leader>xC", "<cmd>XcodebuildCleanDerivedData<cr>", { desc = "Clean Derived Data" })
      keymap("n", "<leader>xs", "<cmd>XcodebuildSelectScheme<cr>", { desc = "Select Scheme" })
      keymap("n", "<leader>xd", "<cmd>XcodebuildSelectDevice<cr>", { desc = "Select Device" })
      keymap("n", "<leader>xp", "<cmd>XcodebuildPicker<cr>", { desc = "Show Picker" })
      keymap("n", "<leader>xl", "<cmd>XcodebuildToggleLogs<cr>", { desc = "Toggle Logs" })
      keymap("n", "<leader>xq", "<cmd>Telescope xcodebuild_picker<cr>", { desc = "Quick Actions" })
    end,
  },

  -- iOS Simulator integration
  {
    "nvim-lua/plenary.nvim",
    config = function()
      -- iOS Simulator functions
      local simulator = {}

      simulator.list_devices = function()
        local Job = require("plenary.job")
        Job:new({
          command = "xcrun",
          args = { "simctl", "list", "devices", "available" },
          on_exit = function(j, return_val)
            if return_val == 0 then
              local devices = j:result()
              vim.notify("Available iOS Devices:\n" .. table.concat(devices, "\n"), vim.log.levels.INFO)
            else
              vim.notify("Failed to list devices", vim.log.levels.ERROR)
            end
          end,
        }):start()
      end

      simulator.take_screenshot = function()
        local filename = "screenshot_" .. os.date("%Y%m%d_%H%M%S") .. ".png"
        local path = vim.fn.expand("~/Desktop/" .. filename)
        
        local Job = require("plenary.job")
        Job:new({
          command = "xcrun",
          args = { "simctl", "io", "booted", "screenshot", path },
          on_exit = function(j, return_val)
            if return_val == 0 then
              vim.notify("Screenshot saved: " .. path, vim.log.levels.INFO)
            else
              vim.notify("Failed to take screenshot", vim.log.levels.ERROR)
            end
          end,
        }):start()
      end

      simulator.open_simulator = function()
        local Job = require("plenary.job")
        Job:new({
          command = "open",
          args = { "-a", "Simulator" },
          on_exit = function(j, return_val)
            if return_val == 0 then
              vim.notify("iOS Simulator opened", vim.log.levels.INFO)
            else
              vim.notify("Failed to open simulator", vim.log.levels.ERROR)
            end
          end,
        }):start()
      end

      -- Create user commands
      vim.api.nvim_create_user_command("IOSDevices", simulator.list_devices, { desc = "List iOS devices" })
      vim.api.nvim_create_user_command("IOSScreenshot", simulator.take_screenshot, { desc = "Take iOS simulator screenshot" })
      vim.api.nvim_create_user_command("IOSSimulator", simulator.open_simulator, { desc = "Open iOS Simulator" })

      -- Key mappings for iOS development
      local keymap = vim.keymap.set
      keymap("n", "<leader>ios", simulator.open_simulator, { desc = "Open iOS Simulator" })
      keymap("n", "<leader>iod", simulator.list_devices, { desc = "List iOS Devices" })
      keymap("n", "<leader>ios", simulator.take_screenshot, { desc = "iOS Screenshot" })
    end,
  },

  -- Swift snippets
  {
    "L3MON4D3/LuaSnip",
    config = function()
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node
      local f = ls.function_node

      ls.add_snippets("swift", {
        -- SwiftUI View snippet
        s("swiftui", {
          t("import SwiftUI"), t({"", "", "struct "}), i(1, "ContentView"), t(": View {"), 
          t({"", "    var body: some View {"}), 
          t({"", "        "}), i(2, "Text(\"Hello, World!\")"),
          t({"", "    }"}),
          t({"", "}"}),
          t({"", "", "#Preview {"}),
          t({"", "    "}), f(function(args) return args[1][1] end, {1}), t("()"),
          t({"", "}"}),
        }),
        
        -- Swift function snippet
        s("func", {
          t("func "), i(1, "functionName"), t("("), i(2), t(") "), i(3, "-> Void "), t("{"),
          t({"", "    "}), i(4),
          t({"", "}"}),
        }),

        -- Swift class snippet
        s("class", {
          t("class "), i(1, "ClassName"), i(2, ": NSObject"), t(" {"),
          t({"", "    "}), i(3),
          t({"", "}"}),
        }),

        -- Swift struct snippet
        s("struct", {
          t("struct "), i(1, "StructName"), i(2, ": Codable"), t(" {"),
          t({"", "    "}), i(3),
          t({"", "}"}),
        }),

        -- Swift property wrapper snippets
        s("@State", {
          t("@State private var "), i(1, "property"), t(": "), i(2, "String"), t(" = "), i(3, "\"\""),
        }),

        s("@Binding", {
          t("@Binding var "), i(1, "property"), t(": "), i(2, "String"),
        }),

        s("@ObservedObject", {
          t("@ObservedObject var "), i(1, "viewModel"), t(": "), i(2, "ViewModel"),
        }),
      })
    end,
  },
}