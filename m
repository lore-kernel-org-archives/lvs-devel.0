From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 4.4.65 -stable 3/3] ipvs: SNAT packet replies only for NATed connections
Date: Mon,  1 May 2017 16:45:37 +0300
Message-ID: <20170501134537.4715-4-ja@ssi.bg>
References: <20170501134537.4715-1-ja@ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20170501134537.4715-1-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

We do not check if packet from real server is for NAT
connection before performing SNAT. This causes problems
for setups that use DR/TUN and allow local clients to
access the real server directly, for example:

- local client in director creates IPVS-DR/TUN connection
CIP->VIP and the request packets are routed to RIP.
Talks are finished but IPVS connection is not expired yet.

- second local client creates non-IPVS connection CIP->RIP
with same reply tuple RIP->CIP and when replies are received
on LOCAL_IN we wrongly assign them for the first client
connection because RIP->CIP matches the reply direction.
As result, IPVS SNATs replies for non-IPVS connections.

The problem is more visible to local UDP clients but in rare
cases it can happen also for TCP or remote clients when the
real server sends the reply traffic via the director.

So, better to be more precise for the reply traffic.
As replies are not expected for DR/TUN connections, better
to not touch them.

Reported-by: Nick Moriarty <nick.moriarty@york.ac.uk>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_core.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 4da5600..dd1649c 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -845,10 +845,8 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 {
 	unsigned int verdict = NF_DROP;
 
-	if (IP_VS_FWD_METHOD(cp) != 0) {
-		pr_err("shouldn't reach here, because the box is on the "
-		       "half connection in the tun/dr module.\n");
-	}
+	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
+		goto ignore_cp;
 
 	/* Ensure the checksum is correct */
 	if (!skb_csum_unnecessary(skb) && ip_vs_checksum_complete(skb, ihl)) {
@@ -882,6 +880,8 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 		ip_vs_notrack(skb);
 	else
 		ip_vs_update_conntrack(skb, cp, 0);
+
+ignore_cp:
 	verdict = NF_ACCEPT;
 
 out:
@@ -1242,8 +1242,11 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
 	 */
 	cp = pp->conn_out_get(ipvs, af, skb, &iph);
 
-	if (likely(cp))
+	if (likely(cp)) {
+		if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
+			goto ignore_cp;
 		return handle_response(af, skb, pd, cp, &iph, hooknum);
+	}
 	if (sysctl_nat_icmp_send(ipvs) &&
 	    (pp->protocol == IPPROTO_TCP ||
 	     pp->protocol == IPPROTO_UDP ||
@@ -1285,9 +1288,15 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
 			}
 		}
 	}
+
+out:
 	IP_VS_DBG_PKT(12, af, pp, skb, iph.off,
 		      "ip_vs_out: packet continues traversal as normal");
 	return NF_ACCEPT;
+
+ignore_cp:
+	__ip_vs_conn_put(cp);
+	goto out;
 }
 
 /*
-- 
2.9.3

