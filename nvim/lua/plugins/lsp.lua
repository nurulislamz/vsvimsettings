return {
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },
    -- 1. LSPCONFIG & AUTOCOMPLETE
    {
        "neovim/nvim-lspconfig",
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
            require("mason").setup()

            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            -- Neovim hardcodes didChangeWatchedFiles off on Linux (vim/lsp/protocol.lua),
            -- even though the inotify backend is available. Force it on so basedpyright
            -- sees file changes made outside nvim (agents, git) without a server restart.
            if vim.fn.has("linux") == 1 and vim.fn.executable("inotifywait") == 1 then
                capabilities.workspace = capabilities.workspace or {}
                capabilities.workspace.didChangeWatchedFiles =
                    { dynamicRegistration = true, relativePatternSupport = true }
            end
            local servers = {
                "lua_ls",
                "ts_ls",
                "gopls",
                "clangd",
                "rust_analyzer",
                "basedpyright",
            }

            require("mason-lspconfig").setup({
                ensure_installed = servers,
                automatic_enable = false,
            })

            vim.lsp.config("*", { capabilities = capabilities })
            vim.lsp.config("basedpyright", {
                settings = {
                    basedpyright = {
                        analysis = {
                            autoSearchPaths = true,
                            diagnosticMode = "openFilesOnly",
                            useLibraryCodeForTypes = true,
                        },
                    },
                },
            })
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                        completion = { callSnippet = "Replace" },
                    },
                },
            })

            for _, server in ipairs(servers) do
                vim.lsp.enable(server)
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
                }),
                sources = cmp.config.sources({
                    { name = "lazydev", group_index = 0 },
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
                matching = {
                    disallow_symbol_nonprefix_matching = false,
                    disallow_fuzzy_matching = false,
                    disallow_fullfuzzy_matching = false,
                    disallow_partial_fuzzy_matching = false,
                    disallow_prefix_unmatching = false,
                },
            })

            -- Diagnostic appearance & behavior
            vim.diagnostic.config({
                virtual_text = {
                    prefix = "● ",
                    severity = { min = vim.diagnostic.severity.HINT },
                },
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "✘",
                        [vim.diagnostic.severity.WARN] = "▲",
                        [vim.diagnostic.severity.HINT] = "⚑",
                        [vim.diagnostic.severity.INFO] = "»",
                    },
                },
                underline = true,
                update_in_insert = true,
                severity_sort = true,
                float = {
                    focused = false,
                    style = "minimal",
                    border = "rounded",
                    source = "always",
                    header = "",
                    prefix = "",
                },
            })
        end
    }
}