From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL nf-next] IPVS for 3.7 #2
Date: Fri, 28 Sep 2012 11:54:57 +0900
Message-ID: <1348800904-23902-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Hans Schillstrom <hans@schillstrom.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Hi Pablo,

please consider the following enhancements to IPVS for inclusion in 3.7.

----------------------------------------------------------------
The following changes since commit 82c93fcc2e1737fede2752520f1bf8f4de6304d8:

  x86: bpf_jit_comp: add XOR instruction for BPF JIT (2012-09-24 16:54:35 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git master

for you to fetch changes up to 92eec78d25aee6bbc9bd295f51c022ddfa80cdd9:

  ipvs: SIP fragment handling (2012-09-28 11:37:16 +0900)

----------------------------------------------------------------
Jesper Dangaard Brouer (7):
      ipvs: Trivial changes, use compressed IPv6 address in output
      ipvs: IPv6 extend ICMPv6 handling for future types
      ipvs: Use config macro IS_ENABLED()
      ipvs: Fix faulty IPv6 extension header handling in IPVS
      ipvs: Complete IPv6 fragment handling for IPVS
      ipvs: API change to avoid rescan of IPv6 exthdr
      ipvs: SIP fragment handling

 include/net/ip_vs.h                     |  194 +++++++++++----
 net/netfilter/ipvs/Kconfig              |    7 +-
 net/netfilter/ipvs/ip_vs_conn.c         |   15 +-
 net/netfilter/ipvs/ip_vs_core.c         |  404 +++++++++++++++++--------------
 net/netfilter/ipvs/ip_vs_dh.c           |    2 +-
 net/netfilter/ipvs/ip_vs_lblc.c         |    2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c        |    2 +-
 net/netfilter/ipvs/ip_vs_pe_sip.c       |   18 +-
 net/netfilter/ipvs/ip_vs_proto.c        |    6 +-
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |    9 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |   42 ++--
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |   40 ++-
 net/netfilter/ipvs/ip_vs_proto_udp.c    |   41 ++--
 net/netfilter/ipvs/ip_vs_sched.c        |    2 +-
 net/netfilter/ipvs/ip_vs_sh.c           |    2 +-
 net/netfilter/ipvs/ip_vs_xmit.c         |   73 +++---
 net/netfilter/xt_ipvs.c                 |    4 +-
 17 files changed, 501 insertions(+), 362 deletions(-)
