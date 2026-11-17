return {
  'lewis6991/gitsigns.nvim',
  event = 'BufEnter',
  opts = {
    signs = {
      add = { text = '▎' },
      change = { text = '▎' },
      delete = { text = '' },
      topdelete = { text = '' },
      changedelete = { text = '▎' },
      untracked = { text = '▎' },
    },
    signs_staged = {
      add = { text = '▎' },
      change = { text = '▎' },
      delete = { text = '' },
      topdelete = { text = '' },
      changedelete = { text = '▎' },
    },
    on_attach = function(buffer)
      local variables = require 'ihtesham.variables'
      local map = require('ihtesham.utils.functions').map
      local gs = package.loaded.gitsigns

      local next_hunk = function()
        if vim.wo.diff then
          vim.cmd.normal { ']c', bang = true }
        else
          gs.nav_hunk 'next'
        end
      end
      local prev_hunk = function()
        if vim.wo.diff then
          vim.cmd.normal { '[c', bang = true }
        else
          gs.nav_hunk 'prev'
        end
      end
      local last_hunk = function()
        gs.nav_hunk 'last'
      end
      local first_hunk = function()
        gs.nav_hunk 'first'
      end
      local blame_hunk = function()
        gs.blame_line { full = true }
      end
      local blame_buffer = function()
        gs.blame()
      end
      local diff_buffer = function()
        gs.diffthis '~'
      end

      map('n', variables.gitNextHunk, next_hunk, { desc = 'Next Hunk', buffer = buffer })
      map('n', variables.gitPrevHunk, prev_hunk, { desc = 'Prev Hunk', buffer = buffer })
      map('n', variables.gitFirstHunk, first_hunk, { desc = 'First Hunk', buffer = buffer })
      map('n', variables.gitLastHunk, last_hunk, { desc = 'Last Hunk', buffer = buffer })
      map({ 'n', 'v' }, variables.gitStageHunk, ':Gitsigns stage_hunk<CR>', { desc = 'Stage Hunk', buffer = buffer })
      map({ 'n', 'v' }, variables.gitHunkReset, ':Gitsigns reset_hunk<CR>', { desc = 'Reset Hunk', buffer = buffer })
      map('n', variables.gitStageBuffer, gs.stage_buffer, { desc = 'Stage Buffer', buffer = buffer })
      map('n', variables.gitStageUndo, gs.undo_stage_hunk, { desc = 'Undo Stage Hunk', buffer = buffer })
      map('n', variables.gitBufferReset, gs.reset_buffer, { desc = 'Reset Buffer', buffer = buffer })
      map('n', variables.gitPreviewHunk, gs.preview_hunk_inline, { desc = 'Preview Hunk Inline', buffer = buffer })
      map('n', variables.gitBlameHunk, blame_hunk, { desc = 'Blame Line', buffer = buffer })
      map('n', variables.gitBlameBuffer, blame_buffer, { desc = 'Blame Buffer', buffer = buffer })
      map('n', variables.gitDiffHunk, gs.diffthis, { desc = 'Diff This', buffer = buffer })
      map('n', variables.gitDiffBuffer, diff_buffer, { desc = 'Diff This ~', buffer = buffer })
    end,
  },
}
