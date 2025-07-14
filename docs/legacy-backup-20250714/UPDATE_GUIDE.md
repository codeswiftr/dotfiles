# 🔄 Dotfiles Update System Guide

## Overview

Your dotfiles now include a sophisticated version management and auto-update system similar to Oh My Zsh. This ensures you always have the latest features, bug fixes, and security improvements.

## 🚀 Quick Commands

```bash
# Check current version and update status
df-version

# Update to latest version
df-update

# View recent changes
df-changelog

# Auto-update (no prompts)
df-update --auto
```

## 🔍 How It Works

### **Automatic Update Checking**
- Checks for updates every **7 days** automatically
- Shows notification when updates are available
- Respects your workflow (only checks once per week)
- No network calls during normal shell usage

### **Version Management**
- **Current version**: Tracked in `~/dotfiles/VERSION`
- **Remote version**: Fetched from GitHub repository
- **Semantic versioning**: `YYYY.MAJOR.MINOR` format
- **Update history**: Logged in `~/.dotfiles_last_update_check`

### **Safe Updates**
- **Automatic backup**: Creates timestamped backup before updating
- **Git-based**: Uses git pull for reliable updates
- **Migration system**: Handles breaking changes automatically
- **Rollback support**: Easy restoration from backups

## 📋 Update Process

When you run `df-update`, here's what happens:

1. **🔍 Check for Updates**
   - Fetches latest version from GitHub
   - Compares with your current version
   - Shows what's new

2. **💾 Create Backup**
   - Backs up current configurations
   - Creates timestamped backup directory
   - Ensures you can rollback if needed

3. **📥 Download Updates**
   - Uses git to fetch latest changes
   - Handles merge conflicts gracefully
   - Stashes local changes if needed

4. **🔧 Run Migrations**
   - Executes version-specific migration scripts
   - Updates configurations for new features
   - Ensures compatibility with new versions

5. **🔗 Update Configurations**
   - Re-links configuration files
   - Updates scripts and permissions
   - Refreshes plugin installations

6. **✅ Verify Installation**
   - Tests that everything works
   - Shows what changed
   - Provides next steps

## 🎯 Update Notifications

When an update is available, you'll see:

```
╔══════════════════════════════════════════════════════════════╗
║                     🚀 Dotfiles Update Available             ║
╠══════════════════════════════════════════════════════════════╣
║  Current version: 2025.1.0                                  ║
║  Latest version:  2025.2.0                                  ║
║                                                              ║
║  Run 'dotfiles-update' to update your configuration         ║
║  Or use 'dotfiles-update --auto' for automatic updates     ║
╚══════════════════════════════════════════════════════════════╝
```

## 📖 Version Information

Use `df-version` to see detailed version information:

```
╔══════════════════════════════════════════════════════════════╗
║                   🚀 Dotfiles Version Info                  ║
╠══════════════════════════════════════════════════════════════╣
║  Current version: 2025.1.0                                  ║
║  Remote version:  2025.1.0                                  ║
║  Repository:      https://github.com/codeswiftr/dotfiles    ║
║  Last check:      Mon Jan  7 14:30:22 PST 2025             ║
╚══════════════════════════════════════════════════════════════╝
```

## 🔧 Configuration

### **Update Frequency**
The system checks for updates every 7 days by default. You can modify this by editing the `UPDATE_INTERVAL` in `lib/version.sh`:

```bash
UPDATE_INTERVAL=$((7 * 24 * 60 * 60))  # 7 days in seconds
```

### **Disable Auto-Checking**
If you prefer manual updates only, comment out this line in `.zshrc`:
```bash
# auto_update_check
```

### **Custom Update Prompts**
You can customize the update notifications by editing the `show_update_prompt()` function in `lib/version.sh`.

## 🛠️ Migration System

### **How Migrations Work**
When you update, the system runs migration scripts to handle:
- Configuration format changes
- New feature installations
- Deprecated setting removal
- File structure updates

### **Migration State**
Completed migrations are tracked in `~/.dotfiles_migrations` to ensure they only run once.

### **Adding Custom Migrations**
To add your own migration for version `2025.3.0`:

1. Edit `lib/migrate.sh`
2. Add a new function `migrate_2025_3_0()`
3. Add it to the migrations array
4. Include migration logic

## 🔄 Manual Update Process

If you prefer manual control:

```bash
# Navigate to dotfiles directory
cd ~/dotfiles

# Check for changes
git fetch origin

# View what's new
git log HEAD..origin/main --oneline

# Update manually
git pull origin main

# Run migrations
./lib/migrate.sh

# Reload configuration
source ~/.zshrc
```

## 🆘 Troubleshooting

### **Update Failed**
1. Check the error message
2. Ensure you have internet connectivity
3. Verify git repository is intact:
   ```bash
   cd ~/dotfiles && git status
   ```
4. Try manual update process

### **Restore from Backup**
If something goes wrong after an update:

1. Find your backup directory:
   ```bash
   ls ~/dotfiles-backup-*
   ```

2. Restore configurations:
   ```bash
   cp -r ~/dotfiles-backup-TIMESTAMP/.zshrc ~/
   cp -r ~/dotfiles-backup-TIMESTAMP/.tmux.conf ~/
   # etc.
   ```

### **Reset to Clean State**
For a fresh start:
```bash
cd ~/dotfiles
git reset --hard origin/main
./install.sh
```

## 📊 Version History

All changes are documented in `CHANGELOG.md` with:
- **Added**: New features
- **Changed**: Modifications to existing features  
- **Fixed**: Bug fixes
- **Removed**: Deprecated features
- **Security**: Security improvements

## 🎯 Best Practices

1. **Regular Updates**: Run `df-update` monthly for best experience
2. **Review Changes**: Check `df-changelog` before updating
3. **Backup Important**: Keep backups of custom modifications
4. **Test Updates**: Verify everything works after updating
5. **Report Issues**: Submit GitHub issues for problems

## 🚀 Future Features

Planned improvements:
- **Rollback command**: Easy version rollback
- **Update channels**: Stable vs. beta updates  
- **Custom hooks**: Pre/post update scripts
- **Update scheduling**: Automatic updates at specific times
- **Notification settings**: Customize update alerts

---

Your dotfiles now have enterprise-grade update management! 🎉