vim.cmd 'let g:netrw_liststyle = 3'

local variables = require 'ihtesham.variables'

local opt = vim.opt

-- User-facing settings (numbers, indentation, search, ui, splits, ...) live in
-- lua/ihtesham/variables.lua under `options`.
for name, value in pairs(variables.options) do
  opt[name] = value
end

-- tabs & indentation
opt.autoindent = true -- copy indent from current line when starting new one
opt.fillchars = 'eob: '
