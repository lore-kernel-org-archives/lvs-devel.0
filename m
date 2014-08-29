From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs,v4 00/20] Support v6 real servers in v4 pools and vice versa
Date: Fri, 29 Aug 2014 01:38:49 -0700
Message-ID: <1409301549-5284-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : mime-version : content-type; s=facebook;
 bh=cGoZHOkkwzmEa5gHNCpbNnaGAuqwRqvo5FSMZ5GSY28=;
 b=ZBPubtFdjlzEFor+TrYwhlfHQ0Ey0EaeStMRuN/KvqBa/hf/dLNKmro3V9K+gGWVlQMy
 T4C95hmSP3ELELThjDkCZe+K9npPCIMHBgXa9TM0lEH6vb+1h4oA58qpxMbota0/VxNg
 nOIPcMrV6+NxpFFPHWKc1KsF4wQnB4Qf7ic= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, kernel-team@fb.com, Alex Gartrell <agartrell@fb.com>

At Facebook we use ipip forwarding to deliver packets from our layer 4 ipvs
load balancers to our layer 7 proxies.  Today these layer 7 proxies are all
dual stacked, so we can simply send v4 over v4 and v6 over v6.  In the
future, we're going to have v6-only layer 7 load balancers (no internal v4
address).  To deal with this, we'll forward v4 packets in v6 tunnels.  This
patchset introduces the necessary functionality into ipvs.

The noteworthy limitation of this is that it is not compatible with state
synchronization, so great care is taken to keep these things mutually
exclusive.

This patchset includes changes that add an additional netlink attribute to
destinations and changes that plumb the destination address family through
parts of the code where it was assumed that it was the same as the service.
Finally, there's a change that updates the transmit functions for tunneling
to share common code and support v4 in v6 and vice versa.

Changes for v2:

Introduced crosses_local_route_boundary and update_pmtu functions and
conditionally do the ip_hdr operations.  The latter means that df will be
effectively zero when we forward an ipv6 packet over an ipv4 tunnel.

Additionally, I addressed Julian's other statements.

Changes for v3:

added back the first two patches
checkpatch.pl all of the things
pull out the mtu changes
other previously detailed fixes

Changes for v4:

Fixed up small things, made it compile without ipv6

Alex Gartrell (10):
  ipvs: Add destination address family to netlink interface
  ipvs: Supply destination addr family to ip_vs_{lookup_dest,find_dest}
  ipvs: Pass destination address family to ip_vs_trash_get_dest
  ipvs: Supply destination address family to ip_vs_conn_new
  ipvs: prevent mixing heterogeneous pools and synchronization
  ipvs: Pull out crosses_local_route_boundary logic
  ipvs: Pull out update_pmtu code
  ipvs: Add generic ensure_mtu_is_adequate to handle mixed pools
  ipvs: support ipv4 in ipv6 and ipv6 in ipv4 tunnel forwarding
  ipvs: Allow heterogeneous pools now that we support them

Julian Anastasov (10):
  ipvs: address family of LBLC entry depends on svc family
  ipvs: address family of LBLCR entry depends on svc family
  ipvs: use correct address family in DH logs
  ipvs: use correct address family in LC logs
  ipvs: use correct address family in NQ logs
  ipvs: use correct address family in RR logs
  ipvs: use correct address family in SED logs
  ipvs: use correct address family in SH logs
  ipvs: use correct address family in WLC logs
  ipvs: use the new dest addr family field

 include/net/ip_vs.h                   |  15 +-
 include/uapi/linux/ip_vs.h            |   3 +
 net/netfilter/ipvs/ip_vs_conn.c       |  74 +++++--
 net/netfilter/ipvs/ip_vs_core.c       |  15 +-
 net/netfilter/ipvs/ip_vs_ctl.c        | 112 +++++++---
 net/netfilter/ipvs/ip_vs_dh.c         |   2 +-
 net/netfilter/ipvs/ip_vs_ftp.c        |   6 +-
 net/netfilter/ipvs/ip_vs_lblc.c       |  12 +-
 net/netfilter/ipvs/ip_vs_lblcr.c      |  12 +-
 net/netfilter/ipvs/ip_vs_lc.c         |   2 +-
 net/netfilter/ipvs/ip_vs_nq.c         |   3 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   2 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |   2 +-
 net/netfilter/ipvs/ip_vs_rr.c         |   2 +-
 net/netfilter/ipvs/ip_vs_sed.c        |   3 +-
 net/netfilter/ipvs/ip_vs_sh.c         |   8 +-
 net/netfilter/ipvs/ip_vs_sync.c       |  13 +-
 net/netfilter/ipvs/ip_vs_wlc.c        |   3 +-
 net/netfilter/ipvs/ip_vs_xmit.c       | 388 +++++++++++++++++++++-------------
 19 files changed, 453 insertions(+), 224 deletions(-)

-- 
1.8.1

