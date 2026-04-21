-- ============================================================
-- Options
-- ============================================================
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.opt.autoread = true
vim.opt.mouse = "a"

-- Auto-reload files changed outside nvim
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  command = "checktime",
})

-- Auto-scroll terminal to bottom on new output
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "TermNormal", { bg = "#010124" })
    -- Re-apply winhighlight to any already-open terminal windows
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].buftype == "terminal" then
        vim.api.nvim_win_set_option(win, "winhighlight", "Normal:TermNormal")
      end
    end
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.api.nvim_set_hl(0, "TermNormal", { bg = "#010124" })
    vim.opt_local.winhighlight = "Normal:TermNormal"
    vim.opt_local.scrolloff = 0
    vim.cmd("startinsert")
    -- Follow output as it arrives
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_attach(buf, false, {
      on_lines = function()
        vim.schedule(function()
          local win = vim.fn.bufwinid(buf)
          if win ~= -1 then
            local line_count = vim.api.nvim_buf_line_count(buf)
            vim.api.nvim_win_set_cursor(win, { line_count, 0 })
          end
        end)
      end,
    })
  end,
})
vim.api.nvim_create_autocmd("TermEnter", {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local line_count = vim.api.nvim_buf_line_count(buf)
    vim.api.nvim_win_set_cursor(0, { line_count, 0 })
  end,
})

-- ============================================================
-- Startup layout: bottom terminal + right terminal
-- ============================================================
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    -- Determine terminal cwd from the path nvim was opened with
    local term_cwd
    local first_arg = vim.fn.argv(0)
    if first_arg ~= "" then
      if vim.fn.isdirectory(first_arg) == 1 then
        term_cwd = vim.fn.fnamemodify(first_arg, ":p")
      else
        term_cwd = vim.fn.fnamemodify(first_arg, ":p:h")
      end
    else
      term_cwd = vim.fn.getcwd()
    end

    local main_win = vim.api.nvim_get_current_win()

    -- Right terminal (vertical split from the main edit window)
    vim.cmd("rightbelow vsplit")
    vim.cmd("enew")
    vim.fn.termopen(vim.o.shell, { cwd = term_cwd })
    local right_win = vim.api.nvim_get_current_win()

    -- Return to main window, then split a bottom terminal below it
    vim.api.nvim_set_current_win(main_win)
    vim.cmd("rightbelow 15split")
    vim.cmd("enew")
    vim.fn.termopen(vim.o.shell, { cwd = term_cwd })
    local bottom_win = vim.api.nvim_get_current_win()

    -- Return focus to the main edit window
    vim.api.nvim_set_current_win(main_win)

    -- Re-apply terminal colors after colorscheme has fully loaded
    vim.schedule(function()
      vim.api.nvim_set_hl(0, "TermNormal", { bg = "#010124" })
      for _, win in ipairs({ right_win, bottom_win }) do
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_set_option(win, "winhighlight", "Normal:TermNormal")
        end
      end
    end)
  end,
})

-- ============================================================
-- Keymaps
-- ============================================================
local map = vim.keymap.set

-- Clear search highlights
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- File explorer
map("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "Toggle file explorer" })

-- Telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>",  { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",   { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>",     { desc = "Buffers" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>",    { desc = "Recent files" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>",   { desc = "Help tags" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Buffer navigation
map("n", "<S-l>", "<cmd>bnext<CR>",     { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- Move selected lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move lines down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move lines up" })

-- Keep cursor centered on search
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Diffview
map("n", "<leader>gd", "<cmd>DiffviewOpen<CR>",        { desc = "Open diffview" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory<CR>", { desc = "File history" })
map("n", "<leader>gq", "<cmd>DiffviewClose<CR>",       { desc = "Close diffview" })

-- LSP (set after LSP attaches via autocmd below)
map("n", "K",          vim.lsp.buf.hover,       { desc = "Hover docs" })
map("n", "gd",         vim.lsp.buf.definition,  { desc = "Go to definition" })
map("n", "gD",         vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "gi",         vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "gr",         "<cmd>Telescope lsp_references<CR>", { desc = "References" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>rn", vim.lsp.buf.rename,      { desc = "Rename symbol" })
map("n", "<leader>d",  vim.diagnostic.open_float, { desc = "Open diagnostic" })
map("n", "[d",         vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "]d",         vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- ============================================================
-- Bootstrap lazy.nvim
-- ============================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================
-- Plugins
-- ============================================================
require("lazy").setup({
  spec = {

    -- Colorscheme
    {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000,
      config = function()
        require("catppuccin").setup({ flavour = "mocha" })
        vim.cmd.colorscheme("catppuccin")
      end,
    },

    -- File explorer
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
      },
      opts = {
        filesystem = {
          filtered_items = { visible = true, hide_dotfiles = false },
          follow_current_file = { enabled = true },
          use_libuv_file_watcher = true,
        },
        default_component_configs = {
          git_status = {
            symbols = {
              added     = "✚",
              modified  = "",
              deleted   = "✖",
              renamed   = "➜",
              untracked = "★",
              ignored   = "◌",
              unstaged  = "✗",
              staged    = "✓",
              conflict  = "",
            },
          },
        },
      },
    },

    -- Fuzzy finder
    {
      "nvim-telescope/telescope.nvim",
      tag = "0.1.8",
      dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      },
      config = function()
        local telescope = require("telescope")
        telescope.setup({
          defaults = {
            file_ignore_patterns = { "node_modules", ".git/", "__pycache__" },
          },
        })
        telescope.load_extension("fzf")
      end,
    },

    -- Syntax highlighting
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter").setup({
          ensure_installed = {
            "lua", "vim", "vimdoc",
            "javascript", "typescript", "tsx",
            "python",
            "html", "css", "json", "yaml",
            "markdown", "markdown_inline", "bash",
          },
          auto_install = true,
        })
      end,
    },

    -- LSP + Mason
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        { "williamboman/mason.nvim", opts = {} },
        "williamboman/mason-lspconfig.nvim",
        { "j-hui/fidget.nvim", opts = {} },
      },
      config = function()
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        require("mason-lspconfig").setup({
          ensure_installed = { "ts_ls", "pyright", "html", "cssls", "lua_ls" },
          handlers = {
            function(server_name)
              require("lspconfig")[server_name].setup({ capabilities = capabilities })
            end,
            ["lua_ls"] = function()
              require("lspconfig").lua_ls.setup({
                capabilities = capabilities,
                settings = {
                  Lua = {
                    diagnostics = { globals = { "vim" } },
                    workspace = { checkThirdParty = false },
                  },
                },
              })
            end,
          },
        })
      end,
    },

    -- Autocompletion
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "rafamadriz/friendly-snippets",
      },
      config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        require("luasnip.loaders.from_vscode").lazy_load()

        cmp.setup({
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
            ["<C-f>"]     = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-e>"]     = cmp.mapping.abort(),
            ["<CR>"]      = cmp.mapping.confirm({ select = true }),
            ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { "i", "s" }),
          }),
          sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "buffer" },
            { name = "path" },
          }),
        })
      end,
    },

    -- Formatting
    {
      "stevearc/conform.nvim",
      opts = {
        format_on_save = { timeout_ms = 500, lsp_fallback = true },
        formatters_by_ft = {
          lua        = { "stylua" },
          python     = { "black" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          typescriptreact = { "prettier" },
          javascriptreact = { "prettier" },
          html       = { "prettier" },
          css        = { "prettier" },
          json       = { "prettier" },
          yaml       = { "prettier" },
          markdown   = { "prettier" },
        },
      },
    },

    -- Git diff viewer
    {
      "sindrets/diffview.nvim",
      dependencies = "nvim-lua/plenary.nvim",
      opts = {},
    },

    -- Git signs in gutter
    {
      "lewis6991/gitsigns.nvim",
      opts = {
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function lmap(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end
          lmap("n", "]c", gs.next_hunk,    "Next git hunk")
          lmap("n", "[c", gs.prev_hunk,    "Prev git hunk")
          lmap("n", "<leader>hs", gs.stage_hunk,   "Stage hunk")
          lmap("n", "<leader>hr", gs.reset_hunk,   "Reset hunk")
          lmap("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
          lmap("n", "<leader>hb", gs.blame_line,   "Blame line")
        end,
      },
    },

    -- Status line
    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
      opts = { options = { theme = "catppuccin-mocha" } },
    },

    -- Buffer tabs
    {
      "akinsho/bufferline.nvim",
      version = "*",
      dependencies = "nvim-tree/nvim-web-devicons",
      opts = {
        highlights = {
          buffer_selected = {
            fg = "#cdd6f4",
            bg = "#313244",
            bold = true,
            italic = false,
          },
          indicator_selected = {
            fg = "#89b4fa",
            bg = "#313244",
          },
        },
        options = {
          diagnostics = "nvim_lsp",
          separator_style = "slant",
          tab_size = 28,
          padding = 3,
          show_buffer_icons = false,
          offsets = {
            { filetype = "neo-tree", text = "Explorer", highlight = "Directory" },
          },
        },
      },
    },

    -- Auto pairs
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      opts = {},
    },

    -- Comments  (gcc / gc)
    {
      "numToStr/Comment.nvim",
      opts = {},
    },

    -- Keybinding hints
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      opts = {},
    },

    -- Indent guides
    {
      "lukas-reineke/indent-blankline.nvim",
      main = "ibl",
      opts = {},
    },

    -- Surround  (ys / cs / ds)
    {
      "kylechui/nvim-surround",
      version = "*",
      event = "VeryLazy",
      opts = {},
    },

    -- GitHub Copilot completions
    {
      "zbirenbaum/copilot.lua",
      cmd = "Copilot",
      event = "InsertEnter",
      opts = {
        suggestion = { enabled = false },
        panel = { enabled = false },
      },
    },

    -- GitHub Copilot Chat
    {
      "CopilotC-Nvim/CopilotChat.nvim",
      dependencies = {
        "zbirenbaum/copilot.lua",
        "nvim-lua/plenary.nvim",
      },
      opts = {
        window = { layout = "vertical", width = 0.4 },
      },
      keys = {
        { "<leader>cc", "<cmd>CopilotChatToggle<CR>",  desc = "Copilot Chat toggle" },
        { "<leader>cg", function()
            require("CopilotChat").open({ agent = "copilot" })
          end, desc = "Copilot agent mode" },
        { "<leader>ce", "<cmd>CopilotChatExplain<CR>", desc = "Copilot explain",     mode = { "n", "v" } },
        { "<leader>cf", "<cmd>CopilotChatFix<CR>",     desc = "Copilot fix",         mode = { "n", "v" } },
        { "<leader>cr", "<cmd>CopilotChatReview<CR>",  desc = "Copilot review",      mode = { "n", "v" } },
      },
    },

    -- Better notifications + cmdline UI
    {
      "folke/noice.nvim",
      event = "VeryLazy",
      dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
      opts = {
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
        },
      },
    },

    -- Local LLM integration
    { "David-Kunz/gen.nvim" },

  },

  install = { colorscheme = { "catppuccin", "habamax" } },
  checker = { enabled = true, notify = false },
})
