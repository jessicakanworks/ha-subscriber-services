# Failover runbook — DNS / DHCP / RADIUS pair

**Unplanned:** keepalived moves the VIP automatically when `check_aaa_services.sh` fails on the MASTER
(≤ 5 s). Kea hot-standby takes over leases. No action needed beyond verification:
1. `bash tests/smoke.sh 10.20.0.10`
2. Grafana → "AAA" dashboard: `aaa_vip_owner` should now be 1 on aaa-02.
3. Open an incident; investigate aaa-01; do **not** restart keepalived on aaa-01 until root cause is known.

**Planned (maintenance on aaa-01):**
1. `sudo systemctl stop keepalived` on aaa-01 → VIP moves to aaa-02. Verify with smoke test.
2. Patch/upgrade aaa-01; `ansible-playbook -i inventory/aaa.ini site.yml -l aaa-01`.
3. `sudo systemctl start keepalived` on aaa-01 → preempts (priority 110) and takes the VIP back. Verify.
