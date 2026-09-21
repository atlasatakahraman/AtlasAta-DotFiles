-- ┌──────────────────────────────────────────┐
-- │         UI Enhancements                  │
-- │   noice, indent-blankline, dashboard     │
-- └──────────────────────────────────────────┘

return {
  -- ═══════════════════════════════════════════
  -- ║ noice.nvim — Fancy UI for cmdline/msgs  ║
  -- ═══════════════════════════════════════════
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },

    init = function()
      local cmdline_bg = "#2a2e45"
      local cmdline_fg = "#dcd7ba"
      local icon_blue = "#7e9cd8"
      local icon_gold = "#e6c384"
      local icon_green = "#98bb6c"

      vim.api.nvim_set_hl(0, "NoiceCmdlineCustom", { bg = cmdline_bg, fg = cmdline_fg })
      vim.api.nvim_set_hl(0, "NoiceCmdline", { bg = cmdline_bg, fg = cmdline_fg })
      vim.api.nvim_set_hl(0, "NoiceCmdlinePrompt", { bg = cmdline_bg, fg = icon_blue, bold = true })
      vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { bg = cmdline_bg, fg = icon_blue, bold = true })
      vim.api.nvim_set_hl(0, "NoiceCmdlineIconSearch", { bg = cmdline_bg, fg = icon_gold, bold = true })
      vim.api.nvim_set_hl(0, "NoiceCmdlineIconFilter", { bg = cmdline_bg, fg = icon_green, bold = true })
      vim.api.nvim_set_hl(0, "NoiceCmdlineIconLua", { bg = cmdline_bg, fg = icon_blue, bold = true })
      vim.api.nvim_set_hl(0, "NoiceCmdlineIconHelp", { bg = cmdline_bg, fg = icon_gold, bold = true })
    end,

    opts = {
      -- Noice styled bottom command line
      -- Classic bottom bar placement with syntax highlighting and icons,
      -- without the floating popup dialog in the center.
      cmdline = {
        enabled = true,
        view = "cmdline",  -- Bottom command line
        format = {
          cmdline = { pattern = "^:", icon = "  ", lang = "vim" },
          search_down = { kind = "search", pattern = "^/", icon = "  ", lang = "regex" },
          search_up = { kind = "search", pattern = "^%?", icon = "  ", lang = "regex" },
          filter = { pattern = "^:%s*!", icon = "  ", lang = "bash" },
          lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "  ", lang = "lua" },
          help = { pattern = "^:%s*he?l?p?%s+", icon = "  " },
        },
      },
      views = {
        cmdline = {
          win_options = {
            winhighlight = {
              Normal = "NoiceCmdlineCustom",
              IncSearch = "",
              CurSearch = "",
              Search = "",
            },
          },
        },
      },
      popupmenu = {
        enabled = true,
        backend = "nui",
      },

      -- Replace default messages with notifications
      messages = {
        enabled = true,
        view = "notify",
        view_error = "notify",
        view_warn = "notify",
      },

      -- LSP progress messages
      lsp = {
        progress = {
          enabled = true,
        },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
        hover = {
          enabled = false,  -- blink.cmp handles hover docs to avoid double floats
        },
        signature = {
          enabled = false,  -- blink.cmp handles signature help (prevents double windows)
        },
      },

      -- Presets for common configurations
      presets = {
        bottom_search = true,          -- Use classic bottom search
        command_palette = false,       -- Disable popup command palette
        long_message_to_split = false, -- Never hijack the layout with a message split
        lsp_doc_border = true,         -- Borders for LSP docs
      },

      -- Routes: hide certain messages
      routes = {
        -- Hide "written" messages
        {
          filter = {
            event = "msg_show",
            kind = "",
            find = "written",
          },
          opts = { skip = true },
        },
        -- Neovide 0.15 validates its BUILT-IN default font chain at startup.
        -- That chain ends in the family "monospace", which does not exist on
        -- Windows, so it always fails and echoes a ~40-line FontOptions dump.
        -- It is unrelated to the configured font (proven: point config.toml at
        -- a bogus family and the error names THAT family instead). Nothing in
        -- Neovim can fix it, so drop it.
        {
          filter = {
            event = "msg_show",
            find = "Font can't be updated to",
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = "msg_show",
            find = "Following fonts couldn't be loaded",
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = "notify",
            find = "Font can't be updated to",
          },
          opts = { skip = true },
        },

        -- Hide search count messages
        {
          filter = {
            event = "msg_show",
            kind = "search_count",
          },
          opts = { skip = true },
        },
        -- Suppress vim.tbl_flatten deprecation (fired by neo-tree/plenary on Nvim 0.12+).
        -- This warning fires during file open and noice's notification steals the
        -- render cycle, making the buffer appear empty on first open from the tree.
        {
          filter = {
            event = "msg_show",
            find = "vim%.tbl_flatten",
          },
          opts = { skip = true },
        },
        -- Also suppress other common deprecation noise from upstream plugins
        {
          filter = {
            event = "msg_show",
            find = "deprecated",
          },
          opts = { skip = true },
        },
        -- Suppress Neovim 0.12 languagetree 'range' nil bug that triggers in Telescope preview
        {
          filter = {
            event = "msg_show",
            find = "languagetree%.lua.*range.*nil value",
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = "notify",
            find = "languagetree%.lua.*range.*nil value",
          },
          opts = { skip = true },
        },
      },
    },

    config = function(_, opts)
      local function apply_cmdline_highlights()
        -- Modern elevated slate background for the bottom command line
        -- Rather than harsh pitch black (#000000), use an elevated tone (#2a2e45)
        local cmdline_bg = "#2a2e45"
        local cmdline_fg = "#dcd7ba"
        local icon_blue = "#7e9cd8"
        local icon_gold = "#e6c384"
        local icon_green = "#98bb6c"

        vim.api.nvim_set_hl(0, "NoiceCmdlineCustom", { bg = cmdline_bg, fg = cmdline_fg })
        vim.api.nvim_set_hl(0, "NoiceCmdline", { bg = cmdline_bg, fg = cmdline_fg })
        vim.api.nvim_set_hl(0, "NoiceCmdlinePrompt", { bg = cmdline_bg, fg = icon_blue, bold = true })
        vim.api.nvim_set_hl(0, "NoiceCmdlineIcon", { bg = cmdline_bg, fg = icon_blue, bold = true })
        vim.api.nvim_set_hl(0, "NoiceCmdlineIconSearch", { bg = cmdline_bg, fg = icon_gold, bold = true })
        vim.api.nvim_set_hl(0, "NoiceCmdlineIconFilter", { bg = cmdline_bg, fg = icon_green, bold = true })
        vim.api.nvim_set_hl(0, "NoiceCmdlineIconLua", { bg = cmdline_bg, fg = icon_blue, bold = true })
        vim.api.nvim_set_hl(0, "NoiceCmdlineIconHelp", { bg = cmdline_bg, fg = icon_gold, bold = true })
      end

      require("noice").setup(opts)
      apply_cmdline_highlights()

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("NoiceCmdlineColors", { clear = true }),
        callback = apply_cmdline_highlights,
      })
    end,
  },

  -- ═══════════════════════════════════════════
  -- ║ nvim-notify — Notification manager      ║
  -- ═══════════════════════════════════════════
  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = "#000000",  -- silences notify's transparency warning
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      render = "wrapped-compact",
      stages = "static",  -- faster than fade_in_slide_out (reduces GPU overhead)
      top_down = true,
    },
  },

  -- ═══════════════════════════════════════════
  -- ║ indent-blankline — Indent guides        ║
  -- ═══════════════════════════════════════════
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },

    opts = {
      indent = {
        char = "│",          -- Thin indent guide character
        tab_char = "│",
      },
      scope = {
        enabled = true,      -- Highlight current scope
        show_start = true,
        show_end = false,
      },
      exclude = {
        filetypes = {
          "help", "dashboard", "neo-tree", "Trouble",
          "lazy", "mason", "notify", "toggleterm",
        },
      },
    },
  },

  -- ═══════════════════════════════════════════
  -- ║ dashboard-nvim — Startup screen         ║
  -- ═══════════════════════════════════════════
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },

    opts = {
      theme = "doom",
      config = {
        header = {
          "",
          "",
          "  █████╗ ████████╗██╗      █████╗ ███████╗",
          " ██╔══██╗╚══██╔══╝██║     ██╔══██╗██╔════╝",
          " ███████║   ██║   ██║     ███████║███████╗",
          " ██╔══██║   ██║   ██║     ██╔══██║╚════██║",
          " ██║  ██║   ██║   ███████╗██║  ██║███████║",
          " ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚══════╝",
          "",
          "          ╔═══════════════════════╗",
          "          ║   Neovim + Neovide    ║",
          "          ╚═══════════════════════╝",
          "",
          "",
        },
        center = {
          { action = "Telescope find_files",     desc = " Find File",     icon = " ", key = "f" },
          { action = "OpenFolder",               desc = " Open Folder",   icon = " ", key = "o" },
          { action = "RecentFolders",            desc = " Recent Folders",icon = " ", key = "d" },
          { action = "enew | startinsert",        desc = " New File",      icon = " ", key = "n" },
          { action = "Telescope oldfiles",       desc = " Recent Files",  icon = " ", key = "r" },
          { action = "Telescope live_grep",      desc = " Find Text",     icon = " ", key = "g" },
          { action = "Lazy",                     desc = " Plugins",       icon = " ", key = "p" },
          { action = "Mason",                    desc = " LSP Manager",   icon = " ", key = "m" },
          { action = "e " .. vim.fn.stdpath("config") .. "/init.lua", desc = " Config", icon = " ", key = "c" },
          { action = "qa",                       desc = " Quit",          icon = " ", key = "q" },
        },
        footer = function()
          local stats = require("lazy").stats()
          return {
            "",
            "⚡ Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. string.format("%.1f", stats.startuptime) .. "ms",
          }
        end,
      },
    },
    config = function(_, opts)
      -- ── Custom command to prompt and open a folder cleanly ────────
      vim.api.nvim_create_user_command("OpenFolder", function()
        local current_dir = vim.fn.getcwd()
        local default_path = current_dir .. (vim.fn.has("win32") == 1 and "\\" or "/")

        vim.ui.input({
          prompt = "Open Folder: ",
          default = default_path,
          completion = "dir",
        }, function(input)
          if input and input ~= "" then
            local path = vim.fn.fnamemodify(input, ":p")
            
            -- Remove trailing slash/backslash (except for drive letters like C:\)
            if #path > 3 and (path:sub(-1) == "/" or path:sub(-1) == "\\") then
              path = path:sub(1, -2)
            end

            if vim.fn.isdirectory(path) == 1 then
              -- Set the working directory
              vim.api.nvim_set_current_dir(path)

              -- Create a clean unnamed listed buffer in the current window
              local new_buf = vim.api.nvim_create_buf(true, false)
              vim.api.nvim_win_set_buf(0, new_buf)

              -- Open Neo-tree explorer in the new working directory
              if vim.fn.exists(":Neotree") ~= 2 then
                require("lazy").load({ plugins = { "neo-tree.nvim" } })
              end
              vim.cmd("Neotree close")
              vim.cmd("Neotree show")

              vim.notify("Opened folder: " .. path, vim.log.levels.INFO)
            else
              vim.notify("Directory does not exist: " .. path, vim.log.levels.WARN)
            end
          end
        end)
      end, {})

      -- ── Custom command to list recent folders in Telescope ────────
      vim.api.nvim_create_user_command("RecentFolders", function()
        -- Ensure Telescope is loaded
        if pcall(require, "telescope") == false then
          require("lazy").load({ plugins = { "telescope.nvim" } })
        end

        local history_file = vim.fn.stdpath("data") .. "/recent_folders.json"
        local folders = {}

        local f = io.open(history_file, "r")
        if f then
          local content = f:read("*a")
          f:close()
          local ok, decoded = pcall(vim.json.decode, content)
          if ok and type(decoded) == "table" then
            folders = decoded
          end
        end

        local existing_folders = {}
        local changed = false
        for _, folder in ipairs(folders) do
          if vim.fn.isdirectory(folder) == 1 then
            table.insert(existing_folders, folder)
          else
            changed = true
          end
        end

        if changed then
          local wf = io.open(history_file, "w")
          if wf then
            wf:write(vim.json.encode(existing_folders))
            wf:close()
          end
        end

        if #existing_folders == 0 then
          vim.notify("No recent folders found.", vim.log.levels.INFO)
          return
        end

        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")

        pickers.new({}, {
          prompt_title = "Recent Folders",
          finder = finders.new_table({
            results = existing_folders,
          }),
          sorter = conf.generic_sorter({}),
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              if selection then
                local path = selection[1]
                vim.api.nvim_set_current_dir(path)

                local new_buf = vim.api.nvim_create_buf(true, false)
                vim.api.nvim_win_set_buf(0, new_buf)

                if vim.fn.exists(":Neotree") ~= 2 then
                  require("lazy").load({ plugins = { "neo-tree.nvim" } })
                end
                vim.cmd("Neotree close")
                vim.cmd("Neotree show")

                vim.notify("Opened folder: " .. path, vim.log.levels.INFO)
              end
            end)
            return true
          end,
        }):find()
      end, {})

      require("dashboard").setup(opts)
    end,
  },
}
