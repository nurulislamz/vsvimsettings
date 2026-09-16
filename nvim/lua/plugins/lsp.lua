return {
    -- 1. LSPCONFIG & AUTOCOMPLETE
    {
        "neovim/nvim-lspconfig",
        cond = not vim.g.vscode,
        dependencies = {
            "mason-org/mason.nvim",
            "mason-org/mason-lspconfig.nvim",
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local dotnet_tools = vim.fn.expand("~/.dotnet/tools")
            if vim.fn.isdirectory(dotnet_tools) == 1 and not string.find(vim.env.PATH, dotnet_tools, 1, true) then
                vim.env.PATH = dotnet_tools .. ":" .. vim.env.PATH
            end

            local openjdk_home = "/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home"
            local openjdk_bin = openjdk_home .. "/bin"
            if vim.fn.executable(openjdk_bin .. "/java") == 1 then
                vim.env.JAVA_HOME = vim.env.JAVA_HOME or openjdk_home
                if not string.find(vim.env.PATH, openjdk_bin, 1, true) then
                    vim.env.PATH = openjdk_bin .. ":" .. vim.env.PATH
                end
            end

            require("mason").setup({
                registries = {
                    "github:mason-org/mason-registry",
                    "github:Crashdummyy/mason-registry",
                },
            })

            local lspconfig = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            local servers = {
                "lua_ls",
                "ts_ls",
                "gopls",
                "clangd",
                "rust_analyzer",
                "jdtls",
                "pyright",
            }

            require("mason-lspconfig").setup({
                ensure_installed = servers,
                automatic_enable = false,
            })

            -- Helper: find project virtualenv python executable by walking ancestors
            local function is_file(path)
                return vim.fn.filereadable(path) == 1
            end

            local function find_ancestor_with(start, names)
                local dir = start
                if not dir or dir == vim.NIL or dir == "" then
                    dir = vim.fn.getcwd()
                end
                while dir and dir ~= "/" do
                    for _, name in ipairs(names) do
                        local candidate = dir .. "/" .. name
                        if is_file(candidate) or vim.fn.isdirectory(candidate) == 1 then
                            return dir
                        end
                    end
                    local parent = vim.fn.fnamemodify(dir, ':h')
                    if parent == dir then break end
                    dir = parent
                end
                return nil
            end

            local function find_project_python(root)
                -- try to find nearest project root that contains a known marker
                local markers = { ".venv", "venv", "env", "pyproject.toml", "poetry.lock", "setup.cfg", "setup.py" }
                local project_root = find_ancestor_with(root, markers)

                -- If the server root didn't help, try from the current buffer's path
                if not project_root or project_root == nil then
                    local bufname = vim.api.nvim_buf_get_name(0)
                    if bufname and bufname ~= "" then
                        local bufdir = vim.fn.fnamemodify(bufname, ':h')
                        project_root = find_ancestor_with(bufdir, markers)
                    end
                end

                if project_root then
                    -- prefer local venv dirs
                    for _, v in ipairs({".venv", "venv", "env"}) do
                        local py = project_root .. "/" .. v .. "/bin/python"
                        if is_file(py) then
                            return py
                        end
                    end
                end

                -- fall back to VIRTUAL_ENV if set
                if vim.env.VIRTUAL_ENV and is_file(vim.env.VIRTUAL_ENV .. "/bin/python") then
                    return vim.env.VIRTUAL_ENV .. "/bin/python"
                end

                -- as a last resort, try to find in workspace-level .venv (current working dir)
                local ws_py = vim.fn.getcwd() .. "/.venv/bin/python"
                if is_file(ws_py) then return ws_py end

                -- fallback to system python3/python
                local py3 = vim.fn.exepath("python3")
                if py3 ~= "" then return py3 end
                return vim.fn.exepath("python")
            end

            -- pyright config to prefer project venv when present
            local pyright_config = {
                capabilities = capabilities,
                on_new_config = function(new_config, root_dir)
                    local python_path = find_project_python(root_dir)
                    new_config.settings = new_config.settings or {}
                    new_config.settings.python = new_config.settings.python or {}
                    if python_path then
                        new_config.settings.python.pythonPath = python_path
                    end
                end,
            }

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(event)
                    local opts = function(desc)
                        return { buffer = event.buf, desc = "LSP: " .. desc }
                    end

                    -- Clean up any Neovim 0.11+ buffer-local defaults that interfere with gr
                    pcall(vim.keymap.del, "n", "grr", { buffer = event.buf })
                    pcall(vim.keymap.del, "n", "gra", { buffer = event.buf })
                    pcall(vim.keymap.del, "n", "gri", { buffer = event.buf })
                    pcall(vim.keymap.del, "n", "grn", { buffer = event.buf })
                    pcall(vim.keymap.del, "n", "grt", { buffer = event.buf })

                    local smart_gd = require("config.keymaps").smart_goto_definition
                    vim.keymap.set("n", "gd", smart_gd or vim.lsp.buf.definition, opts("Go to Definition / References at Root"))
                    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts("Go to References (Submenu)"))
                    vim.keymap.set("n", "gi", function()
                        require("telescope.builtin").lsp_implementations({ reuse_win = true })
                    end, opts("Go to Implementation"))
                    vim.keymap.set("n", "gy", function()
                        require("telescope.builtin").lsp_type_definitions({ reuse_win = true })
                    end, opts("Go to Type Definition"))
                    vim.keymap.set("n", "<leader>gr", function()
                        require("telescope.builtin").lsp_references()
                    end, opts("Go to References (Telescope)"))
                    vim.keymap.set("n", "<leader>gd", function()
                        require("telescope.builtin").lsp_definitions({ reuse_win = true })
                    end, opts("Go to Definition (Telescope)"))
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("Hover Documentation"))
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts("Rename Symbol"))
                    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts("Code Action"))
                    vim.keymap.set("n", "gl", vim.diagnostic.open_float, opts("Show Line Diagnostics"))
                end,
            })

            -- Use native nvim 0.11 API for lua_ls
            if vim.lsp.config then
                local dotnet10 = "/opt/homebrew/opt/dotnet/libexec/dotnet"
                local roslyn_dll = vim.fn.stdpath("data") ..
                    "/mason/packages/roslyn/libexec/Microsoft.CodeAnalysis.LanguageServer.dll"
                if vim.fn.executable(dotnet10) == 1 and vim.fn.filereadable(roslyn_dll) == 1 then
                    vim.lsp.config("roslyn", {
                        capabilities = capabilities,
                        cmd = { dotnet10, roslyn_dll, "--stdio" },
                    })
                else
                    vim.lsp.config("roslyn", { capabilities = capabilities })
                end

                -- Configure pyright to prefer project venv when available
                vim.lsp.config("pyright", pyright_config)

                for _, server in ipairs(servers) do
                    if server ~= "pyright" then
                        vim.lsp.config(server, { capabilities = capabilities })
                        vim.lsp.enable(server)
                    else
                        -- ensure pyright enabled
                        vim.lsp.enable("pyright")
                    end
                end
                -- Explicitly disable omnisharp to avoid interference with easy-dotnet
                vim.lsp.config("omnisharp", { autostart = false })
            else
                local lspconfig = require("lspconfig")
                for _, server in ipairs(servers) do
                    if server == "pyright" then
                        lspconfig.pyright.setup(pyright_config)
                    else
                        lspconfig[server].setup({ capabilities = capabilities })
                    end
                end
                -- Explicitly disable omnisharp to avoid interference with easy-dotnet
                lspconfig.omnisharp.setup({ autostart = false })
            end

            -- Autocompletion Setup
            local cmp = require("cmp")

            -- AI (neocursor OR copilot) uses inline ghost text + Tab/CR accept.
            -- nvim-cmp stays for LSP/snippets/buffer/path only.
            local function accept_ai_or_cmp(fallback)
                if vim.g.ai_neocursor then
                    local ok, neocursor = pcall(require, "neocursor")
                    if ok and neocursor.accept and neocursor.accept() then
                        return
                    end
                elseif vim.g.ai_copilot then
                    local ok, suggestion = pcall(require, "copilot.suggestion")
                    if ok and suggestion.is_visible() then
                        suggestion.accept()
                        return
                    end
                end
                if cmp.visible() then
                    cmp.confirm({ select = true })
                else
                    fallback()
                end
            end

            cmp.setup({
                snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<Tab>"] = cmp.mapping(accept_ai_or_cmp, { "i", "s" }),
                    ["<CR>"] = cmp.mapping(accept_ai_or_cmp, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                }),
            })

            -- Cmdline setup for "/" and "?"
            cmp.setup.cmdline({ "/", "?" }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = { { name = "buffer" } }
            })

            -- Cmdline setup for ":"
            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = "path" }
                }, {
                    { name = "cmdline" }
                }),
                matching = { disallow_symbol_nonprefix_matching = false }
            })

            -- Auto-show diagnostic float when cursor rests on a line with an error
            vim.o.updatetime = 500
            vim.api.nvim_create_autocmd("CursorHold", {
                callback = function()
                    vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
                end,
            })

            vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
        end
    }
}