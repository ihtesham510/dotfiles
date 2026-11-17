local variables = require 'ihtesham.variables'
local map = require('ihtesham.utils.functions').map
return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'mason-org/mason.nvim', opts = {} },
    'mason-org/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    'b0o/schemastore.nvim',
  },

  config = function()
    local servers = {
      sqlls = {},
      qmlls = {
        cmd = { 'qmlls6' },
        filetypes = { 'qml', 'qmljs' },
      },
      pyright = {},
      clangd = {},
      dockerls = {},
      docker_compose_language_service = {},
      vtsls = {
        filetypes = {
          'javascript',
          'javascriptreact',
          'javascript.jsx',
          'typescript',
          'typescriptreact',
          'typescript.tsx',
        },
        settings = {
          complete_function_calls = true,
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              maxInlayHintLength = 30,
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = 'always' },
            suggest = {
              completeFunctionCalls = true,
            },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = 'literals' },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
          },
        },
      },
      emmet_ls = {},
      tailwindcss = {},
      rust_analyzer = {},
      jsonls = {
        settings = {
          json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
          },
          diagnostics = true,
        },
      },
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = { globals = { 'vim' } },
            completion = {
              callSnippet = 'Replace',
            },
          },
        },
      },
    }

    local tools = {
      'stylua',
      'taplo',
      'prettierd',
      'biome',
      'black',
      'pylint',
      'clang-format',
    }

    -- Setup Mason and Mason-LSPConfig
    require('mason').setup()
    require('mason-tool-installer').setup { ensure_installed = tools }

    local ensure_installed = vim.tbl_keys(servers)

    require('mason-lspconfig').setup {
      ensure_installed = ensure_installed,
      automatic_installation = true,
    }

    -- Setup capabilities for completion
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    -- Configure and enable all servers
    for server_name, server_config in pairs(servers) do
      -- Merge capabilities
      if capabilities then
        server_config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server_config.capabilities or {})
      end

      -- Configure the server
      vim.lsp.config(server_name, server_config)
      -- Enable the server
      vim.lsp.enable(server_name)
    end

    -- LSP Attach handler for keybindings and features
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local setKeymap = function(keys, func, desc, mode)
          mode = mode or 'n'
          map(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        setKeymap(variables.lspRename, vim.lsp.buf.rename, '[R]e[n]ame')
        setKeymap(variables.lspDiagnostics, vim.diagnostic.open_float, 'Show diagnostics under the cursor')

        setKeymap(variables.lspCodeAction, vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
        setKeymap(variables.lspReferences, require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        setKeymap(variables.lspImplementations, require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        setKeymap(variables.lspDefinitions, require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        setKeymap(variables.lspDeclaration, vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        setKeymap(variables.lspDocumentSymbols, require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
        setKeymap(variables.lspWorkspaceSymbols, require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
        setKeymap(variables.lspTypeDefinitions, require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if not client then
          return
        end

        -- Document highlight on hover
        if client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        -- Inlay hints toggle
        if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          setKeymap(variables.lspToggleInlayHints, function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    -- Diagnostic configuration
    vim.diagnostic.config {
      severity_sort = true,
      float = { border = 'rounded', source = 'if_many' },
      underline = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚 ',
          [vim.diagnostic.severity.WARN] = '󰀪 ',
          [vim.diagnostic.severity.INFO] = '󰋽 ',
          [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
      },
      virtual_text = {
        source = 'if_many',
        spacing = 2,
        format = function(diagnostic)
          return diagnostic.message
        end,
      },
    }
  end,
}
