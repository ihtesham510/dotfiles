-- Statusline colours come from the wallpaper palette. The fallbacks keep the
-- old look when matugen has not written a palette yet.
--
-- The theme is a *function*, not a table: lualine calls it again on every
-- ColorScheme (and `require('lualine').setup()` is re-run there), so switching
-- the wallpaper repaints the statusline instead of keeping the colours that
-- were current when the plugin first loaded.
local palette = require('ihtesham.palette')

local function build_theme()
  local p = palette.get()

  local colors
  if p then
    colors = {
      normal = p.primary,
      insert = p.syntax_green,
      visual = p.primary_container,
      visual_fg = p.on_primary_container,
      command = p.syntax_yellow,
      replace = p.error,
      fg = p.on_surface,
      -- "#00rrggbb" is fully transparent in Neovim, so the wallpaper shows through
      bg = '#00' .. p.surface:sub(2),
      nfg = p.on_primary,
      inactive_bg = p.surface_container_low,
      inactive_fg = p.outline,
    }
  else
    colors = {
      normal = '#848fbf',
      insert = '#3EFFDC',
      visual = '#3e279d',
      visual_fg = '#ffffff',
      command = '#FFDA7B',
      replace = '#FF4A4A',
      fg = '#ffffff',
      bg = '#00112638',
      nfg = '#000000',
      inactive_bg = '#2c3043',
      inactive_fg = '#a0a0a0',
    }
  end

  local function section(bg, fg)
    return {
      a = { bg = bg, fg = fg },
      b = { bg = colors.bg, fg = colors.fg },
      c = { bg = colors.bg, fg = colors.fg },
    }
  end

  return {
    normal = section(colors.normal, colors.nfg),
    insert = section(colors.insert, colors.nfg),
    visual = section(colors.visual, colors.visual_fg),
    command = section(colors.command, colors.nfg),
    replace = section(colors.replace, colors.nfg),
    inactive = {
      a = { bg = colors.inactive_bg, fg = colors.inactive_fg },
      b = { bg = colors.inactive_bg, fg = colors.inactive_fg },
      c = { bg = colors.inactive_bg, fg = colors.inactive_fg },
    },
  }
end
local hide_in_width = function()
  return vim.fn.winwidth(0) > 80
end
local diff = {
  'diff',
  colored = true,
  symbols = { added = ' ', modified = ' ', removed = ' ' }, -- changes diff symbols
  cond = hide_in_width,
}

return {
  'nvim-lualine/lualine.nvim',
  config = function()
    require('lualine').setup {
      options = {
        icons_enabled = true,
        theme = build_theme,
        component_separators = { left = '|', right = '|' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', diff },
        lualine_c = {},
        lualine_x = { 'diagnostics' },
        lualine_y = { 'filetype' },
        lualine_z = { 'progress', 'filename' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {},
    }
  end,
}
