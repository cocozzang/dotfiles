return {
  "mfussenegger/nvim-dap",

  optional = true,

  dependencies = {
    -- "mxsdev/nvim-dap-vscode-js",
    {
      "rcarriga/nvim-dap-ui",
      dependencies = { "nvim-neotest/nvim-nio" },
    },
    {
      "theHamsta/nvim-dap-virtual-text",
      opts = {},
    },
    {
      "williamboman/mason.nvim",
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        table.insert(opts.ensure_installed, "js-debug-adapter")
      end,
    },
  },

  -- stylua: ignore
  keys = {
    { "<leader>do", function() require("dap").step_over() end, desc = "Step Over" },
    { "<leader>dO", function() require("dap").step_out() end, desc = "Step Out" },
  },

  opts = function()
    local dap = require("dap")

    -- typescript파일 debugging
    dap.configurations.typescript = {
      {
        name = "Launch Typescript file",
        type = "node",
        request = "launch",
        runtimeExecutable = "${workspaceFolder}/node_modules/.bin/ts-node",
        program = "${file}",
        rumtimeArgs = { "--transpile-only" },
        cwd = "${workspaceFolder}",
        protocol = "inspector",
        env = {
          stage = "debug",
        },
        skipFiles = { "<node_internals>/**", "node_modules/**" },
        sourceMaps = true,
        resolveSourceMapLocations = {
          "${workspaceFolder}/**",
          "!**/node_modules/**",
        },
      },
    }

    if not dap.adapters["pwa-node"] then
      require("dap").adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            LazyVim.get_pkg_path(
              "js-debug-adapter",
              "/home/coco/.local/share/nvim/lazy/vscode-js-debug/src/debugServer.ts"
            ),
            "${port}",
          },
        },
      }
    end
    if not dap.adapters["node"] then
      dap.adapters["node"] = function(cb, config)
        if config.type == "node" then
          config.type = "pwa-node"
        end
        local nativeAdapter = dap.adapters["pwa-node"]
        if type(nativeAdapter) == "function" then
          nativeAdapter(cb, config)
        else
          cb(nativeAdapter)
        end
      end
    end

    local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }

    local vscode = require("dap.ext.vscode")
    vscode.type_to_filetypes["node"] = js_filetypes
    vscode.type_to_filetypes["pwa-node"] = js_filetypes

    for _, language in ipairs(js_filetypes) do
      if not dap.configurations[language] then
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch Javascript file",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
        }
      end
    end
  end,
}
