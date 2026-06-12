-- VSCode-specific keymaps
-- Loaded only when running inside VS Code via vscode-neovim
-- Path: ~/.config/nvim/lua/vscode-keymaps.lua
-- Required from: polish.lua

if not vim.g.vscode then return end

local vscode = require "vscode"
local map = vim.keymap.set

local function action(name)
  return function() vscode.action(name) end
end

local function actions(...)
  local cmds = { ... }
  return function()
    for _, c in ipairs(cmds) do
      vscode.action(c)
    end
  end
end

-- ═══════════════════════════════════════════════════════════════
-- FIND / TELESCOPE EQUIVALENTS (Leader f...)
-- ═══════════════════════════════════════════════════════════════
map({ "n", "v" }, "<leader>ff", action "workbench.action.quickOpen", { desc = "Find files" })
map({ "n", "v" }, "<leader>fb", action "workbench.action.showAllEditors", { desc = "Find buffers" })
map({ "n", "v" }, "<leader>fw", action "workbench.action.findInFiles", { desc = "Find word in files" })
map({ "n", "v" }, "<leader>fh", action "workbench.action.openRecent", { desc = "Recent files" })
map({ "n", "v" }, "<leader>fo", action "workbench.action.openRecent", { desc = "Recent files" })
map({ "n", "v" }, "<leader>fs", action "workbench.action.gotoSymbol", { desc = "Symbols in file" })
map({ "n", "v" }, "<leader>fS", action "workbench.action.showAllSymbols", { desc = "Workspace symbols" })
map({ "n", "v" }, "<leader>ft", action "workbench.action.selectTheme", { desc = "Theme picker" })
map({ "n", "v" }, "<leader>fk", action "workbench.action.openGlobalKeybindings", { desc = "Keybindings" })
map({ "n", "v" }, "<leader>fm", action "editor.action.formatDocument", { desc = "Format document" })
map({ "n", "v" }, "<leader>fn", action "explorer.newFile", { desc = "New file" })
map({ "n", "v" }, "<leader>f/", action "actions.find", { desc = "Find in file" })

-- ═══════════════════════════════════════════════════════════════
-- BUFFER MANAGEMENT (Leader b...)
-- ═══════════════════════════════════════════════════════════════
map({ "n", "v" }, "<leader>bd", action "workbench.action.closeActiveEditor", { desc = "Close buffer" })
map({ "n", "v" }, "<leader>bc", action "workbench.action.closeOtherEditors", { desc = "Close others" })
map({ "n", "v" }, "<leader>bC", action "workbench.action.closeAllEditors", { desc = "Close all" })
map({ "n", "v" }, "<leader>bl", action "workbench.action.closeEditorsToTheRight", { desc = "Close right" })
map({ "n", "v" }, "<leader>bh", action "workbench.action.closeEditorsToTheLeft", { desc = "Close left" })
map({ "n", "v" }, "<leader>bs", action "workbench.action.files.save", { desc = "Save" })
map({ "n", "v" }, "<leader>bn", action "workbench.action.nextEditorInGroup", { desc = "Next editor" })
map({ "n", "v" }, "<leader>bp", action "workbench.action.previousEditorInGroup", { desc = "Previous editor" })
map({ "n", "v" }, "<leader>c", action "workbench.action.closeActiveEditor", { desc = "Close current" })
map({ "n", "v" }, "<leader>cb", action "workbench.action.closeAllEditors", { desc = "Close all buffers" })

-- Buffer navigation
map({ "n", "v" }, "]b", action "workbench.action.nextEditor", { desc = "Next editor" })
map({ "n", "v" }, "[b", action "workbench.action.previousEditor", { desc = "Previous editor" })

-- ═══════════════════════════════════════════════════════════════
-- FILE EXPLORER (Leader e / E) - the one we've been fighting
-- ═══════════════════════════════════════════════════════════════
-- Smart explorer toggle:
-- - Sidebar hidden -> open + focus explorer
-- - Sidebar visible, editor focused -> focus explorer
-- - Sidebar visible, explorer focused -> close + focus editor
map({ "n", "v" }, "<leader>e", function()
  vscode.with_insert(function()
    vscode.action("workbench.view.explorer")
  end)
end, { desc = "Toggle/focus explorer" })

map({ "n", "v" }, "<leader>E", action "workbench.action.toggleSidebarVisibility", { desc = "Toggle sidebar" })
map({ "n", "v" }, "<leader>o", action "workbench.action.focusActiveEditorGroup", { desc = "Focus editor" })

-- ═══════════════════════════════════════════════════════════════
-- LSP / CODE ACTIONS (Leader l...)
-- ═══════════════════════════════════════════════════════════════
map({ "n", "v" }, "<leader>la", action "editor.action.codeAction", { desc = "Code actions" })
map({ "n", "v" }, "<leader>lf", action "editor.action.formatDocument", { desc = "Format" })
map({ "n", "v" }, "<leader>lr", action "editor.action.rename", { desc = "Rename" })
map({ "n", "v" }, "<leader>lh", action "editor.action.showHover", { desc = "Show hover" })
map({ "n", "v" }, "<leader>ld", action "editor.action.revealDefinition", { desc = "Definition" })
map({ "n", "v" }, "<leader>lD", action "editor.action.revealDeclaration", { desc = "Declaration" })
map({ "n", "v" }, "<leader>li", action "editor.action.goToImplementation", { desc = "Implementation" })
map({ "n", "v" }, "<leader>lt", action "editor.action.goToTypeDefinition", { desc = "Type definition" })
map({ "n", "v" }, "<leader>lR", action "editor.action.goToReferences", { desc = "References" })
map({ "n", "v" }, "<leader>ls", action "workbench.action.gotoSymbol", { desc = "Symbols" })
map({ "n", "v" }, "<leader>lS", action "workbench.action.showAllSymbols", { desc = "Workspace symbols" })

-- vim-native LSP keys
map({ "n" }, "gd", action "editor.action.revealDefinition", { desc = "Definition" })
map({ "n" }, "gD", action "editor.action.revealDeclaration", { desc = "Declaration" })
map({ "n" }, "gI", action "editor.action.goToImplementation", { desc = "Implementation" })
map({ "n" }, "gr", action "editor.action.goToReferences", { desc = "References" })
map({ "n" }, "gy", action "editor.action.goToTypeDefinition", { desc = "Type definition" })
map({ "n" }, "K", action "editor.action.showHover", { desc = "Hover" })

-- ═══════════════════════════════════════════════════════════════
-- GIT (Leader g...)
-- ═══════════════════════════════════════════════════════════════
map({ "n", "v" }, "<leader>gg", action "workbench.view.scm", { desc = "Git view" })
map({ "n", "v" }, "<leader>gs", action "workbench.view.scm", { desc = "Git status" })
map({ "n", "v" }, "<leader>gb", action "gitlens.toggleFileBlame", { desc = "Blame" })
map({ "n", "v" }, "<leader>gd", action "git.openChange", { desc = "Diff" })
map({ "n", "v" }, "<leader>gc", action "gitlens.showQuickRepoHistory", { desc = "Commits" })
map({ "n", "v" }, "<leader>gh", action "gitlens.showQuickFileHistory", { desc = "File history" })
map({ "n", "v" }, "<leader>gl", action "gitlens.showQuickRepoHistory", { desc = "Log" })
map({ "n", "v" }, "<leader>gt", action "git.stage", { desc = "Stage" })

-- Hunk navigation
map({ "n" }, "]g", action "workbench.action.editor.nextChange", { desc = "Next hunk" })
map({ "n" }, "[g", action "workbench.action.editor.previousChange", { desc = "Previous hunk" })

-- ═══════════════════════════════════════════════════════════════
-- SEARCH / REPLACE (Leader s...)
-- ═══════════════════════════════════════════════════════════════
map({ "n", "v" }, "<leader>sb", action "actions.find", { desc = "Find in buffer" })
map({ "n", "v" }, "<leader>sw", action "workbench.action.findInFiles", { desc = "Search workspace" })
map({ "n", "v" }, "<leader>sr", action "editor.action.startFindReplaceAction", { desc = "Find/replace" })

-- ═══════════════════════════════════════════════════════════════
-- TERMINAL (Leader t...)
-- ═══════════════════════════════════════════════════════════════
map({ "n", "v" }, "<leader>tf", action "workbench.action.terminal.toggleTerminal", { desc = "Toggle terminal" })
map({ "n", "v" }, "<leader>th", action "workbench.action.terminal.toggleTerminal", { desc = "Toggle terminal" })
map({ "n", "v" }, "<leader>tv", action "workbench.action.terminal.split", { desc = "Split terminal" })
map({ "n", "v" }, "<leader>tn", action "workbench.action.terminal.new", { desc = "New terminal" })

-- ═══════════════════════════════════════════════════════════════
-- DEBUG (Leader d...)
-- ═══════════════════════════════════════════════════════════════
map({ "n", "v" }, "<leader>dc", action "workbench.action.debug.continue", { desc = "Continue" })
map({ "n", "v" }, "<leader>db", action "editor.debug.action.toggleBreakpoint", { desc = "Breakpoint" })
map({ "n", "v" }, "<leader>ds", action "workbench.action.debug.start", { desc = "Start debug" })
map({ "n", "v" }, "<leader>dS", action "workbench.action.debug.stop", { desc = "Stop debug" })
map({ "n", "v" }, "<leader>di", action "workbench.action.debug.stepInto", { desc = "Step into" })
map({ "n", "v" }, "<leader>do", action "workbench.action.debug.stepOut", { desc = "Step out" })
map({ "n", "v" }, "<leader>dO", action "workbench.action.debug.stepOver", { desc = "Step over" })

-- ═══════════════════════════════════════════════════════════════
-- WORKSPACE / WINDOW
-- ═══════════════════════════════════════════════════════════════
map({ "n", "v" }, "<leader>p", action "workbench.action.showCommands", { desc = "Command palette" })
map({ "n", "v" }, "<leader>w", action "workbench.action.files.save", { desc = "Save" })
map({ "n", "v" }, "<leader>n", action "workbench.action.files.newUntitledFile", { desc = "New file" })
map({ "n", "v" }, "<leader>z", action "workbench.action.toggleZenMode", { desc = "Zen mode" })
map({ "n", "v" }, "<leader>RR", action "workbench.action.reloadWindow", { desc = "Reload window" })

-- Quick fix
map({ "n", "v" }, "<leader>qf", action "editor.action.quickFix", { desc = "Quick fix" })

-- ═══════════════════════════════════════════════════════════════
-- PROBLEMS / DIAGNOSTICS
-- ═══════════════════════════════════════════════════════════════
map({ "n" }, "]d", action "editor.action.marker.next", { desc = "Next problem" })
map({ "n" }, "[d", action "editor.action.marker.prev", { desc = "Previous problem" })
map({ "n", "v" }, "<leader>x", action "workbench.actions.view.problems", { desc = "Problems panel" })

-- ═══════════════════════════════════════════════════════════════
-- WINDOW NAVIGATION
-- ═══════════════════════════════════════════════════════════════
map({ "n" }, "<C-h>", action "workbench.action.focusLeftGroup", { desc = "Left group" })
map({ "n" }, "<C-j>", action "workbench.action.focusBelowGroup", { desc = "Below group" })
map({ "n" }, "<C-k>", action "workbench.action.focusAboveGroup", { desc = "Above group" })
map({ "n" }, "<C-l>", action "workbench.action.focusRightGroup", { desc = "Right group" })
