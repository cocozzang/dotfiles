return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "typescript",
        "vim",
        "yaml",
        "prisma",
        "tsx",
        "typescript",
        "proto",
        "gotmpl",
        "helm",
      },
    },
    autotag = {
      enabled = true,
    },
  },

  {
    "dlvandenberg/nvim-treesitter-nginx",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },
}
