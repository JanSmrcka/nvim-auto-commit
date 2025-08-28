local M = {}

local defaults = {
  openai_api_key = os.getenv('OPENAI_API_KEY'),
  openai_model = 'gpt-3.5-turbo',
  max_commit_messages = 4,
  conventional_commits = true,
  auto_push = false,
  temperature = 0.7,
}

local config = {}

function M.setup(opts)
  config = vim.tbl_deep_extend('force', defaults, opts or {})
end

function M.get(key)
  if not config[key] then
    return defaults[key]
  end
  return config[key]
end

function M.get_all()
  return config
end

return M