vim.keymap.set("n", "<leader><CR>", "o<Esc>", { desc = "new line in nomal mode" })
vim.keymap.set("i", "<C-a>", "<Esc>A", { desc = "jump to end of line in insert mode" })
vim.keymap.set("i", "<D-o>", "<Esc>o", { desc = "jump to next line in insert mode" })

-- Applied on VeryLazy so these win over LazyVim defaults.
-- init.lua requires this file early, which caches the module; LazyVim then
-- re-sets <leader><tab>l on VeryLazy and the second require is a no-op.
local function map_tabs()
  pcall(vim.keymap.del, "n", "<leader><tab>f")
  pcall(vim.keymap.del, "n", "<leader><tab>]")
  pcall(vim.keymap.del, "n", "<leader><tab>[")
  vim.keymap.set("n", "<leader><tab>l", "<cmd>tabnext<cr>", { desc = "Next Tab", silent = true })
  vim.keymap.set("n", "<leader><tab>h", "<cmd>tabprevious<cr>", { desc = "Previous Tab", silent = true })
  vim.keymap.set("n", "<leader><tab>j", "<cmd>tabfirst<cr>", { desc = "First Tab", silent = true })
  vim.keymap.set("n", "<leader><tab>k", "<cmd>tablast<cr>", { desc = "Last Tab", silent = true })
end
map_tabs()
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = map_tabs,
})

vim.keymap.set("n", "<D-j>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
vim.keymap.set("n", "<D-k>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
vim.keymap.set("i", "<D-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down", silent = true })
vim.keymap.set("i", "<D-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up", silent = true })
vim.keymap.set("v", "<D-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
vim.keymap.set("v", "<D-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })
