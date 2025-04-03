return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  version = false, -- set this if you want to always pull the latest change
  opts = {
    anthropic = {
      model = "claude-3-7-sonnet-20250219",
      timeout = 300000,
      max_tokens = 15000,
    },

    -- auto_suggestions_provider = "copilot",
    -- behaviour = {
    --   auto_suggestions = true,
    -- },
    -- provider = "openai",
    -- openai = {
    --   model = "gpt-4o-mini",
    -- },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  config = function()
    require("avante").setup({
      -- other config
      -- The system_prompt type supports both a string and a function that returns a string. Using a function here allows dynamically updating the prompt with mcphub
      system_prompt = function()
        local hub = require("mcphub").get_hub_instance()
        return hub:get_active_servers_prompt()
      end,
      -- The custom_tools type supports both a list and a function that returns a list. Using a function here prevents requiring mcphub before it's loaded
      custom_tools = function()
        return {
          require("mcphub.extensions.avante").mcp_tool(),
        }
      end,
    })
  end,
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter",
      opts = {
        highlight = { enable = true },
        indent = { enable = true },
      },
      ---@param opts TSConfig
      config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
      end,
    },
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
        latex = { enabled = false }, -- Disable LaTeX support
      },
      ft = { "markdown", "Avante" },
    },
  },
}
