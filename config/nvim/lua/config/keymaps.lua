-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- add undo break-points
vim.keymap.set({ "n", "i", "v" }, "<C-z>", vim.cmd.undo, { desc = "Undo" })
vim.keymap.set("n", "<leader><CR>", "o<Esc>", { desc = "new line in nomal mode" })
