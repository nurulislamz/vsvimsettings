local map = vim.keymap.set
local smart_goto_definition = nil

-- Clear search highlights with Esc or <leader>nh
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
map("n", "<leader>nh", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- ==========================================
-- Clipboard & Paste Buffer Management
-- "p should paste the clipboard always. space + p would allow me to search through the paste buffer"
-- ==========================================
map("n", "p", '"+p', { desc = "Paste clipboard after cursor" })
map("n", "P", '"+P', { desc = "Paste clipboard before cursor" })
map("x", "p", '"_d"+P', { desc = "Paste clipboard over selection (keep clipboard)" })
map("x", "P", '"_d"+P', { desc = "Paste clipboard over selection (keep clipboard)" })

-- ==========================================
-- Smart Delete: route to clipboard or black hole
-- Normal deletes → clipboard (so p pastes them back).
-- Empty-line dd and single-char x/X → black hole (don't pollute clipboard).
-- ==========================================
map("n", "x", '"_x', { desc = "Delete char to black hole" })
map("n", "X", '"_X', { desc = "Backspace char to black hole" })

map("n", "dd", function()
  if vim.api.nvim_get_current_line():match("^%s*$") then
    return '"_dd'
  else
    return '"+dd'
  end
end, { expr = true, desc = "Smart delete line (empty → black hole, else → clipboard)" })

map("n", "d", '"+d', { desc = "Delete motion to clipboard" })
map("n", "D", '"+D', { desc = "Delete to EOL to clipboard" })
map("x", "d", '"+d', { desc = "Delete selection to clipboard" })

-- Shared paste-buffer picker (used by both VSCode and terminal Neovim)
local function search_paste_buffer()
  local registers = { '"', "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+" }
  local items = {}
  local seen = {}
  for _, reg in ipairs(registers) do
    local content = vim.fn.getreg(reg)
    if content and content:match("%S") and not seen[content] then
      seen[content] = true
      local preview = content:gsub("[\r\n]+", " "):sub(1, 80)
      local label = string.format("[%s] %s", reg, preview)
      table.insert(items, { reg = reg, label = label, content = content })
    end
  end

  if #items == 0 then
    vim.notify("Paste buffer is empty", vim.log.levels.INFO, { title = "Paste Buffer" })
    return
  end

  local labels = {}
  for _, item in ipairs(items) do
    table.insert(labels, item.label)
  end

  vim.ui.select(labels, { prompt = "Search Paste Buffer:" }, function(choice)
    if not choice then return end
    for _, item in ipairs(items) do
      if item.label == choice then
        local lines = vim.split(item.content, "\n", { plain = true })
        if #lines > 1 and lines[#lines] == "" then table.remove(lines) end
        local regtype = vim.fn.getregtype(item.reg)
        vim.api.nvim_put(lines, regtype == "V" and "l" or "c", true, true)
        break
      end
    end
  end)
end

if vim.g.vscode then
    local vscode = require('vscode')

    -- File Explorer (Reveal active file in VS Code sidebar)
    map("n", "<leader>e", function() vscode.action("workbench.files.action.showActiveFileInExplorer") end, { desc = "Reveal File in Explorer" })

    -- Window/Buffer Management (VS Code equivalent)
    map("n", "<leader>v", function() vscode.action("workbench.action.splitEditor") end, { desc = "Split window vertically" })
    map("n", "<leader>-", function() vscode.action("workbench.action.splitEditorOrthogonal") end, { desc = "Split window horizontally" })
    map("n", "<leader>c", function() vscode.action("workbench.action.files.newUntitledFile") end, { desc = "Create new buffer" })
    map("n", "<leader>q", function() vscode.action("workbench.action.closeActiveEditor") end, { desc = "Close current buffer" })
    map("n", "<leader>bn", function() vscode.action("workbench.action.nextEditor") end, { desc = "Next buffer" })
    map("n", "<leader>bp", function() vscode.action("workbench.action.previousEditor") end, { desc = "Previous buffer" })

    -- Space-p: Search through paste buffer (registers & clipboard history)
    map("n", "<leader>p", search_paste_buffer, { desc = "Search paste buffer" })

    map({ "i", "x", "n", "s" }, "<C-s>", function() vscode.action("workbench.action.files.save") end, { desc = "Save file" })

    -- LSP Navigation
    map("n", "gd", function() vscode.action("editor.action.revealDefinition") end, { desc = "Go to Definition" })
    map("n", "gr", function() vscode.action("editor.action.goToReferences") end, { desc = "Go to References" })
    map("n", "gi", function() vscode.action("editor.action.goToImplementation") end, { desc = "Go to Implementation" })
    map("n", "K", function() vscode.action("editor.action.showHover") end, { desc = "Hover Documentation" })
    map("n", "<leader>rn", function() vscode.action("editor.action.rename") end, { desc = "Rename Symbol" })
    map("n", "<leader>ca", function() vscode.action("editor.action.quickFix") end, { desc = "Code Action" })
else
    map("n", "<leader>e", function()
      local api = require("nvim-tree.api")
      if vim.bo.filetype == "NvimTree" then
        api.tree.close()
      else
        api.tree.find_file({ open = true, focus = true })
      end
    end, { desc = "Toggle / Focus File Explorer at Current File" })

    -- Custom Unified Window/Buffer Management (Tmux Synergy)
    map("n", "<leader>v", "<C-w>v", { desc = "Split window vertically" })
    map("n", "<leader>-", "<C-w>s", { desc = "Split window horizontally" })
    map("n", "<leader>c", ":enew<CR>", { desc = "Create new buffer" })
    map("n", "<leader>q", function()
      if vim.bo.buftype == "quickfix" then
        vim.cmd("cclose")
      elseif vim.bo.filetype == "trouble" then
        vim.cmd("Trouble close")
      elseif vim.bo.filetype == "NvimTree" then
        require("nvim-tree.api").tree.close()
      else
        vim.cmd("bd")
      end
    end, { desc = "Close current buffer or submenu" })
    map("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
    map("n", "<leader>bp", ":bprev<CR>", { desc = "Previous buffer" })

    -- Space-p: Search through paste buffer (registers & clipboard history)
    map("n", "<leader>p", search_paste_buffer, { desc = "Search paste buffer" })

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
    -- Unmap conflicting Neovim 0.11+ built-in global LSP maps (grr, gra, gri, grn, grt)
    -- to prevent delay when pressing 'gr' and avoid duplicate/fragmented navigation.
    pcall(vim.keymap.del, "n", "grr")
    pcall(vim.keymap.del, "n", "gra")
    pcall(vim.keymap.del, "n", "gri")
    pcall(vim.keymap.del, "n", "grn")
    pcall(vim.keymap.del, "n", "grt")
    pcall(vim.keymap.del, "x", "gra")

    local function lsp_or_fallback(action_fn, fallback_fn)
      return function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients > 0 then
          action_fn()
        elseif fallback_fn then
          fallback_fn()
        else
          vim.notify("No active LSP client for current buffer", vim.log.levels.WARN, { title = "LSP" })
        end
      end
    end

    -- Quickfix reference preview namespace
    local qf_ns = vim.api.nvim_create_namespace("qf_reference_preview")

    -- Enhance Quickfix submenu navigation:
    -- Enter / click jumps to & highlights the reference while keeping cursor in the submenu.
    -- Space+q or q closes the submenu and stays at your chosen reference in the file.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "qf",
      callback = function(event)
        local function qf_jump(stay_in_qf)
          local qf_win = vim.api.nvim_get_current_win()
          local lnum = vim.api.nvim_win_get_cursor(0)[1]

          local ok, _ = pcall(vim.cmd, lnum .. "cc")
          if not ok then return end

          local target_win = vim.api.nvim_get_current_win()
          if target_win ~= qf_win then
            vim.cmd("normal! zz")
            local target_buf = vim.api.nvim_win_get_buf(target_win)
            local cursor = vim.api.nvim_win_get_cursor(target_win)
            local line_idx = cursor[1] - 1

            vim.api.nvim_buf_clear_namespace(target_buf, qf_ns, 0, -1)
            pcall(vim.hl.range, target_buf, qf_ns, "IncSearch", { line_idx, 0 }, { line_idx, -1 }, {
              timeout = 1500,
            })
          end

          if stay_in_qf and vim.api.nvim_win_is_valid(qf_win) then
            vim.api.nvim_set_current_win(qf_win)
          end
        end

        -- Enter / Double Click: jump to reference & highlight, keep cursor in submenu
        vim.keymap.set("n", "<CR>", function() qf_jump(true) end, { buffer = event.buf, desc = "Preview reference (stay in submenu)" })
        vim.keymap.set("n", "<2-LeftMouse>", function() qf_jump(true) end, { buffer = event.buf, desc = "Preview reference (stay in submenu)" })

        -- o: jump to reference and close submenu immediately
        vim.keymap.set("n", "o", function()
          qf_jump(false)
          vim.cmd("cclose")
        end, { buffer = event.buf, desc = "Jump to reference and close submenu" })

        -- <leader>q (Space+q) or q: close the submenu
        vim.keymap.set("n", "<leader>q", function() vim.cmd("cclose") end, { buffer = event.buf, desc = "Close submenu" })
        vim.keymap.set("n", "q", function() vim.cmd("cclose") end, { buffer = event.buf, desc = "Close submenu" })
      end,
    })

    -- Also close Trouble with <leader>q if open
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "trouble",
      callback = function(event)
        vim.keymap.set("n", "<leader>q", "<cmd>Trouble close<CR>", { buffer = event.buf, desc = "Close Trouble" })
      end,
    })

    -- Always use LSP for Definition & References
    -- gr opens the references submenu (quickfix) with stay-in-submenu navigation
    map("n", "gr", lsp_or_fallback(
      vim.lsp.buf.references
    ), { desc = "Go to References (LSP Submenu)" })

    -- Smart Go-to-Definition:
    -- Jumps to definition. If already at definition ("at the root"), automatically shows references (gr)!
    smart_goto_definition = function()
      local bufnr = vim.api.nvim_get_current_buf()
      local win = vim.api.nvim_get_current_win()
      local clients = vim.lsp.get_clients({ bufnr = bufnr })
      if #clients == 0 then
        vim.cmd("normal! gd")
        return
      end

      local current_cursor = vim.api.nvim_win_get_cursor(win)
      local current_lnum = current_cursor[1]
      local current_file = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
      local from = vim.fn.getpos(".")
      from[1] = bufnr
      local tagname = vim.fn.expand("<cword>")

      vim.lsp.buf.definition({
        on_list = function(options)
          if not options.items or #options.items == 0 then
            vim.notify("No definition found", vim.log.levels.INFO, { title = "LSP" })
            return
          end

          -- Check if the definition is at the current position (i.e. already at the root)
          local is_at_root = false
          if #options.items == 1 then
            local item = options.items[1]
            local item_file = item.filename and vim.fs.normalize(item.filename)
              or vim.fs.normalize(vim.api.nvim_buf_get_name(item.bufnr))
            if item_file == current_file and item.lnum == current_lnum then
              is_at_root = true
            end
          else
            local all_here = true
            for _, item in ipairs(options.items) do
              local item_file = item.filename and vim.fs.normalize(item.filename)
                or vim.fs.normalize(vim.api.nvim_buf_get_name(item.bufnr))
              if item_file ~= current_file or item.lnum ~= current_lnum then
                all_here = false
                break
              end
            end
            if all_here then
              is_at_root = true
            end
          end

          if is_at_root then
            -- Already at definition / root: trigger references (gr)
            vim.notify("Already at definition, showing references...", vim.log.levels.INFO, { title = "LSP" })
            vim.lsp.buf.references()
            return
          end

          if #options.items == 1 then
            local item = options.items[1]
            local b = item.bufnr or vim.fn.bufadd(item.filename)
            vim.bo[b].buflisted = true

            -- Record position in jumplist and tagstack for Ctrl-O / Ctrl-T
            vim.cmd("normal! m'")
            local tagstack = { { tagname = tagname, from = from } }
            vim.fn.settagstack(vim.fn.win_getid(win), { items = tagstack }, "t")

            if vim.api.nvim_win_get_buf(win) ~= b then
              vim.api.nvim_win_set_buf(win, b)
            end
            local col = math.max(0, (item.col or 1) - 1)
            local lnum = math.max(1, item.lnum or 1)
            vim.api.nvim_win_set_cursor(win, { lnum, col })
            vim.cmd("normal! zvzz")
          else
            -- Multiple definitions: open quickfix submenu
            vim.fn.setqflist({}, " ", options)
            vim.cmd("botright copen")
          end
        end,
      })
    end

    map("n", "gd", smart_goto_definition, { desc = "Go to Definition / References at Root" })

    map("n", "gi", lsp_or_fallback(
      function() require("telescope.builtin").lsp_implementations({ reuse_win = true }) end
    ), { desc = "Go to Implementation (LSP)" })

    map("n", "gy", lsp_or_fallback(
      function() require("telescope.builtin").lsp_type_definitions({ reuse_win = true }) end
    ), { desc = "Go to Type Definition (LSP)" })

    -- Telescope shortcuts if modal picker is ever desired
    map("n", "<leader>gr", function() require("telescope.builtin").lsp_references() end, { desc = "Telescope References" })
    map("n", "<leader>gd", function() require("telescope.builtin").lsp_definitions({ reuse_win = true }) end, { desc = "Telescope Definitions" })

    map("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
    map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
    map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
    map("n", "gl", vim.diagnostic.open_float, { desc = "Show Line Diagnostics" })

    -- Recover pyright after edits made outside nvim (agents, git, etc.):
    -- reload on-disk changes into buffers, and restart a stale server on demand.
    vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
      callback = function()
        if vim.fn.mode() ~= "c" then
          vim.cmd("checktime")
        end
      end,
    })

    -- After a buffer is reloaded from disk, nudge pyright to re-resolve its
    -- cross-file type cache (fixes stale "parameter not found" on imports).
    vim.api.nvim_create_autocmd("FileChangedShellPost", {
      callback = function()
        for _, client in ipairs(vim.lsp.get_clients({ name = "pyright" })) do
          client:notify("workspace/didChangeConfiguration", { settings = client.config.settings })
        end
      end,
    })
    map("n", "<leader>lr", "<cmd>LspRestart<CR>", { desc = "Restart LSP server" })

    -- Open file under cursor in new tab
    map("n", "<S-CR>", function()
      local cfile = vim.fn.expand("<cfile>")
      if cfile and cfile ~= "" then
        pcall(vim.cmd, "tabedit " .. vim.fn.fnameescape(cfile))
      end
    end, { desc = "Open file under cursor in new tab" })

    -- ==========================================
    -- Hot Reload & Instant Restart
    -- ==========================================
    local function reload_config()
      for k in pairs(package.loaded) do
        if k:match("^config%.") or k:match("^plugins%.") then
          package.loaded[k] = nil
        end
      end
      dofile(vim.env.MYVIMRC or (vim.fn.stdpath("config") .. "/init.lua"))
      vim.notify("Neovim configuration reloaded!", vim.log.levels.INFO, { title = "Config Reload" })
    end

    vim.api.nvim_create_user_command("ReloadConfig", reload_config, { desc = "Hot reload Neovim configuration" })
    map("n", "<leader><leader>r", reload_config, { desc = "Hot reload configuration" })
    map("n", "<leader><leader>R", "<cmd>restart<cr>", { desc = "Restart Neovim instance (0.12+)" })

    -- Command-line abbreviation: typing lowercase :codediff expands to :CodeDiff
    vim.cmd([[cnoreabbrev <expr> codediff (getcmdtype() == ':' && getcmdline() =~ '^codediff') ? 'CodeDiff' : 'codediff']])

    -- Toggle and resync scrollbind across diff windows
    local function toggle_scrollbind()
      local cur = vim.wo.scrollbind
      local new_val = not cur
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.bo[buf].filetype
        if ft ~= "codediff-explorer" and ft ~= "NvimTree" then
          vim.wo[win].scrollbind = new_val
        end
      end
      if new_val then
        vim.cmd("syncbind")
        vim.notify("Diff scroll locked (scrollbind ON)", vim.log.levels.INFO, { title = "ScrollBind" })
      else
        vim.notify("Diff scroll unlocked (scrollbind OFF)", vim.log.levels.INFO, { title = "ScrollBind" })
      end
    end

    vim.api.nvim_create_user_command("ToggleScrollBind", toggle_scrollbind, { desc = "Toggle synchronized scrolling across diff panes" })
    map("n", "<leader>sb", toggle_scrollbind, { desc = "Toggle synchronized scrolling (lock/unlock)" })
end

return {
  smart_goto_definition = smart_goto_definition,
}
