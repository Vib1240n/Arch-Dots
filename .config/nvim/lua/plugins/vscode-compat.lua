-- VS Code Compatibility Configuration for AstroNvim
-- Disables UI plugins that cause errors in VS Code

local in_vscode = vim.g.vscode ~= nil

return {
  { "folke/snacks.nvim", enabled = not in_vscode },
  { "lukas-reineke/indent-blankline.nvim", enabled = not in_vscode },
  { "nvim-neo-tree/neo-tree.nvim", enabled = not in_vscode },
  { "goolord/alpha-nvim", enabled = not in_vscode },
  { "folke/noice.nvim", enabled = not in_vscode },
  { "stevearc/dressing.nvim", enabled = not in_vscode },
  { "rcarriga/nvim-notify", enabled = not in_vscode },
  { "rebelot/heirline.nvim", enabled = not in_vscode },
  { "nvim-telescope/telescope.nvim", enabled = not in_vscode },
  { "folke/which-key.nvim", enabled = not in_vscode },
}
