return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = 20,
      open_mapping = [[<c-\>]],
      direction = "horizontal",
      shading_factor = 2,
      autochdir = true,
      persist_size = true,
    })
  end,
}

