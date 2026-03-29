return {
    -- 1. THE ROSLYN LSP (For C#)
    {
        "seblj/roslyn.nvim",
        ft = "cs",
        dependencies = { "hrsh7th/cmp-nvim-lsp" },
        config = function()
            local roslyn_dll = "/home/nurul/.dotnet/tools/.store/easydotnet/3.0.19/easydotnet/3.0.19/tools/Roslyn/LanguageServer/Microsoft.CodeAnalysis.LanguageServer.dll"
            require("roslyn").setup({
                exe = "dotnet",
                args = {
                    roslyn_dll,
                    "--logLevel=Information",
                    "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
                    "--perProjectInitialization",
                },
                config = {
                    capabilities = require("cmp_nvim_lsp").default_capabilities(),
                    on_attach = function(client, bufnr)
                        local map = function(keys, func, desc)
                            vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
                        end
                        -- Force "gd" and "gr" to use Telescope properly
                        map("gd", vim.lsp.buf.definition, "Go to Definition")
                        map("gr", function() require("telescope.builtin").lsp_references() end, "Go to References (Telescope)")
                        map("gi", vim.lsp.buf.implementation, "Go to Implementation")
                        map("K", vim.lsp.buf.hover, "Hover Doc")
                        map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
                        map("<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
                    end,
                },
            })
        end,
    },

    -- 2. LSPCONFIG & AUTOCOMPLETE (For Lua and General Config)
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip"
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({ 
                ensure_installed = { "lua_ls" }
            })

            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Native Neovim 0.11 API for Lua support
            vim.lsp.config("lua_ls", { capabilities = capabilities })
            vim.lsp.enable("lua_ls")

            -- Autocompletion Setup
            local cmp = require("cmp")
            cmp.setup({
                snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
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
        end
    }
}