return {
  "L3MON4D3/LuaSnip",
  -- follow latest release.
  version = "v2.3", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
  -- install jsregexp (optional!).
  build = "make install_jsregexp",
  opts = function()
    local luasnip = require("luasnip")
    require("luasnip/loaders/from_vscode").lazy_load() -- needed this to show snippets

    -- or load using vscode-package-loader
    luasnip.snippets = {
      html = { "javascript", "javascriptreact", "tye", "typescriptreact" },
    }

    require("luasnip").filetype_extend("javascript", { "javascriptreact" })
    require("luasnip").filetype_extend("javascript", { "html" })
    require("luasnip").filetype_extend("typescriptreact", { "typescriptreact" })
    require("luasnip").filetype_extend("typescriptreact", { "html" })
  end,
}
