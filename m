From: Marco Angaroni <marcoangaroni@gmail.com>
Subject: [PATCH] ipvs: make drop_entry protection effective for SIP-pe
Date: Tue, 26 Apr 2016 21:20:22 +0200
Message-ID: <571fbf76.2SIflQ7gFAmOpH7S%marcoangaroni@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=date:from:to:subject:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=+z20zi3AfzcQPStXd5KL+EcxRlnx0W/yNS5Av7o40TY=;
        b=Hq8FZoRuf1XsyRsDu2l4LRa7OXDs+MFcxZuAYivNE+x5IHnCB+U/++s/pjAq70o5FL
         MSDy7+G8/p7SH6r5iTCs77RQMVqbYab0r9qVyUfvowZHQyx0Oe/W4tSUIrnK71SNwLXE
         87P45/YF9i6s8KZC7o2QnexREuJeD7krkOCpgOxzQ5f+ndejcif5FWF6QSqQDeiiC/1e
         RygKhwgo0P8ubloQX1CFmZIsne+v+quUwC0iz/GDlFn3VtrONAHNhzdoNpxdn+MvYbZp
         AZ56tBc0saianloU6t4WDzSLiBZacqxCBtbyXPwLSwwmtWQ7vBYo7F+fNwphEw5itymy
         kvNQ==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org

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
---
 net/netfilter/ipvs/ip_vs_conn.c | 22 +++++++++++++++++++---
 net/netfilter/ipvs/ip_vs_core.c |  8 +++++++-
 2 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 292365f..2cb3c62 100644
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
index 398ccb5..a97de51 100644
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
@@ -1971,6 +1974,9 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
 
 	if (ipvs->sync_state & IP_VS_STATE_MASTER)
 		ip_vs_sync_conn(ipvs, cp, pkts);
+	else if ((cp->flags & IP_VS_CONN_F_ONE_PACKET) && cp->control)
+		/* increment is done inside ip_vs_sync_conn too */
+		atomic_inc(&cp->control->in_pkts);
 
 	ip_vs_conn_put(cp);
 	return ret;
-- 
1.8.3.1

