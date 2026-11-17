return {
  'tomasky/bookmarks.nvim',
  config = function()
    local variables = require 'ihtesham.variables'
    local map = require('ihtesham.utils.functions').map
    require('bookmarks').setup {
      save_file = vim.fn.expand '$HOME/.bookmarks', -- bookmarks save file path
      keywords = {
        ['@t'] = '☑️ ', -- mark annotation startswith @t ,signs this icon as `Todo`
        ['@w'] = '⚠️ ', -- mark annotation startswith @w ,signs this icon as `Warn`
        ['@f'] = '⛏ ', -- mark annotation startswith @f ,signs this icon as `Fix`
        ['@n'] = ' ', -- mark annotation startswith @n ,signs this icon as `Note`
      },
      on_attach = function(_)
        local bm = require 'bookmarks'
        map('n', variables.bmToggle, bm.bookmark_toggle) -- add or remove bookmark at current line
        map('n', variables.bmAnnotation, bm.bookmark_ann) -- add or edit mark annotation at current line
        map('n', variables.bmClean, bm.bookmark_clean) -- clean all marks in local buffer
        map('n', variables.bmPrev, bm.bookmark_prev) -- jump to previous mark in local buffer
        map('n', variables.bmNext, bm.bookmark_next) -- jump to next mark in local buffer
        map('n', variables.bmList, '<cmd>Telescope bookmarks list<cr>') -- show marked file list in quickfix window
        map('n', variables.bmList, bm.bookmark_clear_all) -- removes all bookmarks
      end,
    }
  end,
}
