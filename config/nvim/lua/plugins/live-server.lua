-- live server for html file
return {
  "barrett-ruth/live-server.nvim",
  build = "npm add -g live-server",
  cmd = { "LiveServerStart", "LiveServerStop" },
  config = true,
}
