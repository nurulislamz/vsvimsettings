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
  { "nvim-lualine/lualine.nvim", cond = not vim.g.vscode, dependencies = { "nvim-tree/nvim-web-devicons" }, config = true },
  { 
    "nvim-tree/nvim-tree.lua", 
    cond = not vim.g.vscode, 
    dependencies = { "nvim-tree/nvim-web-devicons" }, 
    config = function()
      require("nvim-tree").setup({
        actions = {
          open_file = {
            quit_on_open = false,
            window_picker = { enable = false },
          },
        },
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          local function opts(desc)
            return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end

          -- Enter = current window; Ctrl-t / Shift-Enter = new tab
          api.config.mappings.default_on_attach(bufnr)

          local function open_in_new_tab()
            local node = api.tree.get_node_under_cursor()
            if not node or node.name == ".." or node.nodes ~= nil then
              api.node.open.edit()
              return
            end
            local path = node.link_to or node.absolute_path
            vim.cmd("tab drop " .. vim.fn.fnameescape(path))
          end

          vim.keymap.set("n", "<S-CR>", open_in_new_tab, opts("Open in new tab"))
        end,
      })
    end 
  },
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
        views = {
          notify = { timeout = 1000 },
        },
      })
    end
  }
}
