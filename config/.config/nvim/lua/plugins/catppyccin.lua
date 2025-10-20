return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  opts = {
    transparent_background = true,
    styles = {
      sidebars = "transparent",
      floats = "transparent",
      comments = { "italic" },
      conditionals = { "italic" },
    },
    integrations = {
      telescope = true,
      nvimtree = true,
      which_key = true,
    },
  },
}
