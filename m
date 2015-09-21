From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 11/84] ipvs: Pass ipvs not net to __ip_vs_service_find
Date: Mon, 21 Sep 2015 13:01:48 -0500
Message-ID: <1442858581-15869-11-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index dcb3c10a4ef2..fd8de5ceffca 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -357,10 +357,9 @@ static int ip_vs_svc_unhash(struct ip_vs_service *svc)
  *	Get service by {netns, proto,addr,port} in the service table.
  */
 static inline struct ip_vs_service *
-__ip_vs_service_find(struct net *net, int af, __u16 protocol,
+__ip_vs_service_find(struct netns_ipvs *ipvs, int af, __u16 protocol,
 		     const union nf_inet_addr *vaddr, __be16 vport)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	unsigned int hash;
 	struct ip_vs_service *svc;
 
@@ -426,7 +425,7 @@ ip_vs_service_find(struct net *net, int af, __u32 fwmark, __u16 protocol,
 	 *	Check the table hashed by <protocol,addr,port>
 	 *	for "full" addressed entries
 	 */
-	svc = __ip_vs_service_find(net, af, protocol, vaddr, vport);
+	svc = __ip_vs_service_find(ipvs, af, protocol, vaddr, vport);
 
 	if (svc == NULL
 	    && protocol == IPPROTO_TCP
@@ -436,7 +435,7 @@ ip_vs_service_find(struct net *net, int af, __u32 fwmark, __u16 protocol,
 		 * Check if ftp service entry exists, the packet
 		 * might belong to FTP data connections.
 		 */
-		svc = __ip_vs_service_find(net, af, protocol, vaddr, FTPPORT);
+		svc = __ip_vs_service_find(ipvs, af, protocol, vaddr, FTPPORT);
 	}
 
 	if (svc == NULL
@@ -444,7 +443,7 @@ ip_vs_service_find(struct net *net, int af, __u32 fwmark, __u16 protocol,
 		/*
 		 * Check if the catch-all port (port zero) exists
 		 */
-		svc = __ip_vs_service_find(net, af, protocol, vaddr, 0);
+		svc = __ip_vs_service_find(ipvs, af, protocol, vaddr, 0);
 	}
 
   out:
@@ -2411,7 +2410,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 	/* Lookup the exact service by <protocol, addr, port> or fwmark */
 	rcu_read_lock();
 	if (usvc.fwmark == 0)
-		svc = __ip_vs_service_find(net, usvc.af, usvc.protocol,
+		svc = __ip_vs_service_find(ipvs, usvc.af, usvc.protocol,
 					   &usvc.addr, usvc.port);
 	else
 		svc = __ip_vs_svc_fwm_find(ipvs, usvc.af, usvc.fwmark);
@@ -2551,7 +2550,7 @@ __ip_vs_get_dest_entries(struct net *net, const struct ip_vs_get_dests *get,
 	if (get->fwmark)
 		svc = __ip_vs_svc_fwm_find(ipvs, AF_INET, get->fwmark);
 	else
-		svc = __ip_vs_service_find(net, AF_INET, get->protocol, &addr,
+		svc = __ip_vs_service_find(ipvs, AF_INET, get->protocol, &addr,
 					   get->port);
 	rcu_read_unlock();
 
@@ -2745,7 +2744,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 		if (entry->fwmark)
 			svc = __ip_vs_svc_fwm_find(ipvs, AF_INET, entry->fwmark);
 		else
-			svc = __ip_vs_service_find(net, AF_INET,
+			svc = __ip_vs_service_find(ipvs, AF_INET,
 						   entry->protocol, &addr,
 						   entry->port);
 		rcu_read_unlock();
@@ -3094,7 +3093,7 @@ static int ip_vs_genl_parse_service(struct net *net,
 	if (usvc->fwmark)
 		svc = __ip_vs_svc_fwm_find(ipvs, usvc->af, usvc->fwmark);
 	else
-		svc = __ip_vs_service_find(net, usvc->af, usvc->protocol,
+		svc = __ip_vs_service_find(ipvs, usvc->af, usvc->protocol,
 					   &usvc->addr, usvc->port);
 	rcu_read_unlock();
 	*ret_svc = svc;
-- 
2.2.1

