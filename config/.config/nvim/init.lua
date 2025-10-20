-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("config.keymaps")
require("lspconfig").protols.setup({})

vim.api.nvim_set_hl(0, "Cursor", { fg = "black", bg = "white" })
vim.api.nvim_set_hl(0, "CursorIM", { fg = "black", bg = "white" })
vim.lsp.enable("yamlls")
