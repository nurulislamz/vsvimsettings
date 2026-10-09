return {
  {
    "teocns/neocursor.nvim",
    cond = function()
      return vim.g.ai_neocursor
    end,
    event = "InsertEnter",
    build = 'uv run --with "httpx[http2]" python -c "import httpx"',
    opts = {
      -- Same Tab/CR path as Copilot ghost text: shared handler in lsp.lua.
      map_tab = false,
    },
  },
}
