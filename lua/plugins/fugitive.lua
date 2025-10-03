return {
  "tpope/vim-fugitive",
  config = function()
	-- fugitive.vimのgit commitの画面をutf-8に変換してから閉じる
	vim.keymap.set("n",
	"<Leader>cmt",
	":set fenc=utf-8<CR>:wq!<CR>",
	{ noremap = true, silent = true })
  end,
}

