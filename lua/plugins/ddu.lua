return{
	"Shougo/ddu.vim",
	dependencies = {
		"vim-denops/denops.vim",
		------------------------------
		-- | filter                   |
		------------------------------
		"Shougo/ddu-filter-matcher_substring",
		"uga-rosa/ddu-filter-converter_devicon",
		"Shougo/ddu-filter-sorter_alpha",
		"Shougo/ddu-filter-sorter_reversed",
		"kuuote/ddu-filter-sorter_mtime",
		"alpaca-tc/ddu-filter-sorter_directory_file",
		------------------------------
		-- | source                   |
		------------------------------
		"Shougo/ddu-source-file_rec", -- file_recursiveの略です。
		"Shougo/ddu-source-file",
		"Bakudankun/ddu-source-dirmark",
		------------------------------
		-- | kind                     |
		------------------------------
		"Shougo/ddu-kind-file",       -- ★ file kind を追加
		"Shougo/ddu-column-filename",
		"kmnk/denite-dirmark",
		------------------------------
		-- | ui                       |
		------------------------------
		"Shougo/ddu-ui-ff", -- fuzzy_finder(あいまい検索)
		"Shougo/ddu-ui-filer", 
	},

	config = function()
		--global
		vim.fn["ddu#custom#patch_global"]({
			ui = "filer",
			uiParams = {
				ff = {
					filterFloatingPosition = "bottom",
					filterSplitDirection = "floating",
					floatingBorder = "rounded",
					previewFloating = true,
					previewFloatingBorder = "rounded",
					previewFloatingTitle = "Preview",
					previewSplit = "horizontal",
					prompt = "> ",
					split = "floating",
					startFilter = true,
				},
				filer = {
					previewFloating = true,
					previewFloatingBorder = "rounded",
					previewFloatingTitle = "Preview",
					previewSplit = "horizontal",
					prompt = "> ",
					split = "no",
					startFilter = true,
				}
			},
			sources = {
				{
					name = "file",
					params = {},
					options = {
						matchers = {
							"matcher_substring",
						},
						sorters = {
							"sorter_alpha",
							-- "sorter_mtime",
							"sorter_directory_file",
							-- "sorter_reversed",
						},
					},
				},
			},
			sourceOptions = {
				file = {
					columns = { "customfilename", "filesize", "filedatetime"},
				},
			},
			columnParams = {
				filesize = {
					format = 'human',
					-- padding = 8,
				},
			},
			kindOptions = {
				file = {
					defaultAction = "open",
				},
				drives = {
					defaultAction = "open",
				}
			}
		})

		-- ----------------------------------------------------------------------------
		-- Filer操作のキーマップ
		-- ----------------------------------------------------------------------------
		vim.api.nvim_create_autocmd("FileType",{
			pattern = "ddu-filer",
			callback = function()
				local opts = { noremap = true, silent = true, buffer = true }
				local map = vim.keymap.set

				-- 親ディレクトリに移動
				cd_up = function()
					-- 現在の選択アイテム
					local nitem = vim.fn["ddu#ui#get_item"]("filer").action.path
					-- カーソル位置を取得
					local row, col = unpack(vim.api.nvim_win_get_cursor(0))
					if row == 1 then
						--カーソルが1行目の場合アイテムがそのまま現在のディレクトリ
						cwd = nitem
					else
						-- 2行目以降はアイテムから現在のディレクトリを取得
						cwd = vim.fn.fnamemodify(nitem, ":h")
					end

					-- 末尾に / が有れば削除
					if cwd:match("[/]$") then
						cwd = cwd:sub(1, -2)
					end

					-- 親ディレクトリを取得
					local new_dir = vim.fn.fnamemodify(cwd, ":h")
					-- 末尾に / が無ければ追加
					if not new_dir:match("[/]$") then
						new_dir = new_dir .. "/"
					end

					vim.fn["ddu#ui#do_action"]("itemAction", {
						name = "narrow",
						params = { path =new_dir }
					})
				end

				map("n", "<C-h>", cd_up, opts)
				map("n", "<BS>", cd_up, opts)

				map("n", "i", function() vim.fn["ddu#ui#do_action"]("openFilterWindow") end, opts)
				map("n", "c", function() vim.fn["ddu#ui#do_action"]("itemAction", { name = "copy" }) end, opts)
				map("n", "p", function() vim.fn["ddu#ui#do_action"]("itemAction", { name = "paste" }) end, opts)
				map("n", "d", function() vim.fn["ddu#ui#do_action"]("itemAction", { name = "delete" }) end, opts)
				map("n", "r", function() vim.fn["ddu#ui#do_action"]("itemAction", { name = "rename" }) end, opts)
				map("n", "m", function() vim.fn["ddu#ui#do_action"]("itemAction", { name = "move" }) end, opts)
				map("n", "N", function() vim.fn["ddu#ui#do_action"]("itemAction", { name = "newFile" }) end, opts)
				map("n", "K", function() vim.fn["ddu#ui#do_action"]("itemAction", { name = "newDirectory" }) end, opts)
				map("n", "yy", function() vim.fn["ddu#ui#do_action"]("itemAction", { name = "clipYank" }) end, opts)
				map("n", "<Space>", function() vim.fn["ddu#ui#do_action"]("toggleSelectItem") end, opts)
				map("n", "t", function() vim.fn["ddu#ui#do_action"]("expandItem", { mode = "toggle" }) end, opts)
				map("n", "x", function() vim.fn["ddu#ui#do_action"]("itemAction", { name = "executeSystem" }) end, opts)
				map("n", "q", function() vim.fn["ddu#ui#do_action"]("quit") end, opts)
				-- 決定（<CR>）
				vim.keymap.set("n", "<CR>", function()
					local item = vim.fn["ddu#ui#get_item"]()
					if item and item.isTree then
						vim.fn["ddu#ui#do_action"]("itemAction", { name = "narrow" })
					else
						vim.fn["ddu#ui#do_action"]("itemAction")
					end
				end, opts)
				map("n", "P", function() vim.fn["ddu#ui#do_action"]("togglePreview") end, opts)
				map("n", "<S-l>", function() vim.fn["ddu#start"]({name="ff_drives"}) end, opts)
			end,
		})
		-- ----------------------------------------------------------------------------
		-- Filer呼出のキーマップ
		-- ----------------------------------------------------------------------------

		local map = vim.keymap.set
		local opts = { noremap = true, silent = true }
		local tms = 0

		-- 左右 同時表示
		map("n", "<leader>vf", function()
			vim.cmd("tabnew")
			vim.cmd("vs")
			vim.fn["ddu#start"]({name="filerR" .. tms ,ui="filer"})
			vim.defer_fn(function()
				vim.cmd.wincmd("l")  -- 右へ
				vim.fn["ddu#start"]({ name = "filerL" .. tms, ui="filer"})
			end, 1000)
			tms = tms + 1
		end, opts)

		-- 左tree表示
		map("n", "<leader>tl", function()
			vim.fn["ddu#start"]({
				name="ftree",
				ui="filer",
				uiParams = {
					filer = {
						split = "vertical",
						winWidth = 35,
					},
				},
				sourceOptions = {
					file = {
						columns = { "filename"},
					},
				},
			})
		end, opts)

		-- :e . を ddu-filer に置き換え
		vim.api.nvim_create_user_command("EditDot", function(opts)
			if opts.args == "." then
				vim.fn["ddu#start"]({ name = "filer", ui = "filer", })
			else
				vim.cmd("edit " .. opts.args)
			end
		end, { nargs = 1, complete = "file" })

		-- :e を :EditDot に置き換え
		vim.cmd("cabbrev e EditDot")

		-- ----------------------------------------------------------------------------
		-- ff
		vim.fn["ddu#custom#patch_local"]("file_rec", {
			ui = "ff",
			sources = {
				{
					name = { "file_rec" },
					options = {
						matchers = {
							"matcher_substring",
						},
						converters = {
							"converter_devicon",
						},
						ignoreCase = true,
					},
					params = {
						ignoredDirectories = { "node_modules", ".git", "cache" },
						expandSymbolicLink = true,
					},
				},
			},
		})

		-- ----------------------------------------------------------------------------
		-- ff操作のキーマップ
		-- ----------------------------------------------------------------------------
		vim.api.nvim_create_autocmd("FileType",{
			pattern = "ddu-ff",
			callback = function()
				local opts = { noremap = true, silent = true, buffer = true }
				-- quit
				vim.keymap.set("n", "q", function() vim.fn["ddu#ui#do_action"]("quit") end, opts)
				-- 決定（<CR>）
				vim.keymap.set("n", "<CR>", function() vim.fn["ddu#ui#do_action"]("itemAction") end, opts)
				-- 決定（<CR>）
				-- vim.keymap.set("n", "<CR>", function()
				-- 	local item = vim.fn["ddu#ui#get_item"]()
				-- 	if item and item.isTree then
				-- 		vim.fn["ddu#ui#do_action"]("itemAction", { name = "cd" })
				-- 	else
				-- 		vim.fn["ddu#ui#do_action"]("itemAction")
				-- 	end
				-- end, opts)
				--filter
				vim.keymap.set("n", "i", function() vim.fn["ddu#ui#do_action"]("openFilterWindow") end, opts)
				-- Preview
				vim.keymap.set("n", "P", function() vim.fn["ddu#ui#do_action"]("togglePreview") end, opts)
			end,
		})

		vim.fn["ddu#custom#patch_local"]("ff_drives", {
			ui = "ff",
			sources = {
				{
					name = { "drives" },
					options = {
						matchers = {
							"matcher_substring",
						},
						ignoreCase = true,
					},
					params = {
						ignoredDirectories = { "node_modules", ".git", "cache" },
						expandSymbolicLink = true,
					},
				},
			},
		})

	end,
}
