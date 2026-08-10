return {
  {
    "folke/persistence.nvim",
    cond = not vim.g.vscode,
    event = "BufReadPre", -- only start saving once a real file is opened
    opts = {
      need = 1,
      branch = true,
    },
    keys = {
      {
        "<leader>Ss",
        function()
          require("persistence").load()
        end,
        desc = "Restore Session (cwd)",
      },
      {
        "<leader>Sl",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Restore Last Session",
      },
      {
        "<leader>SS",
        function()
          require("persistence").select()
        end,
        desc = "Select Session",
      },
      {
        "<leader>Sd",
        function()
          require("persistence").stop()
        end,
        desc = "Don't Save Session on Exit",
      },
    },
    init = function()
      -- VS Code-like: reopen last workspace for this cwd when starting nvim with no args
      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("persistence_autoload", { clear = true }),
        nested = true,
        callback = function()
          if vim.fn.argc(-1) > 0 then
            return
          end
          vim.schedule(function()
            require("persistence").load()
          end)
        end,
      })
    end,
  },
}
