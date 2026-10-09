return {
  { 
    "nvim-telescope/telescope.nvim", 
    lazy = false,
    branch = "0.1.x", 
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      local action_utils = require("telescope.actions.utils")

      local function harpoon_selected(prompt_bufnr)
        local ok, harpoon = pcall(require, "harpoon")
        if not ok then
          return
        end
        local picker = action_state.get_current_picker(prompt_bufnr)
        local selections = picker:get_multi_selection()
        if vim.tbl_isempty(selections) then
          selections = {}
          action_utils.map_entries(prompt_bufnr, function(entry)
            table.insert(selections, entry)
          end)
        end

        local list = harpoon:list()
        local seen = {}
        local count = 0
        for _, entry in ipairs(selections) do
          local raw = entry.path or entry.filename or entry.value
          if type(raw) == "table" then
            raw = raw.filename or raw.value
          end
          if type(raw) == "string" and raw ~= "" and vim.fn.isdirectory(raw) == 0 then
            local rel = vim.fn.fnamemodify(raw, ":.")
            if not seen[rel] then
              seen[rel] = true
              list:add({
                value = rel,
                context = {
                  row = entry.lnum or 1,
                  col = entry.col or 0,
                },
              })
              count = count + 1
            end
          end
        end

        actions.close(prompt_bufnr)
        vim.notify(string.format("Added %d file(s) to Harpoon", count), vim.log.levels.INFO)
      end

      telescope.setup({
        defaults = {
          initial_mode = "normal",
          mappings = {
            -- Enter = current window; Ctrl-t / Shift-Enter = new tab
            i = {
              ["<CR>"] = actions.select_default,
              ["<C-t>"] = actions.select_tab,
              ["<S-CR>"] = actions.select_tab,
              ["<C-q>"] = harpoon_selected,
            },
            n = {
              ["<CR>"] = actions.select_default,
              ["<C-t>"] = actions.select_tab,
              ["<S-CR>"] = actions.select_tab,
              ["<C-q>"] = harpoon_selected,
            },
          },
        },
      })
    end
  },
  { 
    "nvim-treesitter/nvim-treesitter", 
    build = ":TSUpdate", 
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
    config = function()
      require("project_nvim").setup({})
      require("telescope").load_extension("projects")
    end
  },
  { "mbbill/undotree", lazy = false },
  {
    "okuuva/auto-save.nvim",
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
    dependencies = { "nvim-tree/nvim-web-devicons" }, 
    opts = {} 
  },
}
