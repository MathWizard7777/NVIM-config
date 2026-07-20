return {
  { -- Collection of various small independent plugins/modules
    'nvim-mini/mini.nvim',
    config = function()
      require('mini.ai').setup {
        mappings = {
          around_next = 'an',
          inside_next = 'in',
          around_last = 'al',
          inside_last = 'il',
        },
        n_lines = 500,
      }
    end,
  },

  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true -- This runs require('nvim-autopairs').setup() automatically
  },

  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use main branch for latest features
    event = "VeryLazy",
    config = true -- This runs require('nvim-surround').setup() automatically
  },

  {
    'saghen/blink.cmp',
    version = '*', -- use a release tag to download pre-built binaries
    dependencies = {
      'L3MON4D3/LuaSnip',     -- The engine
      'rafamadriz/friendly-snippets', -- Predefined snippets
    },

    opts = {
      -- Use 'super-tab' for nvim-cmp-like Tab behavior
      keymap = { preset = 'super-tab' },

      snippets = {
        -- Tell blink to use luasnip as the engine
        preset = 'luasnip',
      },

      sources = {
        -- 'snippets' here will now pull from LuaSnip
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
    },
  },

  {
    'L3MON4D3/LuaSnip',
    dependencies = { 'rafamadriz/friendly-snippets' },
    config = function()
      -- Load snippets from friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()
      -- Load your custom snippets from ~/.config/nvim/snippets/
      require("luasnip.loaders.from_lua").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/snippets" }
      })
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "biozz/whop.nvim",
        config = function()
          require("whop").setup({
            builtin_commands = true,
            keymap = "<leader>ww",
          })
        end
      }
    },
    keys = {
      { "<leader>tw", ":Telescope whop<CR>", desc = "whop.nvim (telescope)" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        -- other config options
        extensions = {
          whop = {
            preview_buffer_line_limit = 1000,
          }
        }
      })
      telescope.load_extension("whop")
    end
  }
}
