-- AI completion for terminal Neovim (not vscode-neovim / Cursor embed).
-- Exactly one provider: "neocursor" | "copilot" | "off"
-- Default: neocursor. Override with vim.g.ai_completion or NVIM_AI_COMPLETION.
local mode = tostring(vim.g.ai_completion or vim.env.NVIM_AI_COMPLETION or "neocursor")

if mode == "both" then
  -- Legacy value: pick one. Prefer neocursor.
  mode = "neocursor"
end

if mode ~= "neocursor" and mode ~= "copilot" and mode ~= "off" then
  mode = "neocursor"
end

vim.g.ai_completion = mode

-- Host owns AI inside Cursor/VS Code embed.
vim.g.ai_neocursor = (not vim.g.vscode) and mode == "neocursor"
vim.g.ai_copilot = (not vim.g.vscode) and mode == "copilot"
