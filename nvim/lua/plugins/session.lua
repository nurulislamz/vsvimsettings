return {
  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- only start saving once a real file is opened
    opts = {
      need = 1,
      branch = true,
    },
    init = function()
      -- Reopen the last workspace for this cwd when starting Neovim without args
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
      -- Close explorer before saving sessions so zombie buffers aren't restored
      vim.api.nvim_create_autocmd("User", {
        pattern = "PersistenceSavePre",
        callback = function()
          pcall(function()
            local snacks = package.loaded["snacks"]
            if snacks and snacks.picker then
              local explorer = snacks.picker.get({ source = "explorer" })[1]
              if explorer then
                explorer:close()
              end
            end
          end)
        end,
      })
    end,
  },
}
