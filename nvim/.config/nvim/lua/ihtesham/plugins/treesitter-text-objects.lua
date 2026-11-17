local variables = require 'ihtesham.variables'
local map = require('ihtesham.utils.functions').map

return {
  'nvim-treesitter/nvim-treesitter-textobjects',
  lazy = true,
  config = function()
    require('nvim-treesitter.configs').setup {
      textobjects = {
        select = {
          enable = true,

          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,

          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            [variables.sOAssignment] = { query = '@assignment.outer', desc = 'Select outer part of an assignment' },
            [variables.sIAssignment] = { query = '@assignment.inner', desc = 'Select inner part of an assignment' },
            [variables.sLhsAssignment] = { query = '@assignment.lhs', desc = 'Select left hand side of an assignment' },
            [variables.sRhsAssignment] = { query = '@assignment.rhs', desc = 'Select right hand side of an assignment' },

            -- works for javascript/typescript files (custom capture I created in after/queries/ecma/textobjects.scm)
            [variables.sOProperty] = { query = '@property.outer', desc = 'Select outer part of an object property' },
            [variables.sIProperty] = { query = '@property.inner', desc = 'Select inner part of an object property' },
            [variables.sLhsProperty] = { query = '@property.lhs', desc = 'Select left part of an object property' },
            [variables.sRhsProperty] = { query = '@property.rhs', desc = 'Select right part of an object property' },

            [variables.sOParam] = { query = '@parameter.outer', desc = 'Select outer part of a parameter/argument' },
            [variables.sIParam] = { query = '@parameter.inner', desc = 'Select inner part of a parameter/argument' },

            [variables.sOCon] = { query = '@conditional.outer', desc = 'Select outer part of a conditional' },
            [variables.sICon] = { query = '@conditional.inner', desc = 'Select inner part of a conditional' },

            [variables.sOLoop] = { query = '@loop.outer', desc = 'Select outer part of a loop' },
            [variables.sILoop] = { query = '@loop.inner', desc = 'Select inner part of a loop' },

            [variables.sOFunc] = { query = '@call.outer', desc = 'Select outer part of a function call' },
            [variables.sIFunc] = { query = '@call.inner', desc = 'Select inner part of a function call' },

            [variables.sOMethod] = { query = '@function.outer', desc = 'Select outer part of a method/function definition' },
            [variables.sIMethod] = { query = '@function.inner', desc = 'Select inner part of a method/function definition' },

            [variables.sOClass] = { query = '@class.outer', desc = 'Select outer part of a class' },
            [variables.sIClass] = { query = '@class.inner', desc = 'Select inner part of a class' },
          },
        },
        swap = {
          enable = true,
          swap_next = {
            [variables.tsSwapNextParam] = '@parameter.inner', -- swap parameters/argument with next
            [variables.tsSwapNextProperty] = '@property.outer', -- swap object property with next
            [variables.tsSwapNextMethod] = '@function.outer', -- swap function with next
          },
          swap_previous = {
            [variables.tsSwapPrevParam] = '@parameter.inner', -- swap parameters/argument with prev
            [variables.tsSwapPrevProperty] = '@property.outer', -- swap object property with prev
            [variables.tsSwapPrevMethod] = '@function.outer', -- swap function with previous
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [variables.tsNextCallStart] = { query = '@call.outer', desc = 'Next function call start' },
            [variables.tsNextMethodStart] = { query = '@function.outer', desc = 'Next method/function def start' },
            [variables.tsNextClassStart] = { query = '@class.outer', desc = 'Next class start' },
            [variables.tsNextCondStart] = { query = '@conditional.outer', desc = 'Next conditional start' },
            [variables.tsNextLoopStart] = { query = '@loop.outer', desc = 'Next loop start' },

            -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
            -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
            [variables.tsNextScope] = { query = '@scope', query_group = 'locals', desc = 'Next scope' },
            [variables.tsNextFold] = { query = '@fold', query_group = 'folds', desc = 'Next fold' },
          },
          goto_next_end = {
            [variables.tsNextCallEnd] = { query = '@call.outer', desc = 'Next function call end' },
            [variables.tsNextMethodEnd] = { query = '@function.outer', desc = 'Next method/function def end' },
            [variables.tsNextClassEnd] = { query = '@class.outer', desc = 'Next class end' },
            [variables.tsNextCondEnd] = { query = '@conditional.outer', desc = 'Next conditional end' },
            [variables.tsNextLoopEnd] = { query = '@loop.outer', desc = 'Next loop end' },
          },
          goto_previous_start = {
            [variables.tsPrevCallStart] = { query = '@call.outer', desc = 'Prev function call start' },
            [variables.tsPrevMethodStart] = { query = '@function.outer', desc = 'Prev method/function def start' },
            [variables.tsPrevClassStart] = { query = '@class.outer', desc = 'Prev class start' },
            [variables.tsPrevCondStart] = { query = '@conditional.outer', desc = 'Prev conditional start' },
            [variables.tsPrevLoopStart] = { query = '@loop.outer', desc = 'Prev loop start' },
          },
          goto_previous_end = {
            [variables.tsPrevCallEnd] = { query = '@call.outer', desc = 'Prev function call end' },
            [variables.tsPrevMethodEnd] = { query = '@function.outer', desc = 'Prev method/function def end' },
            [variables.tsPrevClassEnd] = { query = '@class.outer', desc = 'Prev class end' },
            [variables.tsPrevCondEnd] = { query = '@conditional.outer', desc = 'Prev conditional end' },
            [variables.tsPrevLoopEnd] = { query = '@loop.outer', desc = 'Prev loop end' },
          },
        },
      },
    }

    local ts_repeat_move = require 'nvim-treesitter.textobjects.repeatable_move'

    -- vim way: ; goes to the direction you were moving.
    map({ 'n', 'x', 'o' }, variables.tsRepeatMove, ts_repeat_move.repeat_last_move)
    map({ 'n', 'x', 'o' }, variables.tsRepeatMoveOpposite, ts_repeat_move.repeat_last_move_opposite)

    -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
    map({ 'n', 'x', 'o' }, variables.tsFind, ts_repeat_move.builtin_f)
    map({ 'n', 'x', 'o' }, variables.tsFindBack, ts_repeat_move.builtin_F)
    map({ 'n', 'x', 'o' }, variables.tsTill, ts_repeat_move.builtin_t)
    map({ 'n', 'x', 'o' }, variables.tsTillBack, ts_repeat_move.builtin_T)
  end,
}
