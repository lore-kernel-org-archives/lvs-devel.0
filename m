From: =?UTF-8?q?Grzegorz=20=C5=81yczba?= <grzegorz.lyczba@gmail.com>
Subject: [PATCH v4] ipvs: Fix reuse connection if real server is dead
Date: Thu, 23 May 2013 17:36:44 +0200
Message-ID: <1369323404-6112-1-git-send-email-grzegorz.lyczba@gmail.com>
References: <20130522055740.GB4392@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=from:to:cc:subject:date:message-id:x-mailer:in-reply-to:references;
        bh=C1xqQHfNpjxY9Pc0az3+go6XsINAVQ/5yRZjSSlHT2g=;
        b=qXrSqvZNDg0AkQhyhdhXpfdZG0j7z3tlxdJ4kP9LA7jxRdUY0E6WdiY5T6DqRFNP2N
         HXo1/9/401BFYm6/ZzBx7xP7SP/GhALkNIOZvpibiFdcLZu4LGYI28rlOxrBnL0WOgwo
         UWoz31tPlsTJ5XbkAqGyccEE/UhBGPsrxl0Qh2gMPphF1vDCdMySjQWM3A/aQOi9y8d1
         E4ufMAZiJMOm+j8uh0dsCiZT2MmTzbWIouvo+S6r7iQjULtQ3EgQqRJwDGSuZACzyjqp
         XZXZ6rmhLwfABUDE8dVg/8Pv/wxb5VnFBu11Y5VW5jDtqcX8kjBi9KFJe0lS4grQcSks
         GN1Q==
In-Reply-To: <20130522055740.GB4392@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Grzegorz Lyczba <grzegorz.lyczba@gmail.com>

From: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>

Expire cached connection for new TCP/SCTP connection if real server is down

Signed-off-by: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>
Acked-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_core.c |   35 +++++++++++++++++++++++++++++++++++
 1 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 47edf5a..85972e4 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1002,6 +1002,32 @@ static inline int is_tcp_reset(const struct sk_buff *skb, int nh_len)
 	return th->rst;
 }
 
+static inline bool is_new_conn(const struct sk_buff *skb,
+			       struct ip_vs_iphdr *iph)
+{
+	switch (iph->protocol) {
+	case IPPROTO_TCP: {
+		struct tcphdr _tcph, *th;
+
+		th = skb_header_pointer(skb, iph->len, sizeof(_tcph), &_tcph);
+		if (th == NULL)
+			return false;
+		return th->syn;
+	}
+	case IPPROTO_SCTP: {
+		sctp_chunkhdr_t *sch, schunk;
+
+		sch = skb_header_pointer(skb, iph->len + sizeof(sctp_sctphdr_t),
+					 sizeof(schunk), &schunk);
+		if (sch == NULL)
+			return false;
+		return sch->type == SCTP_CID_INIT;
+	}
+	default:
+		return false;
+	}
+}
+
 /* Handle response packets: rewrite addresses and send away...
  */
 static unsigned int
@@ -1627,6 +1653,15 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	 * Check if the packet belongs to an existing connection entry
 	 */
 	cp = pp->conn_in_get(af, skb, &iph, 0);
+
+	if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp && cp->dest &&
+	    unlikely(!atomic_read(&cp->dest->weight)) && !iph.fragoffs &&
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

