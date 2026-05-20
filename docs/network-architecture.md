# Network Architecture — Detailed Documentation

## 1. Design Philosophy

The infrastructure follows a **defense-in-depth** and **segmentation-first** approach. Rather than a flat network, each department and service sits in its own subnet, with traffic between segments controlled by the firewall.

Key principles applied:
- **Least privilege** between network segments
- **Isolation** of public-facing services in a DMZ
- **Centralization** of core services (DNS, DHCP, directory)
- **A dedicated, isolated environment** for security testing

---

## 2. VLAN Segmentation

| VLAN | Name    | Purpose                          |
|------|---------|----------------------------------|
| 10   | IT      | IT department workstations       |
| 20   | Gestion | Management department            |
| 30   | Finance | Finance department               |
| 99   | Admin   | Administrative / privileged access |

Each VLAN is mapped to a dedicated DHCP scope, and inter-VLAN routing is filtered through pfSense so that, for example, the Finance VLAN cannot be reached directly from the IT VLAN without an explicit firewall rule.

---

## 3. Core Services

### DNS
- Internal DNS server at `10.0.0.50`
- Resolves internal hostnames (e.g. `mail.cmc.local`)

### DHCP
- Six scopes, one per segment (see main README addressing table)
- Each scope provides: address range, subnet mask, default gateway, DNS server
- Configured via the `Configure-DHCP.ps1` automation script

### Active Directory
- Domain: `cmc.local`
- OUs: ADMIN, COMP, GESTION, IT
- Role-based security groups
- User provisioning automated via `Create-ADUsers.ps1`

### Mail (Zimbra)
- Zimbra Collaboration Suite integrated with AD
- Accessed at `mail.cmc.local` over TLS

### Storage
- NFS for Linux file sharing
- iSCSI for block-level storage
- Samba for Windows interoperability

---

## 4. Security Zones

| Zone       | Contents                       | Exposure          |
|------------|--------------------------------|-------------------|
| Internal   | User VLANs, server farm        | Internal only     |
| DMZ        | Public-facing services         | Controlled        |
| Perimeter  | pfSense firewall               | Internet-facing   |
| Testing    | Kali Linux pentester node      | Isolated          |

---

## 5. Lessons Learned

- Proper subnetting is the foundation of clean segmentation.
- Automation (PowerShell) drastically reduces configuration errors and time when provisioning many users or scopes.
- Centralizing DNS/DHCP simplifies management but makes those servers critical assets to protect.
- An isolated testing environment is essential to safely validate the security posture.
