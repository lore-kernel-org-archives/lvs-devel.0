From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [RFC PATCH 0/9] ipvs network name space (netns) aware
Date: Fri, 8 Oct 2010 13:16:36 +0200
Message-ID: <201010081316.38317.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr

This patch series adds network name space (netns) support to the LVS.

REVISION

This is version 1

OVERVIEW

The patch doesn't remove or add any functionality except for netns.
For users that don't use network name space (netns) this patch is
completely transparent.

No it's possible to run LVS in a Linux container (see lxc-tools)
i.e.  a light weight virtualization. For example it's possible to run
one or several lvs on a real server in their own network name spaces.
From the LVS point of view it looks like it runs on it's own machine.

IMPLEMENTATION
Basic requirements for netns awareness
 - Global variables has to be moved to dyn. allocated memory.

Most global variables now resides in a struct ipvs { } in netns/ip_vs.h.
What is moved and what is not ?

Some cache aligned locks are still in global, module init params and some debug_level.

Algorithm files they are untouched.

QUESTIONS
Drop rate in ip_vs_ctl per netns or grand total ?
Should more lock variables be moved (or less) ?


PATCH SET
This patch set is based upon net-next-2.6 (2.6.36-rc3) from 4 oct 2010
and [patch v4] ipvs: IPv6 tunnel mode

Note: ip_vs_xmit.c will not work without "[patch v4] ipvs: IPv6 tunnel mode"

SUMMARY

 include/net/ip_vs.h                     |  136 ++++---
 include/net/net_namespace.h             |    2 +
 include/net/netns/ip_vs.h               |  112 +++++
 net/netfilter/ipvs/ip_vs_app.c          |   96 +++--
 net/netfilter/ipvs/ip_vs_conn.c         |  296 ++++++++-----
 net/netfilter/ipvs/ip_vs_core.c         |  155 ++++---
 net/netfilter/ipvs/ip_vs_ctl.c          |  771 +++++++++++++++++--------------
 net/netfilter/ipvs/ip_vs_est.c          |  127 +++--
 net/netfilter/ipvs/ip_vs_ftp.c          |   64 ++-
 net/netfilter/ipvs/ip_vs_proto.c        |  108 +++++-
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |   34 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |  126 +++---
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |  112 +++--
 net/netfilter/ipvs/ip_vs_proto_udp.c    |  107 +++--
 net/netfilter/ipvs/ip_vs_sync.c         |  323 +++++++------
 net/netfilter/ipvs/ip_vs_xmit.c         |   12 +-
 16 files changed, 1588 insertions(+), 993 deletions(-)

The patch will be divided for readability into
 1. include files
 2. app
 3. conn
 4. core
 5. ctl
 6. est
 7. ftp
 8. proto files
 9. sync and xmit

Include files,
A new file added include/net/netns/ip_vs.h containg all netns specific data.
include/net/net_namespce.h, pointer to "struct ipvs"  added.
include/net/ip_vs.h a new struct added, and many prototypes changed.

* ip_vs_core.c
All netns init origins from this file - ip_vs_init()

* ip_vs_conn.c
Lock array for conn table is kept due to performance,
(or am I wrong here ?).
"static struct ip_vs_aligned_lock
__ip_vs_conntbl_lock_array[CT_LOCKARRAY_SIZE] __cacheline_aligned;"

* ip_vs_ctl.c
drop_ rate is still global

TESTING
This patch have been running for a month now with three LVS/machine
one in root name-space and two in other name-space.
Both IPv4 & IPv6 have been tested in all three modes DR/TUN and NAT
Only a limited set of algos have been used (read rr).

Backup have been there all the time and a switch has been performed a couple of times.

There is still some BUG_ON(!net) left  ...

Not tested yet:
 Drop level, DOS,  schedulers, performance ....
 Netns exit after usage of LVS (due to a bug in netdev/ipip somewhere tunl0 and


--
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
