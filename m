From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH 0/2] net: ipvs and netfilter IPv6 defrag MTU handling
Date: Mon, 27 Aug 2012 16:40:35 +0200
Message-ID: <20120827144024.5754.23872.stgit@dragon>
References: <Pine.GSO.4.63.1208271238170.5279@stinky-local.trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.GSO.4.63.1208271238170.5279@stinky-local.trash.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Hans Schillstrom <hans@schillstrom.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org

The following patchset makes IPVS compatible with Patrick McHardys
IPv6 NAT patchset: http://thread.gmane.org/gmane.linux.network/239615

Specifically the part that improves defragmentation.

 Patch01: Cleanup (and fixes a bug) in IPVS MTU IPv6 handling

 Patch02: Extend MTU check to account for IPv6 NAT defrag changes

This patchset is based upon:
 Homes ipvs-next tree:
  git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git

BUT with Patrick McHardy's IPv6 NAT patchset applied first, on top of
commit: 3654e61137db891f5312e6dd813b961484b5fdf3
title: "ipvs: add pmtu_disc option to disable IP DF for TUN packets"

Send due to request by Patrick:
 http://thread.gmane.org/gmane.linux.network/239615/focus=43870

---

Jesper Dangaard Brouer (2):
      ipvs: Extend MTU check to account for IPv6 NAT defrag changes
      ipvs: IPv6 MTU checking cleanup and bugfix


 net/netfilter/ipvs/ip_vs_xmit.c |   32 ++++++++++++++++++++++++++------
 1 files changed, 26 insertions(+), 6 deletions(-)


--
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
