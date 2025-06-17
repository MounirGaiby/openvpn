# OpenVPN Setup Script

A bash script to automatically set up and configure OpenVPN client connections on Linux systems.

## Overview

This script (`set_up_vpn.sh`) automates the process of:
- Installing OpenVPN
- Configuring VPN client connections
- Setting up secure file permissions
- Starting and enabling the VPN service
- Verifying the connection

## Prerequisites

- **Root privileges**: The script must be run with `sudo` or as root
- **Linux system** with systemd (Ubuntu, Debian, CentOS, etc.)
- **VPN configuration file** (`.conf` format)
- **Password file** containing your VPN 

## Usage

```bash
sudo apt update
sudo ./set_up_vpn.sh <vpn_config_file_path> <vpn_password_file_path>
```

### Example

```bash
sudo apt update
sudo ./set_up_vpn.sh /path/to/your/vpn_config.conf /path/to/your/password.txt
```

## Password File Format

Create a text file with your VPN credentials in the following format:
```
username
password
```

Example (`vpn_password.txt`):
```
your_username
your_password
```

## Important: OpenVPN Configuration Setup

**Your `.conf` file must be configured to use the password file!**

In your OpenVPN configuration file (`.conf`), you need to add or modify the `auth-user-pass` line to reference your password file:

```
auth-user-pass password_filename.txt
```

**Critical requirement:** The filename in the `auth-user-pass` line must **exactly match** the password file you provide to the script.

### Example:
- If your password file is named `my_vpn_credentials.txt`
- Your `.conf` file must contain: `auth-user-pass my_vpn_credentials.txt`
- Run the script: `sudo ./set_up_vpn.sh config.conf my_vpn_credentials.txt`

**Without this setup, the VPN connection will fail to authenticate!**

## What the Script Does

1. **Validates inputs** - Checks if both config and password files exist
2. **Installs OpenVPN** - Updates package list and installs OpenVPN
3. **Moves files** - Copies configuration and password files to `/etc/openvpn/client/`
4. **Sets permissions** - Secures the password file with 600 permissions (root only)
5. **Enables service** - Configures systemd to start the VPN automatically
6. **Starts VPN** - Initiates the VPN connection
7. **Verifies connection** - Checks if the VPN tunnel is established

## File Structure

```
openvpn/
├── README.md                 # This file
└── set_up_vpn.sh            # Main setup script
```

## Managing VPN Connections

### Check VPN Status
```bash
sudo systemctl status openvpn-client@<config_name>
```

### Stop VPN
```bash
sudo systemctl stop openvpn-client@<config_name>
```

### Start VPN
```bash
sudo systemctl start openvpn-client@<config_name>
```

### Disable Auto-start
```bash
sudo systemctl disable openvpn-client@<config_name>
```

## Troubleshooting

### Common Issues

1. **Permission denied**: Make sure to run with `sudo`
2. **File not found**: Verify the paths to your config and password files
3. **Connection fails**: Check your credentials and VPN server settings

### View Detailed Logs
```bash
sudo journalctl -u openvpn-client@<config_name> -f
```

### Check Network Interface
```bash
ip addr show tun0
```

## Security Notes

- Password files are automatically secured with 600 permissions (owner read/write only)
- Files are moved to `/etc/openvpn/client/` which is the standard OpenVPN directory
- The script requires root privileges for system-level configuration

## Requirements

- **OpenVPN**: Automatically installed by the script
- **systemd**: For service management
- **Root access**: Required for system configuration

## License

This script is provided as-is for educational and personal use.

## Contributing

Feel free to submit issues or pull requests to improve this script.