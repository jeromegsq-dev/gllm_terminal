# RememberCommands - Oh My Zsh plugin entry point
# Translates natural language to shell commands using Mistral AI

local _remembercommands_dir="${0:A:h}"

source "${_remembercommands_dir}/config.zsh"
source "${_remembercommands_dir}/remembercommands.zsh"

# Create alias if different from default
if [[ "$REMEMBERCOMMANDS_ALIAS" != "remembercmd" ]]; then
  alias "$REMEMBERCOMMANDS_ALIAS"="remembercmd"
fi
