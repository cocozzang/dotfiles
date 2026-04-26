-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- views can only be fully collapsed with the global statusline
vim.opt.laststatus = 3

local home = os.getenv("HOME")
package.path = package.path .. ";" .. home .. "/.luarocks/share/lua/5.1/?/init.lua"
package.path = package.path .. ";" .. home .. "/.luarocks/share/lua/5.1/?.lua"
package.cpath = package.cpath .. ";" .. home .. "/.luarocks/lib/lua/5.1/?.so"
