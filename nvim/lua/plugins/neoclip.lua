return {
  "AckslD/nvim-neoclip.lua",
  dependencies = { "nvim-telescope/telescope.nvim" },
  event = "VeryLazy",
  config = function()
    require("neoclip").setup({
      keys = {
        telescope = {
          i = { paste = "<cr>", select = "<c-y>" },
          n = { paste = "<cr>", select = "<c-y>" },
        },
      },
    })
    require("telescope").load_extension("neoclip")
  end,
  keys = {
    { "<leader>p", "<cmd>Telescope neoclip<cr>", desc = "Clipboard History" },
  },
}