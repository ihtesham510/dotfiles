local M = {}

---@param mode string|string[]
---@param keys string|string[]
---@param action string|function|(string|function)[]  a table maps to keys by index
---@param opts? table  same as vim.keymap.set; `desc` may also be a table (one per key)
function M.map(mode, keys, action, opts)
  keys = type(keys) == 'table' and keys or { keys }
  opts = opts or {}

  local actions_is_list = type(action) == 'table'

  if actions_is_list and #keys ~= #action then
    vim.notify(string.format('keymap: %d keys but %d actions (first key: %s)', #keys, #action, tostring(keys[1])), vim.log.levels.ERROR)
    return
  end

  for i, lhs in ipairs(keys) do
    local rhs = actions_is_list and action[i] or action

    local o = opts
    if type(opts.desc) == 'table' then
      o = vim.tbl_extend('force', opts, { desc = opts.desc[i] })
    end

    vim.keymap.set(mode, lhs, rhs, o)
  end
end

---@param list table[]  each entry is { mode, keys, action, opts? }
function M.map_all(list)
  for _, m in ipairs(list) do
    M.map(m[1], m[2], m[3], m[4])
  end
end

return M
