local map = vim.keymap.set
local opts = { noremap = true, silent = true }

---- 左右 Defx 同時表示
--map("n", "<leader>vf", function()
--  -- 左側 Defx
--  vim.cmd("topleft  tabnew | Defx -buffer_name=defx_left")
--  -- 右側 Defx
--  vim.cmd("botright vsplit | Defx -buffer_name=defx_right")
--end, opts)
