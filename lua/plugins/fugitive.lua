return {
  "tpope/vim-fugitive",
  config = function()
	-- fugitive.vim
	vim.keymap.set("n",
	"<Leader>cmt",
	":set fenc=utf-8<CR>:wq!<CR>",
	{ noremap = true, silent = true })
  end,
}

