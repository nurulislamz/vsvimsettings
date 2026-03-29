local map = vim.keymap.set

map("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })
map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })

-- Custom Unified Window/Buffer Management (Tmux Synergy)
map("n", "<leader>v", "<C-w>v", { desc = "Split window vertically" })
map("n", "<leader>-", "<C-w>s", { desc = "Split window horizontally" })
map("n", "<leader>c", ":enew<CR>", { desc = "Create new buffer" })
map("n", "<leader>q", ":bd<CR>", { desc = "Close current buffer" })
map("n", "<leader>n", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>p", ":bprev<CR>", { desc = "Previous buffer" })

map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- ==========================================
-- LSP Navigation (Definitions, References, etc.)
-- ==========================================
local lsp = vim.lsp.buf

map("n", "gd", lsp.definition, { desc = "Go to Definition" })
map("n", "gr", function() require('telescope.builtin').lsp_references() end, { desc = "Go to References (Telescope)" })
map("n", "gi", lsp.implementation, { desc = "Go to Implementation" })
map("n", "K", lsp.hover, { desc = "Hover Documentation" })
map("n", "<leader>rn", lsp.rename, { desc = "Rename Symbol" })
map("n", "<leader>ca", lsp.code_action, { desc = "Code Action" })
