From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/4] ipvs: drop first packet to redirect conntrack
Date: Mon,  7 Mar 2016 12:03:32 +0900
Message-ID: <1457319814-8027-3-git-send-email-horms@verge.net.au>
References: <1457319814-8027-1-git-send-email-horms@verge.net.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1457319820; bh=9rN9e6MV4Ek57ROTJdRC+yP3IG5vxubtIhzScCFEDGw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=fM9myiFvHuPSjBjGSorhySCaQTEHG9R4GKmh0Q9JWsCwQvivZnR+7GllstmYB7c7k
	 gPvIHbr+vsMu4Deh42TNpk0kSZnzu/9vGwgr0+S5430mxTNxZBC9g54EwjWQvxcy78
	 dVWbJe7pqyR62Rqt5Artnm5jNQQY0nXkvNVgzi5E=
In-Reply-To: <1457319814-8027-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Jiri Bohac <jbohac@suse.cz>, Simon Horman <horms@verge.net.au>

From: Julian Anastasov <ja@ssi.bg>

Jiri Bohac is reporting for a problem where the attempt
to reschedule existing connection to another real server
needs proper redirect for the conntrack used by the IPVS
connection. For example, when IPVS connection is created
to NAT-ed real server we alter the reply direction of
conntrack. If we later decide to select different real
server we can not alter again the conntrack. And if we
expire the old connection, the new connection is left
without conntrack.

So, the only way to redirect both the IPVS connection and
the Netfilter's conntrack is to drop the SYN packet that
hits existing connection, to wait for the next jiffie
to expire the old connection and its conntrack and to rely
on client's retransmission to create new connection as
usually.

Jiri Bohac provided a fix that drops all SYNs on rescheduling,
I extended his patch to do such drops only for connections
that use conntrack. Here is the original report from Jiri Bohac:

Since commit dc7b3eb900aa ("ipvs: Fix reuse connection if real server
is dead"), new connections to dead servers are redistributed
immediately to new servers.  The old connection is expired using
ip_vs_conn_expire_now() which sets the connection timer to expire
immediately.

However, before the timer callback, ip_vs_conn_expire(), is run
to clean the connection's conntrack entry, the new redistributed
connection may already be established and its conntrack removed
instead.

Fix this by dropping the first packet of the new connection
instead, like we do when the destination server is not available.
The timer will have deleted the old conntrack entry long before
the first packet of the new connection is retransmitted.

Fixes: dc7b3eb900aa ("ipvs: Fix reuse connection if real server is dead")
Signed-off-by: Jiri Bohac <jbohac@suse.cz>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             | 17 +++++++++++++++++
 net/netfilter/ipvs/ip_vs_core.c | 37 ++++++++++++++++++++++++++++---------
 2 files changed, 45 insertions(+), 9 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 0816c872b689..a6cc576fd467 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1588,6 +1588,23 @@ static inline void ip_vs_conn_drop_conntrack(struct ip_vs_conn *cp)
 }
 #endif /* CONFIG_IP_VS_NFCT */
 
+/* Really using conntrack? */
+static inline bool ip_vs_conn_uses_conntrack(struct ip_vs_conn *cp,
+					     struct sk_buff *skb)
+{
+#ifdef CONFIG_IP_VS_NFCT
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+
+	if (!(cp->flags & IP_VS_CONN_F_NFCT))
+		return false;
+	ct = nf_ct_get(skb, &ctinfo);
+	if (ct && !nf_ct_is_untracked(ct))
+		return true;
+#endif
+	return false;
+}
+
 static inline int
 ip_vs_dest_conn_overhead(struct ip_vs_dest *dest)
 {
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index f57b4dcdb233..4da560005b0e 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1757,15 +1757,34 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
 	cp = pp->conn_in_get(ipvs, af, skb, &iph);
 
 	conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
-	if (conn_reuse_mode && !iph.fragoffs &&
-	    is_new_conn(skb, &iph) && cp &&
-	    ((unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
-	      unlikely(!atomic_read(&cp->dest->weight))) ||
-	     unlikely(is_new_conn_expected(cp, conn_reuse_mode)))) {
-		if (!atomic_read(&cp->n_control))
-			ip_vs_conn_expire_now(cp);
-		__ip_vs_conn_put(cp);
-		cp = NULL;
+	if (conn_reuse_mode && !iph.fragoffs && is_new_conn(skb, &iph) && cp) {
+		bool uses_ct = false, resched = false;
+
+		if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
+		    unlikely(!atomic_read(&cp->dest->weight))) {
+			resched = true;
+			uses_ct = ip_vs_conn_uses_conntrack(cp, skb);
+		} else if (is_new_conn_expected(cp, conn_reuse_mode)) {
+			uses_ct = ip_vs_conn_uses_conntrack(cp, skb);
+			if (!atomic_read(&cp->n_control)) {
+				resched = true;
+			} else {
+				/* Do not reschedule controlling connection
+				 * that uses conntrack while it is still
+				 * referenced by controlled connection(s).
+				 */
+				resched = !uses_ct;
+			}
+		}
+
+		if (resched) {
+			if (!atomic_read(&cp->n_control))
+				ip_vs_conn_expire_now(cp);
+			__ip_vs_conn_put(cp);
+			if (uses_ct)
+				return NF_DROP;
+			cp = NULL;
+		}
 	}
 
 	if (unlikely(!cp)) {
-- 
2.1.4

