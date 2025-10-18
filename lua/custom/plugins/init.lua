-- lua/custom/plugins/init.lua
return {
  {
    'nvimtools/none-ls.nvim',
    dependencies = {
      'nvimtools/none-ls-extras.nvim',
      'jayp0521/mason-null-ls.nvim',
    },
    config = function()
      require('mason-null-ls').setup {
        ensure_installed = {
          'ruff',
          'prettier',
          'shfmt',
          'clang-format', -- Keep this for formatting
          -- REMOVED: 'cpplint' - clangd handles linting via clang-tidy
        },
        automatic_installation = true,
      }

      local null_ls = require 'null-ls'

      local sources = {
        require('none-ls.formatting.ruff').with { extra_args = { '--extend-select', 'I' } },
        require 'none-ls.formatting.ruff_format',
        null_ls.builtins.formatting.prettier.with { filetypes = { 'json', 'yaml' } },
        null_ls.builtins.formatting.shfmt.with { args = { '-i', '4' } },
        null_ls.builtins.formatting.sqlformat.with {
          filetypes = { 'sql', 'mysql', 'pgsql', 'sqlpp' },
          extra_args = { '--reindent' },
        },

        -- REMOVED: cpplint diagnostics - clangd provides better linting

        -- C/C++ formatting with clang-format
        null_ls.builtins.formatting.clang_format.with {
          filetypes = { 'c', 'cpp', 'cc', 'cxx', 'h', 'hpp' },
          -- Optional: specify style
          -- extra_args = { '-style=Google' },
        },
      }

      local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
      null_ls.setup {
        sources = sources,
        on_attach = function(client, bufnr)
          if client.supports_method 'textDocument/formatting' then
            vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
            vim.api.nvim_create_autocmd('BufWritePre', {
              group = augroup,
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format { async = false }
              end,
            })
          end
        end,
      }
    end,
  },
}
