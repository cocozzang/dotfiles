return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      local function add(lang)
        if type(opts.ensure_installed) == "table" then
          table.insert(opts.ensure_installed, lang)
        end
      end

      vim.filetype.add({
        extension = { rasi = "rasi", rofi = "rasi", wofi = "rasi" },
        filename = {
          ["vifmrc"] = "vim",
        },
        pattern = {
          ["%.env.*"] = "sh",
          ["%.env%.[%w_.-]+"] = "sh",
          ["helmfile.*%.ya?ml"] = "helm",
          [".*%.conf"] = "nginx",
          [".*/waybar/config"] = "jsonc",
          [".*/mako/config"] = "dosini",
          [".*/kitty/.+%.conf"] = "bash",
          [".*/hypr/.+%.conf"] = "hyprlang",
        },
      })

      add("git_config")
    end,
  },
}
