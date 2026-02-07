# RememberCommands - Translate natural language to shell commands using Mistral AI

function remembercmd() {
  # Check arguments
  if [[ $# -eq 0 ]]; then
    echo "Usage: remembercmd <describe what you want to do>"
    echo "Example: remembercmd list all files sorted by size"
    return 1
  fi

  # Check jq dependency
  if ! command -v jq &>/dev/null; then
    echo "Error: jq is required but not installed."
    echo "Install it with: brew install jq"
    return 1
  fi

  # Check API key
  if [[ -z "$MISTRAL_API_KEY" ]]; then
    echo "Error: MISTRAL_API_KEY is not set."
    echo "Export it in your .zshrc: export MISTRAL_API_KEY=\"your-key-here\""
    return 1
  fi

  # Validate API URL uses HTTPS
  if [[ ! "$REMEMBERCOMMANDS_API_URL" =~ ^https:// ]]; then
    echo "Error: REMEMBERCOMMANDS_API_URL must use HTTPS for security (found: $REMEMBERCOMMANDS_API_URL)"
    echo "The default is: https://api.mistral.ai/v1/chat/completions"
    return 1
  fi

  # Validate configuration variables
  if [[ ! "$REMEMBERCOMMANDS_TEMPERATURE" =~ ^[0-1](\.[0-9]+)?$ ]]; then
    echo "Warning: Invalid REMEMBERCOMMANDS_TEMPERATURE ($REMEMBERCOMMANDS_TEMPERATURE), using default 0.2"
    REMEMBERCOMMANDS_TEMPERATURE=0.2
  fi

  if [[ ! "$REMEMBERCOMMANDS_MAX_TOKENS" =~ ^[0-9]+$ ]] || [[ "$REMEMBERCOMMANDS_MAX_TOKENS" -lt 1 ]] || [[ "$REMEMBERCOMMANDS_MAX_TOKENS" -gt 4096 ]]; then
    echo "Warning: Invalid REMEMBERCOMMANDS_MAX_TOKENS ($REMEMBERCOMMANDS_MAX_TOKENS), using default 200"
    REMEMBERCOMMANDS_MAX_TOKENS=200
  fi

  local user_message="$*"

  # Validate input length (max 500 chars)
  if [[ ${#user_message} -gt 500 ]]; then
    echo "Error: Input too long (${#user_message} chars). Maximum is 500 characters."
    return 1
  fi

  # Build JSON payload with safe escaping via jq
  local payload
  payload=$(jq -n \
    --arg model "$REMEMBERCOMMANDS_MODEL" \
    --arg system "$REMEMBERCOMMANDS_SYSTEM_PROMPT" \
    --arg user "$user_message" \
    --argjson temp "$REMEMBERCOMMANDS_TEMPERATURE" \
    --argjson max_tokens "$REMEMBERCOMMANDS_MAX_TOKENS" \
    '{
      model: $model,
      messages: [
        { role: "system", content: $system },
        { role: "user", content: $user }
      ],
      temperature: $temp,
      max_tokens: $max_tokens
    }')

  # Call Mistral API with enhanced security options
  local response
  response=$(curl -s -w "\n%{http_code}" \
    -X POST "$REMEMBERCOMMANDS_API_URL" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $MISTRAL_API_KEY" \
    -d "$payload" \
    --max-time 15 \
    --tlsv1.2 \
    --proto '=https')

  # Split response body and HTTP status code
  local http_code body
  http_code=$(echo "$response" | tail -1)
  body=$(echo "$response" | sed '$d')

  # Handle HTTP errors
  if [[ "$http_code" -ne 200 ]]; then
    echo "Error: Mistral API returned HTTP $http_code"
    local error_msg
    error_msg=$(echo "$body" | jq -r '.message // .error.message // "Unknown error"' 2>/dev/null)
    # Sanitize error message (remove potential API keys or sensitive data)
    error_msg=$(echo "$error_msg" | sed 's/[a-zA-Z0-9_-]\{32,\}/***REDACTED***/g')
    echo "Details: $error_msg"
    return 1
  fi

  # Extract command from response
  local command_text
  command_text=$(echo "$body" | jq -r '.choices[0].message.content' 2>/dev/null)

  if [[ -z "$command_text" || "$command_text" == "null" ]]; then
    echo "Error: Could not extract command from API response."
    return 1
  fi

  # Strip code fences and surrounding whitespace if the model added them
  command_text=$(echo "$command_text" | sed 's/^```[a-z]*//;s/```$//' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

  # Validate response length (should be a reasonable command, not a long script)
  if [[ ${#command_text} -gt 1000 ]]; then
    echo "Warning: API returned unusually long response (${#command_text} chars)"
    echo "This might not be a simple command. Review carefully before executing."
  fi

  # Check for dangerous command patterns
  local dangerous_patterns=(
    "rm -rf /"
    "rm -rf \*"
    "rm -rf ~"
    "dd if="
    "mkfs"
    "> /dev/sd"
    "> /dev/disk"
    ":(){:|:&};:"
    "sudo rm"
    "chmod -R 777"
    "chown -R"
  )

  for pattern in "${dangerous_patterns[@]}"; do
    if [[ "$command_text" == *"$pattern"* ]]; then
      echo ""
      echo "⚠️  WARNING: This command may be DANGEROUS!"
      echo "Command: $command_text"
      echo "Pattern detected: $pattern"
      echo ""
      echo "Press Ctrl+C to cancel, or any other key to continue..."
      read -k1 -s
      echo ""
      break
    fi
  done

  # Pre-fill command on the terminal line for user review
  print -z "$command_text"
}
