return {
  "AckslD/nvim-neoclip.lua",
  dependencies = { "nvim-telescope/telescope.nvim" },
  event = "VeryLazy",
  config = function()
    require("neoclip").setup({
      default_register = { '"', '+', '*' },
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
    { "<leader>p", "<cmd>Telescope neoclip<cr>", desc = "Search paste buffer" },
  },
}
