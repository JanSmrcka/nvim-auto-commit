local M = {}

local config = require('nvim-auto-commit.config')
local openai = require('nvim-auto-commit.openai')
local git = require('nvim-auto-commit.git')
local ui = require('nvim-auto-commit.ui')

function M.setup(opts)
  config.setup(opts or {})
end

function M.generate_commit()
  if not config.get('openai_api_key') then
    vim.notify('OPENAI_API_KEY not configured. Set it in your environment or plugin config.', vim.log.levels.ERROR)
    return
  end

  local staged_diff = git.get_staged_diff()
  if not staged_diff or staged_diff == '' then
    vim.notify('No staged changes found. Stage your changes with git add first.', vim.log.levels.WARN)
    return
  end

  vim.notify('Generating commit messages...', vim.log.levels.INFO)
  
  openai.generate_commit_messages(staged_diff, function(messages)
    if not messages or #messages == 0 then
      vim.notify('Failed to generate commit messages', vim.log.levels.ERROR)
      return
    end
    
    ui.show_commit_selector(messages, function(selected_message)
      if selected_message then
        git.commit_with_message(selected_message)
      end
    end)
  end)
end

return M