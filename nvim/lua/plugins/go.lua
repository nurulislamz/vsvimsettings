return {
  {
    "ray-x/go.nvim",
    dependencies = {  -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup({
        -- These commands overlap with Gopher and Godoc below.
        remap_commands = {
          GoDoc = false,
          GoImpl = false,
          GoIfErr = false,
          GoCmt = false,
          GoGet = false,
          GoWork = false,
          GoNew = false,
        },
      })
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    -- build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
  },
  { "olexsmir/gopher.nvim", ft = "go", opts = {} },
  {
    "fredrikaverpil/godoc.nvim",
    version = "*",
    cmd = "GoDoc",
    dependencies = { "nvim-telescope/telescope.nvim" },
    opts = { picker = { type = "telescope" } },
  },
}
