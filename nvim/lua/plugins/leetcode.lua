local leet_arg = "leetcode.nvim"

return {
  {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    lazy = leet_arg ~= vim.fn.argv(0, -1),
    cmd = "Leet",
    init = function()
      vim.cmd([[cnoreabbrev <expr> leet (getcmdtype() == ':' && getcmdline() =~ '^leet') ? 'Leet' : 'leet']])
    end,
    opts = {
      arg = leet_arg,
      lang = "python3",
      picker = { provider = "telescope" },
      plugins = {
        non_standalone = true,
      },
      injector = {},
      storage = {
        home = vim.fn.stdpath("data") .. "/leetcode",
        cache = vim.fn.stdpath("cache") .. "/leetcode",
      },
    },
  },
}

