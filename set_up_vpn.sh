#!/bin/bash

# This script sets up a VPN connection using OpenVPN.

# Static Variables
VPN_CONFIG_LOCATION="/etc/openvpn/client"

# Required Variables
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <vpn_config_file_path> <vpn_pw_file_path>"
  echo "Example: $0 /path/to/my_vpn.ovpn /path/to/my_vpn_password.txt"
  exit 1
fi

vpn_config_file_path="$1"
vpn_pw_file_path="$2"
vpn_config_name="$(basename "${vpn_config_file_path%.*}")"

# Check if the provided configuration file exists
if [ ! -f "$vpn_config_file_path" ]; then
  echo "Error: VPN configuration file '$vpn_config_file_path' does not exist."
  exit 1
fi  

# Check if the provided password file exists
if [ ! -f "$vpn_pw_file_path" ]; then
  echo "Error: VPN password file '$vpn_pw_file_path' does not exist."
  exit 1
fi

# Update and install necessary packages
echo "Updating package list and installing OpenVPN..."
apt update || { echo "Failed to update package list"; exit 1; }
apt install openvpn -y || { echo "Failed to install OpenVPN"; exit 1; }

# mv config file to the OpenVPN directory
if [ ! -d "$VPN_CONFIG_LOCATION" ]; then
  mkdir -p "$VPN_CONFIG_LOCATION" || { echo "Failed to create VPN config directory"; exit 1; }
fi

echo "Moving VPN configuration files..."
mv "$vpn_config_file_path" "$VPN_CONFIG_LOCATION/" || { echo "Failed to move VPN config file"; exit 1; }

# Move password file to the OpenVPN directory
mv "$vpn_pw_file_path" "$VPN_CONFIG_LOCATION/" || { echo "Failed to move VPN password file"; exit 1; }

# Set permissions for the password file
echo "Setting secure permissions..."
chmod 600 "$VPN_CONFIG_LOCATION/$(basename "$vpn_pw_file_path")" || { echo "Failed to set password file permissions"; exit 1; }
chown root:root "$VPN_CONFIG_LOCATION/$(basename "$vpn_pw_file_path")" || { echo "Failed to set password file ownership"; exit 1; }

# Enable and start the OpenVPN service
echo "Enabling and starting OpenVPN service..."
systemctl enable "openvpn-client@${vpn_config_name}" || { echo "Failed to enable OpenVPN service"; exit 1; }
systemctl start "openvpn-client@${vpn_config_name}" || { echo "Failed to start OpenVPN service"; exit 1; }

# Wait a moment for the service to initialize
sleep 3

# Verify the VPN connection and IP address
echo "Verifying VPN connection..."
if systemctl is-active --quiet "openvpn-client@${vpn_config_name}"; then
  echo "VPN connection established successfully."
  echo "Current IP address:"
  # Try to show tun0 interface first, fallback to all interfaces
  if ip addr show tun0 2>/dev/null; then
    echo "VPN tunnel interface (tun0) is up."
  else
    echo "VPN tunnel interface not found, showing all network interfaces:"
    ip addr show | grep inet
  fi
else
  echo "Failed to establish VPN connection."
  echo "Service status:"
  systemctl status "openvpn-client@${vpn_config_name}" --no-pager
  exit 1
fi
