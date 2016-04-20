From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/3] ipvs: optimize release of connections in OPS mode
Date: Wed, 20 Apr 2016 12:46:33 +1000
Message-ID: <1461120394-5548-3-git-send-email-horms@verge.net.au>
References: <1461120394-5548-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1461120406; bh=wTsFn6YF+z7bpPlejaW42zlRvctwiN8yNhlfg/wC4/8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=eXq7MlhVWHCrY+wP9VbzxZ4awRlKwo54ptdzpQGR/obUvFaD+1QBTzaeBTW3joc4h
	 ZrBOzoyIfhNQpYOKPMwXb8j+n4EYtsKilZJx9gz/W3lqUCk21Gwjf2YhHXGWrkgSI6
	 hoyZ2qgnuNRDcQDZcfJ+2S+OikPP7cXqLjeJ3Pok=
In-Reply-To: <1461120394-5548-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Marco Angaroni <marcoangaroni@gmail.com>, Simon Horman <horms@verge.net.au>

From: Marco Angaroni <marcoangaroni@gmail.com>

One-packet-scheduling is the most expensive mode in IPVS from
performance point of view: for each packet to be processed a new
connection data structure is created and, after packet is sent,
deleted by starting a new timer set to expire immediately.

SIP persistent-engine needs OPS mode to have Call-ID based load
balancing, so OPS mode performance has negative impact in SIP
protocol load balancing.

This patch aims to improve performance of OPS mode by means of the
following changes in the release mechanism of OPS connections:
a) call expire callback ip_vs_conn_expire() directly instead of
   starting a timer programmed to fire immediately.
b) avoid call_rcu() overhead inside expire callback, since OPS
   connection are not inserted in the hash-table and last just the
   time to process the packet, hence there is no concurrent access
   to such data structures.

Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c | 26 +++++++++++++++++++++++---
 1 file changed, 23 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 85ca189bdc3d..dd75d4120099 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -104,6 +104,7 @@ static inline void ct_write_unlock_bh(unsigned int key)
 	spin_unlock_bh(&__ip_vs_conntbl_lock_array[key&CT_LOCKARRAY_MASK].l);
 }
 
+static void ip_vs_conn_expire(unsigned long data);
 
 /*
  *	Returns hash value for IPVS connection entry
@@ -453,10 +454,16 @@ ip_vs_conn_out_get_proto(struct netns_ipvs *ipvs, int af,
 }
 EXPORT_SYMBOL_GPL(ip_vs_conn_out_get_proto);
 
+static void __ip_vs_conn_put_notimer(struct ip_vs_conn *cp)
+{
+	__ip_vs_conn_put(cp);
+	ip_vs_conn_expire((unsigned long)cp);
+}
+
 /*
  *      Put back the conn and restart its timer with its timeout
  */
-void ip_vs_conn_put(struct ip_vs_conn *cp)
+static void __ip_vs_conn_put_timer(struct ip_vs_conn *cp)
 {
 	unsigned long t = (cp->flags & IP_VS_CONN_F_ONE_PACKET) ?
 		0 : cp->timeout;
@@ -465,6 +472,16 @@ void ip_vs_conn_put(struct ip_vs_conn *cp)
 	__ip_vs_conn_put(cp);
 }
 
+void ip_vs_conn_put(struct ip_vs_conn *cp)
+{
+	if ((cp->flags & IP_VS_CONN_F_ONE_PACKET) &&
+	    (atomic_read(&cp->refcnt) == 1) &&
+	    !timer_pending(&cp->timer))
+		/* expire connection immediately */
+		__ip_vs_conn_put_notimer(cp);
+	else
+		__ip_vs_conn_put_timer(cp);
+}
 
 /*
  *	Fill a no_client_port connection with a client port number
@@ -834,7 +851,10 @@ static void ip_vs_conn_expire(unsigned long data)
 		ip_vs_unbind_dest(cp);
 		if (cp->flags & IP_VS_CONN_F_NO_CPORT)
 			atomic_dec(&ip_vs_conn_no_cport_cnt);
-		call_rcu(&cp->rcu_head, ip_vs_conn_rcu_free);
+		if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
+			ip_vs_conn_rcu_free(&cp->rcu_head);
+		else
+			call_rcu(&cp->rcu_head, ip_vs_conn_rcu_free);
 		atomic_dec(&ipvs->conn_count);
 		return;
 	}
@@ -850,7 +870,7 @@ static void ip_vs_conn_expire(unsigned long data)
 	if (ipvs->sync_state & IP_VS_STATE_MASTER)
 		ip_vs_sync_conn(ipvs, cp, sysctl_sync_threshold(ipvs));
 
-	ip_vs_conn_put(cp);
+	__ip_vs_conn_put_timer(cp);
 }
 
 /* Modify timer, so that it expires as soon as possible.
-- 
2.7.0.rc3.207.g0ac5344

