From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH ipvs 0/7] Support v6 real servers in v4 pools and vice versa
Date: Tue, 29 Jul 2014 21:10:48 -0700
Message-ID: <1406693455-915-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=from : to : cc : subject :
 date : message-id : mime-version : content-type; s=facebook;
 bh=rTnCDXRxy6OfpKPg+ylnDPxA6NSElTSzLfrsY8zV8I0=;
 b=dlb1ZMSkHECz9sCWtXgFwpGrZLQdTy3j+B5mZzQxWPBTY/JV5CEOQluMTNkBbbricBVU
 dAlU1t2/vJOIkx01dRP8QGfyfXXMBm3GnvZ3yHn93/ta6W8nUwGFJai3m8l3XvXlxLNh
 gH62Hs97KU0Pnj0Iq5pS2d3iKnghF6Gg99M= 
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au
Cc: ja@ssi.bg, lvs-devel@vger.kernel.org, agartrell@fb.com, kernel-team@fb.com

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

Alex Gartrell (7):
  ipvs: Add destination address family to netlink interface
  ipvs: Supply destination addr family to ip_vs_{lookup_dest,find_dest}
  ipvs: Pass destination address family to ip_vs_trash_get_dest
  ipvs: Supply destination address family to ip_vs_conn_new
  ipvs: maintain a mixed_address_family_dest count
  ipvs: prevent mixing heterogeneous pools and synchronization
  ipvs: support ipv4 in ipv6 and ipv6 in ipv4 tunnel forwarding

 include/net/ip_vs.h             |  14 ++++-
 include/uapi/linux/ip_vs.h      |   3 +
 net/netfilter/ipvs/ip_vs_conn.c |  23 +++++--
 net/netfilter/ipvs/ip_vs_core.c |   9 +--
 net/netfilter/ipvs/ip_vs_ctl.c  | 109 +++++++++++++++++++++++++-------
 net/netfilter/ipvs/ip_vs_sync.c |  14 +++--
 net/netfilter/ipvs/ip_vs_xmit.c | 135 ++++++++++++++++++++++++++--------------
 7 files changed, 222 insertions(+), 85 deletions(-)

-- 
1.8.1

