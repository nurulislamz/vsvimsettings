return {
  {
    "christoomey/vim-tmux-navigator",
    lazy = false, 
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },
  { "nvim-lualine/lualine.nvim", cond = not vim.g.vscode, dependencies = { "nvim-tree/nvim-web-devicons" }, config = true },
  { "nvim-tree/nvim-tree.lua", cond = not vim.g.vscode, dependencies = { "nvim-tree/nvim-web-devicons" }, config = true },
  { "folke/tokyonight.nvim", cond = not vim.g.vscode, lazy = false, priority = 1000, config = function() vim.cmd([[colorscheme tokyonight]]) end },
  { 
    "folke/which-key.nvim", 
    event = "VeryLazy", 
    init = function() 
      vim.o.timeout = true; 
      vim.o.timeoutlen = 500 
    end, 
    opts = {} 
  },
  { "RRethy/vim-illuminate", lazy = false, event = { "BufReadPost", "BufNewFile" }, config = function() require("illuminate").configure() end },
  {
    "rcarriga/nvim-notify",
    cond = not vim.g.vscode,
    opts = {
      timeout = 2000, -- 2 seconds instead of 5
      render = "compact", -- use a more compact style
      stages = "static", -- disable complex animations to keep it snappy
    },
  },
  {
    "folke/noice.nvim",
    cond = not vim.g.vscode,
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    config = function()
      require("noice").setup({
        lsp = { 
          override = { 
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true, 
            ["vim.lsp.util.stylize_markdown"] = true, 
            ["cmp.entry.get_documentation"] = true 
          } 
        },
        -- Route common messages to 'mini' (bottom right) instead of a popup
        routes = {
          {
            view = "mini",
            filter = { event = "msg_show", kind = "", find = "written" },
          },
        },
        presets = { bottom_search = true, command_palette = true, long_message_to_split = true },
      })
    end
  }
}
