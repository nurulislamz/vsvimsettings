return {
  { "tpope/vim-fugitive", cond = not vim.g.vscode },
  { 
    "kdheepak/lazygit.nvim", 
    lazy = false,
    cond = not vim.g.vscode,
    dependencies = { "nvim-lua/plenary.nvim" }, 
    keys = { { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" } } 
  },
  {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
    cond = not vim.g.vscode,
    opts = {
      diff = {
        layout = "side-by-side",
        compute_moves = true,
        gutter_signs = true,
        cycle_hunks_across_files = true,
      },
      explorer = {
        view_mode = "tree",
        flatten_dirs = true,
        auto_refresh = true,
        indent_markers = true,
        line_stats = {
          enabled = true,
          count_untracked = true,
        },
      },
      history = {
        view_mode = "tree",
      },
    },
    keys = {
      { "<leader>cd", "<cmd>CodeDiff<cr>", desc = "Open CodeDiff" },
    },
  },
  { "lewis6991/gitsigns.nvim", cond = not vim.g.vscode, config = true },
  {
    "stevearc/conform.nvim",
    cond = not vim.g.vscode,
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        cs = { "csharpier" },
        go = { "gofumpt", "goimports" },
        c = { "clang-format" },
        cpp = { "clang-format" }
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 500, lsp_fallback = true }
      end,
    },
    keys = {
      {
        "<leader>tf",
        function()
          vim.g.disable_autoformat = not vim.g.disable_autoformat
          print("Autoformat " .. (vim.g.disable_autoformat and "disabled" or "enabled"))
        end,
        desc = "Toggle autoformat (global)",
      },
    },
  }
}
