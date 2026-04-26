return {
  "3rd/image.nvim",
  dependencies = {
    "leafo/magick",
  },
  config = function()
    -- Lua 경로 추가 (magick을 찾을 수 있도록)
    package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua"
    package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua"
    package.cpath = package.cpath .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/lib/lua/5.1/?.so"

    require("image").setup({
      backend = "kitty", -- Ghostty는 Kitty protocol 지원!
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "markdown", "vimwiki" },
        },
        neorg = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "norg" },
        },
      },
      max_width = nil,
      max_height = nil,
      max_width_window_percentage = 50,
      max_height_window_percentage = 50,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    })
  end,
}
