return {
  { "tpope/vim-fugitive" },
  { 
    "kdheepak/lazygit.nvim", 
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" }, 
    keys = { { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" } } 
  },
  { "sindrets/diffview.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  { "lewis6991/gitsigns.nvim", config = true },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = { 
        lua = { "stylua" },
        cs = { "csharpier" }
      },
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
    },
  }
}
