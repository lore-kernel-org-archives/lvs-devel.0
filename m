From: Simon Horman <horms@verge.net.au>
Subject: [GIT] Please pull updates for IPVS
Date: Wed, 10 Sep 2008 09:45:40 +1000
Message-ID: <20080909234538.GA12883@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: David Miller <davem@davemloft.net>, Herbert Xu <herbert@gondor.apana.org.au>, Sven Wegener <sven.wegener@stealer.net>, Julius Volz <juliusv@google.com>, Vince Busam <vbusam@google.com>, Malcolm Turnbull <malcolm@loadbalancer.org>, Siim =?iso-8859-1?Q?P=F5der?= <siim@p6drad-teel.net>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Hi Dave,

Sorry for not sending a pull-request for a while. There are two new
features, IPv6 and local process load balancing. Unfortunately there we=
re
some conflicts to shake out. And even more unfortunately some errors we=
re
introduced along the way. In hindsight I should have merged IPv6 first =
and
sent you that. But I think that things are in order now.

If you would like me to change my process, please just let me know.

Summary:

1) Julius Volz and Vince Busam added IPv6 support.

2) Malcolm Turnbull and Siim P=F5der added support to allow
   connections from a local process to be load balanced.

3) I merged the local process load balancing and IPv6 features.

4) Julius Volz noticed that I broke IPv6 during this merge and
   thanks to some extensive testing found a bogus call
   to ip_route_me_harder(). This was a cut-and-paste error
   on my part. Very sorry about that.

5) Julian Anastasov noted that the local process feature was
   allowing for empty TCP checksums which is not legal. After
   discussion with Herbert Xu it was determined that the problem
   was that the new code didn't handle partial checksums correctly.

   Partial checksums were previously not possible as traffic from the
   loopback device was not handled at all (can they show up other ways?=
). I
   added some code to both TCP and UDP to handle PARTIAL_CHECKSUM. Once
   again Julius Volz did a lot of work testing the solution and verifyi=
ng
   that it worked.

   I also came up with some patches to implement IPVS's checksumming in
   terms of the standard proto_csum_replace* helper functions. These
   patches produce incorrect checksums and have been put on hold for no=
w.

6) Sven Wegener provided some post-merge review of the IPv6 code
   and some cleanup patches.

7) Sven Wegener provided a patch to streamline the way that the
   connection table size is configured through Kconfig.


The following changes are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-2.6.git lvs-n=
ext-2.6

They should apply cleanly to net-next-2.6, which I pulled and merged th=
is
morning.

Julius Volz (23):
      IPVS: Add CONFIG_IP_VS_IPV6 option for IPv6 support
      IPVS: Change IPVS data structures to support IPv6 addresses
      IPVS: Add general v4/v6 helper functions / data structures
      IPVS: Add debug macros for v4 and v6 address output
      IPVS: Add internal versions of sockopt interface structs
      IPVS: Convert __ip_vs_svc_get() and __ip_vs_fwm_get()
      IPVS: Add v6 support to ip_vs_service_get()
      IPVS: Add IPv6 support flag to schedulers
      IPVS: Add 'af' args to protocol handler functions
      IPVS: Add protocol debug functions for IPv6
      IPVS: Extend protocol DNAT/SNAT and state handlers
      IPVS: Extend functions for getting/creating connections
      IPVS: Add IPv6 support to xmit() support functions
      IPVS: Add and bind IPv6 xmit functions
      IPVS: Extend scheduling functions for IPv6 support
      IPVS: Add/adjust Netfilter hook functions and helpers for v6
      IPVS: Convert real server lookup functions
      IVPS: Disable sync daemon for IPv6 connections
      IPVS: Turn off FTP application helper for IPv6
      IPVS: Adjust various debug outputs to use new macros
      IPVS: Activate IPv6 Netfilter hooks
      IPVS: Allow adding IPv6 services from userspace
      IPVS: Remove incorrect ip_route_me_harder(), fix IPv6

Malcolm Turnbull (1):
      ipvs: load balance IPv4 connections from a local process

Simon Horman (5):
      ipvs: load balance ipv6 connections from a local process
      IPVS: fix bogus indentation
      IPVS: use ipv6_addr_copy()
      ipvs: handle PARTIAL_CHECKSUM
      Merge git://git.kernel.org/.../davem/net-next-2.6 into lvs-next-2=
=2E6

Sven Wegener (6):
      ipvs: Use pointer to address from sync message
      ipvs: Return negative error values from ip_vs_edit_service()
      ipvs: Mark tcp/udp v4 and v6 debug functions static
      ipvs: Reject ipv6 link-local addresses for destinations
      ipvs: Restrict connection table size via Kconfig
      ipvs: Embed user stats structure into kernel stats structure

Vince Busam (2):
      IPVS: Convert procfs files for IPv6 entry output
      IPVS: Add function to determine if IPv6 address is local

 include/net/ip_vs.h                |  308 ++++++++++---
 net/ipv4/ipvs/Kconfig              |   11=20
 net/ipv4/ipvs/ip_vs_conn.c         |  249 +++++++----
 net/ipv4/ipvs/ip_vs_core.c         |  806 +++++++++++++++++++++++++++-=
--------
 net/ipv4/ipvs/ip_vs_ctl.c          |  523 +++++++++++++++--------
 net/ipv4/ipvs/ip_vs_dh.c           |    5=20
 net/ipv4/ipvs/ip_vs_est.c          |   40 -
 net/ipv4/ipvs/ip_vs_ftp.c          |   61 +-
 net/ipv4/ipvs/ip_vs_lblc.c         |    7=20
 net/ipv4/ipvs/ip_vs_lblcr.c        |   11=20
 net/ipv4/ipvs/ip_vs_lc.c           |   11=20
 net/ipv4/ipvs/ip_vs_nq.c           |   15=20
 net/ipv4/ipvs/ip_vs_proto.c        |   65 ++
 net/ipv4/ipvs/ip_vs_proto_ah_esp.c |  100 ++--
 net/ipv4/ipvs/ip_vs_proto_tcp.c    |  253 ++++++++---
 net/ipv4/ipvs/ip_vs_proto_udp.c    |  226 +++++++---
 net/ipv4/ipvs/ip_vs_rr.c           |   13=20
 net/ipv4/ipvs/ip_vs_sed.c          |   15=20
 net/ipv4/ipvs/ip_vs_sh.c           |    5=20
 net/ipv4/ipvs/ip_vs_sync.c         |   40 +
 net/ipv4/ipvs/ip_vs_wlc.c          |   15=20
 net/ipv4/ipvs/ip_vs_wrr.c          |   15=20
 net/ipv4/ipvs/ip_vs_xmit.c         |  471 ++++++++++++++++++++-
 23 files changed, 2469 insertions(+), 796 deletions(-)

