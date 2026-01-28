-- Custom theme extending monokai-pro with rounded borders and transparent popups
return {
  {
    "loctvl842/monokai-pro.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent_background = true,
      terminal_colors = true,
      devicons = true,
      filter = "pro", -- classic | octagon | pro | machine | ristretto | spectrum
      styles = {
        comment = { italic = true },
        keyword = { italic = true },
        type = { italic = true },
        storageclass = { italic = true },
        structure = { italic = true },
        parameter = { italic = true },
        annotation = { italic = true },
        tag_attribute = { italic = true },
      },
      background_clear = {
        "toggleterm",
        "telescope",
        "renamer",
        "notify",
        "float_win",
      },
      -- Override highlight groups for transparency and borders
      override = function(c)
        return {
          -- Floating windows - transparent with visible border
          NormalFloat = { bg = "NONE", fg = c.base.dimmed1 },
          FloatBorder = { bg = "NONE", fg = c.base.dimmed3 },
          FloatTitle = { bg = "NONE", fg = c.base.yellow, bold = true },

          -- Popup menu
          Pmenu = { bg = "NONE", fg = c.base.dimmed1 },
          PmenuSel = { bg = c.base.dimmed5, fg = c.base.white, bold = true },
          PmenuSbar = { bg = "NONE" },
          PmenuThumb = { bg = c.base.dimmed3 },

          -- Snacks picker overrides
          SnacksPickerBorder = { bg = "NONE", fg = c.base.dimmed3 },
          SnacksPickerNormal = { bg = "NONE", fg = c.base.dimmed1 },
          SnacksPickerTitle = { bg = "NONE", fg = c.base.yellow, bold = true },
          SnacksPickerPrompt = { bg = "NONE", fg = c.base.white },
          SnacksPickerMatch = { fg = c.base.cyan, bold = true },
          SnacksPickerSelected = { bg = c.base.dimmed5, bold = true },
          SnacksPickerPreview = { bg = "NONE" },
          SnacksPickerPreviewBorder = { bg = "NONE", fg = c.base.dimmed3 },
          SnacksPickerList = { bg = "NONE" },
          SnacksPickerListBorder = { bg = "NONE", fg = c.base.dimmed3 },
          SnacksPickerInput = { bg = "NONE", fg = c.base.white },
          SnacksPickerInputBorder = { bg = "NONE", fg = c.base.dimmed3 },

          -- Which-key
          WhichKeyFloat = { bg = "NONE" },
          WhichKeyBorder = { bg = "NONE", fg = c.base.dimmed3 },

          -- Lazy plugin manager
          LazyNormal = { bg = "NONE" },

          -- Mason
          MasonNormal = { bg = "NONE" },

          -- mini.files glassmorphic styling (use Kitty bg #0d0d0d for transparency)
          MiniFilesNormal = { bg = "#0d0d0d", fg = c.base.dimmed1 },
          MiniFilesBorder = { bg = "#0d0d0d", fg = c.base.cyan },
          MiniFilesBorderModified = { bg = "#0d0d0d", fg = c.base.yellow },
          MiniFilesTitle = { bg = "#0d0d0d", fg = c.base.yellow, bold = true },
          MiniFilesTitleFocused = { bg = "#0d0d0d", fg = c.base.cyan, bold = true },
          MiniFilesFile = { fg = c.base.dimmed1 },
          MiniFilesDirectory = { fg = c.base.yellow },
          MiniFilesCursorLine = { bg = c.base.dimmed5 },

          -- Neo-tree glassmorphic styling (use Kitty bg #0d0d0d for transparency)
          NeoTreeNormal = { bg = "#0d0d0d", fg = c.base.dimmed1 },
          NeoTreeNormalNC = { bg = "#0d0d0d", fg = c.base.dimmed2 },
          NeoTreeFloatBorder = { bg = "#0d0d0d", fg = c.base.cyan },
          NeoTreeFloatNormal = { bg = "#0d0d0d", fg = c.base.dimmed1 },
          NeoTreeFloatTitle = { bg = "NONE", fg = c.base.yellow, bold = true },
          NeoTreeEndOfBuffer = { bg = "NONE", fg = "NONE" },
          NeoTreeWinSeparator = { bg = "NONE", fg = c.base.dimmed4 },
          NeoTreeVertSplit = { bg = "NONE", fg = c.base.dimmed4 },
          NeoTreeStatusLine = { bg = "NONE" },
          NeoTreeStatusLineNC = { bg = "NONE" },
          NeoTreeCursorLine = { bg = c.base.dimmed5 },
          NeoTreeDirectoryIcon = { fg = c.base.yellow },
          NeoTreeDirectoryName = { fg = c.base.dimmed1 },
          NeoTreeFileName = { fg = c.base.dimmed2 },
          NeoTreeFileIcon = { fg = c.base.dimmed3 },
          NeoTreeIndentMarker = { fg = c.base.dimmed4 },
          NeoTreeExpander = { fg = c.base.dimmed3 },
          NeoTreeGitAdded = { fg = c.base.green },
          NeoTreeGitModified = { fg = c.base.yellow },
          NeoTreeGitDeleted = { fg = c.base.red },
          NeoTreeRootName = { fg = c.base.yellow, bold = true, italic = true },
        }
      end,
    },
  },

  -- Configure Snacks for rounded borders
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        win = {
          input = {
            border = "rounded",
          },
          list = {
            border = "rounded",
          },
          preview = {
            border = "rounded",
          },
        },
      },
      notifier = {
        style = "compact",
      },
    },
  },

  -- Set global border style to rounded
  {
    "AstroNvim/astrocore",
    opts = {
      options = {
        opt = {
          winblend = 0, -- transparency for floating windows (0 = fully transparent bg)
          pumblend = 0, -- transparency for popup menu
        },
      },
    },
  },
}
