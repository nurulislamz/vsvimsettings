-- Auto-detect WezTerm inside tmux or direct (for terminal image rendering)
if vim.env.TMUX then
  local ok, termtype = pcall(vim.fn.system, { "tmux", "display-message", "-p", "#{client_termtype}" })
  if ok and termtype:lower():find("wezterm") then
    vim.env.SNACKS_WEZTERM = "1"
  end
elseif (vim.env.TERM_PROGRAM or ""):lower():find("wezterm") then
  vim.env.SNACKS_WEZTERM = "1"
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  dependencies = {
    "nvim-mini/mini.icons",
    specs = {
      { "nvim-tree/nvim-web-devicons", enabled = false, optional = true },
    },
    config = function()
      require("mini.icons").setup()
      require("mini.icons").mock_nvim_web_devicons()
    end,
  },
  opts = {
    dashboard = { enabled = true },
    notifier = { enabled = true, timeout = 3000 },
    picker = {
      prompt = "   ",
      formatters = { file = { filename_first = true } },
    },
    lazygit = {
      configure = false,
      win = { position = "float", width = 0.99, height = 0.99 },
    },
    terminal = {
      win = { position = "right", width = 0.5, wo = { winbar = "" } },
    },
    image = {
      enabled = true,
      doc = {
        inline = true,
        float = true,
        max_height = 40,
        max_width = 80,
      },
    },
    words = { enabled = true },
    scratch = { enabled = true },
    zen = { enabled = true },
  },
}
