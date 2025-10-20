return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/neotest-jest",
  },
  opts = {
    adapters = {
      ["neotest-jest"] = {
        dap_js_enabled = true,
        -- jestCommand = "npm test --",
        -- jset-e2e.json파일은 프로젝트 root경로 또는 test폴더 하위에 있어야함
        jestConfigFile = function()
          local file = vim.fn.expand("%")
          if string.match(file, "e2e") then
            local test_config_path = "test/jest-e2e.json"
            if vim.fn.filereadable(test_config_path) == 1 then
              return test_config_path
            else
              return "jest-e2e.json"
            end
          end
        end,
        env = { CI = true, NODE_ENV = "test" },
        cwd = function()
          return vim.fn.getcwd()
        end,
      },
    },
  },
}
