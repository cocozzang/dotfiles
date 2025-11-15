return {
  "nvim-neo-tree/neo-tree.nvim",
  event = "VeryLazy",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
      },
    },
    sort_case_insensitive = true,
    -- 자연스러운 숫자 정렬 함수
    sort_function = function(a, b)
      -- nil 체크
      if not a or not b then
        return false
      end
      
      -- name 필드가 없는 경우 처리
      local a_name = a.name or ""
      local b_name = b.name or ""
      
      -- 디렉토리가 파일보다 먼저 오도록
      if a.type ~= b.type then
        return a.type < b.type
      end

      -- 자연스러운 숫자 정렬을 위한 함수
      local function split_name(name)
        local parts = {}
        -- 숫자와 문자를 분리
        for num, text in name:gmatch("(%d*)([^%d]*)") do
          if num ~= "" then
            table.insert(parts, { type = "number", value = tonumber(num) })
          end
          if text ~= "" then
            table.insert(parts, { type = "text", value = text })
          end
        end
        return parts
      end

      local a_parts = split_name(a_name:lower())
      local b_parts = split_name(b_name:lower())

      -- 각 부분을 비교
      for i = 1, math.max(#a_parts, #b_parts) do
        local a_part = a_parts[i]
        local b_part = b_parts[i]

        -- 한쪽이 끝난 경우
        if not a_part then
          return true
        end
        if not b_part then
          return false
        end

        -- 둘 다 숫자인 경우
        if a_part.type == "number" and b_part.type == "number" then
          if a_part.value ~= b_part.value then
            return a_part.value < b_part.value
          end
        -- 한쪽만 숫자인 경우 (숫자가 먼저)
        elseif a_part.type == "number" then
          return true
        elseif b_part.type == "number" then
          return false
        -- 둘 다 텍스트인 경우
        else
          if a_part.value ~= b_part.value then
            return a_part.value < b_part.value
          end
        end
      end

      return false
    end,
  },
}
