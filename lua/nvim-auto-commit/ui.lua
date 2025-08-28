local M = {}

function M.show_commit_selector(commit_messages, callback)
  local buf = vim.api.nvim_create_buf(false, true)
  
  local lines = {}
  for i, message in ipairs(commit_messages) do
    table.insert(lines, string.format('%d. %s', i, message))
  end
  
  table.insert(lines, '')
  table.insert(lines, 'Press number (1-' .. #commit_messages .. ') to select, q to quit')
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'filetype', 'nvim-auto-commit')

  local width = 80
  local height = #lines + 2
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    style = 'minimal',
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    border = 'rounded',
    title = ' Select Commit Message ',
    title_pos = 'center'
  })

  local function close_and_callback(selected_message)
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_buf_delete(buf, { force = true })
    callback(selected_message)
  end

  for i = 1, #commit_messages do
    vim.api.nvim_buf_set_keymap(buf, 'n', tostring(i), '', {
      noremap = true,
      silent = true,
      callback = function()
        close_and_callback(commit_messages[i])
      end
    })
  end

  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
    noremap = true,
    silent = true,
    callback = function()
      close_and_callback(nil)
    end
  })

  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '', {
    noremap = true,
    silent = true,
    callback = function()
      close_and_callback(nil)
    end
  })

  vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', {
    noremap = true,
    silent = true,
    callback = function()
      local line = vim.api.nvim_win_get_cursor(win)[1]
      if line <= #commit_messages then
        close_and_callback(commit_messages[line])
      end
    end
  })
end

return M