From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 41/84] ipvs: Pass ipvs not net to ip_vs_proc_conn
Date: Thu, 24 Sep 2015 09:52:26 +0900
Message-ID: <1443055989-1306-42-git-send-email-horms@verge.net.au>
References: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1443055989-1306-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, "Eric W. Biederman" <ebiederm@xmission.com>, Simon Horman <horms@verge.net.au>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index a0808f230cd6..98180904ccd2 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -835,7 +835,7 @@ ip_vs_conn_fill_param_sync(struct netns_ipvs *ipvs, int af, union ip_vs_sync_con
  *  Param: ...
  *         timeout is in sec.
  */
-static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
+static void ip_vs_proc_conn(struct netns_ipvs *ipvs, struct ip_vs_conn_param *param,
 			    unsigned int flags, unsigned int state,
 			    unsigned int protocol, unsigned int type,
 			    const union nf_inet_addr *daddr, __be16 dport,
@@ -844,7 +844,6 @@ static void ip_vs_proc_conn(struct net *net, struct ip_vs_conn_param *param,
 {
 	struct ip_vs_dest *dest;
 	struct ip_vs_conn *cp;
-	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	if (!(flags & IP_VS_CONN_F_TEMPLATE)) {
 		cp = ip_vs_conn_in_get(param);
@@ -1014,7 +1013,7 @@ static void ip_vs_process_message_v0(struct netns_ipvs *ipvs, const char *buffer
 				      s->vport, &param);
 
 		/* Send timeout as Zero */
-		ip_vs_proc_conn(ipvs->net, &param, flags, state, s->protocol, AF_INET,
+		ip_vs_proc_conn(ipvs, &param, flags, state, s->protocol, AF_INET,
 				(union nf_inet_addr *)&s->daddr, s->dport,
 				0, 0, opt);
 	}
@@ -1067,6 +1066,7 @@ static int ip_vs_proc_str(__u8 *p, unsigned int plen, unsigned int *data_len,
  */
 static inline int ip_vs_proc_sync_conn(struct net *net, __u8 *p, __u8 *msg_end)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_sync_conn_options opt;
 	union  ip_vs_sync_conn *s;
 	struct ip_vs_protocol *pp;
@@ -1169,21 +1169,21 @@ static inline int ip_vs_proc_sync_conn(struct net *net, __u8 *p, __u8 *msg_end)
 			state = 0;
 		}
 	}
-	if (ip_vs_conn_fill_param_sync(net_ipvs(net), af, s, &param, pe_data,
+	if (ip_vs_conn_fill_param_sync(ipvs, af, s, &param, pe_data,
 				       pe_data_len, pe_name, pe_name_len)) {
 		retc = 50;
 		goto out;
 	}
 	/* If only IPv4, just silent skip IPv6 */
 	if (af == AF_INET)
-		ip_vs_proc_conn(net, &param, flags, state, s->v4.protocol, af,
+		ip_vs_proc_conn(ipvs, &param, flags, state, s->v4.protocol, af,
 				(union nf_inet_addr *)&s->v4.daddr, s->v4.dport,
 				ntohl(s->v4.timeout), ntohl(s->v4.fwmark),
 				(opt_flags & IPVS_OPT_F_SEQ_DATA ? &opt : NULL)
 				);
 #ifdef CONFIG_IP_VS_IPV6
 	else
-		ip_vs_proc_conn(net, &param, flags, state, s->v6.protocol, af,
+		ip_vs_proc_conn(ipvs, &param, flags, state, s->v6.protocol, af,
 				(union nf_inet_addr *)&s->v6.daddr, s->v6.dport,
 				ntohl(s->v6.timeout), ntohl(s->v6.fwmark),
 				(opt_flags & IPVS_OPT_F_SEQ_DATA ? &opt : NULL)
-- 
2.1.4
