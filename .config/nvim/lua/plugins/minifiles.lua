-- mini.files - floating file explorer with miller columns
return {
  "echasnovski/mini.files",
  version = false,
  keys = {
    {
      "<leader>e",
      function()
        local MiniFiles = require "mini.files"
        if not MiniFiles.close() then MiniFiles.open(vim.api.nvim_buf_get_name(0), true) end
      end,
      desc = "Toggle mini.files (current file)",
    },
    {
      "<leader>E",
      function()
        local MiniFiles = require "mini.files"
        if not MiniFiles.close() then MiniFiles.open(vim.fn.getcwd(), true) end
      end,
      desc = "Toggle mini.files (cwd)",
    },
  },
  opts = {
    mappings = {
      close = "q",
      go_in = "l",
      go_in_plus = "<CR>",
      go_out = "h",
      go_out_plus = "H",
      reset = "<BS>",
      reveal_cwd = "@",
      show_help = "g?",
      synchronize = "=",
      trim_left = "<",
      trim_right = ">",
    },
    options = {
      permanent_delete = false,
      use_as_default_explorer = false,
    },
    windows = {
      preview = true,
      width_focus = 35,
      width_nofocus = 20,
      width_preview = 50,
    },
  },
  config = function(_, opts)
    local MiniFiles = require "mini.files"
    MiniFiles.setup(opts)

    -- Set cursorline on open
    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesWindowOpen",
      callback = function(args)
        local win_id = args.data.win_id
        vim.wo[win_id].cursorline = true
      end,
    })

    -- Custom highlight overrides
    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesWindowOpen",
      callback = function()
        vim.api.nvim_set_hl(0, "MiniFilesNormal", { link = "NormalFloat" })
        vim.api.nvim_set_hl(0, "MiniFilesBorder", { link = "FloatBorder" })
        vim.api.nvim_set_hl(0, "MiniFilesTitle", { link = "FloatTitle" })
      end,
    })

    -- Add keybindings for file/directory creation
    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesBufferCreate",
      callback = function(args)
        local buf_id = args.data.buf_id

        -- Create new file
        vim.keymap.set("n", "a", function()
          local path = MiniFiles.get_fs_entry().path
          local name = vim.fn.input("Create file: ", path .. "/")
          if name ~= "" then
            vim.fn.writefile({}, name)
            MiniFiles.synchronize()
          end
        end, { buffer = buf_id, desc = "Create new file" })

        -- Create new directory
        vim.keymap.set("n", "A", function()
          local path = MiniFiles.get_fs_entry().path
          local name = vim.fn.input("Create directory: ", path .. "/")
          if name ~= "" then
            vim.fn.mkdir(name, "p")
            MiniFiles.synchronize()
          end
        end, { buffer = buf_id, desc = "Create new directory" })

        -- Rename file/directory
        vim.keymap.set("n", "r", function()
          local entry = MiniFiles.get_fs_entry()
          local old_name = entry.path
          local new_name = vim.fn.input("Rename to: ", old_name)
          if new_name ~= "" and new_name ~= old_name then
            vim.fn.rename(old_name, new_name)
            MiniFiles.synchronize()
          end
        end, { buffer = buf_id, desc = "Rename file/directory" })

        -- Delete file/directory
        vim.keymap.set("n", "d", function()
          local entry = MiniFiles.get_fs_entry()
          local confirm = vim.fn.input("Delete " .. entry.path .. "? (y/N): ")
          if confirm:lower() == "y" then
            if entry.fs_type == "directory" then
              vim.fn.delete(entry.path, "rf")
            else
              vim.fn.delete(entry.path)
            end
            MiniFiles.synchronize()
          end
        end, { buffer = buf_id, desc = "Delete file/directory" })
      end,
    })
  end,
}
