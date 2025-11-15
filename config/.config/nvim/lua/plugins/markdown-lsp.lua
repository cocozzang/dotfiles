return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Disable marksman by default
        marksman = {
          autostart = false,
        },
        -- Disable markdown-oxide by default
        markdown_oxide = {
          autostart = false,
          capabilities = {
            workspace = {
              didChangeWatchedFiles = {
                dynamicRegistration = true,
              },
            },
          },
        },
      },
      setup = {
        -- Custom setup for markdown LSPs
        marksman = function(_, opts)
          local lspconfig = require("lspconfig")

          lspconfig.marksman.setup(vim.tbl_deep_extend("force", opts, {
            on_attach = function(client, bufnr)
              -- Only attach marksman if NOT in obsidian directory
              local buf_path = vim.api.nvim_buf_get_name(bufnr)
              local obsidian_path = vim.fn.expand("~/obsidian")

              if buf_path:match("^" .. obsidian_path) then
                vim.lsp.stop_client(client.id)
                return
              end
            end,
          }))
          return true
        end,

        markdown_oxide = function(_, opts)
          local lspconfig = require("lspconfig")

          lspconfig.markdown_oxide.setup(vim.tbl_deep_extend("force", opts, {
            on_attach = function(client, bufnr)
              -- Only attach markdown-oxide if in obsidian directory
              local buf_path = vim.api.nvim_buf_get_name(bufnr)
              local obsidian_path = vim.fn.expand("~/obsidian")

              if not buf_path:match("^" .. obsidian_path) then
                vim.lsp.stop_client(client.id)
                return
              end
            end,
          }))
          return true
        end,
      },
    },
  },

  -- Auto-start correct LSP based on file location
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Autocommand to start the correct LSP when opening markdown files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(args)
          local buf_path = vim.api.nvim_buf_get_name(args.buf)
          local obsidian_path = vim.fn.expand("~/obsidian")

          if buf_path:match("^" .. obsidian_path) then
            -- Start markdown-oxide for obsidian files
            vim.cmd("LspStart markdown_oxide")
          else
            -- Start marksman for other markdown files
            vim.cmd("LspStart marksman")
          end
        end,
      })
    end,
  },
}
