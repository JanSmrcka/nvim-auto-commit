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

  local prompt = string.format([[
Generate %d different commit messages for the following git diff. 
%s
Return only the commit messages, one per line, without any additional text or formatting.
The messages should be:
- Clear and descriptive
- Under 50 characters for the subject line
- Follow best practices for git commit messages
%s

Git diff:
```
%s
```]], 
    max_messages,
    conventional and "Use conventional commit format (type(scope): description)." or "",
    conventional and "Examples: feat: add user authentication, fix: resolve memory leak, docs: update API documentation" or "",
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

  local json_data = vim.fn.json_encode(data)
  
  local cmd = string.format(
    'curl -s -X POST "https://api.openai.com/v1/chat/completions" ' ..
    '-H "Content-Type: application/json" ' ..
    '-H "Authorization: Bearer %s" ' ..
    '-d %s',
    api_key,
    vim.fn.shellescape(json_data)
  )

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      local response = table.concat(data, '\n')
      local ok, parsed = pcall(vim.fn.json_decode, response)
      
      if not ok then
        callback(nil, 'Failed to parse OpenAI response')
        return
      end

      if parsed.error then
        callback(nil, 'OpenAI API error: ' .. (parsed.error.message or 'Unknown error'))
        return
      end

      if not parsed.choices or #parsed.choices == 0 then
        callback(nil, 'No commit messages generated')
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
    on_stderr = function(_, data)
      if data and #data > 0 then
        local error_msg = table.concat(data, '\n')
        callback(nil, 'Request failed: ' .. error_msg)
      end
    end
  })
end

function M.generate_commit_messages(diff, callback)
  make_openai_request(diff, callback)
end

return M