From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH V2 0/2] net: ipvs and netfilter IPv6 defrag MTU handling
Date: Tue, 28 Aug 2012 16:21:17 +0200
Message-ID: <20120828142051.11475.63775.stgit@dragon>
References: <Pine.GSO.4.63.1208281020530.18770@stinky-local.trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.GSO.4.63.1208281020530.18770@stinky-local.trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Hans Schillstrom <hans@schillstrom.com>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org

The following patchset V2 makes IPVS compatible with Patrick McHardys
IPv6 NAT patchset: http://thread.gmane.org/gmane.linux.network/239615

Specifically the part that improves defragmentation.

 Patch01: Cleanup (and fixes a bug) in IPVS MTU IPv6 handling
  In V2: we also handle tunnel mode, to use the common helper

 Patch02: Extend MTU check to account for IPv6 NAT defrag changes
  In V2: the tunnel mode is no longer a special case.

This patchset is based upon:
 Homes ipvs-next tree:
  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git

BUT with Patrick McHardy's IPv6 NAT patchset applied first, on top of
commit: 3654e61137db891f5312e6dd813b961484b5fdf3
title: "ipvs: add pmtu_disc option to disable IP DF for TUN packets"

---

Jesper Dangaard Brouer (2):
      ipvs: Extend MTU check to account for IPv6 NAT defrag changes
      ipvs: IPv6 MTU checking cleanup and bugfix


 net/netfilter/ipvs/ip_vs_xmit.c |   28 ++++++++++++++++++++++------
 1 files changed, 22 insertions(+), 6 deletions(-)


--
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
