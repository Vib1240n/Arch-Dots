--          ╭─────────────────────────────────────────────────────────╮
--          │    You can also add or configure plugins by creating    │
--          │             files in this `plugins/` folder             │
--          ╰─────────────────────────────────────────────────────────╯
-- ── PLEASE REMOVE THE EXAMPLES YOU HAVE NO INTEREST IN BEFORE ───────
-- ENABLING THIS FILE
-- ── Here are some examples: ─────────────────────────────────────────

---@type LazySpec
return {

  -- == Examples of Adding Plugins ==

  "andweeb/presence.nvim",
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },

  -- == Examples of Overriding Plugins ==

  -- customize dashboard options
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = table.concat({
            "888     888 8888888 888888b.   d888    .d8888b.     d8888    d8888b.  888b    888",
            "888     888   888   888  88b  d8888   d88P  Y88b    d8P888  d88P  Y88b 8888b   888",
            "888     888   888   888  .88P    888          888  d8P 888  888    888 88888b  888",
            "Y88b   d88P   888   8888888K.    888        .d88P d8P  888  888    888 888Y88b 888",
            "Y88b d88P    888   888  Y88b    888    .od888P  d88   888  888    888 888 Y88b888",
            "Y88o88P     888   888    888   888   d88P      8888888888 888    888 888  Y88888",
            "Y888P      888   888   d88P   888   888             888  Y88b  d88P 888   Y8888",
            "Y8P     8888888 8888888P  8888888   88888888888    888   'Y8888P'  888    Y888",
          }, "\n"),
        },
      },
    },
  },

  -- You can disable default plugins as follows:
  { "max397574/better-escape.nvim", enabled = true },

  -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom luasnip configuration such as filetype extend or custom snippets
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom autopairs configuration such as custom rules
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules(
        {
          Rule("$", "$", { "tex", "latex" })
            -- don't add a pair if the next character is %
            :with_pair(cond.not_after_regex "%%")
            -- don't add a pair if  the previous character is xxx
            :with_pair(
              cond.not_before_regex("xxx", 3)
            )
            -- don't move right when repeat character
            :with_move(cond.none())
            -- don't delete if the next character is xx
            :with_del(cond.not_after_regex "xx")
            -- disable adding a newline when you press <cr>
            :with_cr(cond.none()),
        },
        -- disable for .vim files, but it work for another filetypes
        Rule("a", "a", "-vim")
      )
    end,
  },
  { "AstroNvim/astrotheme" },
  {
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = { -- set to setup table
    },
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
    },
  },
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        python = { "black" },
      },
      format_on_save = {
        timeout_ms = 3000,
        lsp_format = "fallback",
      },
    },
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = false,

    -- For blink.cmp's completion
    -- source
    -- dependencies = {
    --     "saghen/blink.cmp"
    -- },
  },
}
