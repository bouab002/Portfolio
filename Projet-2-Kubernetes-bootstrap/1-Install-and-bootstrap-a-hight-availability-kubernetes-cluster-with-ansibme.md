### Install and bootstrap a hig availability Kubernetes cluster with Ansible

As a Platform Engineer in a multi-VM context, I want to deploy a complete, reproducible, and versioned Kubernetes cluster with a single command, to speed up the delivery of dev/QA environments, standardize technical choices (CNI, ingress, certificates, storage), and have a local kubeconfig ready to be consumed by CI/CD.

- Acceptance criteria
  - A kubeadm init runs with a controlled configuration (CIDRs, LB)
  - Master and worker nodes join automatically
  - Cilium, Ingress-NGINX, Cert-Manager, and OpenEBS are installed
  - A kubeconfig is written locally for kubectl and pipelines
  - The deployment is idempotent and re-runnable

- Impacts
  - Reduced lead time to create environments
  - Consistency across networking/ingress/certificates/storage stacks
  - Easier onboarding: one doc + one command is enough

---

### TL;DR
- Main playbook: `playbooks/install-k8s.yml`
- Inventory: `inventory/hosts_kubernetes.yaml`
- Local kubeconfig: written on localhost at `{{ kubeconfig_file }}` (default `/tmp/kubeconfig.yaml`)
- CNI: Cilium with IPv6 and BGP Control Plane enabled
- Ingress: Ingress-NGINX (DaemonSet mode, hostNetwork)
- Certificates: Cert-Manager (CRDs enabled)
- Storage: OpenEBS (LocalPV only, replicated engines disabled)

---

### What the playbook does

- System preparation (all nodes)
  - Configures DNS resolution, IP forwarding, and updates packages
  - Installs Containerd and Kubernetes packages
- Cluster initialization
  - Generates a `kubeadm-config.yaml` from `templates/kubeadm-config.yaml.j2`
  - Runs `kubeadm init` on the first master and copies the kubeconfig to `/root/.kube/config`
  - Extracts and distributes `kubeadm join` commands (masters and workers)
- Node join
  - Makes the other masters and all workers join (if not already joined)
- Local kubeconfig
  - Fetches `/etc/kubernetes/admin.conf` from the first master and writes the content on `localhost` into `{{ kubeconfig_file }}`
- Addons (on localhost via Helm)
  - Installs Cilium, Ingress-NGINX, Cert-Manager, and OpenEBS via `kubernetes.core.helm`

---

### Prerequisites

- Ansible ≥ 2.13 (2.17+ recommended) and Python 3
- Ansible collection `kubernetes.core` installed:
  ```bash
  ansible-galaxy collection install kubernetes.core
  ```
- Passwordless SSH access to nodes (private key configured in `inventory/hosts_kubernetes.yaml`)
- Target OS: Ubuntu/Debian (tasks are specific to Debian/Ubuntu)
- Internet access from `localhost` (for Helm) and from nodes (for packages/repos)

---

### Inventory structure and variables

- Inventory: `inventory/hosts_kubernetes.yaml` (groups `masters`, `workers`, and `kubernetes`)
- Global variables: `inventory/group_vars/kubernetes.yaml`
- Localhost variables (kubeconfig): `inventory/group_vars/localhost.yaml`

Examples:
```yaml
# inventory/hosts_kubernetes.yaml
all:
  vars:
    ansible_ssh_common_args: -o StrictHostKeyChecking=no
    ansible_ssh_private_key_file: /home/USER/.ssh/id_rsa
  children:
    masters:
      hosts:
        master-0:
          ansible_host: 1.2.3.4
          ansible_user: ubuntu
        master-1:
          ansible_host: 1.2.3.5
          ansible_user: ubuntu
    workers:
      hosts:
        worker-0:
          ansible_host: 1.2.3.6
          ansible_user: ubuntu
    kubernetes:
      children:
        masters: {}
        workers: {}
```

```yaml
# inventory/group_vars/kubernetes.yaml
kubernetes_version: v1.32
master_node_ip: "1.2.3.4"
load_balancer_dns: "k8s.example.com"
load_balancer_port: "6443"
service_cidr: "10.96.0.0/12,fd00:1234::/108"
pod_cidr: "192.168.0.0/16,fd00:5678::/64"
```

```yaml
# inventory/group_vars/localhost.yaml
kubeconfig_file: "/tmp/kubeconfig.yaml"
```

---

### How to use the playbook

1) Test connectivity
```bash
ansible -i inventory/hosts_kubernetes.yaml all -m ping
```

2) Run the full installation
```bash
ansible-playbook -i inventory/hosts_kubernetes.yaml playbooks/install-k8s.yml
```
3) Install only one component (tags)
- Install k8s
  ```bash
  ansible-playbook -i inventory/hosts_kubernetes.yaml playbooks/install-k8s.yml --tags install-k8s
  ```
- Setup k8s
  ```bash
  ansible-playbook -i inventory/hosts_kubernetes.yaml playbooks/install-k8s.yml --tags init-k8s
  ```
- Cilium
  ```bash
  ansible-playbook -i inventory/hosts_kubernetes.yaml playbooks/install-k8s.yml --tags cilium,helm
  ```
- Ingress-NGINX
  ```bash
  ansible-playbook -i inventory/hosts_kubernetes.yaml playbooks/install-k8s.yml --tags nginx,helm
  ```
- Cert-Manager
  ```bash
  ansible-playbook -i inventory/hosts_kubernetes.yaml playbooks/install-k8s.yml --tags certmanager,helm
  ```
- OpenEBS
  ```bash
  ansible-playbook -i inventory/hosts_kubernetes.yaml playbooks/install-k8s.yml --tags openebs,helm
  ```


---

### Customization

- Cilium: adjust values in `playbooks/tasks/helm-cilium.yml` (IPv6, BGP, `kubeProxyReplacement`, replicas, etc.)
- Ingress-NGINX: DaemonSet mode + `hostNetwork`; adapt to your network design
- Cert-Manager: `chart_version`, feature gates, issuers (add your `ClusterIssuer` after installation)
- OpenEBS: by default only LocalPV; enable replicated engines if needed (LVM, ZFS, Mayastor)
- CIDRs/K8s version: via `inventory/group_vars/kubernetes.yaml`

---

### Design and technical choices

- kubeadm: de facto standard for bootstrapping Kubernetes
- Containerd: lightweight container runtime and officially supported
- Cilium (eBPF): modern CNI with improved performance and observability
- Ingress-NGINX: proven ingress controller
- Cert-Manager: automated certificate management (ACME, etc.)
- OpenEBS: simple local storage provisioning for lab/dev (no external dependency)
- Idempotency: Helm tasks make repository add idempotent (`state: present`, `force_update: true`)

---


### Demonstration

[Watch Demo on YouTube](https://youtu.be/5kTSEVWyXw4?t=455)


