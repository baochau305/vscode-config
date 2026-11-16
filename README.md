## 🚀 Setup Guide

### 1. Install Prerequisites

Before running the setup script, make sure you have:

- [Visual Studio Code](https://code.visualstudio.com/) installed.
- VS Code CLI (`code`) available in your terminal.
- Git installed.

To verify VS Code CLI:

```bash
code --version
```

### 2. Clone This Repository

```bash
git clone <your-repository-url>
cd vscode-config
```

### 3. Run the Setup Script

Make the script executable:

```bash
chmod +x setup.sh
```

Run the setup script:

```bash
./setup.sh
```

The script automatically handles:

- Importing `settings.json` into VS Code User Settings.
- Installing all extensions listed in `vscode-extensions.txt`.
- Importing `mcp.json` into your VS Code workspace configuration.
- Backing up existing settings and MCP configurations before replacing them.

### 4. Configure MCP Workspace (If Needed)

If you want to import MCP configurations into a specific project, run:

```bash
./setup.sh --workspace ~/Projects/my-project
```

This will place the MCP configuration at:

```text
my-project/
└── .vscode/
    └── mcp.json
```

Review the MCP configuration and provide any required API keys, environment variables, or credentials.

### 5. Verify Installation

After the script finishes, verify your environment:

```bash
# Check installed extensions
code --list-extensions

# Check VS Code version
code --version
```

Also verify that:
- [ ] VS Code settings have been imported.
- [ ] Required extensions are installed.
- [ ] MCP configurations are available in the workspace.
- [ ] MCP servers are running correctly.

## 🔄 Updating Configuration

Whenever you install a new extension or modify your VS Code settings:

**Update extensions list:**

```bash
code --list-extensions > vscode-extensions.txt
```

**Update settings:**

1. Open VS Code Settings JSON.
2. Copy the updated configuration into `settings.json`.

**Update MCP:**

1. Modify the MCP configuration in your workspace.
2. Copy the updated configuration into `mcp.json`.

Commit and push the changes to this repository.

## 📌 Notes

- The setup script currently supports macOS and Linux.
- Existing settings and MCP configurations are backed up before replacement.
- Make sure the VS Code CLI (`code`) is available in your terminal.
- Never commit API keys, access tokens, passwords, or other sensitive credentials to this repository.
- The `mcp.json` configuration is imported at the workspace level, not globally.

---

**That's it!** Run `./setup.sh` whenever you need to set up your VS Code development environment on a new machine.
