-- yazi.nvim - blazing fast terminal file manager
-- Requires yazi to be installed: brew install yazi
return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>y",
      "<cmd>Yazi<cr>",
      desc = "Open Yazi at current file",
    },
    {
      "<leader>Y",
      "<cmd>Yazi cwd<cr>",
      desc = "Open Yazi at cwd",
    },
    {
      "<leader>yt",
      "<cmd>Yazi toggle<cr>",
      desc = "Resume last Yazi session",
    },
  },
  opts = {
    -- Open yazi in place of netrw
    open_for_directories = false,
    -- Keymaps shown when pressing <f1> in yazi
    keymaps = {
      show_help = "<f1>",
    },
    -- Floating window settings
    floating_window_scaling_factor = 0.9,
    -- Use rounded borders
    yazi_floating_window_border = "rounded",
    -- Highlight buffers in same directory
    highlight_hovered_buffers_in_same_directory = true,
  },
}
