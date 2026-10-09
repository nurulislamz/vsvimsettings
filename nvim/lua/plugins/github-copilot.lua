-- GitHub Copilot. Loaded only when vim.g.ai_copilot.
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
}
