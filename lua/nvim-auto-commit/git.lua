local M = {}
local config = require('nvim-auto-commit.config')

function M.get_staged_diff()
  local handle = io.popen('git diff --cached --no-color --ignore-cr-at-eol 2>/dev/null')
  if not handle then
    return nil
  end
  
  local result = handle:read('*all')
  handle:close()
  
  if not result then
    return nil
  end
  
  -- Filter out binary files and non-UTF8 content
  local lines = {}
  for line in result:gmatch('[^\r\n]*') do
    -- Skip binary file indicators, lines with null bytes, and control characters
    if not line:match('Binary files') and 
       not line:find('\0') and 
       not line:find('[\1-\8\11\12\14-\31\127]') then
      table.insert(lines, line)
    end
  end
  
  local filtered = table.concat(lines, '\n')
  
  -- Limit diff size to prevent API issues  
  if string.len(filtered) > 1500 then
    filtered = string.sub(filtered, 1, 1500) .. '\n... (diff truncated)'
  end
  
  return filtered
end

function M.has_staged_changes()
  local handle = io.popen('git diff --cached --name-only 2>/dev/null')
  if not handle then
    return false
  end
  
  local result = handle:read('*all')
  handle:close()
  
  return result and result:match('%S') ~= nil
end

function M.commit_with_message(message)
  if not message or message == '' then
    vim.notify('Empty commit message', vim.log.levels.ERROR)
    return false
  end

  local escaped_message = vim.fn.shellescape(message)
  local cmd = string.format('git commit -m %s', escaped_message)
  
  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.notify('✓ Committed: ' .. message, vim.log.levels.INFO)
        
        if config.get('auto_push') then
          M.push_changes()
        end
      else
        vim.notify('Failed to commit changes', vim.log.levels.ERROR)
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        local error_msg = table.concat(data, '\n')
        vim.notify('Git commit error: ' .. error_msg, vim.log.levels.ERROR)
      end
    end
  })
  
  return true
end

function M.push_changes()
  vim.notify('Pushing changes...', vim.log.levels.INFO)
  
  vim.fn.jobstart('git push', {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.notify('✓ Changes pushed successfully', vim.log.levels.INFO)
      else
        vim.notify('Failed to push changes', vim.log.levels.WARN)
      end
    end
  })
end

function M.get_repo_root()
  local handle = io.popen('git rev-parse --show-toplevel 2>/dev/null')
  if not handle then
    return nil
  end
  
  local result = handle:read('*all')
  handle:close()
  
  return result and result:match('^(.-)%s*$')
end

function M.is_git_repo()
  local handle = io.popen('git rev-parse --is-inside-work-tree 2>/dev/null')
  if not handle then
    return false
  end
  
  local result = handle:read('*all')
  handle:close()
  
  return result and result:match('true') ~= nil
end

return M