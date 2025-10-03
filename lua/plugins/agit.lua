return {
	"cohama/agit.vim",
	config = function()
		-- Agit.vim
		-- $B%+!<%=%k0\F0$G0lMw$H:9J,$r99?7$5$;$J$$(B
		vim.g.agit_enable_auto_show_commit = 0

		-- autocmd $B%0%k!<%W(B
		vim.api.nvim_create_augroup("agit_rc", { clear = true })

		vim.api.nvim_create_autocmd("FileType", {
			group = "agit_rc",
			pattern = "agit",
			callback = function()
				-- $B%G%U%)%k%H$N%-!<%^%C%T%s%0$rJQ99(B
				vim.keymap.set("n", "cp", "<Plug>(agit-git-cherry-pick)", { buffer = true })
			end,
		})
	end,
}

