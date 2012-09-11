From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH V3 0/8] ipvs: IPv6 fragment handling for IPVS
Date: Tue, 11 Sep 2012 14:36:26 +0200
Message-ID: <20120911123531.4305.40304.stgit@dragon>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Hans Schillstrom <hans@schillstrom.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Thomas Graf <tgraf@suug.ch>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>

The following patchset implement IPv6 fragment handling for IPVS.

This work is based upon patches from Hans Schillstrom.  I have taken
over the patchset, in close agreement with Hans, because he don't have
(gotten allocated) time to complete his work.

I have cleaned up the patchset significantly, and split the patchset
up into eight patches.

The first 4 patches, are ready to be merged

 Patch01: Trivial changes, use compressed IPv6 address in output
 Patch02: IPv6 extend ICMPv6 handling for future types
 Patch03: Use config macro IS_ENABLED()
 Patch04: Fix bug in IPVS IPv6 NAT mangling of ports inside ICMPv6 packets

The next 4 patches, I consider V3 of the patches I have submitted
earlier, where I have incorporated all of Julian's feedback.  I have
also tried to make the patches easier to review, by reorganizing the
changes, to be more strictly split (exthdr vs. fragment handling).

I have also removed the API changes, and moved those to patch07.  This
is done, (1) to make it easier to review the patches, and (2) to allow
easier integration of Patricks idea and my RFC patch of caching exthdr
info in skb->cb[].  Thus, we can get these patches applied (and later
go back and apply the caching scheme easier).

 Patch05: Fix faulty IPv6 extension header handling in IPVS
 Patch06: Complete IPv6 fragment handling for IPVS
 Patch07: IPVS API change to avoid rescan of IPv6 exthdr
 Patch08: IPVS SIP fragment handling

The SIP frag handling have been split into its own patch, as I have
not been able to test this part my self.

This patchset is based upon:
  Pablo's nf-next tree:  git://1984.lsi.us.es/nf-next
  On top of commit 0edd94887d19ad73539477395c17ea0d6898947a

---

Jesper Dangaard Brouer (8):
      ipvs: SIP fragment handling
      ipvs: API change to avoid rescan of IPv6 exthdr
      ipvs: Complete IPv6 fragment handling for IPVS
      ipvs: Fix faulty IPv6 extension header handling in IPVS
      ipvs: Fix bug in IPv6 NAT mangling of ports inside ICMPv6 packets
      ipvs: Use config macro IS_ENABLED()
      ipvs: IPv6 extend ICMPv6 handling for future types
      ipvs: Trivial changes, use compressed IPv6 address in output


 include/net/ip_vs.h                     |  194 +++++++++++-----
 net/netfilter/ipvs/Kconfig              |    7 -
 net/netfilter/ipvs/ip_vs_conn.c         |   15 -
 net/netfilter/ipvs/ip_vs_core.c         |  384 +++++++++++++++++--------------
 net/netfilter/ipvs/ip_vs_dh.c           |    2 
 net/netfilter/ipvs/ip_vs_lblc.c         |    2 
 net/netfilter/ipvs/ip_vs_lblcr.c        |    2 
 net/netfilter/ipvs/ip_vs_pe_sip.c       |   21 +-
 net/netfilter/ipvs/ip_vs_proto.c        |    6 
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |    9 -
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |   42 +--
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |   40 +--
 net/netfilter/ipvs/ip_vs_proto_udp.c    |   41 +--
 net/netfilter/ipvs/ip_vs_sched.c        |    2 
 net/netfilter/ipvs/ip_vs_sh.c           |    2 
 net/netfilter/ipvs/ip_vs_xmit.c         |   73 +++---
 net/netfilter/xt_ipvs.c                 |    4 
 17 files changed, 491 insertions(+), 355 deletions(-)


--
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
