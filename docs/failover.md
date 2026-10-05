# Failover behaviour and test procedure

**Design.** Both nodes run DNS, DHCP and RADIUS. keepalived moves the service VIP
(`10.20.0.10`) to whichever node passes `check_services.sh`. Kea keeps leases in sync via its
HA hook (hot-standby); FreeRADIUS reads a shared SQL database; BIND is stateless.

**Expected failover time:** VIP moves within ~3 s (fall=3 × interval=2 s, minus advert); DHCP
standby takes over after `max-response-delay` (60 s); RADIUS and DNS are immediate.

## Quarterly test
1. Announce window. Record `dig @10.20.0.10 example.com` and `radtest` baselines.
2. On the MASTER: `systemctl stop named` → within 6 s the VIP should appear on the BACKUP
   (`ip a | grep 10.20.0.10`). DNS and RADIUS queries to the VIP keep succeeding.
3. Confirm Kea on the standby serves leases: `journalctl -u kea-dhcp4-server | grep "partner-down"`.
4. Restore: `systemctl start named` on the original MASTER → VIP returns (preempt) after `rise=2`.
5. Record timings and any gaps in `docs/failover-tests.csv`.
