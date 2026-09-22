return {
  'atdma/caelestia-nvim',
  priority = 1000, -- Load before other plugins
  lazy = false, -- Load on startup
  opts = {}, -- Automatically calls require("caelestia").setup()
  config = function(_, opts)
    require('caelestia').setup(opts)
    vim.cmd.colorscheme 'caelestia'
  end,
}
