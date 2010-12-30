From: hans@schillstrom.com
Subject: [*v3 PATCH 00/22] IPVS Network Name Space aware
Date: Thu, 30 Dec 2010 11:50:44 +0100
Message-ID: <1293706266-27152-1-git-send-email-hans@schillstrom.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>

From: Hans Schillstrom <hans.schillstrom@ericsson.com>

This patch series adds network name space support to the LVS.

REVISION

This is version 3

OVERVIEW

The patch doesn't remove or add any functionality except for netns.
For users that don't use network name space (netns) this patch is
completely transparent.

Now it's possible to run LVS in a Linux container (see lxc-tools)
i.e.  a light weight visualization. For example it's possible to run
one or several lvs on a real server in their own network name spaces.
From the LVS point of view it looks like it runs on it's own machine.

IMPLEMENTATION
Basic requirements for netns awareness
 - Global variables has to be moved to dyn. allocated memory.
 - No or very little performance loss

Large hash tables connection hash and service hashes still resides in
global memory with net ptr added in hash key.
Most global variables now resides in a struct ipvs { } in netns/ip_vs.h.
The size of per name space is 2096 bytes (for x86_64) and a little bit less
for 32 bit arch's.

Statistics counters is now lock-free i.e. incremented per CPU,
The estimator does a sum when using it.

Procfs: ip_vs_stats_percpu is added to reflect the "per cpu"
ex.
# cat /proc/net/ip_vs_stats
       Total Incoming Outgoing         Incoming         Outgoing
CPU    Conns  Packets  Packets            Bytes            Bytes
  0        0        3        1               9D               34
  1        0        1        2               49               70
  2        0        1        2               34               76
  3        1        2        2               70               74
  ~        1        7        7              18A              18E

     Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s
           0        0        0                0                0

Algorithm files are untouched except for lblc and lblcr.

STEP BY STEP
First patch creates network name space init for all files that need it.
How ever if a new name space is created an error is returned.
This will be removed in the last patch.

When net ptr ain't available init_net will be used temporarily.

CHANGES

*v2
The patches is totally reworked so each patch compile ...
Depends on the IPv6 and Persistence Backup patch.
Common hash-table per name-space for connections and services
Stats per CPU
smaller changes in lblc and lblcr
Triggered by Julians comment:
"tcp_timeout_change should work with the new struct ip_vs_proto_data
        so that tcp_state_table will go to pd->state_table
        and set_tcp_state will get pd instead of pp"

*v3
  Changes triggered by comment mostly, see individual patches for details.

  procfs ip_vs_stats remains the same, ip_vs_stats_percpu added instead.
  Unused functions removed.
  The pp -> pd conversion should start from functions like ip_vs_out()....
  Timer per ns instead of a common timer in estimator.
  Moved net compare to the end in "fast path"
  __ip_vs_mutex remains global



PATCH SET
This patch set is based upon lvs-test-2.6 / v2.6.37-rc1
and depends upon IPVS sync patches

STATUS
untested protos
 - sctp
 - esp_ah
and SIP for IPv6

SUMMARY
 include/net/ip_vs.h                     |  248 +++++++---
 include/net/net_namespace.h             |    2 +
 include/net/netns/ip_vs.h               |  146 ++++++
 net/netfilter/ipvs/ip_vs_app.c          |  101 +++--
 net/netfilter/ipvs/ip_vs_conn.c         |  159 ++++---
 net/netfilter/ipvs/ip_vs_core.c         |  228 ++++++---
 net/netfilter/ipvs/ip_vs_ctl.c          |  826 ++++++++++++++++++-------------
 net/netfilter/ipvs/ip_vs_est.c          |  131 ++++--
 net/netfilter/ipvs/ip_vs_ftp.c          |   56 ++-
 net/netfilter/ipvs/ip_vs_lblc.c         |   66 +++-
 net/netfilter/ipvs/ip_vs_lblcr.c        |   70 +++-
 net/netfilter/ipvs/ip_vs_nfct.c         |    6 +-
 net/netfilter/ipvs/ip_vs_proto.c        |  121 +++++-
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |   45 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |  144 +++---
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |  133 +++---
 net/netfilter/ipvs/ip_vs_proto_udp.c    |  102 ++--
 net/netfilter/ipvs/ip_vs_sync.c         |  422 +++++++++-------
 net/netfilter/xt_ipvs.c                 |    2 +-
 19 files changed, 1960 insertions(+), 1048 deletions(-)
