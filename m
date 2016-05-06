From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 1/1] ipvs: make drop_entry protection effective for SIP-pe
Date: Fri,  6 May 2016 16:32:39 +0900
Message-ID: <1462519959-22382-2-git-send-email-horms@verge.net.au>
References: <1462519959-22382-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1462519965; bh=XBE6BlwKw02FNM8AdSBQ/MWki9kWteoSIFBn3j0GkiY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=iFDO1paoNDZcXNaS0MMSHsszNkQHtsfzhYBs3YAzb+/g9/hiFGAwME273DeG4hUBI
	 dVhiaZggxewoAyNe9fbszu8qFM+UeGro1lG3SYWQ16lJzhZZiGlFSetD30vKO4/ino
	 ofrJI+5VkaM+Qqdd7syoqDMgLUqExAtWWX9Z0cd4=
In-Reply-To: <1462519959-22382-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Marco Angaroni <marcoangaroni@gmail.com>, Simon Horman <horms@verge.net.au>

From: Marco Angaroni <marcoangaroni@gmail.com>

DoS protection policy that deletes connections to avoid out of memory is
currently not effective for SIP-pe plus OPS-mode for two reasons:
  1) connection templates (holding SIP call-id) are always skipped in
     ip_vs_random_dropentry()
  2) in_pkts counter (used by drop_entry algorithm) is not incremented
     for connection templates

This patch addresses such problems with the following changes:
  a) connection templates associated (via their dest) to virtual-services
     configured in OPS mode are included in ip_vs_random_dropentry()
     monitoring. This applies to SIP-pe over UDP (which requires OPS mode),
     but is more general principle: when OPS is controlled by templates
     memory can be used only by templates themselves, since OPS conns are
     deleted after packet is forwarded.
  b) OPS connections, if controlled by a template, cause increment of
     in_pkts counter of their template. This is already happening but only
     in case director is in master-slave mode (see ip_vs_sync_conn()).

Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c | 22 +++++++++++++++++++---
 net/netfilter/ipvs/ip_vs_core.c |  8 +++++++-
 2 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 292365ffa4f0..2cb3c626cd43 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1261,6 +1261,16 @@ static inline int todrop_entry(struct ip_vs_conn *cp)
 	return 1;
 }
 
+static inline bool ip_vs_conn_ops_mode(struct ip_vs_conn *cp)
+{
+	struct ip_vs_service *svc;
+
+	if (!cp->dest)
+		return false;
+	svc = rcu_dereference(cp->dest->svc);
+	return svc && (svc->flags & IP_VS_SVC_F_ONEPACKET);
+}
+
 /* Called from keventd and must protect itself from softirqs */
 void ip_vs_random_dropentry(struct netns_ipvs *ipvs)
 {
@@ -1275,11 +1285,16 @@ void ip_vs_random_dropentry(struct netns_ipvs *ipvs)
 		unsigned int hash = prandom_u32() & ip_vs_conn_tab_mask;
 
 		hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
-			if (cp->flags & IP_VS_CONN_F_TEMPLATE)
-				/* connection template */
-				continue;
 			if (cp->ipvs != ipvs)
 				continue;
+			if (cp->flags & IP_VS_CONN_F_TEMPLATE) {
+				if (atomic_read(&cp->n_control) ||
+				    !ip_vs_conn_ops_mode(cp))
+					continue;
+				else
+					/* connection template of OPS */
+					goto try_drop;
+			}
 			if (cp->protocol == IPPROTO_TCP) {
 				switch(cp->state) {
 				case IP_VS_TCP_S_SYN_RECV:
@@ -1307,6 +1322,7 @@ void ip_vs_random_dropentry(struct netns_ipvs *ipvs)
 					continue;
 				}
 			} else {
+try_drop:
 				if (!todrop_entry(cp))
 					continue;
 			}
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index f3bac2e9a25a..1207f20d24e4 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -612,7 +612,10 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
 		ret = cp->packet_xmit(skb, cp, pd->pp, iph);
 		/* do not touch skb anymore */
 
-		atomic_inc(&cp->in_pkts);
+		if ((cp->flags & IP_VS_CONN_F_ONE_PACKET) && cp->control)
+			atomic_inc(&cp->control->in_pkts);
+		else
+			atomic_inc(&cp->in_pkts);
 		ip_vs_conn_put(cp);
 		return ret;
 	}
@@ -1991,6 +1994,9 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
 
 	if (ipvs->sync_state & IP_VS_STATE_MASTER)
 		ip_vs_sync_conn(ipvs, cp, pkts);
+	else if ((cp->flags & IP_VS_CONN_F_ONE_PACKET) && cp->control)
+		/* increment is done inside ip_vs_sync_conn too */
+		atomic_inc(&cp->control->in_pkts);
 
 	ip_vs_conn_put(cp);
 	return ret;
-- 
2.7.0.rc3.207.g0ac5344

