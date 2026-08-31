local wk = require("which-key")

wk.add({
  { "<leader>a", group = "+ai" },
  { "<leader>at", "<cmd>CodeCompanionChat Toggle<cr>" },
  { "<leader>aa", "<cmd>CodeCompanionAction<cr>" },
  { "<leader>am", "<cmd>MCPHub<cr>" },
})

-- Obsidian and Markdown Math
wk.add({
  { "<leader>o", group = "+obsidian" },

  -- Note Management
  { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New note" },
  { "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "Open in Obsidian" },
  { "<leader>oq", "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick switch" },
  { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Search notes" },

  -- Daily Notes
  { "<leader>od", group = "daily" },
  { "<leader>odt", "<cmd>ObsidianToday<cr>", desc = "Today" },
  { "<leader>ody", "<cmd>ObsidianYesterday<cr>", desc = "Yesterday" },
  { "<leader>odm", "<cmd>ObsidianTomorrow<cr>", desc = "Tomorrow" },
  { "<leader>odd", "<cmd>ObsidianDailies<cr>", desc = "Daily notes" },

  -- Links & Navigation
  { "<leader>ol", group = "links" },
  { "<leader>olf", "<cmd>ObsidianFollowLink<cr>", desc = "Follow link" },
  { "<leader>olb", "<cmd>ObsidianBacklinks<cr>", desc = "Backlinks" },
  { "<leader>oll", "<cmd>ObsidianLinks<cr>", desc = "All links" },
  { "<leader>oln", "<cmd>ObsidianLinkNew<cr>", desc = "Link to new note", mode = "v" },
  { "<leader>ole", "<cmd>ObsidianExtractNote<cr>", desc = "Extract to note", mode = "v" },

  -- Utilities
  { "<leader>or", "<cmd>ObsidianRename<cr>", desc = "Rename note" },
  { "<leader>ot", "<cmd>ObsidianTags<cr>", desc = "Find tags" },
  { "<leader>oc", "<cmd>ObsidianToggleCheckbox<cr>", desc = "Toggle checkbox" },
  { "<leader>op", "<cmd>ObsidianPasteImg<cr>", desc = "Paste image" },
  { "<leader>oT", "<cmd>ObsidianTemplate<cr>", desc = "Insert template" },
  { "<leader>ow", "<cmd>ObsidianWorkspace<cr>", desc = "Switch workspace" },
  { "<leader>om", "<cmd>MarkdownPreview<cr>", desc = "Markdown preview" },
})

wk.add({
  { "<leader>p", group = "+html-preview" },
  { "<leader>ps", "<cmd>LivePreview start<cr>", desc = "Html preview start" },
  { "<leader>pc", "<cmd>LivePreview close<cr>", desc = "Html preview close" },
})

return {}
