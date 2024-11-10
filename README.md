# Job Posting: DevOps Engineer for Multi-Regional Kubernetes Cluster Setup with Ansible and Rancher

**Location**: Remote  
**Job Type**: Contract / Freelance

---

### Project Overview
We are seeking an experienced **DevOps Engineer** to set up and configure a multi-regional Kubernetes cluster across two VPS machines in different regions, with a Rancher control plane on DigitalOcean.

**⚠️ Important Note**  
Some setup work has already been completed. We are looking for an expert to refine, clean up, and apply best practices to make this infrastructure more flexible, universal, and sustainable, with minimal future adjustments.

### Objectives
- Establish a robust, redundant Kubernetes environment with high security and automation.
- Utilize **Ansible** for automation, **Rancher Kubernetes Engine (RKE)** for cluster management, and **Helm charts** for structured deployments.

---

### Responsibilities

#### 1. Cluster Setup and Node Management
- **1.1** Configure two VPS hosts (one in each region) as standalone nodes in a cross-regional Kubernetes cluster using **Rancher Kubernetes Engine (RKE)**.
- **1.2** Set up the Rancher control plane on a separate DigitalOcean pod.

#### 2. Ansible Automation
- **2.1** Use **Ansible** to automate setup and configuration across all nodes, including both VPS and DigitalOcean instances.
- **2.2** Disable password-based SSH login post-initial setup and switch to SSH key-based authentication (confirm SSH access without password before proceeding).
- **2.3** Ensure necessary Kubernetes tools and dependencies are installed on all nodes.

#### 3. Security Hardening
- **3.1** Apply security patches, enable OS auto-updates, and set up `fail2ban`, antivirus, and DDoS protection across all nodes.
- **3.2** Configure **WireGuard VPN** to secure node communication, exposing only ports 80 and 443 to the public.
- **3.3** Limit log retention to two months with automated cleanup for older logs.
- **3.4** Install and configure **AppArmor**.
- **3.5** Ensure all hosts (VPS and Rancher) use **Let's Encrypt certificates** for HTTPS traffic and automatically renew certificates as needed.

#### 4. VPN Configuration
- **4.1** Integrate Rancher control plane and all nodes into a VPN network, restricting Rancher access to VPN-only.
- **4.2** Restrict cluster access to only HTTP(S) externally, with SSH accessible through VPN only.
- **4.3** Provide VPN access instructions to allow future users, using tools like **OpenVPN/Pritunl**.

#### 5. Parametrized Environment
- **5.1** Ensure all sensitive data (passwords, SSH keys) are managed through environment variables for security.

#### 6. Rancher Integration
- **6.1** Install the Rancher agent on VPS nodes to enable centralized management via the Rancher control panel.

#### 7. Service Exposure and Ingress
- **7.1** Configure **NGINX ingress** on all nodes to expose necessary services (Rancher on ports 80 and 443).
- **7.2** Route HTTP and HTTPS traffic correctly, ensuring public access is limited to application services.

#### 8. Deployment Standardization
- **8.1** Organize Kubernetes deployments using **Helm charts** for structured, maintainable management.
- **8.2** Ensure all Ansible roles can be safely re-run without redundancy or duplication.
- **8.3** Use **Homebrew** as the package manager where possible.
- **8.4** Simplify future VPS host addition by making the process as straightforward as adding the host's address and password to an Ansible group, automatically joining it to the VPN, Kubernetes, and Rancher.

---

### Skills and Experience Required
- Extensive experience with **Ansible** for infrastructure automation.
- Proficiency with **Rancher Kubernetes Engine (RKE)** and Rancher control plane setup.
- Solid understanding of **Kubernetes** setup and management, especially with standalone node clusters.
- Experience with **WireGuard** or similar VPN tools for secure communication.
- Familiarity with **Linux security tools** (e.g., `fail2ban`, antivirus, DDoS protection).
- Strong knowledge of **NGINX ingress** and **Helm charts**.
- Ability to **parameterize sensitive data** and ensure secure, repeatable Ansible automation.

---

### Deliverables
- Well-structured **Ansible playbooks** and roles for each configuration step, including file paths, contents, and setup instructions.
- Verification that all nodes are VPN-restricted, except for ports 80 and 443.
- Helm charts and templates for Kubernetes deployments.
- Detailed **setup and configuration documentation**, including file paths and environment variable requirements.
- PR to this repository with your changes. (We will reset the DigitalOcean pod and reinstall the VPS host to check how it works from scratch, then run it again to verify re-run compatibility.)
- Clear **instructions** on how to connect to the VPN network, including which client to use, and how to add additional users.
- **VPN private keys** included in this repository, with clear instructions on generating new keys and reconfiguring the network with them.

---

### How to Apply
Please submit a cover letter highlighting your experience with **Ansible**, **Rancher**, and **Kubernetes**, as well as examples of past relevant projects. Include your availability and preferred hourly or project-based rate.

**Note**: Please do not submit automated responses. We need a genuine **DevOps expert** to implement this project effectively.
