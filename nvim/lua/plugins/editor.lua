return {
  { 
    "nvim-telescope/telescope.nvim", 
    lazy = false,
    cond = not vim.g.vscode,
    branch = "0.1.x", 
    dependencies = { "nvim-lua/plenary.nvim" }, 
    keys = { 
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" }, 
      { "<leader>fs", "<cmd>Telescope live_grep<cr>", desc = "Find String" } 
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      telescope.setup({
        defaults = {
          mappings = {
            -- Enter = current window; Ctrl-t / Shift-Enter = new tab
            i = {
              ["<CR>"] = actions.select_default,
              ["<C-t>"] = actions.select_tab,
              ["<S-CR>"] = actions.select_tab,
            },
            n = {
              ["<CR>"] = actions.select_default,
              ["<C-t>"] = actions.select_tab,
              ["<S-CR>"] = actions.select_tab,
            },
          },
        },
      })
    end
  },
  { 
    "nvim-treesitter/nvim-treesitter", 
    build = ":TSUpdate", 
    cond = not vim.g.vscode,
    branch = "master",
    config = function() 
      require("nvim-treesitter.configs").setup({ 
        ensure_installed = {
          "c",
          "cpp",
          "c_sharp",
          "go",
          "gomod",
          "gosum",
          "gowork",
          "java",
          "lua",
          -- LSP hover/signature floats are markdown; without these parsers
          -- nvim 0.12's open_floating_preview errors and docs look broken.
          "markdown",
          "markdown_inline",
          "html",
          "typst",
          "yaml",
          "python",
          "rust",
          "vim",
          "vimdoc",
        },
        highlight = { enable = true } 
      }) 
    end 
  },
  {
    "ahmedkhalf/project.nvim",
    cond = not vim.g.vscode,
    config = function()
      require("project_nvim").setup({})
      require("telescope").load_extension("projects")
    end
  },
  { "mbbill/undotree", lazy = false, cond = not vim.g.vscode, keys = { { "<leader>u", vim.cmd.UndotreeToggle, desc = "Toggle Undotree" } } },
  {
    "okuuva/auto-save.nvim",
    cond = not vim.g.vscode,
    event = { "InsertLeave", "TextChanged" },
    opts = {
      debounce_delay = 1000,
      condition = function(buf)
        local fn = vim.fn
        local exclude_ft = { "gitcommit", "gitrebase" }
        if vim.tbl_contains(exclude_ft, vim.bo[buf].filetype) then return false end
        if fn.getbufvar(buf, "&modifiable") ~= 1 then return false end
        return true
      end,
    },
  },
  { "windwp/nvim-autopairs", lazy = false, event = "InsertEnter", config = true },
  { "numToStr/Comment.nvim", opts = {}, lazy = false },
  { 
    "folke/flash.nvim", 
    event = "VeryLazy", 
    opts = {}, 
    keys = { { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" } } 
  },
  { 
    "folke/trouble.nvim", 
    lazy = false,
    cond = not vim.g.vscode,
    dependencies = { "nvim-tree/nvim-web-devicons" }, 
    keys = { { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" } }, 
    opts = {} 
  },
}
