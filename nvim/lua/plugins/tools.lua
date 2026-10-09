return {
  { "tpope/vim-fugitive" },
  {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
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
  { "lewis6991/gitsigns.nvim", config = true },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        go = { "gofumpt", "goimports" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" }
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 500, lsp_fallback = true }
      end,
    },
  }
}
