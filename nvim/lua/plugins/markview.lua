return {
  "OXY2DEV/markview.nvim",
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
    "gunasekar/markview-smart-tables.nvim",
  },
  opts = function()
    local presets = require("markview.presets")
    return {
      preview = {
        modes = { "n", "no", "c" },
        hybrid_modes = { "i" }, -- Keeps normal mode cleanly rendered; reveals raw text in insert mode
      },
      markdown = {
        headings = presets.headings.glow,
        tables = presets.tables.rounded,
        block_quotes = presets.block_quotes.obsidian,
        checkboxes = presets.checkboxes.nerd,
      },
      renderers = {
        markdown_table = function(buffer, item)
          local ok, smart_tables = pcall(require, "markview-smart-tables")
          if ok then
            smart_tables.render(buffer, item)
          end
        end,
      },
      markdown_inline = {
        tags = {
          enable = true,
          default = {
            hl = "MarkviewCodeInfo",
            padding_left = "",
            padding_left_hl = "MarkviewCodeFg",
            padding_right = "",
            padding_right_hl = "MarkviewCodeFg",
          },
        },
      },
    }
  end,
  keys = {
    {
      "<leader>mp",
      "<cmd>Markview Toggle<cr>",
      desc = "Toggle Markview Render",
    },
  },
}

