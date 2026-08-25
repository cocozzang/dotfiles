return {
  "cajames/copy-reference.nvim",
  opts = {}, -- optional configuration
  keys = {
    { "yrf", "<cmd>CopyReference file<cr>", mode = { "n", "v" }, desc = "Copy file path" },
    { "yrl", "<cmd>CopyReference line<cr>", mode = { "n", "v" }, desc = "Copy file:line reference" },
  },
}
