# =============================================================================
# Linux-specific ZSH Configuration
# Platform-specific settings and optimizations for Linux distributions
# =============================================================================

# Linux-specific environment variables
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Distribution-specific settings
case "$PLATFORM_DISTRO" in
    debian)
        export DEBIAN_FRONTEND=noninteractive
        ;;
    arch)
        export MAKEPKG_CONF="/etc/makepkg.conf"
        ;;
    rhel)
        export HISTTIMEFORMAT="%F %T "
        ;;
esac

# Linux-specific aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Package manager aliases based on distribution
case "$PLATFORM_PACKAGE_MANAGER" in
    apt)
        alias update='sudo apt update && sudo apt upgrade'
        alias install='sudo apt install'
        alias search='apt search'
        alias remove='sudo apt remove'
        alias autoremove='sudo apt autoremove'
        alias purge='sudo apt purge'
        alias pkginfo='apt show'
        ;;
    pacman)
        alias update='sudo pacman -Syu'
        alias install='sudo pacman -S'
        alias search='pacman -Ss'
        alias remove='sudo pacman -R'
        alias autoremove='sudo pacman -Rs'
        alias pkginfo='pacman -Si'
        alias orphans='pacman -Qtdq'
        ;;
    dnf)
        alias update='sudo dnf update'
        alias install='sudo dnf install'
        alias search='dnf search'
        alias remove='sudo dnf remove'
        alias autoremove='sudo dnf autoremove'
        alias pkginfo='dnf info'
        ;;
    yum)
        alias update='sudo yum update'
        alias install='sudo yum install'
        alias search='yum search'
        alias remove='sudo yum remove'
        alias pkginfo='yum info'
        ;;
esac

# System information aliases
alias sysinfo='uname -a && lsb_release -a 2>/dev/null || cat /etc/os-release'
alias meminfo='free -h'
alias diskinfo='df -h'
alias cpuinfo='lscpu'
alias netinfo='ip addr show'

# Process management
alias psg='ps aux | grep'
alias topcpu='ps auxf | sort -nr -k 3 | head -10'
alias topmem='ps auxf | sort -nr -k 4 | head -10'

# Network utilities
alias ports='netstat -tulpn'
alias listening='netstat -tln'
alias established='netstat -tn | grep ESTABLISHED'

# Service management (systemd)
if command -v systemctl >/dev/null 2>&1; then
    alias services='systemctl list-units --type=service'
    alias service-status='systemctl status'
    alias service-start='sudo systemctl start'
    alias service-stop='sudo systemctl stop'
    alias service-restart='sudo systemctl restart'
    alias service-enable='sudo systemctl enable'
    alias service-disable='sudo systemctl disable'
    alias logs='sudo journalctl -u'
    alias boot-logs='sudo journalctl -b'
fi

# Linux-specific functions
linux-info() {
    echo "🐧 Linux System Information"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Kernel: $(uname -r)"
    echo "Distribution: $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
    echo "Architecture: $(uname -m)"
    echo "Hostname: $(hostname)"
    echo "Uptime: $(uptime -p 2>/dev/null || uptime | awk '{print $3,$4}' | sed 's/,//')"
    
    # Memory information
    if command -v free >/dev/null 2>&1; then
        local mem_info=$(free -h | awk 'NR==2{printf "Memory: %s/%s (%.2f%%)", $3, $2, $3/$2*100}')
        echo "$mem_info"
    fi
    
    # Disk information
    local disk_info=$(df -h / | awk 'NR==2{printf "Disk: %s/%s (%s used)", $3, $2, $5}')
    echo "$disk_info"
    
    # Load average
    echo "Load: $(cat /proc/loadavg | awk '{print $1, $2, $3}')"
    
    # Package manager info
    case "$PLATFORM_PACKAGE_MANAGER" in
        apt)
            local pkg_count=$(dpkg -l | grep "^ii" | wc -l)
            echo "Packages (apt): $pkg_count installed"
            ;;
        pacman)
            local pkg_count=$(pacman -Q | wc -l)
            echo "Packages (pacman): $pkg_count installed"
            ;;
        dnf|yum)
            local pkg_count=$(rpm -qa | wc -l)
            echo "Packages (rpm): $pkg_count installed"
            ;;
    esac
}

# Distribution-specific package management
pkg-cleanup() {
    echo "🧹 Cleaning package manager cache..."
    
    case "$PLATFORM_PACKAGE_MANAGER" in
        apt)
            sudo apt autoremove -y
            sudo apt autoclean
            sudo apt clean
            ;;
        pacman)
            sudo pacman -Sc --noconfirm
            if pacman -Qtdq >/dev/null 2>&1; then
                sudo pacman -Rs $(pacman -Qtdq) --noconfirm
            fi
            ;;
        dnf)
            sudo dnf autoremove -y
            sudo dnf clean all
            ;;
        yum)
            sudo yum autoremove -y
            sudo yum clean all
            ;;
    esac
    
    echo "✅ Package cleanup complete"
}

# Security updates
security-update() {
    echo "🔒 Installing security updates..."
    
    case "$PLATFORM_PACKAGE_MANAGER" in
        apt)
            sudo apt update
            sudo apt upgrade -y
            sudo unattended-upgrade -d || true
            ;;
        pacman)
            sudo pacman -Syu --noconfirm
            ;;
        dnf)
            sudo dnf update -y --security
            ;;
        yum)
            sudo yum update -y --security
            ;;
    esac
    
    echo "✅ Security updates complete"
}

# Firewall management
firewall-status() {
    if command -v ufw >/dev/null 2>&1; then
        sudo ufw status verbose
    elif command -v firewall-cmd >/dev/null 2>&1; then
        sudo firewall-cmd --list-all
    elif command -v iptables >/dev/null 2>&1; then
        sudo iptables -L -n -v
    else
        echo "No firewall management tool found"
    fi
}

firewall-enable() {
    if command -v ufw >/dev/null 2>&1; then
        sudo ufw --force enable
    elif command -v firewall-cmd >/dev/null 2>&1; then
        sudo systemctl enable --now firewalld
    else
        echo "No firewall management tool found"
    fi
}

# System monitoring
monitor-system() {
    echo "📊 System Monitoring"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # CPU usage
    echo "CPU Usage:"
    if command -v htop >/dev/null 2>&1; then
        htop -n 1 | head -10
    else
        top -bn1 | head -20
    fi
    
    # Memory usage
    echo -e "\nMemory Usage:"
    free -h
    
    # Disk usage
    echo -e "\nDisk Usage:"
    df -h | grep -E '^/dev/'
    
    # Network connections
    echo -e "\nActive Network Connections:"
    netstat -tulpn | head -10
}

# Development environment setup
dev-setup() {
    echo "🛠️ Setting up Linux development environment..."
    
    # Install essential development tools
    case "$PLATFORM_PACKAGE_MANAGER" in
        apt)
            sudo apt update
            sudo apt install -y build-essential curl wget git vim
            sudo apt install -y software-properties-common apt-transport-https
            ;;
        pacman)
            sudo pacman -S --noconfirm base-devel curl wget git vim
            ;;
        dnf)
            sudo dnf groupinstall -y "Development Tools"
            sudo dnf install -y curl wget git vim
            ;;
        yum)
            sudo yum groupinstall -y "Development Tools"
            sudo yum install -y curl wget git vim
            ;;
    esac
    
    # Install modern tools
    install_linux_external_tools
    
    echo "✅ Development environment setup complete"
}

# Container management
docker-cleanup() {
    if command -v docker >/dev/null 2>&1; then
        echo "🐳 Cleaning Docker resources..."
        docker system prune -af
        docker volume prune -f
        echo "✅ Docker cleanup complete"
    else
        echo "Docker not installed"
    fi
}

# Log management
logs-analyze() {
    local service="$1"
    
    if [[ -n "$service" ]]; then
        echo "📋 Analyzing logs for service: $service"
        sudo journalctl -u "$service" --since "24 hours ago" | tail -50
    else
        echo "📋 Recent system logs:"
        sudo journalctl --since "1 hour ago" | tail -50
    fi
}

# File permissions helper
fix-permissions() {
    local target="${1:-.}"
    
    echo "🔧 Fixing permissions for: $target"
    
    # Fix directory permissions
    find "$target" -type d -exec chmod 755 {} \;
    
    # Fix file permissions
    find "$target" -type f -exec chmod 644 {} \;
    
    # Make scripts executable
    find "$target" -name "*.sh" -exec chmod +x {} \;
    find "$target" -name "*.py" -exec chmod +x {} \;
    find "$target" -name "*.pl" -exec chmod +x {} \;
    
    echo "✅ Permissions fixed"
}

# Hardware information
hardware-info() {
    echo "🖥️ Hardware Information"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # CPU information
    echo "CPU:"
    lscpu | grep -E "Model name|CPU\(s\)|Thread|Core"
    
    # Memory information
    echo -e "\nMemory:"
    sudo dmidecode -t memory | grep -E "Size|Speed|Type:" | head -10
    
    # Disk information
    echo -e "\nDisks:"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
    
    # Graphics information
    echo -e "\nGraphics:"
    lspci | grep -i vga
    
    # Network interfaces
    echo -e "\nNetwork:"
    ip link show | grep -E "^[0-9]" | awk '{print $2}' | sed 's/://'
}

# Linux-specific PATH additions
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# Add Snap to PATH if available
if [[ -d "/snap/bin" ]]; then
    export PATH="/snap/bin:$PATH"
fi

# Add Flatpak to PATH if available
if [[ -d "/var/lib/flatpak/exports/bin" ]]; then
    export PATH="/var/lib/flatpak/exports/bin:$PATH"
fi

# Rust/Cargo path
if [[ -d "$HOME/.cargo/bin" ]]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Go path
if [[ -d "/usr/local/go/bin" ]]; then
    export PATH="/usr/local/go/bin:$PATH"
fi
if [[ -d "$HOME/go/bin" ]]; then
    export PATH="$HOME/go/bin:$PATH"
fi

# Python user path
if command -v python3 >/dev/null 2>&1; then
    export PATH="$(python3 -m site --user-base)/bin:$PATH"
fi

# Linux-specific environment optimizations
export EDITOR="${EDITOR:-nano}"
export BROWSER="${BROWSER:-firefox}"

# Locale settings
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# Less configuration
export LESS="-R"
export LESSHISTFILE="/dev/null"

# Man page colors
export MANPAGER="less -X"
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# Distribution-specific completions
case "$PLATFORM_DISTRO" in
    debian)
        if [[ -f "/usr/share/bash-completion/bash_completion" ]]; then
            source /usr/share/bash-completion/bash_completion
        fi
        ;;
    arch)
        if [[ -d "/usr/share/zsh/site-functions" ]]; then
            fpath=("/usr/share/zsh/site-functions" $fpath)
        fi
        ;;
esac

# Export Linux-specific functions
export -f linux-info pkg-cleanup security-update firewall-status firewall-enable
export -f monitor-system dev-setup docker-cleanup logs-analyze fix-permissions hardware-info