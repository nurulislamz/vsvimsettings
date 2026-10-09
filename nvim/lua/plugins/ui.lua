return {
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", mode = { "n", "t" } },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>", mode = { "n", "t" } },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>", mode = { "n", "t" } },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>", mode = { "n", "t" } },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", mode = { "n", "t" } },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      sections = {
        lualine_c = {
          {
            "filename",
            path = 1, -- 0: Just filename, 1: Relative path, 2: Absolute path, 3: Absolute path with ~, 4: Filename and parent dir
          },
        },
      },
    },
  },

  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("cyberdream").setup({
        transparent = true,
        italic_comments = true,
        hide_fillchars = true,
        borderless_pickers = true,
        terminal_colors = true,
      })
      vim.cmd("colorscheme cyberdream")
    end,
  },
  { 
    "folke/which-key.nvim", 
    lazy = false,
    priority = 900,
    init = function() 
      vim.o.timeout = true 
      vim.o.timeoutlen = 500 
    end, 
    opts = {
      preset = "classic",
      icons = { mappings = false, rules = false },
      spec = {
        mode = { "n", "v" },
        { "<leader><Tab>", group = "tabs" },
        { "<leader>c", group = "code / git" },
        { "<leader>f", group = "file/find" },
        { "<leader>g", group = "goto / lsp" },
        { "<leader>h", group = "harpoon" },
        { "<leader>m", group = "markdown" },
        { "<leader>S", group = "session" },
        { "<leader>t", group = "toggle" },
        { "<leader>w", group = "window" },
        { "<leader>1", hidden = true },
        { "<leader>2", hidden = true },
        { "<leader>3", hidden = true },
        { "<leader>4", hidden = true },
        { "<leader>p", desc = "Search paste buffer" },
        { "<leader>e", desc = "File explorer (Snacks)" },
        { "<leader>.", desc = "Scratch buffer" },
      },
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    config = function()
      require("noice").setup({
        lsp = { 
          override = { 
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true, 
            ["vim.lsp.util.stylize_markdown"] = true, 
            ["cmp.entry.get_documentation"] = true,
          } 
        },
        -- Route common messages to 'mini' (bottom right) instead of a popup
        routes = {
          {
            view = "mini",
            filter = { event = "msg_show", kind = "", find = "written" },
          },
        },
        presets = { bottom_search = true, command_palette = true, long_message_to_split = true, inc_rename = true },
        views = {
          notify = { timeout = 1000 },
        },
      })
    end
  },
  {
    "diegok/live-autoread.nvim",
    event = "BufReadPost",
    opts = {},
  },
  {
    "akinsho/bufferline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    },
    opts = function()
      return {
        options = {
          mode = "buffers",
          style_preset = require("bufferline").style_preset.minimal,
          separator_style = "thin",
          show_buffer_close_icons = false,
          show_close_icon = false,
          always_show_bufferline = true,
          diagnostics = "nvim_lsp",
          diagnostics_indicator = function(count, level)
            local icon = level:match("error") and "󰅚 " or (level:match("warning") and "󰅐 " or "󰌵 ")
            return " " .. icon .. count
          end,
          indicator = {
            icon = "▎",
            style = "icon",
          },
          modified_icon = "●",
          close_command = function(n) require("snacks").bufdelete(n) end,
          right_mouse_command = function(n) require("snacks").bufdelete(n) end,
          offsets = {
            {
              filetype = "snacks_layout_box",
              text = "File Explorer",
              highlight = "Directory",
              text_align = "left",
              separator = true,
            },
          },
        },
        highlights = {
          fill = { bg = "none" },
          background = { fg = "#7b8496", bg = "none" },
          buffer_selected = { fg = "#ffffff", bg = "none", bold = true, italic = false },
          buffer_visible = { fg = "#7b8496", bg = "none" },
          separator = { fg = "#3c4048", bg = "none" },
          separator_selected = { fg = "#3c4048", bg = "none" },
          separator_visible = { fg = "#3c4048", bg = "none" },
          indicator_selected = { fg = "#5ef1ff", bg = "none" },
          indicator_visible = { fg = "none", bg = "none" },
          modified = { fg = "#ffbd5e", bg = "none" },
          modified_selected = { fg = "#5eff6c", bg = "none" },
          modified_visible = { fg = "#ffbd5e", bg = "none" },
          diagnostic = { fg = "#7b8496", bg = "none" },
          diagnostic_visible = { fg = "#7b8496", bg = "none" },
          diagnostic_selected = { fg = "#5eff6c", bg = "none", bold = true },
          error = { fg = "#7b8496", bg = "none" },
          error_visible = { fg = "#7b8496", bg = "none" },
          error_selected = { fg = "#ff6e5e", bg = "none", bold = true },
          error_diagnostic = { fg = "#7b8496", bg = "none" },
          error_diagnostic_visible = { fg = "#7b8496", bg = "none" },
          error_diagnostic_selected = { fg = "#ff6e5e", bg = "none" },
          warning = { fg = "#7b8496", bg = "none" },
          warning_visible = { fg = "#7b8496", bg = "none" },
          warning_selected = { fg = "#f1ff5e", bg = "none", bold = true },
          warning_diagnostic = { fg = "#7b8496", bg = "none" },
          warning_diagnostic_visible = { fg = "#7b8496", bg = "none" },
          warning_diagnostic_selected = { fg = "#f1ff5e", bg = "none" },
          info = { fg = "#7b8496", bg = "none" },
          info_visible = { fg = "#7b8496", bg = "none" },
          info_selected = { fg = "#5ea1ff", bg = "none", bold = true },
          info_diagnostic = { fg = "#7b8496", bg = "none" },
          info_diagnostic_visible = { fg = "#7b8496", bg = "none" },
          info_diagnostic_selected = { fg = "#5ea1ff", bg = "none" },
          hint = { fg = "#7b8496", bg = "none" },
          hint_visible = { fg = "#7b8496", bg = "none" },
          hint_selected = { fg = "#5ef1ff", bg = "none", bold = true },
          hint_diagnostic = { fg = "#7b8496", bg = "none" },
          hint_diagnostic_visible = { fg = "#7b8496", bg = "none" },
          hint_diagnostic_selected = { fg = "#5ef1ff", bg = "none" },
        },
      }
    end,
  },
}
