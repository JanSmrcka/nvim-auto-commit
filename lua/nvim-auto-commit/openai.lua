local M = {}
local config = require('nvim-auto-commit.config')

local function make_openai_request(diff, callback)
  local api_key = config.get('openai_api_key')
  local model = config.get('openai_model')
  local max_messages = config.get('max_commit_messages')
  local conventional = config.get('conventional_commits')
  local temperature = config.get('temperature')
  
  if not api_key then
    callback(nil, 'OpenAI API key not configured')
    return
  end

  local prompt = string.format([[Analyze this git diff and generate %d concise commit messages in conventional commit format.

RULES:
- Format: type(scope): description
- Types: feat, fix, docs, style, refactor, test, chore
- Keep under 50 characters
- Focus on WHAT changed, not HOW
- Be specific and actionable

Git diff:
%s

Return ONLY the commit messages, one per line:]], 
    max_messages,
    diff
  )

  local data = {
    model = model,
    messages = {
      {
        role = "user",
        content = prompt
      }
    },
    temperature = temperature,
    max_tokens = 200
  }

  -- Write JSON to temp file
  local body = vim.json.encode(data)
  local temp_file = '/tmp/debug_openai.json'
  local file = io.open(temp_file, 'w')
  if file then
    file:write(body)
    file:close()
  else
    callback(nil, 'Failed to write temp file')
    return
  end

  local job_id = vim.fn.jobstart({'curl', '-s', '-X', 'POST', 
    'https://api.openai.com/v1/chat/completions',
    '-H', 'Content-Type: application/json',
    '-H', 'Authorization: Bearer ' .. api_key,
    '-d', '@' .. temp_file}, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_exit = function(_, code)
      os.remove(temp_file)
      if code ~= 0 then
        callback(nil, 'Curl failed with code: ' .. code)
      end
    end,
    on_stdout = function(_, response_data)
      local response = table.concat(response_data, '\n')
      
      local ok, parsed = pcall(vim.json.decode, response)
      
      if not ok then
        callback(nil, 'Failed to parse OpenAI response')
        return
      end

      if parsed.error then
        callback(nil, 'OpenAI error: ' .. parsed.error.message)
        return
      end

      if not parsed.choices or #parsed.choices == 0 then
        callback(nil, 'No commit messages in response')
        return
      end

      local content = parsed.choices[1].message.content
      
      local messages = {}
      for line in content:gmatch('[^\r\n]+') do
        local trimmed = line:match('^%s*(.-)%s*$')
        if trimmed and trimmed ~= '' then
          table.insert(messages, trimmed)
        end
      end

      callback(messages)
    end,
    on_stderr = function(_, error_data)
      local error_msg = table.concat(error_data, '\n')
      if error_msg ~= '' then
        callback(nil, 'Curl error: ' .. error_msg)
      end
    end
  })
end

function M.generate_commit_messages(diff, callback)
  make_openai_request(diff, callback)
end

return M