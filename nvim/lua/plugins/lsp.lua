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

            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(event)
                    local opts = function(desc)
                        return { buffer = event.buf, desc = "LSP: " .. desc }
                    end

                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("Go to Definition"))
                    vim.keymap.set("n", "gr", function()
                        require("telescope.builtin").lsp_references()
                    end, opts("Go to References"))
                    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts("Go to Implementation"))
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

                for _, server in ipairs(servers) do
                    vim.lsp.config(server, { capabilities = capabilities })
                    vim.lsp.enable(server)
                end
                -- Explicitly disable omnisharp to avoid interference with easy-dotnet
                vim.lsp.config("omnisharp", { autostart = false })
            else
                local lspconfig = require("lspconfig")
                for _, server in ipairs(servers) do
                    lspconfig[server].setup({ capabilities = capabilities })
                end
                -- Explicitly disable omnisharp to avoid interference with easy-dotnet
                lspconfig.omnisharp.setup({ autostart = false })
            end

            -- Autocompletion Setup
            local cmp = require("cmp")

            local function accept_completion(fallback)
                -- neocursor first, then confirm cmp selection, else fallback
                local ok, neocursor = pcall(require, "neocursor")
                if ok and neocursor.accept and neocursor.accept() then
                    return
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
                    ["<Tab>"] = cmp.mapping(accept_completion, { "i", "s" }),
                    ["<CR>"] = cmp.mapping(accept_completion, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" }
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