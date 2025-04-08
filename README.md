# 📦 DevOps Project: SFTP VMs with Automated File Exchange

## 📝 Task Overview

This project provisions **three virtual machines** using **Vagrant**, each running a configured **SFTP server**. Key-based SSH access is set up between the machines, and a basic security audit is performed. Additionally, a scheduled script enables automated file creation across the SFTP network.

---

## ⚙️ Technical Requirements

### 1. Infrastructure Setup
- Provision **3 VMs** using **Vagrant**.
- Assign **static IPs** to each VM for direct access.
- Use Vagrant provisioning (inline shell or external script) to automate setup.

### 2. SFTP Server Configuration
- Install and configure **OpenSSH** on each VM.
- Enable **SFTP** functionality for incoming connections.

### 3. SSH Key Authentication
- Generate SSH keys.
- Set up **key-based authentication** between all machines.
- Disable password login for better security.

### 4. Security Auditing
- Install **rkhunter** or similar tool on each VM.
- Run a security scan after provisioning.
- Save logs in a readable location for inspection.

---

## 🔁 Automated File Exchange

Each VM runs a **Bash script** every **5 minutes** that:

- Connects via **SFTP** to the other two VMs.
- Creates a file in a shared directory on the remote host.
- Writes the **current date, time**, and the **name of the VM** that created the file.

### Example File Content:

- The script is scheduled using `cron` or `systemd` timers.
- File names and target directories can be customized in the script.

---

## 📁 Deliverables

- `Vagrantfile` for provisioning all VMs.
- Shell scripts for:
  - Installing and configuring SFTP.
  - Setting up SSH key authentication.
  - Running security audit tools.
- Bash script for automated file exchange via SFTP.
- `README.md` with setup instructions, usage, and troubleshooting.

---

## 🚀 How to Run

```bash
vagrant up
