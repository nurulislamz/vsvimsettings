-- Disable netrw for nvim-tree (per nvim-tree recommendation)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("config.options")
require("config.ai")
require("config.keymaps")
require("config.lazy")
