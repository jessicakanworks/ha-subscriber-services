#!/usr/bin/env bash
# Usage: tests/smoke.sh <vip>   — verifies DNS, RADIUS and VIP ownership after a change or failover.
set -euo pipefail
VIP="${1:-10.20.0.10}"
echo -n "DNS  : "; dig +short +time=2 @"$VIP" example.com A | head -1 || { echo FAIL; exit 1; }
echo -n "RADIUS: "; radtest testuser testpass "$VIP" 0 "${RADIUS_SECRET:-testing123}" | grep -q 'Access-Accept' && echo OK || { echo FAIL; exit 1; }
echo -n "VIP owner: "; for h in 10.20.0.11 10.20.0.12; do ssh -o ConnectTimeout=3 "$h" "ip a | grep -q $VIP && hostname" 2>/dev/null; done
