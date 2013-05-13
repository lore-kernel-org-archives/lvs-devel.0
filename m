From: =?UTF-8?q?Grzegorz=20=C5=81yczba?= <grzegorz.lyczba@gmail.com>
Subject: [PATCH v3] ipvs: Fix reuse connection if real server is dead
Date: Mon, 13 May 2013 23:56:24 +0200
Message-ID: <1368482184-16985-1-git-send-email-grzegorz.lyczba@gmail.com>
References: <alpine.LFD.2.00.1305111533350.1612@ja.ssi.bg>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=x-received:from:to:cc:subject:date:message-id:x-mailer:in-reply-to
         :references;
        bh=/Mm9BbtEB7DgJRA91AubnlyzgwpV2iPAJcD0yvnkqs8=;
        b=jaysLDcDyfNtqB+LBMWJljur/E58Zlkt3d64ti3w0y7wnGcz6OBDhNY4Nw78EgkEUK
         XjL0OOS3AoAKDeYCTS+jgCSF5CcwROLa85tgwtviffln1Gux93a2qbSnOqrXfyjNoNSw
         EVuJVmqjug0c9RMhwwmPm0RwhFZETIFUobp3wo9nwJEexJFs9RH6Q1KGaicrEapXUGyv
         fS+Zc1hyd/o0DSmU37orKMRqvleR06HX/QK0dg/nzLID2LBWWnP68jY2hH1smwJt4QjI
         pdOaPvCeSYGi49dh1MT/IQ8o8L8p10H2QgMD9iMLi2YOprbbkCpyxja4IHN/wxpwOxFR
         OwsQ==
In-Reply-To: <alpine.LFD.2.00.1305111533350.1612@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, Grzegorz Lyczba <grzegorz.lyczba@gmail.com>

From: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>

Expire cached connection for new TCP/SCTP connection if real server is down

Signed-off-by: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>
---
 net/netfilter/ipvs/ip_vs_core.c |   36 ++++++++++++++++++++++++++++++++++++
 1 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 47edf5a..2e349ca 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1002,6 +1002,33 @@ static inline int is_tcp_reset(const struct sk_buff *skb, int nh_len)
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
+				sizeof(schunk), &schunk);
+		if (sch == NULL)
+			return false;
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

