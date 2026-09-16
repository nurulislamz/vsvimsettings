vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.clipboard = "" -- Yanks sync to clipboard via autocmd; deletions stay in Vim paste buffer
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true
opt.mouse = "a"
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.signcolumn = "yes"
opt.cursorline = true
opt.lazyredraw = true
opt.updatetime = 300
opt.timeoutlen = 500
opt.conceallevel = 2

-- Ensure user tools (e.g. dotnet tools, local bin) are in PATH
local dotnet_tools = vim.fn.expand("~/.dotnet/tools")
if vim.fn.isdirectory(dotnet_tools) == 1 and not vim.env.PATH:find(dotnet_tools, 1, true) then
  vim.env.PATH = dotnet_tools .. ":" .. vim.env.PATH
end

-- Sync yanks (and only yanks) to system clipboard and tmux buffer
-- Deletions (d, x, c) remain in Vim registers (paste buffer) and do NOT overwrite system clipboard
local yank_sync_group = vim.api.nvim_create_augroup("YankClipboardSync", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  group = yank_sync_group,
  desc = "Sync yanks to system clipboard and tmux buffer",
  callback = function()
    if vim.v.event.operator == "y" then
      pcall(vim.fn.setreg, "+", vim.fn.getreg('"'), vim.fn.getregtype('"'))
      if vim.env.TMUX ~= nil then
        local text = table.concat(vim.v.event.regcontents, "\n")
        if #text > 0 then
          pcall(vim.fn.system, { "tmux", "load-buffer", "-" }, text)
        end
      end
    end
  end,
})

-- Markdown options (recommended by Markview: nowrap ensures wide tables render)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = false
    vim.opt_local.conceallevel = 2
  end,
})
