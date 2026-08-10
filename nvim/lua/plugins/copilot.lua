return {
  {
    "zbirenbaum/copilot.lua",
    cond = function()
      return vim.g.ai_copilot
    end,
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        -- Same UX as neocursor: inline ghost text, Tab accepts (see lsp.lua).
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = false, -- owned by shared Tab/CR handler in lsp.lua
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        panel = { enabled = false },
      })
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    cond = function()
      return vim.g.ai_copilot
    end,
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
