return {
	"cohama/agit.vim",
	config = function()
		-- Agit.vim
		vim.g.agit_enable_auto_show_commit = 0

		-- autocmd
		vim.api.nvim_create_augroup("agit_rc", { clear = true })

		vim.api.nvim_create_autocmd("FileType", {
			group = "agit_rc",
			pattern = "agit",
			callback = function()
				vim.keymap.set("n", "cp", "<Plug>(agit-git-cherry-pick)", { buffer = true })
			end,
		})
	end,
}

