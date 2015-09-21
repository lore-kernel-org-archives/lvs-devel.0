From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 10/84] ipvs: Pass ipvs not net to ip_vs_svc_hashkey
Date: Mon, 21 Sep 2015 13:01:47 -0500
Message-ID: <1442858581-15869-10-git-send-email-ebiederm@xmission.com>
References: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>

Use the address of ipvs not the address of net when computing the
hash value.  This removes an unncessary dependency on struct net.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 740703ee7116..dcb3c10a4ef2 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -263,7 +263,7 @@ static struct hlist_head ip_vs_svc_fwm_table[IP_VS_SVC_TAB_SIZE];
  *	Returns hash value for virtual service
  */
 static inline unsigned int
-ip_vs_svc_hashkey(struct net *net, int af, unsigned int proto,
+ip_vs_svc_hashkey(struct netns_ipvs *ipvs, int af, unsigned int proto,
 		  const union nf_inet_addr *addr, __be16 port)
 {
 	register unsigned int porth = ntohs(port);
@@ -276,7 +276,7 @@ ip_vs_svc_hashkey(struct net *net, int af, unsigned int proto,
 			    addr->ip6[2]^addr->ip6[3];
 #endif
 	ahash = ntohl(addr_fold);
-	ahash ^= ((size_t) net >> 8);
+	ahash ^= ((size_t) ipvs >> 8);
 
 	return (proto ^ ahash ^ (porth >> IP_VS_SVC_TAB_BITS) ^ porth) &
 	       IP_VS_SVC_TAB_MASK;
@@ -309,7 +309,7 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
 		/*
 		 *  Hash it by <netns,protocol,addr,port> in ip_vs_svc_table
 		 */
-		hash = ip_vs_svc_hashkey(svc->ipvs->net, svc->af, svc->protocol,
+		hash = ip_vs_svc_hashkey(svc->ipvs, svc->af, svc->protocol,
 					 &svc->addr, svc->port);
 		hlist_add_head_rcu(&svc->s_list, &ip_vs_svc_table[hash]);
 	} else {
@@ -365,7 +365,7 @@ __ip_vs_service_find(struct net *net, int af, __u16 protocol,
 	struct ip_vs_service *svc;
 
 	/* Check for "full" addressed entries */
-	hash = ip_vs_svc_hashkey(net, af, protocol, vaddr, vport);
+	hash = ip_vs_svc_hashkey(ipvs, af, protocol, vaddr, vport);
 
 	hlist_for_each_entry_rcu(svc, &ip_vs_svc_table[hash], s_list) {
 		if ((svc->af == af)
-- 
2.2.1
