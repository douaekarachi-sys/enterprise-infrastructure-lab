# 🏢 Enterprise Infrastructure & Security Lab

> A full corporate network infrastructure built from scratch as a final-year project — featuring network segmentation, Active Directory, mail services, DHCP automation, and a dedicated penetration testing environment.

![Status](https://img.shields.io/badge/status-completed-success)
![Duration](https://img.shields.io/badge/duration-6%20months-blue)
![Platform](https://img.shields.io/badge/platform-PNETLab%20%7C%20VMware-orange)
![Focus](https://img.shields.io/badge/focus-Network%20Security-7030A0)

---

## 📖 Overview

This project simulates a complete **enterprise IT infrastructure** with a strong focus on **security and network segmentation**. It was designed and deployed over six months as a final-year project, covering the full stack: from network topology and VLAN segmentation to directory services, mail, and centralized DHCP — with a dedicated environment for security testing.

The goal was to reproduce a realistic corporate environment where each department is isolated, services are centralized, and the network is built with a security-first mindset (segmentation, DMZ, firewall, controlled inter-VLAN routing).

---

## 🏗️ Architecture

The infrastructure is built around a segmented network with department-based VLANs, a central firewall (pfSense), redundant core switches, and an isolated DMZ for public-facing services.

```<img width="591" height="288" alt="image" src="https://github.com/user-attachments/assets/04709ace-7bb9-4d52-9b0a-5a8194afd83a" />

```

---

## 🧩 Components

### 🔥 Network & Security
- **pfSense firewall** — perimeter security, NAT, inter-VLAN routing rules
- **VLAN segmentation** — department isolation (IT, Management, Finance, Admin)
- **DMZ** — isolated zone for public-facing services
- **Redundant core switches** — Switch Core-1 & Core-2
- **VPN access** — secure remote connectivity
- **Pentester node** — Kali Linux for security testing

### 🗂️ Directory Services (Active Directory)
- Domain: `cmc.local`
- Organizational Units: `ADMIN`, `COMP`, `GESTION`, `IT`
- Security groups for role-based access (admin, dev, tech, soc, finance, etc.)
- **Automated user provisioning** via PowerShell (see `scripts/`)

### 📨 Mail Services (Zimbra)
- Zimbra Collaboration Suite (8.8.15)
- Integration with Active Directory authentication
- 23 managed accounts across departments
- TLS certificate configuration (`mail.cmc.local`)

### 🌐 Core Services
- **DHCP** — six segmented scopes, automated via PowerShell (see `scripts/`)
- **DNS** — internal name resolution (`10.0.0.50`)
- **Storage server** — NFS / iSCSI / Samba for cross-platform file sharing

---

## 📐 Network Addressing Plan

The `10.0.0.0` network is segmented into per-service subnets:

| Segment   | Subnet         | Range              | Mask  |
|-----------|----------------|--------------------|-------|
| Gestion   | 10.0.0.0/28    | .1 – .14           | /28   |
| IT        | 10.0.0.32/28   | .33 – .46          | /28   |
| DMZ       | 10.0.0.48/28   | .49 – .62          | /28   |
| COMP      | 10.0.0.64/28   | .65 – .78          | /28   |
| pfSense   | 10.0.0.80/28   | .81 – .94          | /28   |
| Admin     | 10.0.0.96/29   | .97 – .102         | /29   |

> **Security rationale:** Each subnet maps to a department/service. Segmentation limits lateral movement — if one segment is compromised, the attacker cannot freely reach the others. Inter-segment traffic is controlled by the firewall.

---

## ⚙️ Automation Scripts

This project includes PowerShell scripts to automate repetitive administration tasks.

### `scripts/Create-ADUsers.ps1`
Interactive Active Directory user provisioning:
- Generates login names automatically (first initial + surname)
- Places users in the correct Organizational Unit
- Assigns users to security groups
- Forces password change at first logon (security best practice)
- Logs every operation

### `scripts/Configure-DHCP.ps1`
Automated DHCP scope configuration:
- Creates six DHCP scopes (one per network segment)
- Sets address ranges, subnet masks, gateways, and DNS
- Idempotent — skips scopes that already exist
- Prints a summary of active scopes

> ⚠️ **Note:** These scripts target the lab environment (`cmc.local`, `10.0.0.0/24` segmented). Adapt domain names, OUs, and IP ranges to your own environment before running. Test in a non-production environment first.

---

## 🛠️ Technologies Used

| Category        | Tools                                              |
|-----------------|----------------------------------------------------|
| Virtualization  | PNETLab, VMware Workstation                         |
| Firewall        | pfSense                                             |
| Directory       | Windows Server, Active Directory                    |
| Mail            | Zimbra Collaboration Suite                          |
| Services        | DHCP, DNS, NFS, iSCSI, Samba                        |
| Security Testing| Kali Linux                                          |
| Automation      | PowerShell                                          |
| OS              | Windows Server 2019, Ubuntu Server 22.04            |

---

## 📚 Skills Demonstrated

- Network design and **VLAN segmentation** with a security-first approach
- **Firewall configuration** and inter-VLAN routing (pfSense)
- **Active Directory** administration and automation
- **Subnetting** and structured IP addressing
- **Infrastructure-as-code** mindset through PowerShell automation
- Deployment of enterprise services (mail, DHCP, DNS, storage)
- Building an isolated environment for **security testing**

---

## 📸 Screenshots

Screenshots of the deployed environment are available in the [`screenshots/`](screenshots/) folder, including the PNETLab topology, Active Directory structure, Zimbra administration, and DHCP scope configuration.

---

## 👤 Author

**Douae Karachi** — Junior Cybersecurity Analyst
[LinkedIn](https://linkedin.com/in/douae-karachi) · [Portfolio](https://cspjcts.pages.dev/)

> Final-year project (2024–2025). Some components were carried out collaboratively with classmates; the network design, Active Directory automation, and DHCP configuration documented here represent my own contributions.

---

## 📄 License

This project is shared for educational and portfolio purposes.
