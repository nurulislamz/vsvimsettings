return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    build = "make tiktoken",
    cmd = "CopilotChat",
    opts = {
      debug = false,
      mappings = {
        reset = "<leader>r",
      },
      prompts = {
        Sticky = "> #buffer:active",
      },
    },
    keys = {
      { "<leader>cc", function() require("CopilotChat").open({ message = "#buffer:active" }) end, desc = "Copilot Chat with Buffer" },
      { "<leader>ce", "<cmd>CopilotChatExplain<cr>", desc = "Copilot Chat Explain" },
      { "<leader>cr", "<cmd>CopilotChatReview<cr>", desc = "Copilot Chat Review" },
      { "<leader>cf", "<cmd>CopilotChatFix<cr>", desc = "Copilot Chat Fix" },
    },
  },
}
