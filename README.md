# nvim config

Personal Neovim configuration built with [lazy.nvim](https://github.com/folke/lazy.nvim).

## Requirements

- Neovim >= 0.10
- Git
- A [Nerd Font](https://www.nerdfonts.com/) (for icons)
- `make` (for telescope-fzf-native)
- Optional formatters: `stylua`, `black`, `prettier`

## Installation

```sh
git clone <your-repo-url> ~/.config/nvim
nvim  # lazy.nvim bootstraps itself and installs plugins on first launch
```

## Layout

On startup nvim opens a four-pane layout:

```
┌──────────┬─────────────────┬──────────┐
│          │                 │          │
│ explorer │     editor      │ terminal │
│          │                 │          │
│          ├─────────────────┤          │
│          │    terminal     │          │
└──────────┴─────────────────┴──────────┘
```

The right terminal spans the full height. The bottom terminal sits only beneath the editor pane. The explorer (`<leader>e`) is a toggleable overlay on the left.

Both terminals open in the directory nvim was launched with (e.g. `nvim /tmp/dir/` → terminals start at `/tmp/dir/`).

## Plugins

| Plugin | Purpose |
|---|---|
| catppuccin/nvim | Colorscheme (Mocha) |
| nvim-neo-tree/neo-tree.nvim | File explorer |
| nvim-telescope/telescope.nvim | Fuzzy finder |
| nvim-treesitter/nvim-treesitter | Syntax highlighting |
| neovim/nvim-lspconfig + mason.nvim | LSP, auto-install servers |
| hrsh7th/nvim-cmp | Autocompletion |
| stevearc/conform.nvim | Format on save |
| sindrets/diffview.nvim | Git diff viewer |
| lewis6991/gitsigns.nvim | Git gutter signs |
| nvim-lualine/lualine.nvim | Status line |
| akinsho/bufferline.nvim | Buffer tabs |
| windwp/nvim-autopairs | Auto-close brackets |
| numToStr/Comment.nvim | `gcc` / `gc` comments |
| folke/which-key.nvim | Keybinding hints |
| lukas-reineke/indent-blankline.nvim | Indent guides |
| kylechui/nvim-surround | `ys` / `cs` / `ds` surround |
| zbirenbaum/copilot.lua | GitHub Copilot completions |
| CopilotC-Nvim/CopilotChat.nvim | GitHub Copilot Chat |
| folke/noice.nvim | Better notifications + cmdline UI |
| David-Kunz/gen.nvim | Local LLM integration |

## LSP servers (auto-installed via Mason)

`ts_ls`, `pyright`, `html`, `cssls`, `lua_ls`

## Key bindings

**Leader key:** `Space`

### File / search
| Key | Action |
|---|---|
| `<leader>e` | Toggle file explorer |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fr` | Recent files |
| `<leader>fh` | Help tags |

### Windows
| Key | Action |
|---|---|
| `<C-h/j/k/l>` | Navigate windows |

### Buffers
| Key | Action |
|---|---|
| `<S-l>` / `<S-h>` | Next / prev buffer |
| `<leader>bd` | Delete buffer |

### Git
| Key | Action |
|---|---|
| `<leader>gd` | Open diffview |
| `<leader>gh` | File history |
| `<leader>gq` | Close diffview |
| `]c` / `[c` | Next / prev hunk |
| `<leader>hs/hr/hp/hb` | Stage / reset / preview / blame hunk |

### LSP
| Key | Action |
|---|---|
| `K` | Hover docs |
| `gd` / `gD` | Definition / declaration |
| `gi` | Implementation |
| `gr` | References |
| `<leader>ca` | Code action |
| `<leader>rn` | Rename symbol |
| `<leader>d` | Diagnostics float |
| `[d` / `]d` | Prev / next diagnostic |

### Copilot Chat
| Key | Action |
|---|---|
| `<leader>cc` | Toggle chat |
| `<leader>ce` | Explain (visual) |
| `<leader>cf` | Fix (visual) |
| `<leader>cr` | Review (visual) |
