local map = vim.keymap.set
local smart_goto_definition = nil

local function rename_symbol()
  return ":IncRename " .. vim.fn.expand("<cword>")
end

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
map("v", "<C-c>", '"+y', { desc = "Copy selection to clipboard" })

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

-- Neovim paste-buffer picker
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

do
    map("n", "<leader>e", function()
      local snacks = require("snacks")
      local explorer = snacks.picker.get({ source = "explorer" })[1]
      if explorer then
        explorer:close()
      else
        snacks.explorer()
      end
    end, { desc = "Toggle File Explorer (Snacks)" })

    map("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory (Oil)" })

    -- Custom Unified Window/Buffer Management (Tmux Synergy)
    map("n", "<leader>v", "<C-w>v", { desc = "Split window vertically" })
    map("n", "<leader>_", "<C-w>v", { desc = "Split window vertically (tmux)" })
    map("n", "<leader>|", "<C-w>v", { desc = "Split window vertically" })
    map("n", "<leader>-", "<C-w>s", { desc = "Split window horizontally" })
    local function close_current_buffer()
      if vim.bo.buftype == "quickfix" then
        vim.cmd("cclose")
      elseif vim.bo.filetype == "trouble" then
        vim.cmd("Trouble close")
      elseif vim.bo.filetype == "oil" then
        require("oil").close()
      elseif vim.bo.buftype == "terminal" then
        vim.cmd("bd!")
      else
        require("snacks").bufdelete()
      end
    end
    map("n", "<leader>q", close_current_buffer, { desc = "Close current buffer or submenu" })
    map("n", "<leader>Q", close_current_buffer, { desc = "Close current buffer or submenu" })

    -- Space-p: Search through paste buffer (registers & clipboard history)
    map("n", "<leader>p", search_paste_buffer, { desc = "Search paste buffer" })

    -- Tabs (Scott McKendry convention)
    map("n", "<leader><tab><tab>", ":tabnew<cr>", { desc = "New Tab" })
    map("n", "<leader><tab>d", ":tabclose<cr>", { desc = "Close Tab" })
    map("n", "<leader><tab>l", ":tabnext<cr>", { desc = "Next Tab" })
    map("n", "<leader><tab>h", ":tabprevious<cr>", { desc = "Previous Tab" })
    map("n", "<leader>d", function()
      if vim.fn.tabpagenr("$") > 1 then
        pcall(vim.cmd, "tabnext #")
      else
        pcall(vim.cmd, "b#")
      end
    end, { desc = "Toggle last two tabs/buffers" })

    -- Toggles (via Snacks)
    local snacks = require("snacks")

    snacks.toggle({
      name = "Autoformat (on save)",
      get = function() return not vim.g.disable_autoformat end,
      set = function(state) vim.g.disable_autoformat = not state end,
    }):map("<leader>ts")

    -- Cursor Autocomplete toggle (replaces Copilot toggle with Cursor sidecar)
    snacks.toggle({
      name = "Cursor Autocomplete",
      get = function() return vim.g.ai_completion ~= "off" and vim.g.ai_neocursor end,
      set = function(state)
        if state then
          vim.g.ai_completion = "neocursor"
          vim.g.ai_neocursor = true
          vim.notify("Cursor Autocomplete enabled", vim.log.levels.INFO, { title = "AI" })
        else
          vim.g.ai_completion = "off"
          vim.g.ai_neocursor = false
          pcall(function() require("neocursor").dismiss() end)
          vim.notify("Cursor Autocomplete disabled", vim.log.levels.INFO, { title = "AI" })
        end
      end,
    }):map("<leader>tc")

    snacks.toggle.diagnostics():map("<leader>td")
    snacks.toggle.line_number():map("<leader>tl")
    snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>tL")
    snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>tw")
    snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>tS")
    snacks.toggle.inlay_hints():map("<leader>th")
    snacks.toggle.treesitter():map("<leader>tT")
    snacks.toggle.option("conceallevel", { off = 0, on = 2 }):map("<leader>tC")

    -- Toggle Menu (<leader>tm)
    map("n", "<leader>tm", function()
      local items = {}
      for _, t in pairs(snacks.toggle.toggles) do
        local state = t:get()
        table.insert(items, {
          text = string.format("%s %-5s %s", state and " " or " ", state and "[ON]" or "[OFF]", t.opts.name),
          toggle = t,
        })
      end
      table.sort(items, function(a, b) return a.toggle.opts.name < b.toggle.opts.name end)
      snacks.picker({
        title = "Toggle Menu",
        layout = "select",
        items = items,
        confirm = function(picker, item)
          picker:close()
          if item and item.toggle then
            item.toggle:toggle()
          end
        end,
      })
    end, { desc = "Toggle Menu (All States)" })

    -- Snacks Pickers
    map("n", "<leader>ff", function() snacks.picker.smart({ hidden = true }) end, { desc = "Smart find files (all)" })
    map("n", "<leader>fr", function() snacks.picker.recent() end, { desc = "Fuzzy find recent files" })
    map("n", "<leader>fs", function() snacks.picker.grep() end, { desc = "Find string in CWD" })
    map("n", "<leader>fc", function() snacks.picker.grep_word() end, { desc = "Find word under cursor" })
    map("n", "<leader>fh", function() snacks.picker.help() end, { desc = "Find help tags" })

    -- Snacks Ergonomics & Tools
    map("n", "<leader>z", function() snacks.zen() end, { desc = "Zen mode" })
    map("n", "<leader>.", function() snacks.scratch() end, { desc = "Toggle Scratch Buffer" })
    map("n", "<leader>cb", function() snacks.gitbrowse() end, { desc = "Git Browse" })
    map("n", "<leader>cg", function() snacks.lazygit() end, { desc = "Lazygit" })
    map("n", "<leader>cs", function() snacks.picker.git_status() end, { desc = "Git Status (changed files)" })
    map("n", "<leader>cD", function() snacks.picker.git_diff() end, { desc = "Git Diff" })
    map("n", "<leader>cq", "<cmd>Gitsigns setqflist target=all<cr>", { desc = "Git diff to quickfix / Trouble" })
    map({ "n", "t" }, "<C-\\>", function() snacks.terminal() end, { desc = "Toggle Terminal" })

    map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

    -- Ctrl+Backspace often arrives as <C-h> in tmux/terminals
    map("i", "<C-h>", "<C-w>", { desc = "Delete previous word" })
    map("i", "<C-BS>", "<C-w>", { desc = "Delete previous word" })

    map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
    -- Navigate between splits from terminal mode.
    map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Move to left window" })
    map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Move to lower window" })
    map("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Move to upper window" })
    map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Move to right window" })
    local function scroll_terminal_line(direction)
      local motion = direction == "down" and "<C-e>" or "<C-y>"
      local keys = "<C-\\><C-n>" .. motion
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
    end
    -- Some terminals deliver Alt as a separate Escape followed by the key.
    map("t", "<M-j>", function() scroll_terminal_line("down") end, { desc = "Scroll terminal down 1 line" })
    map("t", "<M-k>", function() scroll_terminal_line("up") end, { desc = "Scroll terminal up 1 line" })
    map("t", "<Esc>j", function() scroll_terminal_line("down") end, { desc = "Scroll terminal down 1 line" })
    map("t", "<Esc>k", function() scroll_terminal_line("up") end, { desc = "Scroll terminal up 1 line" })

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
    map("n", "<leader>rn", rename_symbol, { expr = true, desc = "Rename Symbol" })
    map({ "n", "x" }, "ga", vim.lsp.buf.code_action, { desc = "Code Action" })
    map("n", "gl", vim.diagnostic.open_float, { desc = "Show Line Diagnostics" })

    -- Hidden buffers can be LSP dependencies; refresh them while idle too.
    local function check_buffer_time(buf)
      if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
        vim.cmd("checktime " .. buf)
      end
    end

    vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
      callback = function(event)
        if vim.fn.mode() == "c" then return end
        vim.schedule(function()
          if event.event == "FocusGained" or event.event == "CursorHold" or event.event == "CursorHoldI" then
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              check_buffer_time(buf)
            end
          else
            check_buffer_time(event.buf)
          end
        end)
      end,
    })

    -- Coalesce Pyright refreshes when several external edits reload together.
    local reload_seq = 0
    vim.api.nvim_create_autocmd("FileChangedShellPost", {
      callback = function(event)
        if vim.bo[event.buf].filetype ~= "python" then return end
        reload_seq = reload_seq + 1
        local seq = reload_seq
        vim.defer_fn(function()
          if seq ~= reload_seq then return end
          for _, client in ipairs(vim.lsp.get_clients({ name = "pyright" })) do
            client:notify("workspace/didChangeConfiguration", { settings = client.config.settings })
          end
        end, 150)
      end,
    })
    map("n", "<leader>lr", "<cmd>LspRestart<CR>", { desc = "Restart LSP server" })


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
        if ft ~= "codediff-explorer" and ft ~= "oil" and not ft:find("^snacks_") then
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
  rename_symbol = rename_symbol,
}
