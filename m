From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next 0/8] Changes for IPVS sync
Date: Tue,  6 Mar 2012 00:00:00 +0200
Message-ID: <1330984808-2343-1-git-send-email-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Aleksey Chudov <aleksey.chudov@gmail.com>

	The following patchset contains changes for the
master-backup synchronization mechanism.

Patches 1-4 fix some flags and transmitter issues for the backup

Patch 5 (use adaptive pause in master thread) changes the fixed
pause of 1 HZ in master thread to adaptive pause, useful for
setups that use v0 of the sync protocol or when persistence
is used for v1 because the next patch changes the sync rate for
persistence connections back to original method (sync templates
every time when syncing controlled connections).

Patch 6 (reduce sync rate with time thresholds) addresses the
problem of high sync rate for loaded sites. With commit
986a075795339c5ea1122ce9290dfd5504252eb0
(Backup, Change sending to Version 1 format) we tried to
reduce the sync rate for templates in protocol v1 but using
sync_threshold for templates is too arbitrary and leads
to inaccurate information in backup when the template life
time is extended. This change restores the high rate of
templates for the default case (using sync_threshold parameters)
but adds new controls that can reduce the sync rate for all
kind of connections: sync_refresh_period and sync_retries.
Tests with sync_refresh_period=1000 can show 10 times lower
sync traffic compared to sync_threshold=3 100.

Patch 7 (add support for sync threads) addresses the problem
that single thread in backup server is not suitable for high sync
rate. For setups that use many masters and single backup or
when the backup is used as master or real server at the same time
we can prefer to serve the sync traffic on many CPUs. This patch
adds sysctl var "sync_ports" and starts the specified number of
threads (one thread per port). This value is used for master
threads too.

Patch 8 (optimize the use of flags in ip_vs_bind_dest) is just
an optimization for the cp->flags usage.


Special thanks to Aleksey Chudov <aleksey.chudov@gmail.com> for
being patient with me, for his extensive reports and helping
in all tests.


Julian Anastasov (8):
  ipvs: ignore IP_VS_CONN_F_NOOUTPUT in backup server
  ipvs: remove check for IP_VS_CONN_F_SYNC from ip_vs_bind_dest
  ipvs: fix ip_vs_try_bind_dest to rebind app and transmitter
  ipvs: always update some of the flags bits in backup
  ipvs: use adaptive pause in master thread
  ipvs: reduce sync rate with time thresholds
  ipvs: add support for sync threads
  ipvs: optimize the use of flags in ip_vs_bind_dest

 include/linux/ip_vs.h           |    5 +
 include/net/ip_vs.h             |   59 ++++-
 net/netfilter/ipvs/ip_vs_conn.c |   69 ++++--
 net/netfilter/ipvs/ip_vs_core.c |   30 +--
 net/netfilter/ipvs/ip_vs_ctl.c  |   54 ++++-
 net/netfilter/ipvs/ip_vs_sync.c |  585 +++++++++++++++++++++++++--------------
 6 files changed, 540 insertions(+), 262 deletions(-)

-- 
1.7.3.4

