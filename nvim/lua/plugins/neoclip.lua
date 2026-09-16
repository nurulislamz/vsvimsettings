return {
  "AckslD/nvim-neoclip.lua",
  dependencies = { "nvim-telescope/telescope.nvim" },
  event = "VeryLazy",
  config = function()
    require("neoclip").setup({
      -- Only capture yanks, not deletes/changes; skip empty/whitespace-only
      filter = function(data)
        if data.event.operator ~= "y" then return false end
        local content = table.concat(data.event.regcontents, "\n")
        return content:match("%S") ~= nil
      end,
      -- Newest entries first
      default_register_macros = "q",
      enable_macro_history = false,
      keys = {
        telescope = {
          i = {
            -- Enter/Tab paste (like cmp confirm); Ctrl-y only sets the register
            paste = { "<cr>", "<tab>" },
            select = "<c-y>",
          },
          n = {
            paste = { "<cr>", "<tab>" },
            select = "<c-y>",
          },
        },
      },
    })
    require("telescope").load_extension("neoclip")
  end,
  keys = {
    { "<leader>p", function()
      require("telescope").extensions.neoclip.default({
        sorting_strategy = "ascending",
        layout_config = { prompt_position = "top" },
      })
    end, desc = "Clipboard History" },
  },
}
