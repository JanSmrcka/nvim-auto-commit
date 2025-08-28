# nvim-auto-commit

**Never write commit messages again!** This Neovim plugin analyzes your staged git changes and generates multiple AI-powered commit messages. Simply stage your changes, run `:AICommit`, and select from 4 professionally crafted commit messages in a beautiful modal interface.

Perfect for developers who want consistent, high-quality commit messages without the mental overhead of writing them manually.

## Features

- 🤖 Generate commit messages using OpenAI GPT models
- 🎯 Modal selection interface with 4 suggested messages
- ⚡ Asynchronous generation (non-blocking)
- 📏 Conventional commit format support
- 🚀 Optional auto-push after commit
- ⚙️ Configurable AI model and parameters

## Requirements

- Neovim >= 0.8.0
- Git
- OpenAI API key

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'JanSmrcka/nvim-auto-commit',
  config = function()
    require('nvim-auto-commit').setup({
      -- Optional configuration
    })
  end
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'JanSmrcka/nvim-auto-commit',
  config = function()
    require('nvim-auto-commit').setup()
  end
}
```

### Local Development

For local testing:

```lua
-- lazy.nvim
{
  dir = '/path/to/your/nvim-auto-commit',
  config = function()
    require('nvim-auto-commit').setup()
  end
}

-- packer.nvim  
use {
  '/path/to/your/nvim-auto-commit',
  config = function()
    require('nvim-auto-commit').setup()
  end
}
```

## Setup

1. Set your OpenAI API key as an environment variable:
   ```bash
   export OPENAI_API_KEY="your-api-key-here"
   ```

2. Configure the plugin (optional):
   ```lua
   require('nvim-auto-commit').setup({
     openai_api_key = nil,           -- Uses OPENAI_API_KEY env var by default
     openai_model = 'gpt-3.5-turbo', -- OpenAI model to use
     max_commit_messages = 4,         -- Number of suggestions to generate
     conventional_commits = true,     -- Use conventional commit format
     auto_push = false,              -- Auto-push after commit
     temperature = 0.7,              -- AI creativity (0.0-1.0)
   })
   ```

## Quick Start

1. **Stage your changes**: `git add .` or `git add <files>`
2. **Generate commit messages**: Run `:AICommit` in Neovim
3. **Select and commit**: Choose from 4 AI-generated options:
   - Press `1`, `2`, `3`, or `4` to select instantly
   - Use arrow keys + `Enter` to navigate and select  
   - Press `q` or `Esc` to cancel

That's it! Your commit is created automatically with the selected message.

## Example Workflow

```
$ git add src/auth.lua
$ nvim
:AICommit

┌─────── Select Commit Message ───────┐
│ 1. feat(auth): add login validation │
│ 2. fix(auth): resolve session bug   │ 
│ 3. refactor: improve auth logic     │
│ 4. chore(auth): update dependencies │
│                                     │
│ Press number (1-4) to select, q to quit │
└─────────────────────────────────────┘
```

## Commands

- `:AICommit` - Generate and select AI commit messages

## Troubleshooting

**"OPENAI_API_KEY not configured"**
- Set your API key: `export OPENAI_API_KEY="sk-..."`
- Or configure in plugin setup: `openai_api_key = "sk-..."`

**"No staged changes found"**  
- Stage your changes first: `git add .` or `git add <files>`
- Check status: `git status`

**"Failed to generate commit messages"**
- Check your internet connection
- Verify your OpenAI API key is valid
- Try a smaller diff (large diffs are automatically truncated)

## Example Generated Messages

The AI analyzes your actual code changes and generates contextual commit messages:

**For adding a new feature:**
- `feat(auth): add JWT token validation`
- `feat(api): implement user registration endpoint`
- `feat(ui): add loading spinner component`

**For bug fixes:**
- `fix(database): resolve connection timeout issue`
- `fix(validation): handle empty email input`
- `fix(memory): prevent leak in event listeners`

**For refactoring:**
- `refactor(utils): simplify date formatting logic`
- `refactor(components): extract reusable button component`
- `refactor(api): consolidate error handling`

## Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `openai_api_key` | `$OPENAI_API_KEY` | Your OpenAI API key |
| `openai_model` | `'gpt-3.5-turbo'` | OpenAI model to use |
| `max_commit_messages` | `4` | Number of commit messages to generate |
| `conventional_commits` | `true` | Use conventional commit format |
| `auto_push` | `false` | Automatically push after commit |
| `temperature` | `0.7` | AI creativity level (0.0-1.0) |

## License

MIT