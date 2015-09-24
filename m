From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 26/84] ipvs: Pass ipvs not net to __ip_vs_get_service_entries
Date: Thu, 24 Sep 2015 09:52:11 +0900
Message-ID: <1443055989-1306-27-git-send-email-horms@verge.net.au>
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
index 7aba55c875cb..05f7e1d14738 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2477,11 +2477,10 @@ ip_vs_copy_service(struct ip_vs_service_entry *dst, struct ip_vs_service *src)
 }
 
 static inline int
-__ip_vs_get_service_entries(struct net *net,
+__ip_vs_get_service_entries(struct netns_ipvs *ipvs,
 			    const struct ip_vs_get_services *get,
 			    struct ip_vs_get_services __user *uptr)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	int idx, count=0;
 	struct ip_vs_service *svc;
 	struct ip_vs_service_entry entry;
@@ -2720,7 +2719,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 			ret = -EINVAL;
 			goto out;
 		}
-		ret = __ip_vs_get_service_entries(net, get, user);
+		ret = __ip_vs_get_service_entries(ipvs, get, user);
 	}
 	break;
 
-- 
2.1.4
