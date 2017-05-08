From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] ipvs: SNAT packet replies only for NATed connections
Date: Mon,  8 May 2017 11:48:43 +0200
Message-ID: <1494236923-8015-2-git-send-email-horms@verge.net.au>
References: <1494236923-8015-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1494236928; bh=QMI4ouWKAqrm6/wYSMLW5alco8PK6de4sLjay8R7jl8=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=F6upCJZI+ErKrBpb2DS5CnK75PSyc/zuuPrkIHTDNEH00i45xvmFZlbRPifKhVPoW
         mETQUySYnaIDDyv+su2C4In0B1sgnnDRir7ZQFKEnbwYA8M66y6PzAzI7rRqfePM6Q
         PZvJKS2QSVRDvAfCbJhWpqUZNEpBQC/gMUWBazpQ=
In-Reply-To: <1494236923-8015-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

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
Tested-by: Nick Moriarty <nick.moriarty@york.ac.uk>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index d2d7bdf1d510..ad99c1ceea6f 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -849,10 +849,8 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
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
@@ -886,6 +884,8 @@ static int handle_response_icmp(int af, struct sk_buff *skb,
 		ip_vs_notrack(skb);
 	else
 		ip_vs_update_conntrack(skb, cp, 0);
+
+ignore_cp:
 	verdict = NF_ACCEPT;
 
 out:
@@ -1385,8 +1385,11 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
 	 */
 	cp = pp->conn_out_get(ipvs, af, skb, &iph);
 
-	if (likely(cp))
+	if (likely(cp)) {
+		if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
+			goto ignore_cp;
 		return handle_response(af, skb, pd, cp, &iph, hooknum);
+	}
 
 	/* Check for real-server-started requests */
 	if (atomic_read(&ipvs->conn_out_counter)) {
@@ -1444,9 +1447,15 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
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
2.1.4

