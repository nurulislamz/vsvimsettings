return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- v2 requires nvim-treesitter main; this config still uses its legacy master API.
      { "fredrikaverpil/neotest-golang", version = "^1.0.0" },
    },
    keys = {
      { "<leader>tr", function() require("neotest").run.run() end, desc = "Run nearest test" },
      { "<leader>tR", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run current file tests" },
    },
    config = function()
      require("neotest").setup({
        adapters = { require("neotest-golang")({}) },
      })
    end,
  },
}
