return {
  {
    "teocns/neocursor.nvim",
    cond = function()
      return vim.g.ai_neocursor
    end,
    event = "InsertEnter",
    build = 'uv run --with "httpx[http2]" python -c "import httpx"',
    opts = {
      -- Keep map_tab false when cmp (and optionally copilot-cmp) owns <Tab>.
      -- lsp.lua calls neocursor.accept() first so ghost text still accepts on Tab/CR.
      map_tab = false,
    },
    config = function(_, opts)
      -- GUI/WSL nvim may not inherit shell PATH where uv lives
      if vim.fn.exepath("uv") == "" then
        for _, path in ipairs({
          vim.fn.expand("~/.local/bin/uv"),
          "/home/linuxbrew/.linuxbrew/bin/uv",
        }) do
          if vim.fn.executable(path) == 1 then
            vim.env.PATH = vim.fn.fnamemodify(path, ":h") .. ":" .. (vim.env.PATH or "")
            break
          end
        end
      end

      -- WSL cannot sqlite-open Cursor's state.vscdb on /mnt/c (disk I/O error).
      -- Mirror auth from Windows auth.json + storage.json onto the Linux FS.
      local win_cursor = "/mnt/c/Users/nurul/AppData/Roaming/Cursor"
      local mirror = vim.fn.expand("~/.local/share/neocursor/Cursor")
      local gs = mirror .. "/User/globalStorage"
      local auth_json = win_cursor .. "/auth.json"
      local win_storage = win_cursor .. "/User/globalStorage/storage.json"
      local state_db = gs .. "/state.vscdb"
      local storage_json = gs .. "/storage.json"

      if vim.fn.isdirectory(win_cursor) == 1 and vim.fn.filereadable(auth_json) == 1 then
        vim.fn.mkdir(gs, "p")

        -- storage.json is fine over /mnt/c; keep a local copy for the sidecar
        if vim.fn.filereadable(win_storage) == 1 then
          vim.fn.system({ "cp", "-f", win_storage, storage_json })
        end

        local sync = string.format(
          [[python3 - <<'PY'
import json, sqlite3, os
auth_path = %q
db_path = %q
with open(auth_path) as f:
    auth = json.load(f)
token = auth.get("accessToken")
refresh = auth.get("refreshToken")
if not token:
    raise SystemExit("no accessToken in auth.json")
if os.path.exists(db_path):
    os.remove(db_path)
con = sqlite3.connect(db_path)
con.execute("CREATE TABLE ItemTable (key TEXT PRIMARY KEY, value BLOB)")
rows = [("cursorAuth/accessToken", token)]
if refresh:
    rows.append(("cursorAuth/refreshToken", refresh))
con.executemany("INSERT INTO ItemTable(key, value) VALUES (?, ?)", rows)
con.commit()
con.close()
print("synced")
PY]],
          auth_json,
          state_db
        )
        local out = vim.fn.system({ "bash", "-lc", sync })
        if vim.v.shell_error ~= 0 then
          vim.notify("neocursor: failed to sync Cursor auth: " .. out, vim.log.levels.ERROR)
        else
          vim.env.CURSOR_CONFIG_DIR = mirror
        end
      elseif vim.fn.isdirectory(win_cursor) == 1 then
        -- Fallback: point at Windows Cursor (may fail sqlite on WSL)
        vim.env.CURSOR_CONFIG_DIR = win_cursor
      end

      require("neocursor").setup(opts)
    end,
  },
}
