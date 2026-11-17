local variables = require 'ihtesham.variables'
local map_all = require('ihtesham.utils.functions').map_all
vim.g.mapleader = variables.leader

local opts = variables.defaultOpts

map_all {
  { 'v', 'p', '"_dP', { desc = 'Paste without yanking replaced text' } },
  { 'i', variables.exitInsertMode, '<ESC>', { desc = 'Exit insert mode with jk', silent = true } },
  { 'n', variables.copyWholeBuffer, '<cmd>%y+<cr>', { desc = 'Copy Whole Buffer' } },
  { 'n', variables.deleteAndYankWholeBuffer, '<cmd>%d+<cr>', { desc = 'Delete and Copy Whole Buffer' } },
  { 'n', variables.switchWindows, { '<C-w>h', '<C-w>j', '<C-w>k', '<C-w>l' } },
  { 'n', variables.clearHighlights, ':nohl<CR>', { desc = 'Clear search highlights', silent = true } },
  { 'v', variables.exitVisualMode, '<ESC>', { desc = 'Exit Visual Mode' } },
  { 'n', variables.saveFile, ':w<CR>', { desc = 'Save File', silent = true } },
  { 'n', variables.quit, ':qa<CR>', { desc = 'Quit', silent = true } },
  { 'x', variables.moveTextDown, ":m '>+1<CR>gv=gv", opts },
  { 'x', variables.moveTextUp, ":m '<-2<CR>gv=gv", opts },
  { 'n', variables.increment, '<C-a>', { desc = 'Increment number', silent = true } },
  { 'n', variables.decrement, '<C-x>', { desc = 'Decrement number', silent = true } },
  { 'n', variables.increaseWindowSize, '<C-w>>', { desc = 'Increase Window to left', silent = true } },
  { 'n', variables.nextTab, '<cmd>bnext<CR>', { desc = 'Next tab', silent = true } },
  { 'n', variables.prevTab, '<cmd>bprevious<CR>', { desc = 'Previous tab', silent = true } },
  { 'n', variables.closeTab, '<cmd>bd!<CR>', { desc = 'Close tab' } },
  { 'n', variables.decreaseWindowSize, '<C-w><', { desc = 'Increase Window to right', silent = true } },
  { 'n', variables.splitVertical, '<C-w>v', { desc = 'Split window vertically' } },
  { 'n', variables.splitHorizontal, '<C-w>s', { desc = 'Split window horizontally' } },
  { 'n', variables.makeWindowEquals, '<C-w>=', { desc = 'Make splits equal size' } },
  { 'n', variables.closeSplit, '<cmd>close<CR>', { desc = 'Close current split' } },
}
