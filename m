From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 08/84] ipvs: Pass ipvs not net to ip_vs_svc_fwm_hashkey
Date: Mon, 21 Sep 2015 13:01:45 -0500
Message-ID: <1442858581-15869-8-git-send-email-ebiederm@xmission.com>
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

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 7132e83617b6..5e5f40f85a31 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -285,9 +285,9 @@ ip_vs_svc_hashkey(struct net *net, int af, unsigned int proto,
 /*
  *	Returns hash value of fwmark for virtual service lookup
  */
-static inline unsigned int ip_vs_svc_fwm_hashkey(struct net *net, __u32 fwmark)
+static inline unsigned int ip_vs_svc_fwm_hashkey(struct netns_ipvs *ipvs, __u32 fwmark)
 {
-	return (((size_t)net>>8) ^ fwmark) & IP_VS_SVC_TAB_MASK;
+	return (((size_t)ipvs>>8) ^ fwmark) & IP_VS_SVC_TAB_MASK;
 }
 
 /*
@@ -316,7 +316,7 @@ static int ip_vs_svc_hash(struct ip_vs_service *svc)
 		/*
 		 *  Hash it by fwmark in svc_fwm_table
 		 */
-		hash = ip_vs_svc_fwm_hashkey(svc->ipvs->net, svc->fwmark);
+		hash = ip_vs_svc_fwm_hashkey(svc->ipvs, svc->fwmark);
 		hlist_add_head_rcu(&svc->f_list, &ip_vs_svc_fwm_table[hash]);
 	}
 
@@ -393,7 +393,7 @@ __ip_vs_svc_fwm_find(struct net *net, int af, __u32 fwmark)
 	struct ip_vs_service *svc;
 
 	/* Check for fwmark addressed entries */
-	hash = ip_vs_svc_fwm_hashkey(net, fwmark);
+	hash = ip_vs_svc_fwm_hashkey(ipvs, fwmark);
 
 	hlist_for_each_entry_rcu(svc, &ip_vs_svc_fwm_table[hash], f_list) {
 		if (svc->fwmark == fwmark && svc->af == af
-- 
2.2.1
