return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    build = "bash build.sh",
    opts = {
      provider = "opencode",
      input = { provider = "snacks" },
      behaviour = { auto_suggestions = false },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      { "ColinKennedy/mega.cmdparse", dependencies = { "ColinKennedy/mega.logging" } },
      "folke/snacks.nvim",
      "nvim-mini/mini.icons",
    },
  },
}
