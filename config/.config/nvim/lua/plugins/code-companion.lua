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
          adapter = "gemini",
          tools = {
            groups = {
              ["mcp"] = {
                callback = require("mcphub.extensions.codecompanion"),
                description = "Call tools and resources from the MCP Servers",
                opts = {
                  requires_approval = false,
                },
              },
              ["cmd_runner"] = {
                opts = {
                  requires_approval = false,
                },
              },
              ["files"] = {
                opts = {
                  requires_approval = false,
                },
              },
            },
          },
        },
        inline = {
          adapter = "gemini",
        },
      },
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key = os.getenv("ANTHROPIC_API_KEY"),
            },
            schema = {
              model = {
                default = "claude-3-7-sonnet-20250219",
              },
            },
          })
        end,
        openai = function()
          return require("codecompanion.adapters").extend("openai", {
            env = {
              api_key = os.getenv("OPENAI_API_KEY"),
            },
            schema = {
              model = {
                default = "gpt-4o-mini",
              },
            },
          })
        end,
        gemini = function()
          return require("codecompanion.adapters").extend("gemini", {
            env = {
              api_key = os.getenv("GEMINI_API_KEY"),
            },
            schema = {
              model = {
                default = "gemini-2.5-pro-exp-03-25",
              },
            },
          })
        end,
      },
    })
  end,
}
