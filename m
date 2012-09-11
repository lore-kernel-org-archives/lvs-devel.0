From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH V3 4/8] ipvs: Fix bug in IPv6 NAT mangling of ports inside
	ICMPv6 packets
Date: Tue, 11 Sep 2012 14:37:15 +0200
Message-ID: <20120911123708.4305.50410.stgit@dragon>
References: <20120911123531.4305.40304.stgit@dragon>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20120911123531.4305.40304.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Hans Schillstrom <hans@schillstrom.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Thomas Graf <tgraf@suug.ch>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>

ICMPv6 return traffic, which needs to be NAT modified, does
not get modified correctly, because the SKB have not been
made sufficiently "writable".

Make sure SKB is writable in ip_vs_nat_icmp_v6().

Note, the calling code path have handled this case for IPv4, but
not for IPv6.  I have placed the change in ip_vs_nat_icmp_v6()
in-order to reduce the changes/impact of that path.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/netfilter/ipvs/ip_vs_core.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index ebd105c..fd50f47 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -737,6 +737,12 @@ void ip_vs_nat_icmp_v6(struct sk_buff *skb, struct ip_vs_protocol *pp,
 						      icmp_offset);
 	struct ipv6hdr *ciph	 = (struct ipv6hdr *)(icmph + 1);
 
+	/* Make sure SKB is writable */
+	unsigned int write;
+	write = icmp_offset + sizeof(struct icmp6hdr) + sizeof(struct ipv6hdr);
+	if (!skb_make_writable(skb, write + 2 * sizeof(__u16)))
+		return;
+
 	if (inout) {
 		iph->saddr = cp->vaddr.in6;
 		ciph->daddr = cp->vaddr.in6;
