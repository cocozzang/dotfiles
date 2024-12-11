return {
  "nvim-neo-tree/neo-tree.nvim",
  event = "VeryLazy",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
      },
      sort_function = function(a, b)
        vim.notify("Sorting: " .. a.name .. " vs " .. b.name)

        local function natural_sort(str)
          local segments = {}
          for segment in str:gmatch("%d+") do
            table.insert(segments, tonumber(segment) or segment)
          end
          return segments
        end

        local a_segments = natural_sort(a.name)
        local b_segments = natural_sort(b.name)

        for i = 1, math.min(#a_segments, #b_segments) do
          if a_segments[i] ~= b_segments[i] then
            return a_segments[i] < b_segments[i]
          end
        end

        return #a_segments < #b_segments
      end,
    },
  },
}

-- FIX: natural_sort가 왜안되냐.
--
-- https://github.com/nvim-neo-tree/neo-tree.nvim/issues/1226 (custom sort 관련 버그가 있음 처리되면 다시 적용하고 확인해보자)
-- custom sort_function을 neo-tree 기본로 override하거나 무시하는 경우일수도 있음.
-- return {
--   "nvim-neo-tree/neo-tree.nvim",
--   dependencies = { "nvim-lua/plenary.nvim" },
--   event = "VeryLazy", -- Neo-tree를 lazy-load로 설정
--   config = function()
--     require("neo-tree").setup({
--       filesystem = {
--         filtered_items = {
--           visible = true,
--         },
--         sort_function = function(a, b)
--           vim.notify("Sorting: " .. a.name .. " vs " .. b.name)
--
--           local function natural_sort(str)
--             local segments = {}
--             for segment in str:gmatch("%d+") do
--               table.insert(segments, tonumber(segment) or segment)
--             end
--             return segments
--           end
--
--           local a_segments = natural_sort(a.name)
--           local b_segments = natural_sort(b.name)
--
--           for i = 1, math.min(#a_segments, #b_segments) do
--             if a_segments[i] ~= b_segments[i] then
--               return a_segments[i] < b_segments[i]
--             end
--           end
--
--           return #a_segments < #b_segments
--         end,
--       },
--     })
--   end,
-- }
