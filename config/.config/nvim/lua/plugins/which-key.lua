local wk = require("which-key")

wk.add({
  { "<leader>a", group = "+ai" },
  { "<leader>at", "<cmd>CodeCompanionChat Toggle<cr>" },
  { "<leader>aa", "<cmd>CodeCompanionAction<cr>" },
  { "<leader>am", "<cmd>MCPHub<cr>" },
})

return {}
