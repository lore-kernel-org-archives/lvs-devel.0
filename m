From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 63/84] ipvs: Pass ipvs not net to ip_vs_conn_hashkey
Date: Thu, 24 Sep 2015 09:52:48 +0900
Message-ID: <1443055989-1306-64-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Use the address of struct netns_ipvs in the hash not the address of
struct net.  Both addresses are equally valid candidates and by using
the address of struct netns_ipvs there becomes no need deal with
struct net in this part of the code.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 7a4d1d8e8f0c..a99bbf6c8202 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -108,7 +108,7 @@ static inline void ct_write_unlock_bh(unsigned int key)
 /*
  *	Returns hash value for IPVS connection entry
  */
-static unsigned int ip_vs_conn_hashkey(struct net *net, int af, unsigned int proto,
+static unsigned int ip_vs_conn_hashkey(struct netns_ipvs *ipvs, int af, unsigned int proto,
 				       const union nf_inet_addr *addr,
 				       __be16 port)
 {
@@ -116,11 +116,11 @@ static unsigned int ip_vs_conn_hashkey(struct net *net, int af, unsigned int pro
 	if (af == AF_INET6)
 		return (jhash_3words(jhash(addr, 16, ip_vs_conn_rnd),
 				    (__force u32)port, proto, ip_vs_conn_rnd) ^
-			((size_t)net>>8)) & ip_vs_conn_tab_mask;
+			((size_t)ipvs>>8)) & ip_vs_conn_tab_mask;
 #endif
 	return (jhash_3words((__force u32)addr->ip, (__force u32)port, proto,
 			    ip_vs_conn_rnd) ^
-		((size_t)net>>8)) & ip_vs_conn_tab_mask;
+		((size_t)ipvs>>8)) & ip_vs_conn_tab_mask;
 }
 
 static unsigned int ip_vs_conn_hashkey_param(const struct ip_vs_conn_param *p,
@@ -141,7 +141,7 @@ static unsigned int ip_vs_conn_hashkey_param(const struct ip_vs_conn_param *p,
 		port = p->vport;
 	}
 
-	return ip_vs_conn_hashkey(p->ipvs->net, p->af, p->protocol, addr, port);
+	return ip_vs_conn_hashkey(p->ipvs, p->af, p->protocol, addr, port);
 }
 
 static unsigned int ip_vs_conn_hashkey_conn(const struct ip_vs_conn *cp)
-- 
2.1.4

