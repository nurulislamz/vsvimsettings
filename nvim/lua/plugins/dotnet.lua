return {
  {
    "GustavEikaas/easy-dotnet.nvim",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    config = function() require("easy-dotnet").setup() end,
    keys = {
      { "<leader>dr", function() require("easy-dotnet").run() end, desc = ".NET Run" },
      { "<leader>dt", function() require("easy-dotnet").test() end, desc = ".NET Test" },
      { "<leader>db", function() require("easy-dotnet").build() end, desc = ".NET Build" },
    }
  }
}
