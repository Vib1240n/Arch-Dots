--          ╭─────────────────────────────────────────────────────────╮
--          │ AstroCore provides a central place to modify mappings,  │
--          │          vim options, autocommands, and more!           │
--          │    Configuration documentation can be found with `:h    │
--          │                       astrocore`                        │
--          ╰─────────────────────────────────────────────────────────╯
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- passed to `vim.filetype.add`
    filetypes = {
      -- see `:h vim.filetype.add` for usage
      extension = {
        foo = "fooscript",
      },
      filename = {
        [".foorc"] = "fooscript",
      },
      pattern = {
        [".*/etc/foo/.*"] = "fooscript",
      },
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>

        termguicolors = true,
        clipboard = "",
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = false, -- sets vim.opt.wrap
        guicursor = "n-v-c-sm:block-nCursor,i-ci-ve:ver30-iCursor-blinkwait300-blinkon200-blinkoff150,r-cr-o:hor20",
        autochdir = false,
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    --          ╭─────────────────────────────────────────────────────────╮
    --          │  Mappings can be configured through AstroCore as well.  │
    --          ╰─────────────────────────────────────────────────────────╯
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      --          ╭─────────────────────────────────────────────────────────╮
      --          │                  first key is the mode                  │
      --          ╰─────────────────────────────────────────────────────────╯
      n = {
        -- second key is the lefthand side of the map

        --          ╭─────────────────────────────────────────────────────────╮
        --          │     Disable AstroNvim's default Neo-tree keybindings    │
        --          │            (using mini.files instead)                   │
        --          ╰─────────────────────────────────────────────────────────╯
        ["<Leader>e"] = false,
        ["<Leader>o"] = false,

        -- Cmd+C/V for copy/paste (works in GUI Neovim like Neovide)
        ["<D-c>"] = { '"+y', desc = "Copy to clipboard" },
        ["<D-v>"] = { '"+p', desc = "Paste from clipboard" },

        -- navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        --          ╭─────────────────────────────────────────────────────────╮
        --          │         mappings seen under group name "Buffer          │
        --          ╰─────────────────────────────────────────────────────────╯
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },
        ["<M-H>"] = { function() require("smart-splits").move_cursor_left() end, desc = "Move to left split" },
        ["<M-J>"] = { function() require("smart-splits").move_cursor_down() end, desc = "Move to below split" },
        ["<M-K>"] = { function() require("smart-splits").move_cursor_up() end, desc = "Move to above split" },
        ["<M-L>"] = { function() require("smart-splits").move_cursor_right() end, desc = "Move to right split" },

        ["d"] = { '"_d', noremap = true, silent = true, desc = "blackhole" },
        ["Y"] = { '"+y', noremap = true, silent = true, desc = "copy to clipboard" },
        ["<Leader>cb"] = { "<Cmd>CBccbox<CR>", noremap = true, silent = true, desc = "Title Comment box" },
        ["<Leader>cr"] = { "<Cmd>CBd<CR>", noremap = true, silent = true, desc = "Remove Comment box" },
        ["<Leader>ct"] = { "<Cmd>CBllline<CR>", noremap = true, silent = true, desc = "Line Comment box" },
        ["<Leader>cl"] = { "<Cmd>CBline<CR>", noremap = true, silent = true, desc = "Simple line comment box" },
        ["<Leader>RR"] = { "<Cmd>AstroReload<CR>", noremap = true, silent = true, desc = "Reload Astronvim" },
        ["<Leader>sr"] = { ":", noremap = true, silent = true, desc = "search and replace" },
      },
      v = {
        -- Cmd+C/V for copy/paste (works in GUI Neovim like Neovide)
        ["<D-c>"] = { '"+y', desc = "Copy to clipboard" },
        ["<D-v>"] = { '"+p', desc = "Paste from clipboard" },

        ["d"] = {
          noremap = true,
          desc = "visual mode blackhole",
          silent = true,
          '"_d',
        },

        ["<Leader>cb"] = { "<Cmd>CBccbox<CR>", noremap = true, silent = true, desc = "Comment box" },
        ["<Leader>cr"] = { "<Cmd>CBd<CR>", noremap = true, silent = true, desc = "Remove Comment box" },
        ["<Leader>ct"] = { "<Cmd>CBllline<CR>", noremap = true, silent = true, desc = "Line Comment box" },
        ["<Leader>sr"] = { ".:%s/", noremap = true, silent = true, desc = "search and replace" },
      },
      i = {
        -- Cmd+V to paste in insert mode
        ["<D-v>"] = { "<C-r>+", desc = "Paste from clipboard" },
      },
      c = {
        -- Cmd+V to paste in command mode
        ["<D-v>"] = { "<C-r>+", desc = "Paste from clipboard" },
      },
    },
  },
}
