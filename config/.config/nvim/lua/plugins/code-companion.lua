return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("codecompanion").setup({
      opts = {
        language = "Korean",
      },
      strategies = {
        chat = {
          adapter = "anthropic",
          tools = {
            ["mcp"] = {
              callback = require("mcphub.extensions.codecompanion"),
              description = "Call tools and resources from the MCP Servers",
              opts = {
                requires_approval = false,
              },
            },
          },
        },
        inline = {
          adapter = "anthropic",
        },
      },
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key = os.getenv("ANTHROPIC_API_KEY"),
            },
          })
        end,
        openai = function()
          return require("codecompanion.adapters").extend("openai", {
            env = {
              api_key = os.getenv("OPENAI_API_KEY"),
            },
          })
        end,
      },
    })
  end,
}
