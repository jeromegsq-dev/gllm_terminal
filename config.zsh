# RememberCommands configuration
# Override any of these in your .zshrc before the plugin loads

REMEMBERCOMMANDS_ALIAS="${REMEMBERCOMMANDS_ALIAS:-remembercmd}"
REMEMBERCOMMANDS_API_URL="${REMEMBERCOMMANDS_API_URL:-https://api.mistral.ai/v1/chat/completions}"
REMEMBERCOMMANDS_MODEL="${REMEMBERCOMMANDS_MODEL:-ministral-3b-latest}"
REMEMBERCOMMANDS_TEMPERATURE="${REMEMBERCOMMANDS_TEMPERATURE:-0.2}"
REMEMBERCOMMANDS_MAX_TOKENS="${REMEMBERCOMMANDS_MAX_TOKENS:-200}"
REMEMBERCOMMANDS_SYSTEM_PROMPT="${REMEMBERCOMMANDS_SYSTEM_PROMPT:-You are a bash shell command generator. The user describes what they want to do and you respond with ONLY the exact shell command to run. No explanation, no markdown, no code fences, no comments. Just the raw command. If multiple commands are needed, use the most used. Always prefer the simplest command, use basic commands over advanced ones when possible.}"
