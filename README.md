# ha-subscriber-services

Redundant, Ansible-managed **DNS, DHCP and RADIUS/AAA** services for subscriber and enterprise-VPN
authentication — the platform pattern used for fibre / 4G+ subscribers and institutional VPN users.

```
                 VIP 10.20.0.10 (keepalived VRRP)
                          │
              ┌───────────┴───────────┐
        aaa-01 (MASTER)         aaa-02 (BACKUP)
        ├─ BIND 9  (recursive + authoritative, zone replication)
        ├─ Kea DHCP (hot-standby HA pair)
        ├─ FreeRADIUS (shared users/clients, PostgreSQL backend)
        └─ HAProxy (RADIUS/DNS health-checked front-end) + exporters
```

* `site.yml` applies roles `keepalived`, `bind9`, `kea_dhcp`, `freeradius`, `haproxy`, `exporters`
* `inventory/aaa.ini` — the two-node pair; `group_vars/aaa.yml` — VIP, zones, pools, RADIUS clients
* `docker-compose.yml` — single-node lab of the same services for testing changes before production
* `tests/` — smoke tests: DNS resolution, DHCP lease, RADIUS auth via `radtest`
* `runbook-failover.md` — planned and unplanned failover procedure

```bash
ansible-playbook -i inventory/aaa.ini site.yml --check --diff
ansible-playbook -i inventory/aaa.ini site.yml
bash tests/smoke.sh 10.20.0.10
```
