return {
  { 'NMAC427/guess-indent.nvim', opts = {} }, -- Guess Indent

  { -- Highlight todo, notes, etc in comments
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    ---@module 'todo-comments'
    ---@type TodoOptions
    ---@diagnostic disable-next-line: missing-fields
    opts = { signs = false },
  },

  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl', -- Required for version 3+
    opts = {},    -- Automatically runs require('ibl').setup({})
  },

  {
    'echasnovski/mini.indentscope',
    version = false, -- Use latest version
    opts = {
      symbol = '│', -- The character used to show the scope
      draw = {
        delay = 0,
        animation = function() return 0 end,
      },
      options = { try_as_border = true },
    },
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'help', 'alpha', 'dashboard', 'neo-tree', 'Trouble', 'lazy', 'mason' },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false, -- Ensures it loads immediately on startup
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('catppuccin').setup {
        no_italic = true, -- Disables italics globally (or change to your liking)
      }

      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'catppuccin-latte', 'catppuccin-frappe', 'catppuccin-macchiato', or 'catppuccin-mocha'.
      vim.cmd.colorscheme 'catppuccin-mocha'
    end,
  },

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        options = {
          theme = 'auto',
          -- These "powerline" separators create the sharp triangle look
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
        },
        sections = {
          lualine_a = { { 'mode', separator = { left = '' }, right_padding = 2 } },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { 'filename' },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { { 'location', separator = { right = '' }, left_padding = 2 } },
        },
      })
    end,
  }
}
