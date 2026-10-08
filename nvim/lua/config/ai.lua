-- AI completion provider selection for Neovim.
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

vim.g.ai_neocursor = mode == "neocursor"
vim.g.ai_copilot = mode == "copilot"
