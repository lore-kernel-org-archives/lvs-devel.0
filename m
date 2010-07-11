From: horms@vergenet.net
Subject: [patch v2.6 0/4] IPVS full NAT support + netfilter 'ipvs' match support
Date: Sun, 11 Jul 2010 18:03:42 +0900
Message-ID: <20100711090342.035149543@vergenet.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
From: Simon Horman <horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Malcolm Turnbull <malcolm@loadbalancer.org>, Wensong Zhang <wensong@linux-vs.org>, Julius Volz <julius.volz@gmail.com>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, Hannes Eder <heder@google.com>

This is a repost of a patch-series posted by Hannes Eder last September.
This is v2 of the patch series and I don't see any outstanding objections to
it in the mailing list archives.

Series v2.6 fixes the arguments to  of %pI4

Series v2.5 fixes some problems introduced in v2.4.

Series v2.4 addresses all of the concerns that Patrick McHardy raised
witht the v2.3 series.

Malcolm Turnbull has offered to test this code so I'd like to get
a Reviewed-by from him before the code gets merged. In other words,
at this stage these patches are for review not merging.

The original cover-email from Hannes follows.
The diffstat output has been updated to reflect minor up-porting by me.

From:	Hannes Eder <heder@google.com>

The following series implements full NAT support for IPVS.  The
approach is via a minimal change to IPVS (make friends with
nf_conntrack) and adding a netfilter matcher, kernel- and user-space
part, i.e. xt_ipvs and libxt_ipvs.

Example usage:

% ipvsadm -A -t 192.168.100.30:80 -s rr
% ipvsadm -a -t 192.168.100.30:80 -r 192.168.10.20:80 -m
# ...

# Source NAT for VIP 192.168.100.30:80
% iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.100.30/32 \
> --vport 80 -j SNAT --to-source 192.168.10.10

or SNAT-ing only a specific real server:

% iptables -t nat -A POSTROUTING --dst 192.168.11.20 \
> -m ipvs --vaddr 192.168.100.30/32 -j SNAT --to-source 192.168.10.10


First of all, thanks for all the feedback.  This is the changelog for v2:

- Make ip_vs_ftp work again.  Setup nf_conntrack expectations for
  related data connections (based on Julian's patch see
  http://www.ssi.bg/~ja/nfct/) and let nf_conntrack/nf_nat do the
  packet mangling and the TCP sequence adjusting.

  This change rises the question how to deal with ip_vs_sync?  Does it
  work together with conntrackd?  Wild idea: what about getting rid of
  ip_vs_sync and piggy packing all on nf_conntrack and use conntrackd?

  Any comments on this?

- xt_ipvs: add new rule '--vportctl port' to match the VIP port of the
  controlling connection, e.g. port 21 for FTP.  Can be used to match
  a related data connection for FTP:

  # SNAT FTP control connection
  % iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.100.30/32 \
  > --vport 21 -j SNAT --to-source 192.168.10.10
  
  # SNAT FTP passive data connection
  % iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.100.30/32 \
  > --vportctl 21 -j SNAT --to-source 192.168.10.10

- xt_ipvs: use 'par->family' instead of 'skb->protocol'

- xt_ipvs: add ipvs_mt_check and restrict to NFPROTO_IPV4 and NFPROTO_IPV6

- Call nf_conntrack_alter_reply(), so helper lookup is performed based
  on the changed tuple.

Changes to the linux kernel
(nf-next-2.6, "bridge: add per bridge device controls for invoking iptables")

Hannes Eder (3):
      netfilter: xt_ipvs (netfilter matcher for IPVS)
      IPVS: make friends with nf_conntrack
      IPVS: make FTP work with full NAT support


 include/linux/netfilter/xt_ipvs.h |   25 +++++
 include/net/ip_vs.h              |    2 
 net/netfilter/Kconfig            |   10 ++
 net/netfilter/Makefile           |    1 
 net/netfilter/ipvs/Kconfig       |    4 
 net/netfilter/ipvs/ip_vs_app.c   |   43 ---------
 net/netfilter/ipvs/ip_vs_core.c  |   37 --------
 net/netfilter/ipvs/ip_vs_ftp.c   |  174 +++++++++++++++++++++++++++++++++++---
 net/netfilter/ipvs/ip_vs_proto.c |    1 
 net/netfilter/ipvs/ip_vs_xmit.c  |   29 ++++++
 net/netfilter/xt_ipvs.c           |  189 +++++++++++++++++++++++++++++++++++++
 11 files changed, 420 insertions(+), 95 deletions(-)
 create mode 100644 include/linux/netfilter/xt_ipvs.h
 create mode 100644 net/netfilter/xt_ipvs.c


Changes to iptables
(iptables.git, "xt_quota: also document negation")

Hannes Eder (1):
      libxt_ipvs: user-space lib for netfilter matcher xt_ipvs

 configure.ac                      |   10 1
 extensions/libxt_ipvs.c           |  365 +++++++++++++++++++++++++++++++++++++
 extensions/libxt_ipvs.man         |   24 ++
 include/linux/netfilter/xt_ipvs.h |   25 +++
 4 files changed, 422 insertions(+), 2 deletions(-)
 create mode 100644 extensions/libxt_ipvs.c
 create mode 100644 extensions/libxt_ipvs.man
 create mode 100644 include/linux/netfilter/xt_ipvs.h


--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
