return {
  "nvim-telescope/telescope.nvim",
  opts = function()
    local actions = require("telescope.actions")

    return {

      defaults = {
        mappings = {
          i = {
            ["<C-Y>"] = actions.select_vertical,
          },
          n = {
            ["<C-Y>"] = actions.select_vertical,
          },
        },
      },
    }
  end,
}
