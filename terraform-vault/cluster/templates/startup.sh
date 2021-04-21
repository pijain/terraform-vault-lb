#!/bin/sh

#run the script as root
# Download and install Vault
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum -y install vault

mkdir -p /home/vault/vault-data

install -o vault -g vault -m 750 -d /home/vault

cd /home/vault

chown -R vault:vault /home/vault/

touch /etc/vault.d/config.hcl

# Vault config
cat> /etc/vault.d/config.hcl << EOPY

# Enable HA backend storage with GCS
storage "gcs" {
  bucket    = "${vault_tls_bucket}"
  ha_enabled = "true"
}

# Create local non-TLS listener
listener "tcp" {
  address     = "0.0.0.0:${vault_port}"
  tls_disable = "true"
}

disable_mlock = true

# Run Vault in HA mode. Even if there's only one Vault node.
api_addr = "http://${api_addr}:${vault_port}"

#cluster address set to default address
cluster_addr = "http://${api_addr}:${vault_proxy_port}"

# Enable the UI
ui = true
EOPY

chown -R vault:vault /etc/vault.d/
chmod 640 /etc/vault.d/config.hcl

touch /etc/systemd/system/vault.service

# Systemd service
cat> /etc/systemd/system/vault.service <<EOPY
[Unit]
Description=HashiCorp Vault to manage secrets
Documentation=https://vaultproject.io/docs/
After=network.target
ConditionFileNotEmpty=/etc/vault.d/config.hcl
[Service]
User=vault
Group=vault
ExecStart=/usr/bin/vault server -config=/etc/vault.d/config.hcl
ExecReload=/usr/local/bin/kill --signal HUP $MAINPID
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
AmbientCapabilities=CAP_IPC_LOCK
SecureBits=keep-caps
NoNewPrivileges=yes
KillSignal=SIGINT
[Install]
WantedBy=multi-user.target
EOPY
chmod 640 /etc/systemd/system/vault.service

systemctl daemon-reload
systemctl start vault.service
systemctl enable vault.service
systemctl status vault.service

sleep 10s

# Setup vault env
export VAULT_ADDR='http://127.0.0.1:${vault_port}'

# Enable auto-unsealing with operator init
vault operator init  >> /etc/vault.d/init.file 

key1="$(awk '/Unseal Key 1/ {print $4}' /etc/vault.d/init.file)"
echo "$key1"
key2="$(awk '/Unseal Key 2/ {print $4}' /etc/vault.d/init.file)"
echo "$key2"
key3="$(awk '/Unseal Key 3/ {print $4}' /etc/vault.d/init.file)"
echo "$key3"
token= "$(awk '/Initial Root Token/ {print $4}' /etc/vault.d/init.file)"

vault operator unseal "$key1"
vault operator unseal "$key2"
vault operator unseal "$key3"