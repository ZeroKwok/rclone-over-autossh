#!/bin/bash
set -euo pipefail

# Error handling function
error() {
    echo "[ERROR] $*" >&2
}

# Info logging function
info() {
    echo "[INFO] $*"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    error "Please run this script as root"
    exit 1
fi

# Check required commands
for cmd in rclone autossh; do
    if ! command -v "$cmd" &> /dev/null; then
        error "Please install '$cmd' manually"
        exit 1
    fi
done

# Create user if not exists
if ! getent passwd shared >/dev/null 2>&1; then
    useradd -r -m -s /usr/sbin/nologin -g shared shared
    info "User 'shared' created"
else
    info "User 'shared' already exists, skipping"
fi

# Create required directories
mkdir -p /etc/rclone-over-autossh
mkdir -p /var/log/rclone-over-autossh
info "Directories created"

# Copy main configuration file
if [ ! -f /etc/rclone-over-autossh/service.conf ]; then
    cp ./etc/rclone-over-autossh.conf.template /etc/rclone-over-autossh/service.conf
    info "Main configuration file copied"
else
    info "Main configuration file already exists, skipping"
fi

# Generate SSH key if not exists
if [ ! -f /etc/rclone-over-autossh/ssh_key ]; then
    ssh-keygen -t ed25519 -f /etc/rclone-over-autossh/ssh_key -N "" -C "rclone-autossh-key"
    chmod 600 /etc/rclone-over-autossh/ssh_key
    info "SSH key generated: /etc/rclone-over-autossh/ssh_key"
else
    info "SSH key already exists, skipping generation"
fi

# Set proper ownership and permissions
chown -R shared:shared /etc/rclone-over-autossh /var/log/rclone-over-autossh
chmod 700 /etc/rclone-over-autossh
chmod 755 /var/log/rclone-over-autossh
info "Permissions configured"

# Copy service files
cp -v ./service/rclone.service /etc/systemd/system/
cp -v ./service/autossh.service /etc/systemd/system/
info "Service files copied to /etc/systemd/system/"

# Reload systemd
systemctl daemon-reload
info "systemd daemon reloaded"

# Display completion message
cat << EOF

[SUCCESS] Installation completed!

Next steps:
1. View and edit /etc/rclone-over-autossh/service.conf to set your remote host and credentials.
   nano /etc/rclone-over-autossh/service.conf

2. View the public key (add to remote server authorized_keys):
   cat /etc/rclone-over-autossh/ssh_key.pub

3. Enable and start the service:
   make enable

4. Check service status:
   make status

5. View logs:
   make logs
EOF