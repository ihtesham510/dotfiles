return {
  'nvim-treesitter/nvim-treesitter',
  event = { 'BufReadPre', 'BufNewFile' },
  -- `master` is the frozen v1 branch. It is the only branch that still supports
  -- the `highlight`/`indent`/`ensure_installed` config below, so stay on it and
  -- patch the one Neovim 0.12 incompatibility at the bottom of this file.
  branch = 'master',
  build = ':TSUpdate',
  config = function()
    local treesitter = require 'nvim-treesitter.configs'

    -- configure treesitter
    treesitter.setup { -- enable syntax highlighting
      auto_install = true,
      highlight = {
        enable = true,
      },
      -- enable indentation
      indent = { enable = true },
      -- ensure these language parsers are installed
      ensure_installed = {
        'json',
        'javascript',
        'typescript',
        'tsx',
        'yaml',
        'html',
        'css',
        'prisma',
        'markdown',
        'markdown_inline',
        'svelte',
        'graphql',
        'bash',
        'lua',
        'vim',
        'dockerfile',
        'gitignore',
        'query',
        'vimdoc',
        'c',
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<C-space>',
          node_incremental = '<C-space>',
          scope_incremental = false,
          node_decremental = '<bs>',
        },
      },
    }

    -- Neovim 0.12 compatibility shim.
    --
    -- nvim-treesitter's markdown injection query uses its own
    -- `#set-lang-from-info-string!` directive. Its handler predates the 0.11
    -- change where `Query:iter_matches()` returns a *list* of nodes per
    -- capture; it opted into the legacy single-node behaviour with
    -- `{ all = false }`, and Neovim 0.12 removed that option (see :h news).
    -- The handler then passes a node list to `get_node_text()`, which fails
    -- with "attempt to call method 'range' (a nil value)" on any markdown file
    -- that has a language-tagged code fence (e.g. README.md).
    --
    -- Re-register the directive with a 0.12-shaped handler. Must run after
    -- `require 'nvim-treesitter.configs'` above, which is what registers the
    -- original one.
    vim.treesitter.query.add_directive('set-lang-from-info-string!', function(match, _, bufnr, pred, metadata)
      local nodes = match[pred[2]]
      if not nodes or #nodes == 0 then
        return
      end

      local alias = vim.treesitter.get_node_text(nodes[1], bufnr):lower()
      -- `vim.filetype.match` maps aliases like sh -> bash and ts -> typescript;
      -- fall back to the raw alias for anything it does not know.
      metadata['injection.language'] = vim.filetype.match { filename = 'a.' .. alias } or alias
    end, { force = true })

    -- use bash parser for zsh files
    vim.treesitter.language.register('bash', 'zsh')
  end,
}
