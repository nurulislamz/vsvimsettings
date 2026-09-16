return {
  {
    "christoomey/vim-tmux-navigator",
    cond = not vim.g.vscode,
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
    cond = not vim.g.vscode,
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
    "nvim-tree/nvim-tree.lua", 
    cond = not vim.g.vscode, 
    dependencies = { "nvim-tree/nvim-web-devicons" }, 
    config = function()
      require("nvim-tree").setup({
        update_focused_file = { enable = true, update_root = true },
        sync_root_with_cwd = true,
        hijack_cursor = false,
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

          -- Enter = current window; Ctrl-t / Shift-Enter = tab drop (reuse tab, no blank)
          api.config.mappings.default_on_attach(bufnr)

          local function open_keep_explorer()
            local node = api.tree.get_node_under_cursor()
            if node and node.nodes == nil and node.name ~= ".." then
              local path = node.link_to or node.absolute_path
              local tree_win = vim.api.nvim_get_current_win()
              local target_win = nil
              for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                if win ~= tree_win then
                  local buf = vim.api.nvim_win_get_buf(win)
                  if vim.bo[buf].buftype == "" and vim.bo[buf].filetype ~= "NvimTree" then
                    target_win = win
                    break
                  end
                end
              end
              if target_win then
                vim.api.nvim_set_current_win(target_win)
              else
                vim.cmd("wincmd v")
                vim.cmd("wincmd l")
              end
              vim.cmd("edit " .. vim.fn.fnameescape(path))
            else
              api.node.open.edit()
            end
          end
          vim.keymap.set("n", "<CR>", open_keep_explorer, opts("Open"))
          vim.keymap.set("n", "o", open_keep_explorer, opts("Open"))

          -- Override default <C-t> (tabnew + edit) which often leaves a blank [No Name] tab.
          local function open_in_new_tab()
            local node = api.tree.get_node_under_cursor()
            if not node or node.name == ".." or node.nodes ~= nil then
              api.node.open.edit(node, { quit_on_open = false })
              return
            end
            if api.node.open.tab_drop then
              api.node.open.tab_drop(node, { quit_on_open = false })
            else
              local path = node.link_to or node.absolute_path
              vim.cmd("tab drop " .. vim.fn.fnameescape(path))
            end
          end

          vim.keymap.set("n", "<C-t>", open_in_new_tab, opts("Open in new tab"))
          vim.keymap.set("n", "<S-CR>", open_in_new_tab, opts("Open in new tab"))
        end,
      })
    end 
  },
  { "folke/tokyonight.nvim", cond = not vim.g.vscode, lazy = false, priority = 1000, config = function() vim.cmd([[colorscheme tokyonight]]) end },
  { 
    "folke/which-key.nvim", 
    lazy = false,
    priority = 900,
    init = function() 
      vim.o.timeout = true; 
      vim.o.timeoutlen = 500 
    end, 
    opts = {} 
  },
  {
    "RRethy/vim-illuminate",
    cond = not vim.g.vscode,
    lazy = false,
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
    },
    config = function(_, opts)
      require("illuminate").configure(opts)
    end,
  },
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
