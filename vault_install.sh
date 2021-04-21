#!/bin/sh

#run the script as root
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install vault

sudo mkdir -p /home/vault/vault-data

sudo install -o vault -g vault -m 750 -d /home/vault

sudo cd /home/vault

sudo chown -R vault:vault /home/vault/

sudo touch /etc/vault.d/config.hcl

sudo cat> /etc/vault.d/config.hcl << EOPY
#storage "raft" {
#  path    = "/home/vault/vault-data"
#  node_id = "node1"
#}
storage "gcs" {
  bucket    = "vault-data-test"
  #node_id = "node1"
}
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"
}
#if you are using SSL certificate
#listener "tcp" {
#      address     = "0.0.0.0:8200"
#       tls_disable = 0
#       tls_cert_file = "/opt/vault/tls/tls.crt"
#       tls_key_file = "/opt/vault/tls/tls.key"
#}
disable_mlock = true
api_addr = "http://0.0.0.0:8200"
cluster_addr = "http://127.0.0.1:8201"
ui = true
EOPY

sudo chown -R vault:vault /etc/vault.d/
sudo chmod 640 /etc/vault.d/config.hcl

sudo touch /etc/systemd/system/vault.service

sudo cat> /etc/systemd/system/vault.service <<EOPY
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


sudo systemctl daemon-reload
sudo systemctl start vault.service
sudo systemctl enable vault.service

sudo systemctl status vault.service

sleep 10s

export VAULT_ADDR='http://127.0.0.1:8200'

vault operator init  >> /etc/vault.d/init.file 

key1="$(awk '/Unseal Key 1/ {print $4}' /etc/vault.d/init.file)"
key2="$(awk '/Unseal Key 2/ {print $4}' /etc/vault.d/init.file)"
key3="$(awk '/Unseal Key 3/ {print $4}' /etc/vault.d/init.file)"
token= "$(awk '/Initial Root Token/ {print $4}' /etc/vault.d/init.file)"

vault operator unseal "${key1}"
vault operator unseal "${key2}"
vault operator unseal "${key3}"
