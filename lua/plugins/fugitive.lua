return {
  "tpope/vim-fugitive",
  config = function()
	-- fugitive.vim$B$N(Bgit commit$B$N2hLL$r(Butf-8$B$KJQ49$7$F$+$iJD$8$k(B
	vim.keymap.set("n",
	"<Leader>cmt",
	":set fenc=utf-8<CR>:wq!<CR>",
	{ noremap = true, silent = true })
  end,
}

