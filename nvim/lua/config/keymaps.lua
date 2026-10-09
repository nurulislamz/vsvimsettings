local map = vim.keymap.set

local function rename_symbol()
    return ":IncRename " .. vim.fn.expand("<cword>")
end

-- Clear search highlights with Esc or <leader>nh
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
map("n", "<leader>nh", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

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
    map("n", '<leader>"', "<cmd>split<CR>", { desc = "Split horizontal" })
    map("n", "<leader>%", "<cmd>vsplit<CR>", { desc = "Split vertical" })

    local function normal_wins()
        local wins = {}
        for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.api.nvim_win_get_config(w).relative == "" then
                table.insert(wins, w)
            end
        end
        return wins
    end

    -- tmux prefix+x: kill pane; last pane in tab → tabclose; last tab → no-op
    local function kill_pane()
        if #normal_wins() > 1 then
            pcall(vim.cmd, "close")
            return
        end
        if vim.fn.tabpagenr("$") > 1 then
            pcall(vim.cmd, "tabclose")
            return
        end
    end

    map("n", "<leader>q", "<C-w>q", { desc = "Quit window (Ctrl-w q)" })
    map("n", "<leader>x", kill_pane, { desc = "Kill pane (tmux x)" })

    -- Tabs (Scott McKendry convention)
    map("n", "<leader><tab><tab>", ":tabnew<cr>", { desc = "New Tab" })
    map("n", "<leader><tab>l", ":tabnext<cr>", { desc = "Next Tab" })
    map("n", "<leader><tab>h", ":tabprevious<cr>", { desc = "Previous Tab" })
    map("n", "<leader><tab>o", function()
        if vim.fn.tabpagenr("$") > 1 then
            pcall(vim.cmd, "tabonly")
        end
    end, { desc = "Close all other tabs" })
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

    local disabled_lsp_configs = {}
    snacks.toggle({
        name = "LSP",
        get = function()
            if vim.g.lsp_disabled ~= nil then
                return not vim.g.lsp_disabled
            end
            return #vim.lsp.get_clients() > 0 or (vim.lsp._enabled_configs and next(vim.lsp._enabled_configs) ~= nil)
        end,
        set = function(state)
            vim.g.lsp_disabled = not state
            if not state then
                local configs = {}
                if vim.lsp._enabled_configs then
                    for name in pairs(vim.lsp._enabled_configs) do
                        table.insert(configs, name)
                    end
                end
                if #configs > 0 then
                    disabled_lsp_configs = configs
                    pcall(vim.lsp.enable, configs, false)
                end
                for _, client in ipairs(vim.lsp.get_clients()) do
                    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                        if vim.api.nvim_buf_is_loaded(buf) then
                            pcall(vim.lsp.buf_detach_client, buf, client.id)
                        end
                    end
                    pcall(function() client:stop() end)
                end
            else
                if #disabled_lsp_configs > 0 then
                    pcall(vim.lsp.enable, disabled_lsp_configs, true)
                elseif vim.lsp.config and vim.lsp.config._configs then
                    local all_configs = {}
                    for name in pairs(vim.lsp.config._configs) do
                        table.insert(all_configs, name)
                    end
                    pcall(vim.lsp.enable, all_configs, true)
                end
                vim.cmd.doautoall("FileType")
            end
        end,
    }):map("<leader>tp")

    -- LSP Word Reference Highlight
    snacks.toggle.words():map("<leader>tW")

    -- Whitespace and Search UI options
    snacks.toggle.option("list", { name = "Whitespace Chars" }):map("<leader>tI")
    snacks.toggle.option("hlsearch", { name = "Search Highlight" }):map("<leader>tH")

    -- Git Blame & Gutter Signs
    snacks.toggle({
        name = "Git Line Blame",
        get = function()
            local ok, cfg = pcall(function() return require("gitsigns.config").config end)
            return ok and cfg and cfg.current_line_blame or false
        end,
        set = function(state)
            local ok, gs = pcall(require, "gitsigns")
            if ok then
                local cfg = require("gitsigns.config").config
                if cfg.current_line_blame ~= state then
                    gs.toggle_current_line_blame()
                end
            end
        end,
    }):map("<leader>tb")

    snacks.toggle({
        name = "Git Signs (Gutter)",
        get = function()
            local ok, cfg = pcall(function() return require("gitsigns.config").config end)
            return ok and cfg and cfg.signcolumn or false
        end,
        set = function(state)
            local ok, gs = pcall(require, "gitsigns")
            if ok then
                local cfg = require("gitsigns.config").config
                if cfg.signcolumn ~= state then
                    gs.toggle_signs()
                end
            end
        end,
    }):map("<leader>tG")

    -- Auto Save
    snacks.toggle({
        name = "Auto Save",
        get = function()
            local ok, as = pcall(require, "auto-save")
            return ok and as.enabled() or false
        end,
        set = function(state)
            local ok, as = pcall(require, "auto-save")
            if ok and as.enabled() ~= state then
                as.toggle()
            end
        end,
    }):map("<leader>ta")

    -- Smear Cursor
    snacks.toggle({
        name = "Smear Cursor",
        get = function()
            local ok, sc = pcall(require, "smear_cursor")
            return ok and sc.enabled or false
        end,
        set = function(state)
            local ok, sc = pcall(require, "smear_cursor")
            if ok and sc.enabled ~= state then
                sc.toggle()
            end
        end,
    }):map("<leader>tu")

    -- Toggle Menu (<leader>tm)
    map("n", "<leader>tm", function()
        local items = {}
        for _, t in pairs(snacks.toggle.toggles) do
            local state = t:get()
            table.insert(items, {
                text = string.format("%s %s %s", state and "[ON]" or "[OFF]", state and "on" or "off", t.opts.name),
                name = t.opts.name,
                state = state,
                toggle = t,
            })
        end
        table.sort(items, function(a, b) return a.name < b.name end)
        snacks.picker({
            title = "Toggle Menu (<CR> toggle, <Esc> exit)",
            layout = "select",
            items = items,
            format = function(item)
                local icon = item.state and " " or " "
                local status = item.state and "[ON] " or "[OFF]"
                local hl = item.state and "DiagnosticOk" or "DiagnosticWarn"
                return {
                    { icon .. status .. " ", hl },
                    { item.name,             "Normal" },
                }
            end,
            actions = {
                toggle = function(picker, item)
                    item = item or picker:current()
                    if item and item.toggle then
                        item.toggle:toggle()
                        item.state = item.toggle:get()
                        item.text = string.format("%s %s %s", item.state and "[ON]" or "[OFF]",
                            item.state and "on" or "off", item.name)
                        picker.list.dirty = true
                        picker.list:render()
                    end
                end,
                toggle_close = function(picker, item)
                    item = item or picker:current()
                    if item and item.toggle then
                        item.toggle:toggle()
                    end
                    picker:close()
                end,
            },
            confirm = "toggle",
            win = {
                input = {
                    keys = {
                        ["<CR>"] = { "toggle", mode = { "n", "i" } },
                        ["<Tab>"] = { "toggle", mode = { "n", "i" } },
                        ["<S-CR>"] = { "toggle_close", mode = { "n", "i" } },
                    },
                },
                list = {
                    keys = {
                        ["<CR>"] = "toggle",
                        ["<Tab>"] = "toggle",
                        ["<Space>"] = "toggle",
                        ["<S-CR>"] = "toggle_close",
                    },
                },
            },
        })
    end, { desc = "Toggle Menu (All States)" })

    -- Snacks Pickers
    map("n", "<leader>ff", function() snacks.picker.smart({ hidden = true }) end, { desc = "Smart find files (all)" })
    map("n", "<leader>fr", function() snacks.picker.recent() end, { desc = "Fuzzy find recent files" })
    map("n", "<leader>fs", function() snacks.picker.grep() end, { desc = "Find string in CWD" })
    map("n", "<leader>fc", function() snacks.picker.grep_word() end, { desc = "Find word under cursor" })

    -- Snacks Ergonomics & Tools
    map("n", "<leader>z", function() snacks.zen() end, { desc = "Zen mode" })
    map("n", "<leader>.", function() snacks.scratch() end, { desc = "Toggle Scratch Buffer" })
    map("n", "<leader>cb", function() snacks.gitbrowse() end, { desc = "Git Browse" })
    map("n", "<leader>cg", function() snacks.lazygit() end, { desc = "Lazygit" })
    map("n", "<leader>cs", function() snacks.picker.git_status() end, { desc = "Git Status (changed files)" })
    map("n", "<leader>cD", function() snacks.picker.git_diff() end, { desc = "Git Diff" })
    map("n", "<leader>cq", "<cmd>Gitsigns setqflist target=all<cr>", { desc = "Git diff to quickfix / Trouble" })
    map({ "n", "t" }, "<C-\\>", function() snacks.terminal() end, { desc = "Toggle Terminal" })

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
            vim.keymap.set("n", "<CR>", function() qf_jump(true) end,
                { buffer = event.buf, desc = "Preview reference (stay in submenu)" })
            vim.keymap.set("n", "<2-LeftMouse>", function() qf_jump(true) end,
                { buffer = event.buf, desc = "Preview reference (stay in submenu)" })

            -- o: jump to reference and close submenu immediately
            vim.keymap.set("n", "o", function()
                qf_jump(false)
                vim.cmd("cclose")
            end, { buffer = event.buf, desc = "Jump to reference and close submenu" })

            -- <leader>q (Space+q) or q: close the submenu
            vim.keymap.set("n", "<leader>q", function() vim.cmd("cclose") end,
                { buffer = event.buf, desc = "Close submenu" })
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

    map("n", "gd", "<cmd>Glance definitions<CR>", { desc = "Smart Go-to-Definition (Glance)" })
    map("n", "gr", "<cmd>Glance references<CR>", { desc = "Go to References (Glance)" })
    map("n", "gi", "<cmd>Glance implementations<CR>", { desc = "Go to Implementation (Glance)" })
    map("n", "gy", "<cmd>Glance type_definitions<CR>", { desc = "Go to Type Definition (Glance)" })

    map("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
    map("n", "<leader>rn", rename_symbol, { expr = true, desc = "Rename Symbol" })
    map({ "n", "x" }, "ga", vim.lsp.buf.code_action, { desc = "Code Action" })
    map("n", "gl", vim.diagnostic.open_float, { desc = "Show Line Diagnostics" })
    map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
    map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })

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
                for _, client in ipairs(vim.lsp.get_clients()) do
                    if client.name == "pyright" or client.name == "basedpyright" then
                        client:notify("workspace/didChangeConfiguration", { settings = client.config.settings })
                    end
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

    -- Command-line abbreviation: typing lowercase :codediff expands to :CodeDiff
    vim.cmd(
    [[cnoreabbrev <expr> codediff (getcmdtype() == ':' && getcmdline() =~ '^codediff') ? 'CodeDiff' : 'codediff']])

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

    vim.api.nvim_create_user_command("ToggleScrollBind", toggle_scrollbind,
        { desc = "Toggle synchronized scrolling across diff panes" })
end
