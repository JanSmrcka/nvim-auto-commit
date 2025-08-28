# nvim-auto-commit

A Neovim plugin that generates AI-powered commit messages using OpenAI's API. Select from multiple generated suggestions in a clean modal interface.

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

## Usage

1. Stage your changes with `git add`
2. Run `:AICommit` in Neovim
3. Wait for AI to generate commit messages
4. Select a message using number keys (1-4) or navigate with arrow keys and press Enter
5. Press `q` or `Esc` to cancel

## Commands

- `:AICommit` - Generate and select AI commit messages
- `:AICommitConfig` - Open configuration (if implemented)

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