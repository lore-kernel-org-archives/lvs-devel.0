From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [*v2 PATCH 00/22] IPVS, Network Name Space aware
Date: Mon, 13 Dec 2010 14:38:08 +0100
Message-ID: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

This patch series adds network name space support to the LVS.

REVISION

This is version 2

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
The size of per name space is 2004 bytes (for x86_64) and a little bit less
for 32 bit archs.

Statistics counters is now lock-free i.e. incremented per CPU,
The estimator does a sum when using it.

Procfs ip_vs_stats is also changed to reflect the "per cpu"
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


PATCH SET
This patch set is based upon lvs-test-2.6 / v2.6.37-rc1 
and depends upon IPVS sync patches

STATUS 
untested protos
 - sctp
 - esp_ah
and SIP for IPv6

SUMMARY
 include/net/ip_vs.h                     |  236 +++++++---
 include/net/net_namespace.h             |    2 +
 include/net/netns/ip_vs.h               |  144 ++++++
 net/netfilter/ipvs/ip_vs_app.c          |  101 +++--
 net/netfilter/ipvs/ip_vs_conn.c         |  156 ++++---
 net/netfilter/ipvs/ip_vs_core.c         |  163 +++++--
 net/netfilter/ipvs/ip_vs_ctl.c          |  823 +++++++++++++++++--------------
 net/netfilter/ipvs/ip_vs_est.c          |  157 ++++--
 net/netfilter/ipvs/ip_vs_ftp.c          |   57 ++-
 net/netfilter/ipvs/ip_vs_lblc.c         |   66 +++-
 net/netfilter/ipvs/ip_vs_lblcr.c        |   70 +++-
 net/netfilter/ipvs/ip_vs_nfct.c         |    6 +-
 net/netfilter/ipvs/ip_vs_proto.c        |  121 +++++-
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |   35 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |  134 +++---
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |  125 +++---
 net/netfilter/ipvs/ip_vs_proto_udp.c    |  102 +++--
 net/netfilter/ipvs/ip_vs_sync.c         |  422 +++++++++-------
 18 files changed, 1900 insertions(+), 1020 deletions(-)
