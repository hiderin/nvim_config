return {
	"cohama/agit.vim",
	config = function()
		-- Agit.vim
		-- カーソル移動で一覧と差分を更新させない
		vim.g.agit_enable_auto_show_commit = 0

		-- autocmd グループ
		vim.api.nvim_create_augroup("agit_rc", { clear = true })

		vim.api.nvim_create_autocmd("FileType", {
			group = "agit_rc",
			pattern = "agit",
			callback = function()
				-- デフォルトのキーマッピングを変更
				vim.keymap.set("n", "cp", "<Plug>(agit-git-cherry-pick)", { buffer = true })
			end,
		})
	end,
}

