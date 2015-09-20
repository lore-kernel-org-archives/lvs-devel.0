From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 27/84] ipvs: Pass ipvs not net to __ip_vs_get_dest_entries
Date: Sun, 20 Sep 2015 01:22:43 -0500
Message-ID: <1442730220-32458-27-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 9c307a822962..176068c3a7fe 100644
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
2.2.1
