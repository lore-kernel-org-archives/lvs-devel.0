From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 09/84] ipvs: Pass ipvs not net to __ip_vs_svc_fwm_find
Date: Mon, 21 Sep 2015 13:01:46 -0500
Message-ID: <1442858581-15869-9-git-send-email-ebiederm@xmission.com>
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

ipvs is what the code actually wants to use.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 5e5f40f85a31..740703ee7116 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -386,9 +386,8 @@ __ip_vs_service_find(struct net *net, int af, __u16 protocol,
  *	Get service by {fwmark} in the service table.
  */
 static inline struct ip_vs_service *
-__ip_vs_svc_fwm_find(struct net *net, int af, __u32 fwmark)
+__ip_vs_svc_fwm_find(struct netns_ipvs *ipvs, int af, __u32 fwmark)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	unsigned int hash;
 	struct ip_vs_service *svc;
 
@@ -418,7 +417,7 @@ ip_vs_service_find(struct net *net, int af, __u32 fwmark, __u16 protocol,
 	 *	Check the table hashed by fwmark first
 	 */
 	if (fwmark) {
-		svc = __ip_vs_svc_fwm_find(net, af, fwmark);
+		svc = __ip_vs_svc_fwm_find(ipvs, af, fwmark);
 		if (svc)
 			goto out;
 	}
@@ -2415,7 +2414,7 @@ do_ip_vs_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		svc = __ip_vs_service_find(net, usvc.af, usvc.protocol,
 					   &usvc.addr, usvc.port);
 	else
-		svc = __ip_vs_svc_fwm_find(net, usvc.af, usvc.fwmark);
+		svc = __ip_vs_svc_fwm_find(ipvs, usvc.af, usvc.fwmark);
 	rcu_read_unlock();
 
 	if (cmd != IP_VS_SO_SET_ADD
@@ -2543,13 +2542,14 @@ static inline int
 __ip_vs_get_dest_entries(struct net *net, const struct ip_vs_get_dests *get,
 			 struct ip_vs_get_dests __user *uptr)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_service *svc;
 	union nf_inet_addr addr = { .ip = get->addr };
 	int ret = 0;
 
 	rcu_read_lock();
 	if (get->fwmark)
-		svc = __ip_vs_svc_fwm_find(net, AF_INET, get->fwmark);
+		svc = __ip_vs_svc_fwm_find(ipvs, AF_INET, get->fwmark);
 	else
 		svc = __ip_vs_service_find(net, AF_INET, get->protocol, &addr,
 					   get->port);
@@ -2743,7 +2743,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 		addr.ip = entry->addr;
 		rcu_read_lock();
 		if (entry->fwmark)
-			svc = __ip_vs_svc_fwm_find(net, AF_INET, entry->fwmark);
+			svc = __ip_vs_svc_fwm_find(ipvs, AF_INET, entry->fwmark);
 		else
 			svc = __ip_vs_service_find(net, AF_INET,
 						   entry->protocol, &addr,
@@ -3051,6 +3051,7 @@ static int ip_vs_genl_parse_service(struct net *net,
 				    struct nlattr *nla, int full_entry,
 				    struct ip_vs_service **ret_svc)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct nlattr *attrs[IPVS_SVC_ATTR_MAX + 1];
 	struct nlattr *nla_af, *nla_port, *nla_fwmark, *nla_protocol, *nla_addr;
 	struct ip_vs_service *svc;
@@ -3091,7 +3092,7 @@ static int ip_vs_genl_parse_service(struct net *net,
 
 	rcu_read_lock();
 	if (usvc->fwmark)
-		svc = __ip_vs_svc_fwm_find(net, usvc->af, usvc->fwmark);
+		svc = __ip_vs_svc_fwm_find(ipvs, usvc->af, usvc->fwmark);
 	else
 		svc = __ip_vs_service_find(net, usvc->af, usvc->protocol,
 					   &usvc->addr, usvc->port);
-- 
2.2.1
