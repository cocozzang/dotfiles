return {
  "mfussenegger/nvim-dap",
  keys = {
    {
      "<leader>do",
      function()
        require("dap").step_over()
      end,
      desc = "Step Over",
    },
    {
      "<leader>dO",
      function()
        require("dap").step_out()
      end,
      desc = "Step Out",
    },
  },
  opts = function(_, opts)
    -- 기존 LazyVim DAP 설정에 추가
    local dap = require("dap")

    -- TypeScript 디버깅 설정 수정
    if dap.configurations.typescript then
      for _, config in ipairs(dap.configurations.typescript) do
        -- Source Map 비활성화
        config.sourceMaps = false
        -- 스킵 파일 추가
        config.skipFiles = config.skipFiles or {}
        vim.list_extend(config.skipFiles, {
          "**/*.js.map",
          "**/dist/**/*.map",
          "**/node_modules/**",
        })
      end
    end

    return opts
  end,
}
