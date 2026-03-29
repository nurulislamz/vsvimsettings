return {
  { 
    "nvim-telescope/telescope.nvim", 
    lazy = false,
    branch = "0.1.x", 
    dependencies = { "nvim-lua/plenary.nvim" }, 
    keys = { 
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" }, 
      { "<leader>fs", "<cmd>Telescope live_grep<cr>", desc = "Find String" } 
    } 
  },
  { 
    "nvim-treesitter/nvim-treesitter", 
    build = ":TSUpdate", 
    branch = "master",
    config = function() 
      require("nvim-treesitter.configs").setup({ 
        ensure_installed = { "c_sharp", "lua", "vim", "vimdoc" }, 
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
  { "mbbill/undotree", lazy = false, keys = { { "<leader>u", vim.cmd.UndotreeToggle, desc = "Toggle Undotree" } } },
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
    keys = { { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" } }, 
    opts = {} 
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()
      vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Harpoon Add" })
      vim.keymap.set("n", "<leader>hm", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon Menu" })
      vim.keymap.set("n", "<C-1>", function() harpoon:list():select(1) end, { desc = "Harpoon File 1" })
      vim.keymap.set("n", "<C-2>", function() harpoon:list():select(2) end, { desc = "Harpoon File 2" })
    end,
  }
}
