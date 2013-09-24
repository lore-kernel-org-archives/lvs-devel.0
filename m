From: Alexander Frolkin <avf@eldamar.org.uk>
Subject: Re: [PATCH] ipvs: improved SH fallback strategy
Date: Tue, 24 Sep 2013 10:32:38 +0100
Message-ID: <20130924093238.GD18494@eldamar.org.uk>
References: <20130923115139.GA15034@eldamar.org.uk>
 <524099BA.5020303@cogentembedded.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <524099BA.5020303@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org

Improve the SH fallback realserver selection strategy.
 
With sh and sh-fallback, if a realserver is down, this attempts to
distribute the traffic that would have gone to that server evenly
among the remaining servers.
 
Signed-off-by: Alexander Frolkin <avf@eldamar.org.uk>
--
diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index 3588fae..0db7d01 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -120,22 +120,33 @@ static inline struct ip_vs_dest *
 ip_vs_sh_get_fallback(struct ip_vs_service *svc, struct ip_vs_sh_state *s,
 		      const union nf_inet_addr *addr, __be16 port)
 {
-	unsigned int offset;
-	unsigned int hash;
+	unsigned int offset, roffset;
+	unsigned int hash, ihash;
 	struct ip_vs_dest *dest;
 
-	for (offset = 0; offset < IP_VS_SH_TAB_SIZE; offset++) {
-		hash = ip_vs_sh_hashkey(svc->af, addr, port, offset);
-		dest = rcu_dereference(s->buckets[hash].dest);
-		if (!dest)
-			break;
-		if (is_unavailable(dest))
-			IP_VS_DBG_BUF(6, "SH: selected unavailable server "
-				      "%s:%d (offset %d)",
+	ihash = ip_vs_sh_hashkey(svc->af, addr, port, 0);
+	dest = rcu_dereference(s->buckets[ihash].dest);
+	if (!dest)
+		return NULL;
+	if (is_unavailable(dest)) {
+		IP_VS_DBG_BUF(6, "SH: selected unavailable server "
+		      "%s:%d, reselecting",
+		      IP_VS_DBG_ADDR(svc->af, &dest->addr),
+		      ntohs(dest->port));
+		for (offset = 0; offset < IP_VS_SH_TAB_SIZE; offset++) {
+			roffset = (offset + ihash) % IP_VS_SH_TAB_SIZE;
+			hash = ip_vs_sh_hashkey(svc->af, addr, port, roffset);
+			dest = rcu_dereference(s->buckets[hash].dest);
+			if (is_unavailable(dest))
+				IP_VS_DBG_BUF(6, "SH: selected unavailable "
+				      "server %s:%d (offset %d), reselecting",
 				      IP_VS_DBG_ADDR(svc->af, &dest->addr),
-				      ntohs(dest->port), offset);
-		else
-			return dest;
+				      ntohs(dest->port), roffset);
+			else
+				return dest;
+		}
+	} else {
+		return dest;
 	}
 
 	return NULL;
