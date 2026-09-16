return {
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor", "cshtml" },
    init = function()
      vim.filetype.add({
        extension = {
          razor = "razor",
          cshtml = "razor",
        },
      })
    end,
    opts = {},
  },
  {
    "GustavEikaas/easy-dotnet.nvim",
    cond = not vim.g.vscode,
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim", "mfussenegger/nvim-dap", "nvim-telescope/telescope.nvim" },
    config = function()
      local dotnet = require("easy-dotnet")
      
      dotnet.setup({
        managed_terminal = {
          auto_hide = true,
          auto_hide_delay = 1000,
        },
        external_terminal = nil,
        lsp = {
          enabled = false,
          preload_roslyn = true,
          roslynator_enabled = true,
          easy_dotnet_analyzer_enabled = true,
          auto_refresh_codelens = false, -- Disabled to avoid duplicate counts
          analyzer_assemblies = {},
          config = {
            on_attach = function(client, bufnr)
              local map = function(keys, func, desc)
                vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
              end
              pcall(vim.keymap.del, "n", "grr", { buffer = bufnr })
              pcall(vim.keymap.del, "n", "gra", { buffer = bufnr })
              pcall(vim.keymap.del, "n", "gri", { buffer = bufnr })
              pcall(vim.keymap.del, "n", "grn", { buffer = bufnr })
              pcall(vim.keymap.del, "n", "grt", { buffer = bufnr })

              local smart_gd = require("config.keymaps").smart_goto_definition
              map("gd", smart_gd or vim.lsp.buf.definition, "Go to Definition / References at Root")
              map("gr", vim.lsp.buf.references, "Go to References")
              map("gi", function() require("telescope.builtin").lsp_implementations({ reuse_win = true }) end, "Go to Implementation")
              map("gy", function() require("telescope.builtin").lsp_type_definitions({ reuse_win = true }) end, "Go to Type Definition")
              map("K", vim.lsp.buf.hover, "Hover Doc")
              map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
              map("<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
            end,
            capabilities = require("cmp_nvim_lsp").default_capabilities(),
          },
        },
        debugger = {
          bin_path = nil,
          console = "integratedTerminal",
          apply_value_converters = true,
          auto_register_dap = true,
          mappings = {
            open_variable_viewer = { lhs = "T", desc = "open variable viewer" },
          },
        },
        test_runner = {
          auto_start_testrunner = true,
          hide_legend = false,
          viewmode = "float",
          icons = {
            passed = "",
            skipped = "",
            failed = "",
            success = "",
            reload = "",
            test = "",
            sln = "󰘐",
            project = "󰘐",
            dir = "",
            package = "",
            class = "",
            build_failed = "󰒡",
          },
          mappings = {
            run_test_from_buffer = { lhs = "<leader>r", desc = "run test from buffer" },
            get_build_errors = { lhs = "<leader>e", desc = "get build errors" },
            peek_stack_trace_from_buffer = { lhs = "<leader>p", desc = "peek stack trace from buffer" },
            debug_test_from_buffer = { lhs = "<leader>d", desc = "run test from buffer" },
            debug_test = { lhs = "<leader>d", desc = "debug test" },
            go_to_file = { lhs = "g", desc = "go to file" },
            run_all = { lhs = "<leader>R", desc = "run all tests" },
            run = { lhs = "<leader>r", desc = "run test" },
            peek_stacktrace = { lhs = "<leader>p", desc = "peek stacktrace of failed test" },
            expand = { lhs = "o", desc = "expand" },
            expand_node = { lhs = "E", desc = "expand node" },
            collapse_all = { lhs = "W", desc = "collapse all" },
            close = { lhs = "q", desc = "close testrunner" },
            refresh_testrunner = { lhs = "<C-r>", desc = "refresh testrunner" },
            cancel = { lhs = "<C-c>", desc = "cancel in-flight operation" },
          }
        },
        new = {
          project = {
            prefix = "sln"
          }
        },
        csproj_mappings = true,
        fsproj_mappings = true,
        auto_bootstrap_namespace = {
            type = "block_scoped",
            enabled = true,
            use_clipboard_json = {
              behavior = "prompt",
              register = "+",
            },
        },
        server = {
            log_level = nil,
        },
        picker = "telescope",
        background_scanning = true,
        notifications = {
          handler = function(start_event)
            local spinner = require("easy-dotnet.ui-modules.spinner").new()
            spinner:start_spinner(start_event.job.name)
            return function(finished_event)
              spinner:stop_spinner(finished_event.result.msg, finished_event.result.level)
            end
          end,
        },
        diagnostics = {
          default_severity = "error",
          setqflist = false,
        },
      })

      vim.api.nvim_create_user_command("Secrets", function()
        dotnet.secrets()
      end, {})

      vim.keymap.set("n", "<C-p>", function()
        dotnet.run_project()
      end)
    end
  }
}