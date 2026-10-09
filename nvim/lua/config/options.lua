vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt
opt.autoread = true
opt.number = true
opt.relativenumber = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.wildignorecase = true
opt.wildoptions = { "pum", "tagfile", "fuzzy" }
opt.wildmode = "longest:full,full"
opt.termguicolors = true
opt.mouse = "a"
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.signcolumn = "yes"
opt.cursorline = true
opt.lazyredraw = false
opt.updatetime = 300
opt.timeoutlen = 500
opt.conceallevel = 2
opt.inccommand = "split"
if vim.fn.has("nvim-0.11") == 1 then
    opt.tabclose = "uselast"
end

-- Markdown options (recommended by Markview: nowrap ensures wide tables render)
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        vim.opt_local.wrap = false
        vim.opt_local.conceallevel = 2
    end,
})
