local map = vim.keymap.set

map("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

if vim.g.vscode then
    local vscode = require('vscode')

    -- File Explorer
    map("n", "<leader>e", function() vscode.action("workbench.view.explorer") end, { desc = "Toggle File Explorer" })

    -- Window/Buffer Management (VS Code equivalent)
    map("n", "<leader>v", function() vscode.action("workbench.action.splitEditor") end, { desc = "Split window vertically" })
    map("n", "<leader>-", function() vscode.action("workbench.action.splitEditorOrthogonal") end, { desc = "Split window horizontally" })
    map("n", "<leader>c", function() vscode.action("workbench.action.files.newUntitledFile") end, { desc = "Create new buffer" })
    map("n", "<leader>q", function() vscode.action("workbench.action.closeActiveEditor") end, { desc = "Close current buffer" })
    map("n", "<leader>n", function() vscode.action("workbench.action.nextEditor") end, { desc = "Next buffer" })
    map("n", "<leader>p", function() vscode.action("workbench.action.previousEditor") end, { desc = "Previous buffer" })

    map({ "i", "x", "n", "s" }, "<C-s>", function() vscode.action("workbench.action.files.save") end, { desc = "Save file" })

    -- LSP Navigation
    map("n", "gd", function() vscode.action("editor.action.revealDefinition") end, { desc = "Go to Definition" })
    map("n", "gr", function() vscode.action("editor.action.goToReferences") end, { desc = "Go to References" })
    map("n", "gi", function() vscode.action("editor.action.goToImplementation") end, { desc = "Go to Implementation" })
    map("n", "K", function() vscode.action("editor.action.showHover") end, { desc = "Hover Documentation" })
    map("n", "<leader>rn", function() vscode.action("editor.action.rename") end, { desc = "Rename Symbol" })
    map("n", "<leader>ca", function() vscode.action("editor.action.quickFix") end, { desc = "Code Action" })
else
    map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })

    -- Custom Unified Window/Buffer Management (Tmux Synergy)
    map("n", "<leader>v", "<C-w>v", { desc = "Split window vertically" })
    map("n", "<leader>-", "<C-w>s", { desc = "Split window horizontally" })
    map("n", "<leader>c", ":enew<CR>", { desc = "Create new buffer" })
    map("n", "<leader>q", ":bd<CR>", { desc = "Close current buffer" })
    map("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
    map("n", "<leader>bp", ":bprev<CR>", { desc = "Previous buffer" })

    -- Tab Management
    map("n", "<leader>tt", ":tabnew<CR>", { desc = "New tab" })
    map("n", "<leader>tc", ":tabclose<CR>", { desc = "Close current tab" })
    map("n", "<leader>to", ":tabonly<CR>", { desc = "Close all other tabs" })
    map("n", "<leader>tn", ":tabnext<CR>", { desc = "Next tab" })
    map("n", "<leader>tp", ":tabprevious<CR>", { desc = "Previous tab" })

    map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

    -- Ctrl+Backspace often arrives as <C-h> in tmux/terminals
    map("i", "<C-h>", "<C-w>", { desc = "Delete previous word" })
    map("i", "<C-BS>", "<C-w>", { desc = "Delete previous word" })

    map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

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
    map("n", "gl", vim.diagnostic.open_float, { desc = "Show Line Diagnostics" })
end
