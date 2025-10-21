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
        "ts_ls",
        "intelephense",
        "sqlls",
      },
      automatic_installation = true,
    })

  end,
}
