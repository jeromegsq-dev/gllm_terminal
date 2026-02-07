# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| Latest  | :white_check_mark: |

We always recommend using the latest version of RememberCommands to ensure you have the most up-to-date security features and patches.

## Security Features

The RememberCommands plugin includes several built-in security protections:

### Network Security
- **HTTPS enforcement**: API URLs must use HTTPS protocol
- **TLS 1.2+ requirement**: Enforced via curl options
- **Certificate validation**: Relies on system CA bundle

### Input Validation
- **Length limits**: User input limited to 500 characters
- **Configuration validation**: Temperature (0-1) and max_tokens (1-4096) validated
- **Response length checks**: Warns on unusually long API responses (>1000 chars)

### Command Safety
- **Dangerous pattern detection**: Automatically detects risky commands:
  - `rm -rf /` or `rm -rf *`
  - `dd if=` (disk operations)
  - `mkfs` (filesystem formatting)
  - `sudo rm`
  - `chmod -R 777`
  - `chown -R`
- **User confirmation**: Prompts before pre-filling dangerous commands
- **Review before execution**: Commands are pre-filled, not auto-executed

### Data Protection
- **Error message sanitization**: Redacts potential API keys (32+ alphanumeric strings)
- **No automatic execution**: Users must press Enter after reviewing commands
- **No command logging**: Plugin does not store command history

## API Key Security

### Recommended: macOS Keychain

Store your API key in macOS Keychain instead of plaintext:

```bash
# One-time setup
security add-generic-password -a "$USER" -s "mistral-api-key" -w "your-api-key-here"

# Add to ~/.zshrc
export MISTRAL_API_KEY=$(security find-generic-password -a "$USER" -s "mistral-api-key" -w 2>/dev/null)
```

### What to Avoid

❌ **Don't:**
- Commit API keys to version control
- Store keys in plaintext files
- Share your API key publicly
- Use the same key across multiple projects/users

✅ **Do:**
- Use environment-specific keys
- Rotate keys regularly
- Set up billing alerts in Mistral console
- Review API usage periodically

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability in RememberCommands, please help us by reporting it responsibly.

### How to Report

1. **Open a GitHub Issue** with the "Security" label
2. **Include the following information:**
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact (data exposure, privilege escalation, etc.)
   - Suggested fix (if applicable)

3. **Do not:**
   - Disclose the vulnerability publicly before it's fixed
   - Exploit the vulnerability beyond confirming its existence
   - Test the vulnerability on systems you don't own

### What to Expect

- **Initial response**: Within 48 hours
- **Status update**: Within 7 days
- **Fix timeline**: Depends on severity (critical fixes within days, low-priority within weeks)
- **Credit**: Security researchers will be credited in release notes (unless anonymity is requested)

### Severity Levels

- **Critical**: Remote code execution, API key exposure
- **High**: Command injection, unauthorized API access
- **Medium**: Input validation bypass, information disclosure
- **Low**: Error message leaks, minor configuration issues

## Security Best Practices for Users

### Installation
- Only install from official repository
- Review code before running `install.sh`
- Verify symlink targets after installation

### Usage
- **Always review commands** before pressing Enter
- **Test with low-risk queries** first (e.g., `remembercmd list files`)
- **Be cautious with prompts** mentioning:
  - File deletion
  - Permission changes
  - System modifications
  - Sudo operations

### Monitoring
- Monitor API usage at https://console.mistral.ai
- Set up billing alerts
- Review generated commands periodically
- Check for unusual API activity

### Environment
- Keep Oh My Zsh updated
- Use the latest version of curl (with TLS 1.2+ support)
- Keep jq updated
- Ensure system CA certificates are current

## Known Limitations

### Current Scope
This plugin is designed for:
- ✅ Single-user development environments
- ✅ Local terminal usage
- ✅ Interactive command generation

It is **NOT designed for:**
- ❌ Multi-user or shared environments
- ❌ Automated/unattended execution
- ❌ Production server automation
- ❌ CI/CD pipelines

### Trust Model
- The plugin **trusts the Mistral API** to return safe commands
- Users **must review** all commands before execution
- The plugin **cannot guarantee** 100% detection of dangerous commands
- Advanced obfuscation techniques may bypass detection

## Incident Response

If you believe your API key has been compromised:

1. **Immediately revoke the key** at https://console.mistral.ai/api-keys
2. **Generate a new key** and update your configuration
3. **Review API usage logs** for unauthorized activity
4. **Report suspicious activity** to Mistral support
5. **Check billing** for unexpected charges

## Updates and Patches

Security updates are released as needed. To stay informed:
- ⭐ Star the repository on GitHub
- 👀 Watch releases
- 📢 Follow announcements

To update:

```bash
cd ~/.oh-my-zsh/custom/plugins/remembercommands
git pull
source ~/.zshrc
```

## Contact

For security concerns that don't fit the above categories, you can open a general GitHub Issue.

---

**Last Updated**: 2026-02-07  
**Version**: 1.0.0
