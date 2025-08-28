if vim.g.loaded_nvim_auto_commit then
  return
end
vim.g.loaded_nvim_auto_commit = 1

vim.api.nvim_create_user_command('AICommit', function()
  require('nvim-auto-commit').generate_commit()
end, {})

vim.api.nvim_create_user_command('AICommitConfig', function()
  require('nvim-auto-commit').setup()
end, {})