-- https://github.com/mxsdev/nvim-dap-vscode-js를 참고합시다.
-- LazyVim에서 vscode-js-debug를 설치해야합니다.
-- 71번쨰 라인의 경로와 debugServer.ts 위치가 일치해야합니다.
-- TODO: jest debug 설정은 아직 추가 되지 않았습니다.
return {
  "mfussenegger/nvim-dap",

  optional = true,

  dependencies = {
    "mxsdev/nvim-dap-vscode-js",
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

    -- 단일 typescript파일 debugging
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
              "/home/coco/.local/share/nvim/lazy/vscode-js-debug/out/src/vsDebugServer.js"
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
            name = "Launch file",
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
