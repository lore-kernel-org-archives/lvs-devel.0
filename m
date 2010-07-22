From: Simon Horman <horms@verge.net.au>
Subject: [patch v2.8 0/4] IPVS full NAT support + netfilter 'ipvs' match support
Date: Thu, 22 Jul 2010 16:35:47 +0900
Message-ID: <20100722073547.504156161@vergenet.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Malcolm Turnbull <malcolm@loadbalancer.org>, Mark Brooks <mark@loadbalancer.org>, Wensong Zhang <wensong@linux-vs.org>, Julius Volz <julius.volz@gmail.com>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>, Hannes Eder <heder@google.com>, Jan Engelhardt <jengelh@medozas.de>

This is a repost of a patch-series posted by Hannes Eder last September.
This is v2 of the patch series and I don't see any outstanding objections to
it in the mailing list archives.

Series v2.8 Convert XT_IPVS_IPVS_* from #defines to an enum,
       as suggested by Jan Engelhardt <jengelh@medozas.de>

Series v2.7 Fixes header miss-match between kernel and user-space

Series v2.6 fixes the arguments to  of %pI4

Series v2.5 fixes some problems introduced in v2.4.

Series v2.4 addresses all of the concerns that Patrick McHardy raised
witht the v2.3 series.

The original cover-email from Hannes follows.
The diffstat output has been updated to reflect changes by me.

Mark Brooks has tested the v2.7 patchset, and found no problems.
Details of his test follow Hannes's cover. I have made minor
edits to Mark's email but not the results.

----------------------------------------------------------------------

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


 include/linux/netfilter/xt_ipvs.h |   27 +++++
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
 11 files changed, 422 insertions(+), 95 deletions(-)
 create mode 100644 include/linux/netfilter/xt_ipvs.h
 create mode 100644 net/netfilter/xt_ipvs.c


Changes to iptables
(iptables.git, "xt_quota: also document negation")

Hannes Eder (1):
      libxt_ipvs: user-space lib for netfilter matcher xt_ipvs

 configure.ac                      |   10 1
 extensions/libxt_ipvs.c           |  365 +++++++++++++++++++++++++++++++++++++
 extensions/libxt_ipvs.man         |   24 ++
 include/linux/netfilter/xt_ipvs.h |   27 +++
 4 files changed, 424 insertions(+), 2 deletions(-)
 create mode 100644 extensions/libxt_ipvs.c
 create mode 100644 extensions/libxt_ipvs.man
 create mode 100644 include/linux/netfilter/xt_ipvs.h

----------------------------------------------------------------------

From: Mark Brooks <mark@loadbalancer.org>

I'm going to detail my setup and what I did to test/confirm this (you can
probably skip this bit if you want bit I thought I should include it for
completeness)

The Loadbalancer

IPVS 1.2.1
iptables 1.4.8 --patched
kernel - 2.6.35-rc1 --patched

eth0 ip 192.168.17.93
eth0:45 192.168.18.21 (I would have used eth1 but couldn't find a test box
spare with 2 network cards in)

My test box -

eth0 192.168.18.1

The Webserver -

192.168.17.4:80

Commands to setup ipvs and iptables

IPVS
ipvsadm -A -t 192.168.18.21:80 -s rr
ipvsadm -a -t 192.168.18.21:80 -r 192.168.17.4:80 -m

iptables
/usr/local/sbin/iptables -t nat -A POSTROUTING -m ipvs --vaddr
192.168.18.21/24 --vport 80 -j SNAT --to-source 192.168.17.93

iptables shows -

iptables -t nat -L
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination

Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination

Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
SNAT       all  --  anywhere             anywhere            vaddr
192.168.18.0/24 vport 80 to:192.168.17.93

ipvsadm shows -

ipvsadm -ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  192.168.18.21:80 rr
  -> 192.168.17.4:80              Masq    1      0          0



Connected to the IP from my browser page loaded fine and you can see in the
apache log -

"192.168.17.93 - - [21/Jul/2010:08:44:00 -0400] "GET / HTTP/1.1" 200 82"

Finally I ran a couple of tests with httperf for about 6 hours to see if
anything strange happened

httperf --hog --server 192.168.18.21 --num-con 250 --ra $NUMBER --timeout 5

A maximum number of connections of 250 at rates between 1 and 250
connections per second. Every connection completed fine and there appeared
to be no problems.

