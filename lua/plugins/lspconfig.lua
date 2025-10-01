return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    local mason_lspconfig = require("mason-lspconfig")

    mason_lspconfig.setup({
      ensure_installed = {
        "pyright",
        "html",
        "cssls",
        "eslint",
        "ts_ls",        -- TypeScript/JavaScript
        "intelephense",
        "sqlls",
      },
      automatic_installation = true,
    })

    local lspconfig = require("lspconfig")
    lspconfig.pyright.setup({})
    lspconfig.ts_ls.setup({})
    lspconfig.html.setup({})
    lspconfig.cssls.setup({})
    lspconfig.intelephense.setup({})
    lspconfig.sqlls.setup({})
  end,
}

