local MAX_DEPTH = 3

local function skip(path)
  return path:find("/node_modules/", 1, true) or path:find("/vendor/", 1, true) or path:find("/.git/", 1, true)
end

local function repo_depth(root, repo)
  if repo == root then
    return 0
  end
  local rel = repo:sub(#root + 2)
  local depth = 1
  for _ in rel:gmatch("/") do
    depth = depth + 1
  end
  return depth
end

local function find_git_paths(root)
  if vim.fn.executable("fd") == 1 then
    local job = vim.system({
      "fd",
      "--hidden",
      "--exclude",
      "node_modules",
      "--exclude",
      "vendor",
      "--max-depth",
      tostring(MAX_DEPTH),
      "--glob",
      ".git",
      "--absolute-path",
      root,
    }, { text = true })
    local result = job:wait()
    if result.code == 0 and result.stdout and result.stdout ~= "" then
      return vim.split(result.stdout, "\n", { trimempty = true })
    end
  end

  return vim.fs.find(".git", { path = root, upward = false, limit = 50 })
end

local function collect_repos()
  local cwd = vim.fs.normalize(vim.uv.cwd() or ".")
  local repos = {}
  local seen = {}

  local function add(repo)
    if not repo then
      return
    end
    repo = vim.fs.normalize(repo)
    if seen[repo] or skip(repo) or repo_depth(cwd, repo) > MAX_DEPTH then
      return
    end
    seen[repo] = true
    repos[#repos + 1] = repo
  end

  for _, gitpath in ipairs(find_git_paths(cwd)) do
    add(vim.fs.dirname(vim.fs.normalize(gitpath):gsub("/+$", "")))
  end

  local file = vim.api.nvim_buf_get_name(0)
  if file ~= "" then
    add(vim.fs.root(file, ".git"))
  end

  local current = file ~= "" and vim.fs.root(file, ".git") or nil
  table.sort(repos, function(a, b)
    if current then
      if a == current then
        return true
      end
      if b == current then
        return false
      end
    end
    return a < b
  end)

  return repos, cwd
end

local function repo_label(repo, cwd)
  if repo == cwd then
    return vim.fn.fnamemodify(repo, ":t")
  end
  if repo:sub(1, #cwd + 1) == cwd .. "/" then
    return repo:sub(#cwd + 2)
  end
  return vim.fn.fnamemodify(repo, ":~")
end

local function open_lazygit_at(repo)
  Snacks.lazygit({ cwd = repo })
end

local function open_lazygit()
  local repos, cwd = collect_repos()
  if #repos == 0 then
    Snacks.lazygit()
    return
  end
  if #repos == 1 then
    open_lazygit_at(repos[1])
    return
  end

  local items = {}
  for i, repo in ipairs(repos) do
    items[#items + 1] = {
      idx = i,
      text = repo_label(repo, cwd),
      repo = repo,
    }
  end

  Snacks.picker.pick({
    title = "Git repos",
    items = items,
    format = "text",
    preview = false,
    layout = { preset = "select" },
    confirm = function(picker, item)
      picker:close()
      vim.schedule(function()
        open_lazygit_at(item.repo)
      end)
    end,
  })
end

return {
  "snacks.nvim",
  keys = {
    { "<leader>gg", open_lazygit, desc = "Lazygit" },
  },
  init = function()
    -- LazyVim maps <leader>gg on VeryLazy; re-apply after that.
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        vim.keymap.set("n", "<leader>gg", open_lazygit, { desc = "Lazygit" })
      end,
    })
  end,
}
