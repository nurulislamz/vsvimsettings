-- Run: nvim --headless -u NONE -i NONE -l nvim/tests/explorer_watchers.lua
local config_root = arg[1] or vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local plugin_root = vim.fn.stdpath("data") .. "/lazy/"
vim.opt.runtimepath:append(plugin_root .. "nvim-tree.lua")
vim.opt.runtimepath:append(plugin_root .. "nvim-web-devicons")
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local specs = dofile(config_root .. "/lua/plugins/ui.lua")
for _, spec in ipairs(specs) do
  if spec[1] == "nvim-tree/nvim-tree.lua" then
    spec.config()
    break
  end
end
assert(vim.g.NvimTreeSetup == 1, "Explorer configuration must load")

local api = require("nvim-tree.api")
local fixture = vim.fn.tempname()
vim.fn.mkdir(fixture, "p")
vim.fn.writefile({ "stable" }, fixture .. "/project.txt")
vim.fn.writefile({ "visible dotfile" }, fixture .. "/.env.example")
api.tree.open({ path = fixture })

local tree_buf = vim.api.nvim_get_current_buf()
local function rows()
  return vim.api.nvim_buf_get_lines(tree_buf, 0, -1, false)
end
local function has_name(name)
  for _, line in ipairs(rows()) do
    if line:find(name, 1, true) then
      return true
    end
  end
  return false
end
local function settle()
  vim.wait(600, function() return false end, 5)
end

local function transient_folders_do_not_shift_explorer_rows()
  settle()
  assert(has_name("project.txt") and has_name(".env.example"), "Fixture must render normal files and dotfiles")
  local initial = rows()
  local changed = false
  api.events.subscribe(api.events.Event.TreeRendered, function(event)
    if event.bufnr == tree_buf and not vim.deep_equal(rows(), initial) then
      changed = true
    end
  end)
  local names = { ".agents", ".aws", ".codex", ".git" }
  for _, name in ipairs(names) do
    vim.fn.mkdir(fixture .. "/" .. name)
  end
  vim.wait(100, function() return false end, 5)
  for _, name in ipairs(names) do
    assert(vim.fn.delete(fixture .. "/" .. name, "d") == 0, "Transient folder cleanup must succeed")
  end
  settle()
  assert(not changed, "Transient folders shifted visible explorer rows")
  print("PASS: transient folders do not shift explorer rows")
end

local function persistent_folders_and_dotfolders_refresh()
  local names = { "persistent-folder", ".agents" }
  for _, name in ipairs(names) do
    vim.fn.mkdir(fixture .. "/" .. name)
  end
  assert(vim.wait(1000, function()
    return has_name("persistent-folder") and has_name(".agents")
  end, 5), "Persistent folders and dotfolders must appear without a manual reload")
  for _, name in ipairs(names) do
    assert(vim.fn.delete(fixture .. "/" .. name, "d") == 0, "Persistent folder cleanup must succeed")
  end
  assert(vim.wait(1000, function()
    return not has_name("persistent-folder") and not has_name(".agents")
  end, 5), "Deleted folders must disappear without a manual reload")
  print("PASS: persistent folders and dotfolders refresh automatically")
end

local function main()
  transient_folders_do_not_shift_explorer_rows()
  persistent_folders_and_dotfolders_refresh()
end

local ok, failure = xpcall(main, debug.traceback)
api.tree.close()
vim.fn.delete(fixture, "rf")
if not ok then
  io.stderr:write("FAIL: " .. failure .. "\n")
  vim.cmd("cquit 1")
end
vim.cmd("qa!")
