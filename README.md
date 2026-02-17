# RememberCommands - Natural Language to Shell Commands (ZSH)

A **ZSH / Oh My Zsh plugin** that translates natural language into shell commands using [Codestral](https://mistral.ai/news/codestral) (Mistral AI's code-specialized model). The suggested command is pre-filled on your command line so you can review it before pressing Enter.

> **Why?** I liked WARP's AI command generation, but I didn't want to give up my ZSH + Oh My Zsh setup just for that one feature. So I built this instead — same idea, works right in your existing terminal.

https://github.com/user-attachments/assets/847def64-2822-4754-a1c1-fe602b57c011

## Prerequisites

- **ZSH** with [Oh My Zsh](https://ohmyz.sh/) installed
- `curl` (pre-installed on macOS)
- `jq` - install with `brew install jq`
- A [Codestral API key](https://console.mistral.ai) (onglet "Codestral" sur console.mistral.ai)

## Installation

### Automatic

```bash
# Clone or navigate to this project, then run:
bash install.sh
```

### Configure

Add the following to your `~/.zshrc`:

```zsh
# Codestral API key (see Security section below for secure storage options)
# Obtenez votre clé sur https://console.mistral.ai (onglet Codestral)
export CODESTRAL_API_KEY="your-key-here"

# Add remembercommands to your plugins list
plugins=(remembercommands)
```

Then reload your shell:

```bash
source ~/.zshrc
```

**⚠️ Security Note:** Storing your API key directly in `~/.zshrc` exposes it in plaintext. See the [Security](#security) section below for safer alternatives using macOS Keychain.

## Usage

```bash
$ remembercmd list all files sorted by size
# Pre-fills: ls -lS

$ remembercmd find python files modified today
# Pre-fills: find . -name "*.py" -mtime 0

$ remembercmd count lines in all js files
# Pre-fills: find . -name "*.js" | xargs wc -l

$ remembercmd compress the logs folder
# Pre-fills: tar -czf logs.tar.gz logs/
```

The command appears on your terminal line ready to execute. Press **Enter** to run it, or edit it first.

### Custom Alias

You can use a shorter alias like `rr`, `rc`, or `cmd` instead of `remembercmd`. Add this to your `~/.zshrc` **before** the `plugins=()` line:

```zsh
export REMEMBERCOMMANDS_ALIAS="rr"
```

Then use it:
```bash
rr list all files
```

## Configuration

All settings can be overridden in your `~/.zshrc` (before the `plugins=()` line):

| Variable | Default | Description |
|---|---|---|
| `CODESTRAL_API_KEY` | *(required)* | Your Codestral API key (from console.mistral.ai, onglet Codestral) |
| `MISTRAL_API_KEY` | *(fallback)* | Fallback si `CODESTRAL_API_KEY` n'est pas défini |
| `REMEMBERCOMMANDS_ALIAS` | `remembercmd` | Custom command alias (e.g., `rr`, `rc`, `cmd`) |
| `REMEMBERCOMMANDS_MODEL` | `codestral-latest` | Codestral model to use |
| `REMEMBERCOMMANDS_TEMPERATURE` | `0.2` | Response creativity (0-1) |
| `REMEMBERCOMMANDS_MAX_TOKENS` | `200` | Max response length |
| `REMEMBERCOMMANDS_API_URL` | `https://codestral.mistral.ai/v1/chat/completions` | API endpoint |
| `REMEMBERCOMMANDS_SYSTEM_PROMPT` | *(built-in)* | Custom system prompt |

## Security

### API Key Storage

**⚠️ Important:** Never commit your API key to version control.

**Recommended: Use macOS Keychain** (most secure)

```bash
# Store your API key in Keychain (one-time setup)
security add-generic-password -a "$USER" -s "codestral-api-key" -w "your-api-key-here"

# Add this to your ~/.zshrc to retrieve it automatically
export CODESTRAL_API_KEY=$(security find-generic-password -a "$USER" -s "codestral-api-key" -w 2>/dev/null)
```

**Alternative: Environment Variable** (less secure)

```bash
# Add to ~/.zshrc
export CODESTRAL_API_KEY="your-key-here"
```

⚠️ **Warning:** Storing the key in `~/.zshrc` means:
- It's visible in plaintext on your disk
- It appears in `env` output
- It could be accidentally committed if you version-control your dotfiles

### Command Review & Safety

**Always review commands before executing.** The plugin pre-fills the command on your terminal line, allowing you to:
- Review the command for accuracy
- Edit it if needed
- Press **Ctrl+C** to cancel

**Dangerous Command Detection:** The plugin automatically detects potentially dangerous patterns like:
- `rm -rf /` or `rm -rf *`
- `dd if=` (disk operations)
- `mkfs` (filesystem formatting)
- `sudo rm` 
- `chmod -R 777`

When detected, you'll see a warning prompt before the command is pre-filled.

### Rate Limiting & API Usage

Be mindful of API usage. The Codestral API has rate limits and each request incurs costs. Consider:
- Reviewing your API usage at https://console.mistral.ai (onglet Codestral)
- Setting up billing alerts in your Mistral AI account
- Using the plugin judiciously for actual needs

### Security Features

This plugin includes several security protections:
- ✅ **HTTPS enforcement**: API URL must use HTTPS
- ✅ **TLS 1.2+ required**: Enforced via curl flags
- ✅ **Input validation**: Maximum 500 character input length
- ✅ **Configuration validation**: Temperature and token limits validated
- ✅ **Response length check**: Warns on unusually long responses
- ✅ **Error message sanitization**: API keys redacted from error messages
- ✅ **Dangerous command warnings**: Alerts before risky operations

### Reporting Security Issues

If you discover a security vulnerability, please report it by opening a GitHub Issue. Please include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact

Do not disclose security issues publicly until they are resolved.

## How It Works

1. You type `remembercmd <your question>`
2. The plugin sends your question to Codestral (Mistral AI) with a system prompt that instructs the model to return only the raw shell command
3. The response is cleaned up and placed on your command line using `print -z`
4. You review the command, optionally edit it, then press Enter to execute

## Troubleshooting

**`Error: CODESTRAL_API_KEY is not set`**
Add `export CODESTRAL_API_KEY="your-key"` to your `~/.zshrc` and run `source ~/.zshrc`. Obtenez votre clé sur https://console.mistral.ai (onglet Codestral).

**`Error: jq is required but not installed`**
Run `brew install jq`.

**`Error: Codestral API returned HTTP 401`**
Your API key is invalid. Check it at https://console.mistral.ai (onglet Codestral).

**`Error: Codestral API returned HTTP 429`**
Rate limited. Wait a moment and try again.

**Command not found: remembercmd**
Make sure `remembercommands` is in your `plugins=(...)` list in `~/.zshrc` and you ran `source ~/.zshrc`.
