From: Hans Schillstrom <hans@schillstrom.com>
Subject: [v2 PATCH 0/6] IPVS: init and cleanup.
Date: Fri, 29 Apr 2011 08:25:28 +0200
Message-ID: <1304058334-17594-1-git-send-email-hans@schillstrom.com>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ja@ssi.bg, horms@verge.net.au, ebiederm@xmission.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans.schillstrom@ericsson.com, Hans Schillstrom <hans@schillstrom.com>

This patch series handles exit from a network name space.

REVISION

This is version 3

OVERVIEW
Basically there was three faults in the netns implementation.
- Kernel threads hold devices and preventing an exit.
- dst cache holds references to devices.
- Services was not always released.

Patch 1 & 3 contains the functionality
      4 renames funcctions
      5 removes empty functions
      6 Debuging.

IMPLEMENTATION
- Avoid to increment the usage counter for kernel threads.
  this is done in the first patch.
- Patch 3 tries to restore the cleanup order.
  Add NETDEV_UNREGISTER notification for dst_reset

Revision 3 
Residies in patch 3
        Throttle renamed to enable.
        Comments from Julian implemented
        Check enable in ip_vs_in, ip_vs_out and ip_vs_forward_icmp*
        Remove in ip_vs_in_icmp*.
        ip_vs_svc_reset() moved into ip_vs_dst_event().
        ip_vs_service_cleanup() uses ip_vs_flush and mutex lock.
        ip_vs_unlink_service_nolock() added.
 
An netns exit could look like this
IPVS: Enter: __ip_vs_dev_cleanup, net/netfilter/ipvs/ip_vs_core.c
IPVS: stopping master sync thread 1286 ...
IPVS: stopping backup sync thread 1294 ...
IPVS: Leave: __ip_vs_dev_cleanup, net/netfilter/ipvs/ip_vs_core.c
IPVS: Enter: ip_vs_dst_event, net/netfilter/ipvs/ip_vs_ctl.c line
IPVS: Leave: ip_vs_dst_event, net/netfilter/ipvs/ip_vs_ctl.c line
...
IPVS: Enter: ip_vs_dst_event, net/netfilter/ipvs/ip_vs_ctl.c line
IPVS: Leave: ip_vs_dst_event, net/netfilter/ipvs/ip_vs_ctl.c line
IPVS: Enter: ip_vs_service_net_cleanup, net/netfilter/ipvs/ip_vs_ctl.c
IPVS: __ip_vs_del_service: enter
IPVS: Moving dest 192.168.1.6:0 into trash, dest->refcnt=43450
...
IPVS: Moving dest 192.168.1.3:0 into trash, dest->refcnt=43449
IPVS: __ip_vs_del_service: enter
IPVS: Removing destination 0/[2003:0000:0000:0000:0000:0002:0000:0006]:80
...
IPVS: Removing destination 0/[2003:0000:0000:0000:0000:0002:0000:0003]:80
IPVS: Removing service 0/[2003:0000:0000:0000:0000:0002:0004:0100]:80 usecnt=0
IPVS: Leave: ip_vs_service_net_cleanup, net/netfilter/ipvs/ip_vs_ctl.c
IPVS: Enter: ip_vs_control_net_cleanup, net/netfilter/ipvs/ip_vs_ctl.c
IPVS: Removing service 80/0.0.0.0:0 usecnt=0
IPVS: Leave: ip_vs_control_net_cleanup, net/netfilter/ipvs/ip_vs_ctl.c
IPVS: ipvs netns 8 released

PATCH SET
This patch set is based upon net-next-2.6 (2.6.39-rc2)


SUMMARY

 include/net/ip_vs.h              |   23 ++++--
 net/netfilter/ipvs/ip_vs_app.c   |   23 +-----
 net/netfilter/ipvs/ip_vs_conn.c  |   14 +---
 net/netfilter/ipvs/ip_vs_core.c  |  132 +++++++++++++++++++++--------
 net/netfilter/ipvs/ip_vs_ctl.c   |  178 ++++++++++++++++++++++++++++++--------
 net/netfilter/ipvs/ip_vs_est.c   |   21 +----
 net/netfilter/ipvs/ip_vs_proto.c |   11 +--
 net/netfilter/ipvs/ip_vs_sync.c  |   70 ++++++++--------
 8 files changed, 299 insertions(+), 173 deletions(-)

