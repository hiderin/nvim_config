-- netrw を無効化する
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Ctrl-C/V/X の Windows 風ショートカットを無効化
vim.keymap.set({"n", "v", "i"}, "<C-c>", "<C-c>", { noremap = true })
vim.keymap.set({"n", "v", "i"}, "<C-v>", "<C-v>", { noremap = true })
vim.keymap.set({"n", "v", "i"}, "<C-x>", "<C-x>", { noremap = true })

-- Leader キー
vim.g.mapleader = ","

-- マウス有効化
vim.opt.mouse = "a"

-- 日本語ファイルのエンコーディング判定
vim.opt.fileencodings = { "utf-8", "cp932", "iso-2022-jp-3" }

-- Neovim が使う Python provider を指定
vim.g.python3_host_prog = os.getenv("NVIM_PYTHON")

-- ファイルを閉じた後でも変更履歴を残す
vim.o.undofile = true
vim.o.undodir = vim.fn.stdpath("state") .. "/undo"

-- ==============================================================================
-- プラグインマネージャ
-- ==============================================================================
-- init.lua
require("lazy_init").setup()      -- lazy.nvim 読み込み
require("keymaps")   -- キーマップ（あれば）
-- Defx キーマップを適用 
vim.cmd('source ' .. vim.fn.stdpath('config') .. '/lua/keymaps_defx.vim')
-- ==============================================================================

-- カラー設定
-- set t_Co=256 は不要（Neovimは自動対応）
--vim.cmd("colorscheme desert") -- ctermdesert2 が無ければ desert に置き換え
vim.cmd("colorscheme ctermdesert2") -- ctermdesert2 が無ければ desert に置き換え

-- シンタックス関連
vim.cmd("syntax on")
vim.opt.synmaxcol = 200

-- =====================================================================
-- ステータスライン
-- （autocmd で色を変える設定は Neovim では lualine などのプラグイン利用推奨）
vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    vim.cmd("highlight StatusLine guifg=#ccdc90 guibg=#2E4340 ctermfg=blue ctermbg=green")
  end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    vim.cmd("highlight StatusLine guifg=#2E4340 guibg=#ccdc90 ctermfg=green ctermbg=blue")
  end,
})
vim.cmd("highlight StatusLine guifg=#2E4340 guibg=#ccdc90 ctermfg=green ctermbg=blue")

vim.opt.statusline = "%F%m%r%h%w%=[ENC=%{&fileencoding}][FF=%{&fileformat}][LOW=%l/%L]"
vim.opt.laststatus = 2

-- =====================================================================
-- 基本設定
vim.opt.fileformats = { "unix", "dos", "mac" }
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.scrolloff = 2
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.formatoptions = "q"
vim.opt.smartindent = true
vim.opt.cmdheight = 1
vim.opt.listchars = { tab = "^ ", trail = "_", eol = "$" }
vim.opt.list = true
vim.opt.wrap = false
vim.opt.tags = "./tags;/"
vim.opt.hidden = true
vim.opt.history = 100
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrapscan = true
vim.opt.incsearch = true
vim.opt.autoread = true

-- =====================================================================
-- 検索ハイライト解除
vim.keymap.set("n", "<Esc><Esc>", ":nohlsearch<CR>", { silent = true })

-- =====================================================================
-- 略語定義（コメント装飾）
vim.cmd [[
  inoreabbrev sl /*******************************************************************************
  inoreabbrev el *******************************************************************************/
  inoreabbrev l1 //------------------------------------------------------------------------------
  inoreabbrev l2 //==============================================================================
  inoreabbrev l3 ////////////////////////////////////////////////////////////////////////////////
  inoreabbrev vl1 '-------------------------------------------------------------------------------
  inoreabbrev vl2 '===============================================================================
  inoreabbrev vl3 '///////////////////////////////////////////////////////////////////////////////
]]

-- =====================================================================
--起動時にDefxの2画面ファイラを起動
--vim.api.nvim_create_autocmd("VimEnter", {
--  callback = function()
--    -- 起動時に引数が無い場合のみ実行
--    if vim.fn.argc() == 0 then
--      vim.cmd("topleft  Defx -buffer_name=defx_left")
--      vim.cmd("botright vsplit | Defx -buffer_name=defx_right")
--      vim.cmd("wincmd h") -- 左ウィンドウに移動
--    end
--  end,
--})
--
--コメントの自動挿入をキャンセル
vim.opt.formatoptions:remove({ "r", "o" })

