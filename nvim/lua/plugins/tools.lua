return {
  { "tpope/vim-fugitive", cond = not vim.g.vscode },
  { 
    "kdheepak/lazygit.nvim", 
    lazy = false,
    cond = not vim.g.vscode,
    dependencies = { "nvim-lua/plenary.nvim" }, 
    keys = { { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" } } 
  },
  { "sindrets/diffview.nvim", cond = not vim.g.vscode, dependencies = { "nvim-lua/plenary.nvim" } },
  {
    "stevearc/conform.nvim",
    cond = not vim.g.vscode,
    opts = {
      formatters_by_ft = { 
        lua = { "stylua" },
        cs = { "csharpier" },
        go = { "gofumpt", "goimports" }
      },
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
    },
  }
}
