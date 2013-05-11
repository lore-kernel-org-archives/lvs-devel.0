From: =?UTF-8?q?Grzegorz=20=C5=81yczba?= <grzegorz.lyczba@gmail.com>
Subject: [PATCH] ipvs: Fix reuse connection if real server is dead
Date: Sat, 11 May 2013 11:32:25 +0200
Message-ID: <1368264745-15242-1-git-send-email-grzegorz.lyczba@gmail.com>
References: <alpine.LFD.2.00.1305081012310.1912@ja.ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=x-received:from:to:cc:subject:date:message-id:x-mailer:in-reply-to
         :references;
        bh=tK4dAxg0B7l6C+j3IMDIq1EtS6HQxmALBTSraRFl8UU=;
        b=GVq0xWY4maekJXia//9hbQJV/8PabjFabMn0NJUgVHUEGkRSHNg2bWL47Em9ed3Xdk
         R9mC1UlNPgoqWio0BT1wpFZ9Op/FB+CC6m8JnLkutawc/+snyzywlGyl2MYCS3aOEslq
         mgu86zdDzPYFAkvUhKmx8FSWLrzdJpo64jVw2AYJ7zi9brXW6HqRMTfho72PrGn6UxQg
         fg2UFaDSakUMhAO78sF5Po+iwk3nWySpDQo7GTiVKXlinCSpkKc5LfgnTVCqEkF2JwgR
         FN/qylSOo5exvy47ZC31JWdXmcTYDHdf/1xO36EAlCSCwQPoXUeJMl95k7gpzMvH5zAh
         0yTg==
In-Reply-To: <alpine.LFD.2.00.1305081012310.1912@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, Grzegorz Lyczba <grzegorz.lyczba@gmail.com>

From: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>

Expire cached connection for new TCP/SCTP connection if real server is down

Signed-off-by: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>
---
 net/netfilter/ipvs/ip_vs_core.c |   36 ++++++++++++++++++++++++++++++++++++
 1 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 47edf5a..9ee8b70 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1002,6 +1002,33 @@ static inline int is_tcp_reset(const struct sk_buff *skb, int nh_len)
 	return th->rst;
 }
 
+static inline bool is_new_conn(const struct sk_buff *skb,
+	    struct ip_vs_iphdr *iph)
+{
+	switch (iph->protocol) {
+	case IPPROTO_TCP: {
+		struct tcphdr _tcph, *th;
+		th = skb_header_pointer(skb, iph->len, sizeof(_tcph), &_tcph);
+		if (th == NULL) {
+			return false;
+		}
+		return th->syn;
+	}
+	case IPPROTO_SCTP: {
+		sctp_chunkhdr_t *sch, schunk;
+		sch = skb_header_pointer(skb, iph->len + sizeof(sctp_sctphdr_t),
+				sizeof(schunk), &schunk);
+		if (sch == NULL) {
+			return false;
+		}
+		return (sch->type == SCTP_CID_INIT);
+	}
+	default:
+		return false;
+	}
+}
+
+
 /* Handle response packets: rewrite addresses and send away...
  */
 static unsigned int
@@ -1627,6 +1654,15 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	 * Check if the packet belongs to an existing connection entry
 	 */
 	cp = pp->conn_in_get(af, skb, &iph, 0);
+
+	if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp && cp->dest &&
+	    !iph.fragoffs && unlikely(!atomic_read(&cp->dest->weight)) &&
+	    is_new_conn(skb, &iph)) {
+		ip_vs_conn_expire_now(cp);
+		__ip_vs_conn_put(cp);
+		cp = NULL;
+	}
+
 	if (unlikely(!cp) && !iph.fragoffs) {
 		/* No (second) fragments need to enter here, as nf_defrag_ipv6
 		 * replayed fragment zero will already have created the cp
-- 
1.7.5.4

