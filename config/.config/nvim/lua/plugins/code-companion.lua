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
                callback = "strategies.chat.agents.tools.cmd_runner",
                description = "Run shell commands initiated by the LLM",
                opts = {
                  requires_approval = false,
                },
              },
              ["files"] = {
                callback = "strategies.chat.agents.tools.files",
                description = "Update the file system with the LLM's response",
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
    -- Add the keymap here
    vim.keymap.set("v", "<leader>ae", function()
      vim.ui.input({ prompt = "질문: " }, function(input)
        if input and input ~= "" then
          -- Execute CodeCompanion command for the visual selection
          -- Need to escape potential special characters in the input for the command line
          local escaped_input = vim.fn.escape(input, [[\"]])
          local cmd = string.format("'<','>CodeCompanion %s", escaped_input)
          -- Use feedkeys to ensure the command is executed correctly after UI input
          vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes(string.format(":%s<CR>", cmd), true, false, true),
            "n",
            false
          )
        end
      end)
    end, { desc = "CodeCompanion 인라인 질문 (선택 영역)" })
  end,
}
