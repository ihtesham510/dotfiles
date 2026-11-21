-- Wallpaper palette for Neovim.
--
-- The Quickshell side runs matugen on every wallpaper change and writes the
-- Material 3 roles to ~/.cache/quickshell/colors.json (see
-- dotfiles/matugen/.config/matugen). This module only reads them.
--
-- Nothing here is cached: the colorscheme re-reads the file when the watcher
-- fires, so switching wallpaper retints a running Neovim.

local M = {}

M.path = vim.fn.expand '~/.cache/quickshell/colors.json'

local function hex_to_rgb(hex)
  return tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
end

local function rgb_to_hex(r, g, b)
  return string.format('#%02x%02x%02x', math.floor(r + 0.5), math.floor(g + 0.5), math.floor(b + 0.5))
end

--- Read the palette written by matugen. Returns nil when it does not exist
--- (fresh install, or matugen is not installed).
--- @return table<string, string>|nil
function M.load()
  local f = io.open(M.path, 'r')
  if not f then
    return nil
  end
  local raw = f:read '*a'
  f:close()

  local ok, data = pcall(vim.json.decode, raw)
  if not ok or type(data) ~= 'table' then
    return nil
  end

  local out = {}
  for k, v in pairs(data) do
    if type(v) == 'string' and v:match '^#%x%x%x%x%x%x$' then
      out[k] = v
    end
  end
  for _, k in ipairs { 'surface', 'on_surface', 'primary', 'outline', 'error' } do
    if not out[k] then
      return nil
    end
  end
  return out
end

-- Only used when matugen did not emit a syntax_* colour (for example an old
-- colors.json written before the custom colours were added to the template).
-- Falls back to Material roles; nothing is computed. Each entry lists the
-- roles to try in order, first one present wins.
local SYNTAX_FALLBACK = {
  red = { 'error' },
  green = { 'secondary', 'primary' },
  yellow = { 'tertiary', 'primary' },
  blue = { 'primary' },
  magenta = { 'tertiary', 'primary' },
  cyan = { 'secondary', 'primary' },
}

--- Role-based fallback for any syntax_* colour.
--- @param p table<string, string>
--- @return table<string, string>
function M.syntax(p)
  local out = {}
  for name, roles in pairs(SYNTAX_FALLBACK) do
    for _, role in ipairs(roles) do
      if p[role] then
        out['syntax_' .. name] = p[role]
        break
      end
    end
  end
  return out
end

--- Palette from matugen. syntax_* colours supplied by matugen are used as-is;
--- the role fallback only fills in the ones that are missing.
--- @return table<string, string>|nil
function M.get()
  local p = M.load()
  if not p then
    return nil
  end
  for k, v in pairs(M.syntax(p)) do
    if not p[k] then
      p[k] = v
    end
  end
  return p
end

--- Blend two hex colours; a=1 is all c1.
function M.blend(c1, c2, a)
  local r1, g1, b1 = hex_to_rgb(c1)
  local r2, g2, b2 = hex_to_rgb(c2)
  return rgb_to_hex(r1 * a + r2 * (1 - a), g1 * a + g2 * (1 - a), b1 * a + b2 * (1 - a))
end

return M
