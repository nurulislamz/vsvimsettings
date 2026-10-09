return {
  {
    "TheLazyCat00/runner-nvim",
    keys = {
      { "<leader>rr", function() require("runner-nvim").run() end, desc = "Runner: Run" },
      { "<leader>rl", function() require("runner-nvim").runLast() end, desc = "Runner: Run Last" },
      { "<leader>rt", function() require("runner-nvim").toggle() end, mode = { "n", "t" }, desc = "Runner: Toggle" },
    },
    opts = {},
  },
}
