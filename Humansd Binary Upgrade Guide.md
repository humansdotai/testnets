# Humansd Binary Upgrade Guide

This guide will help you navigate the process of upgrading your Humansd binary to the latest version. We'll also guide you through stopping and restarting your validator to ensure a smooth transition. Please follow the steps below carefully.

## Prerequisites

Before proceeding, ensure you have the following software installed:

```sh
Go version: v1.20.1+
Humans version: v0.2.1
```

To check if Go is installed, run the following command:

```sh
go version
```

Should return go version go1.20.1 linux/amd64
Upgrade Instructions
The following instructions are specifically for Ubuntu 20.04 systems. If you're using a different OS/architecture, adjust the commands accordingly.

Stop your validator

Before upgrading the binary, it's essential to stop your running validator. Use the following command:

```bash
sudo service humansd stop
```

Install the new humansd binary

Clone the Humans repository and checkout the appropriate version:

```bash
git clone https://github.com/humansdotai/humans
cd humans && git checkout tags/v0.2.2
make install
```

If the humansd command isn't recognized, you may need to move the binary to the correct directory. Use the following command, adding sudo if necessary:

```bash
cp ./build/humansd /usr/local/sbin/
```

Ensure you have checked out the correct v0.2.2 tag.

### Now, verify the installation:

```bash
humansd version
```

If the output is similar to the one below, the Humansd binary has been successfully installed:

```bash
build_tags: netgo ledger,
commit: a3e608e8fc45ace7055fc312b7e5f4831ca79816
cosmos_sdk_version: v0.46.11
go: go version go1.20.3 linux/amd64
name: humans
server_name: humansd
version: 0.2.2
```

### Restart your validator

After successfully upgrading the Humansd binary, restart your validator:

```bash
sudo service humansd start
```

🎊 Congratulations! You've successfully upgraded your Humansd binary. Remember, regular updates are crucial to maintain your system's efficiency and security. Enjoy using the updated Humansd binary!
