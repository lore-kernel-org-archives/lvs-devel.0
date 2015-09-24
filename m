From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 27/84] ipvs: Pass ipvs not net to __ip_vs_get_dest_entries
Date: Thu, 24 Sep 2015 09:52:12 +0900
Message-ID: <1443055989-1306-28-git-send-email-horms@verge.net.au>
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
 net/netfilter/ipvs/ip_vs_ctl.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 05f7e1d14738..6c06e9a8414d 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2528,10 +2528,9 @@ out:
 }
 
 static inline int
-__ip_vs_get_dest_entries(struct net *net, const struct ip_vs_get_dests *get,
+__ip_vs_get_dest_entries(struct netns_ipvs *ipvs, const struct ip_vs_get_dests *get,
 			 struct ip_vs_get_dests __user *uptr)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_service *svc;
 	union nf_inet_addr addr = { .ip = get->addr };
 	int ret = 0;
@@ -2761,7 +2760,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 			ret = -EINVAL;
 			goto out;
 		}
-		ret = __ip_vs_get_dest_entries(net, get, user);
+		ret = __ip_vs_get_dest_entries(ipvs, get, user);
 	}
 	break;
 
-- 
2.1.4
