return {
  { import = "lazyvim.plugins.extras.lang.typescript" },
  { import = "lazyvim.plugins.extras.lang.json" },
  { import = "lazyvim.plugins.extras.formatting.prettier" },

  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      autoformat = false,
      servers = {
        vtsls = {
          settings = {
            typescript = {
              diagnostics = {
                noUnusedLocals = false,
                noUnusedParameters = false,
              },
            },
            javascript = {
              diagnostics = {
                noUnusedLocals = false,
                noUnusedParameters = false,
              },
            },
          },
        },
        eslint = {
          settings = {
            workingDirectory = { mode = "auto" },
            runOnSave = false,
            runOnType = false,
          },
        },
      },
      diagnostics = {
        virtual_text = { prefix = "●", spacing = 4 },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "vtsls",
        "eslint-lsp",
        "prettierd",
        "tailwindcss-language-server",
      },
    },
  },
}
