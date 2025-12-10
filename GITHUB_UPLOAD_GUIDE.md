# GitHub Upload Guide

## Prerequisites

1. **Install Git for Windows:**
   - Download from: https://git-scm.com/download/win
   - Run installer with default settings
   - Restart VS Code after installation

2. **Create GitHub Account:**
   - Visit: https://github.com
   - Sign up if you don't have an account

## Step-by-Step Upload Process

### 1. Initialize Git Repository

Open PowerShell in VS Code and run:

```powershell
cd d:\Projects\OS_Project
git init
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

### 2. Stage All Files

```powershell
git add .
```

### 3. Create Initial Commit

```powershell
git commit -m "Initial commit: DNS Client Monitor with real-time tracking

Features:
- Real-time DNS client monitoring with tcpdump
- Activity timeout management (30s inactivity removal)
- IP blocking/unblocking via UFW firewall
- Live statistics and query tracking
- Professional terminal UI with color coding
- Automatic cleanup on exit

Technical Details:
- BIND9 DNS server integration
- Secure temporary file handling
- Root privilege validation
- Background packet capture process
- Interactive command system

Documentation:
- Comprehensive README with installation guide
- DNS configuration instructions
- Firewall setup documentation
- Pre-installation checklist
- XAMPP integration guide"
```

### 4. Create GitHub Repository

**Option A: Via GitHub Website**
1. Go to https://github.com/new
2. Repository name: `dns-client-monitor`
3. Description: `Real-time DNS client monitoring tool for BIND9 with activity tracking and IP management`
4. Choose: Public or Private
5. **DO NOT** initialize with README (we already have one)
6. Click "Create repository"

**Option B: Via GitHub CLI** (if installed)
```powershell
gh repo create dns-client-monitor --public --description "Real-time DNS client monitoring tool for BIND9"
```

### 5. Link to Remote Repository

Replace `YOUR_USERNAME` with your GitHub username:

```powershell
git remote add origin https://github.com/YOUR_USERNAME/dns-client-monitor.git
git branch -M main
```

### 6. Push to GitHub

```powershell
git push -u origin main
```

**If prompted for credentials:**
- Username: Your GitHub username
- Password: Use **Personal Access Token** (not your password)

### 7. Create Personal Access Token (if needed)

1. Go to: https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Note: "DNS Monitor Upload"
4. Select scopes: `repo` (all checkboxes)
5. Click "Generate token"
6. **Copy the token immediately** (you won't see it again)
7. Use this token as password when pushing

## Alternative: Using GitHub Desktop

1. **Download GitHub Desktop:**
   - https://desktop.github.com/
   - Install and sign in

2. **Add Repository:**
   - File → Add Local Repository
   - Choose: `d:\Projects\OS_Project`
   - Click "Create Repository" if prompted

3. **Publish to GitHub:**
   - Click "Publish repository"
   - Name: `dns-client-monitor`
   - Description: Add description
   - Uncheck "Keep this code private" for public repo
   - Click "Publish Repository"

## Repository URL

After upload, your project will be available at:
```
https://github.com/YOUR_USERNAME/dns-client-monitor
```

## Adding Repository Topics (Recommended)

On GitHub repository page:
1. Click ⚙️ (gear icon) next to "About"
2. Add topics:
   - `dns-monitoring`
   - `bind9`
   - `network-security`
   - `bash-script`
   - `system-administration`
   - `linux`
   - `real-time-monitoring`
3. Save changes

## Future Updates

To push updates:
```powershell
git add .
git commit -m "Description of changes"
git push
```

## Troubleshooting

**Error: "git is not recognized"**
- Install Git for Windows and restart terminal

**Error: "Permission denied (publickey)"**
- Use HTTPS URL instead of SSH
- Or set up SSH keys: https://docs.github.com/en/authentication

**Error: "Repository already exists"**
- Use a different repository name
- Or delete the existing repository on GitHub

## Making Repository Stand Out

1. **Add topics** (see above)
2. **Add a description** in repository settings
3. **Pin repository** to your profile
4. **Create releases** for versions
5. **Add a website** (GitHub Pages for docs)

---

**Note:** Replace all instances of `YOUR_USERNAME` with your actual GitHub username.
