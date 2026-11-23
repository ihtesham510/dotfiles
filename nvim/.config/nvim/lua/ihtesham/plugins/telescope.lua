return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },

    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = function()
    local variables = require 'ihtesham.variables'
    local actions = require 'telescope.actions'
    local builtin = require 'telescope.builtin'
    require('telescope').setup {
      defaults = {
        color_devicons = true,
        initial_mode = 'normal',
        file_ignore_patterns = { '^.git/', '%.git/', 'target/', 'node_modules/' },
        prompt_prefix = '     ',
        selection_caret = ' ❯ ',
        sorting_strategy = 'ascending',
        layout_strategy = 'horizontal',
        layout_config = {
          horizontal = {
            prompt_position = 'top',
            preview_width = 0.55,
            results_width = 0.8,
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 60,
        },
        mappings = {
          i = {
            ['<C-j>'] = require('telescope.actions').preview_scrolling_down,
            ['<C-k>'] = require('telescope.actions').preview_scrolling_up,
          },
          n = {
            ['<C-j>'] = require('telescope.actions').preview_scrolling_down,
            ['<C-k>'] = require('telescope.actions').preview_scrolling_up,
            ['['] = require('telescope.actions').preview_scrolling_up,
            [']'] = require('telescope.actions').preview_scrolling_down,
            ['<esc>'] = actions.close,
            ['q'] = actions.close,
            ['<CR>'] = actions.select_default,
            ['l'] = actions.select_default,
            ['h'] = actions.select_horizontal,
            ['s'] = actions.select_vertical,
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true,
        },
        live_grep = {
          additional_args = { '--hidden' },
        },
        grep_string = {
          additional_args = { '--hidden' },
        },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }
    local keymap = require('ihtesham.utils.functions').map

    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'project')
    pcall(require('telescope').load_extension, 'bookmarks')
    pcall(require('telescope').load_extension, 'ui-select')

    -- fuzzy find and search
    keymap('n', variables.telescopeBuiltIn, builtin.builtin, { desc = 'Search [S]elect Telescope' })

    keymap('n', variables.findDiagnostics, builtin.diagnostics, { desc = 'Search [D]iagnostics' })

    keymap('n', variables.findRecentFiles, builtin.oldfiles, { desc = 'Search Recent Files ("." for repeat)' })
    keymap('n', variables.findTodos, '<cmd>TodoTelescope<cr>', { desc = 'Search todos' })
    keymap('n', variables.findBuffers, builtin.buffers, { desc = 'Find existing buffers' })
    keymap('n', variables.findHelpTags, builtin.help_tags, { desc = 'Search [H]elp' })
    keymap('n', variables.findKeymaps, builtin.keymaps, { desc = 'Search [K]eymaps' })
    keymap('n', variables.findFiles, builtin.find_files, { desc = 'Search [F]iles' })

    keymap({ 'n', 'v' }, variables.grepString, builtin.grep_string, { desc = 'Search current [W]ord' })
    keymap('n', variables.grep, builtin.live_grep, { desc = 'Search by [G]rep' })
    keymap('n', variables.resumeFind, builtin.resume, { desc = 'Search [R]esume' })

    keymap('n', variables.grepCurrentBuffer, function()
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        previewer = false,
      })
    end, { desc = '[/] Fuzzily Search in current buffer' })

    keymap('n', variables.grepOpenFiles, function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = 'Search [/] in Open Files' })

    keymap('n', variables.findConfigFiles, function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = 'Search [N]eovim files' })
    -- git
    --
    keymap('n', variables.gitFiles, function()
      builtin.git_files()
    end, { desc = 'Git Files' })
    keymap('n', variables.gitStash, function()
      builtin.git_stash()
    end, { desc = 'Git Stash' })
    keymap('n', variables.gitStash, function()
      builtin.git_status()
    end, { desc = 'Git Status' })
    keymap('n', variables.gitBranches, function()
      builtin.git_branches()
    end, { desc = 'Git Branches' })
    keymap('n', variables.gitCommits, function()
      builtin.git_commits()
    end, { desc = 'Git Commits' })
  end,
}
