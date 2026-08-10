-- AI inline/completion provider for terminal Neovim (not VS Code / Cursor embed).
-- Values: "neocursor" | "copilot" | "both" | "off"
-- Default "both": Cursor ghost text via neocursor + Copilot cmp/chat plugins.
-- Override: set vim.g.ai_completion before this file, or NVIM_AI_COMPLETION env.
vim.g.ai_completion = vim.g.ai_completion or vim.env.NVIM_AI_COMPLETION or "both"

local mode = tostring(vim.g.ai_completion)

-- In vscode-neovim / Cursor, the host owns AI completion - keep both off.
vim.g.ai_neocursor = (not vim.g.vscode) and (mode == "neocursor" or mode == "both")
vim.g.ai_copilot = (not vim.g.vscode) and (mode == "copilot" or mode == "both")
