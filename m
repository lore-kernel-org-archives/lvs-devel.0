From: Simon Horman <horms@verge.net.au>
Subject: [GIT] Please pull updates for IPVS
Date: Tue, 7 Oct 2008 11:17:10 +1100
Message-ID: <20081007001707.GA12647@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: David Miller <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>, Sven Wegener <sven.wegener@stealer.net>, Julius Volz <juliusv@google.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Hi Dave,

Please pull the following changes. Sorry I have let some of
them sit in my tree for a while, I wanted to be sure that
Patrick McHardy was ok with the move to netfilter.

1) Fix from Sven Wegener to prevent more than 255 connections
   from being added to a synchronisation packet - which results
   in something unparsable by the other end. The cause of this was
   an assumption that 1500 would be the largest MTU.

   This bug is likely as old as the synchronisation code.

2) An unused label fix from Sven Wegener.

   This is just minor fall-out from the the IPVS IPv6 merge.

3) Julius Volz moved IPVS from net/ipv4/ipvs/ to net/netfilter/ipvs/

   This is an enourmous patch, but really is a simple as
   the commit message claims.


The following changes are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-2.6.git lvs-next-2.6

They should apply cleanly to net-next-2.6, which I pulled and merged this
morning.

Julius Volz (1):
      IPVS: Move IPVS to net/netfilter/ipvs

Simon Horman (1):
      Merge git://git.kernel.org/.../davem/net-next-2.6 into lvs-next-2.6

Sven Wegener (2):
      ipvs: Restrict sync message to 255 connections
      ipvs: Fix unused label warning

 net/ipv4/Kconfig                        |    2 
 net/ipv4/Makefile                       |    1 
 net/ipv4/ipvs/Kconfig                   |  239 --
 net/ipv4/ipvs/Makefile                  |   33 
 net/ipv4/ipvs/ip_vs_app.c               |  622 -----
 net/ipv4/ipvs/ip_vs_conn.c              | 1110 ---------
 net/ipv4/ipvs/ip_vs_core.c              | 1542 -------------
 net/ipv4/ipvs/ip_vs_ctl.c               | 3441 ------------------------------
 net/ipv4/ipvs/ip_vs_est.c               |  166 -
 net/ipv4/ipvs/ip_vs_ftp.c               |  410 ---
 net/ipv4/ipvs/ip_vs_lblc.c              |  555 ----
 net/ipv4/ipvs/ip_vs_lblcr.c             |  755 ------
 net/ipv4/ipvs/ip_vs_lc.c                |  103 
 net/ipv4/ipvs/ip_vs_nq.c                |  138 -
 net/ipv4/ipvs/ip_vs_proto.c             |  288 --
 net/ipv4/ipvs/ip_vs_proto_ah_esp.c      |  235 --
 net/ipv4/ipvs/ip_vs_proto_tcp.c         |  732 ------
 net/ipv4/ipvs/ip_vs_proto_udp.c         |  533 ----
 net/ipv4/ipvs/ip_vs_rr.c                |  112 -
 net/ipv4/ipvs/ip_vs_sched.c             |  251 --
 net/ipv4/ipvs/ip_vs_sed.c               |  140 -
 net/ipv4/ipvs/ip_vs_sh.c                |  258 --
 net/ipv4/ipvs/ip_vs_sync.c              |  940 --------
 net/ipv4/ipvs/ip_vs_wlc.c               |  128 -
 net/ipv4/ipvs/ip_vs_wrr.c               |  237 --
 net/ipv4/ipvs/ip_vs_xmit.c              | 1004 ---------
 net/netfilter/Kconfig                   |    2 
 net/netfilter/Makefile                  |    3 
 net/netfilter/ipvs/Kconfig              |  239 ++
 net/netfilter/ipvs/Makefile             |   33 
 net/netfilter/ipvs/ip_vs_app.c          |  622 +++++
 net/netfilter/ipvs/ip_vs_conn.c         | 1110 +++++++++
 net/netfilter/ipvs/ip_vs_core.c         | 1542 +++++++++++++
 net/netfilter/ipvs/ip_vs_ctl.c          | 3443 +++++++++++++++++++++++++++++++
 net/netfilter/ipvs/ip_vs_dh.c           |  261 ++
 net/netfilter/ipvs/ip_vs_est.c          |  166 +
 net/netfilter/ipvs/ip_vs_ftp.c          |  410 +++
 net/netfilter/ipvs/ip_vs_lblc.c         |  555 ++++
 net/netfilter/ipvs/ip_vs_lblcr.c        |  755 ++++++
 net/netfilter/ipvs/ip_vs_lc.c           |  103 
 net/netfilter/ipvs/ip_vs_nq.c           |  138 +
 net/netfilter/ipvs/ip_vs_proto.c        |  288 ++
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |  235 ++
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |  732 ++++++
 net/netfilter/ipvs/ip_vs_proto_udp.c    |  533 ++++
 net/netfilter/ipvs/ip_vs_rr.c           |  112 +
 net/netfilter/ipvs/ip_vs_sched.c        |  251 ++
 net/netfilter/ipvs/ip_vs_sed.c          |  140 +
 net/netfilter/ipvs/ip_vs_sh.c           |  258 ++
 net/netfilter/ipvs/ip_vs_sync.c         |  942 ++++++++
 net/netfilter/ipvs/ip_vs_wlc.c          |  128 +
 net/netfilter/ipvs/ip_vs_wrr.c          |  237 ++
 net/netfilter/ipvs/ip_vs_xmit.c         | 1004 +++++++++
 53 files changed, 14242 insertions(+), 13975 deletions(-)

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

