-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing
---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    colorscheme = "monokai-pro",
    -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
    highlights = {
      init = { -- this table overrides highlights in all themes
        -- Normal = { bg = "#000000" },
        Visual = { bg = "#266D71", fg = "#000000" },
        CursorLine = { bg = "#266D71" },
        ["NeoTreeDirectoryIcon"] = { fg = "#7a7a7a" },
        ["NeoTreeDirectoryName"] = { fg = "#cccccc" },
        ["NeoTreeFileName"] = { fg = "#cccccc" },
        ["NeoTreeFileIcon"] = { fg = "#7a7a7a" },
        ["NeoTreeIndentMarker"] = { fg = "#3a3a3a" },
        ["NeoTreeExpander"] = { fg = "#5a5a5a" },
        ["NeoTreeNormal"] = { bg = "#1e1e1e", fg = "#cccccc" },
        ["NeoTreeNormalNC"] = { bg = "#1e1e1e", fg = "#cccccc" },
        -- ========== PYTHON HIGHLIGHTS ==========
        ["@variable.python"] = { fg = "#9896FF", italic = true },
        ["@variable.builtin.python"] = { fg = "#9896FF" },
        ["@variable.parameter.python"] = { fg = "#ff7936" },
        ["@variable.parameter.builtin.python"] = { fg = "#FF6D5A" },

        ["@function.python"] = { fg = "#74D100" },
        ["@function.builtin.python"] = { fg = "#74D100", italic = true },
        ["@function.method.python"] = { fg = "#74D100" },
        ["@function.call.python"] = { fg = "#AAE859" },

        ["@type.python"] = { fg = "#00D4EF" },
        ["@type.builtin.python"] = { fg = "#3CDAFF", italic = true },

        ["@keyword.python"] = { fg = "#FF6E5A" },
        ["@keyword.control.python"] = { fg = "#FF6E5A" },
        ["@keyword.control.import.python"] = { fg = "#ff8205", italic = true },
        ["@keyword.operator.python"] = { fg = "#B179FF" },

        ["@property.python"] = { fg = "#74D100", italic = true },
        ["@function.macro.python"] = { fg = "#8483DD" },
        ["@attribute.python"] = { fg = "#ff8205", italic = true },

        ["@comment.python"] = { fg = "#ffffff" },
        ["@comment.note.python"] = { fg = "#ff8205", italic = true, bold = true },
        ["@module.python"] = { fg = "#fd5b5b" },

        ["@constant.builtin.python"] = { fg = "#3CDAFF", italic = true },
        ["@boolean.python"] = { fg = "#ffb405", italic = true },

        -- ========== JAVASCRIPT/TYPESCRIPT HIGHLIGHTS ==========
        ["@variable.javascript"] = { fg = "#009bfb" },
        ["@variable.javascriptreact"] = { fg = "#009bfb" },
        ["@variable.typescript"] = { fg = "#009bfb" },
        ["@variable.typescriptreact"] = { fg = "#009bfb" },
        ["@variable.other.constant"] = { fg = "#2d9ab2" },

        ["@function.javascript"] = { fg = "#ae76f8" },
        ["@function.typescript"] = { fg = "#ae76f8" },
        ["@function.call.javascript"] = { fg = "#964cfd" },
        ["@function.call.typescript"] = { fg = "#964cfd" },
        ["@function.call.javascriptreact"] = { fg = "#964cfd" },
        ["@function.call.typescriptreact"] = { fg = "#964cfd" },

        ["@function.method.javascript"] = { fg = "#74D100", italic = true },
        ["@function.method.javascriptreact"] = { fg = "#599f03", italic = true },
        ["@function.method.typescript"] = { fg = "#74D100", italic = true },
        ["@function.method.typescriptreact"] = { fg = "#599f03", italic = true },

        ["@type.javascript"] = { fg = "#fb00e2" },
        ["@type.javascriptreact"] = { fg = "#fb00e2" },
        ["@type.typescript"] = { fg = "#fb00e2" },
        ["@type.typescriptreact"] = { fg = "#fb00e2" },

        ["@property.javascript"] = { fg = "#7E7AFF" },
        ["@property.javascriptreact"] = { fg = "#7E7AFF" },
        ["@property.typescript"] = { fg = "#7E7AFF" },
        ["@property.typescriptreact"] = { fg = "#7E7AFF" },

        ["@variable.parameter.javascript"] = { fg = "#ff7272" },
        ["@variable.parameter.typescript"] = { fg = "#ff7272" },
        ["@variable.parameter.typescriptreact"] = { fg = "#ff7272" },

        ["@keyword.javascript"] = { fg = "#fea639", italic = true },
        ["@keyword.javascriptreact"] = { fg = "#fea639", italic = true },
        ["@keyword.typescript"] = { fg = "#fea639", italic = true },
        ["@keyword.typescriptreact"] = { fg = "#fea639", italic = true },
        ["@keyword.import.javascript"] = { fg = "#fea639", italic = true },
        ["@keyword.export.javascript"] = { fg = "#fea639", italic = true },
        ["@keyword.return.javascript"] = { fg = "#c63a64", bold = true },

        ["@keyword.storage.javascript"] = { fg = "#c63a64", bold = true },
        ["@keyword.storage.javascriptreact"] = { fg = "#c63a64", bold = true },
        ["@keyword.storage.type.tsx"] = { fg = "#FF5FCE" },

        ["@string.javascript"] = { fg = "#a1a1a0", italic = true },
        ["@string.template.javascript"] = { fg = "#c0c0c0", italic = true },

        ["@tag.tsx"] = { fg = "#b50164" },
        ["@tag.attribute.tsx"] = { fg = "#21858a" },
        ["@tag.delimiter.tsx"] = { fg = "#116806", bold = true },

        ["@boolean.true.javascript"] = { fg = "#64fe05" },
        ["@boolean.false.javascript"] = { fg = "#fe0505" },
        ["@namespace.javascript"] = { fg = "#edb03e" },

        ["@type.qualifier.typescript"] = { fg = "#fea639" },
        ["@type.qualifier.typescriptreact"] = { fg = "#fea639" },

        -- ========== JAVA HIGHLIGHTS ==========
        ["@type.java"] = { fg = "#AAE859" },
        ["@type.qualifier.java"] = { fg = "#b375ff" },
        ["@function.java"] = { fg = "#AAE859" },
        ["@function.method.java"] = { fg = "#74D100" },
        ["@variable.java"] = { fg = "#7764E5" },
        ["@property.java"] = { fg = "#7E7AFF", italic = true },
        ["@property.static.java"] = { fg = "#9896FF" },
        ["@variable.parameter.java"] = { fg = "#DB8F68" },
        ["@keyword.modifier.java"] = { fg = "#FF6E5A" },
        ["@keyword.import.java"] = { fg = "#FF6E5A", italic = true },
        ["@attribute.java"] = { fg = "#F9951F" },

        -- ========== C/C++ HIGHLIGHTS ==========
        ["@function.c"] = { fg = "#e477f7" },
        ["@keyword.directive.c"] = { fg = "#ffc05a" },
        ["@punctuation.special.c"] = { fg = "#ffc05a" },

        -- ========== HTML HIGHLIGHTS ==========
        ["@tag.html"] = { fg = "#09ff00", italic = true },
        ["@tag.attribute.html"] = { fg = "#00f2ff" },
        ["@constant.html"] = { fg = "#FF0000", italic = true },

        -- ========== SHELL SCRIPT HIGHLIGHTS ==========
        ["@string.shell"] = { fg = "#dad7d7" },
        ["@string.special.shell"] = { fg = "#64fe05" },
        ["@variable.shell"] = { fg = "#ff7105", italic = true },
        ["@function.builtin.shell"] = { fg = "#ff2054", italic = true },
        ["@function.shell"] = { fg = "#8531fa", italic = true },
        ["@function.call.shell"] = { fg = "#0088ff", italic = true },
        ["@keyword.shell"] = { fg = "#fea639", italic = true },
        ["@property.shell"] = { fg = "#09ff05", italic = true },
        ["@string.unquoted.shell"] = { fg = "#ff9100" },
        ["@comment.shell"] = { fg = "#a0a0a0" },

        -- ========== JSON HIGHLIGHTS ==========
        ["@property.json"] = { fg = "#6c62d7", italic = true },
        ["@string.json"] = { fg = "#dad7d7" },

        -- ========== DART HIGHLIGHTS ==========
        ["@keyword.modifier.dart"] = { fg = "#ff8205", italic = true },

        -- ========== GENERAL HIGHLIGHTS ==========
        ["@comment"] = { fg = "#c79696" },
        ["@comment.documentation"] = { fg = "#ffffff" },
        ["@string"] = { fg = "#c7c5c2" },
        ["@keyword"] = { fg = "#FF6E5A" },
        ["@keyword.storage"] = { fg = "#FF6E5A" },
        ["@keyword.operator"] = { fg = "#fea639", italic = true },
        ["@punctuation.delimiter"] = { fg = "#a1a1a0", bold = true },
        ["@constant.builtin"] = { fg = "#3CDAFF", italic = true },
        ["@boolean"] = { fg = "#ffb405", italic = true },

        -- ========== LSP SEMANTIC TOKENS ==========
        ["@lsp.type.variable.python"] = { fg = "#9896FF", italic = true },
        ["@lsp.type.parameter.python"] = { fg = "#ff7936" },
        ["@lsp.type.function.python"] = { fg = "#74D100" },
        ["@lsp.type.method.python"] = { fg = "#74D100" },
        ["@lsp.type.class.python"] = { fg = "#00D4EF" },
        ["@lsp.type.property.python"] = { fg = "#74D100", italic = true },
        ["@lsp.type.decorator.python"] = { fg = "#8483DD" },
        ["@lsp.mod.builtin.python"] = { italic = true },

        ["@lsp.type.variable.javascript"] = { fg = "#009bfb" },
        ["@lsp.type.variable.typescript"] = { fg = "#009bfb" },
        ["@lsp.type.property.javascript"] = { fg = "#7E7AFF" },
        ["@lsp.type.property.typescript"] = { fg = "#7E7AFF" },
        ["@lsp.type.parameter.typescript"] = { fg = "#ff7272" },
        ["@lsp.type.class.typescript"] = { fg = "#fb00e2" },
        ["@lsp.type.interface.typescript"] = { fg = "#fea639" },

        ["@lsp.type.variable.java"] = { fg = "#7764E5" },
        ["@lsp.type.property.java"] = { fg = "#7E7AFF", italic = true },
        ["@lsp.type.method.java"] = { fg = "#74D100" },
        ["@lsp.type.class.java"] = { fg = "#AAE859" },
      },
      astrodark = { -- a table of overrides/changes when applying the astrotheme theme
        -- Normal = { bg = "#000000" },
      },
    },
    -- Icons can be configured throughout the interface
    icons = {
      -- configure the loading of the lsp in the status line
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    },
  },
}
