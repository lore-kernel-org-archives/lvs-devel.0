From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [PATCH 1/2] IPVS: labels at pos 0
Date: Mon, 13 Jun 2011 12:19:26 +0200
Message-ID: <1307960367-15318-2-git-send-email-hans.schillstrom@ericsson.com>
References: <1307960367-15318-1-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1307960367-15318-1-git-send-email-hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans@schillstrom.com, Hans Schillstrom <hans.schillstrom@ericsson.com>

Put goto labels at the beginig of row
acording to coding style example.

Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 net/netfilter/ipvs/ip_vs_core.c |   10 +++++-----
 net/netfilter/ipvs/ip_vs_ctl.c  |    8 ++++----
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index f54719a..673504e 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1384,7 +1384,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 		offset += 2 * sizeof(__u16);
 	verdict = ip_vs_icmp_xmit(skb, cp, pp, offset, hooknum);
 
-  out:
+out:
 	__ip_vs_conn_put(cp);
 
 	return verdict;
@@ -2019,14 +2019,14 @@ cleanup_sub:
 	unregister_pernet_subsys(&ipvs_core_ops);
 cleanup_sync:
 	ip_vs_sync_cleanup();
-  cleanup_conn:
+cleanup_conn:
 	ip_vs_conn_cleanup();
-  cleanup_app:
+cleanup_app:
 	ip_vs_app_cleanup();
-  cleanup_protocol:
+cleanup_protocol:
 	ip_vs_protocol_cleanup();
 	ip_vs_control_cleanup();
-  cleanup_estimator:
+cleanup_estimator:
 	ip_vs_estimator_cleanup();
 	return ret;
 }
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 6bedea1..be43fd8 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1334,9 +1334,9 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
 		ip_vs_bind_pe(svc, pe);
 	}
 
-  out_unlock:
+out_unlock:
 	write_unlock_bh(&__ip_vs_svc_lock);
-  out:
+out:
 	ip_vs_scheduler_put(old_sched);
 	ip_vs_pe_put(old_pe);
 	return ret;
@@ -2469,7 +2469,7 @@ __ip_vs_get_service_entries(struct net *net,
 			count++;
 		}
 	}
-  out:
+out:
 	return ret;
 }
 
@@ -2707,7 +2707,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 		ret = -EINVAL;
 	}
 
-  out:
+out:
 	mutex_unlock(&__ip_vs_mutex);
 	return ret;
 }
-- 
1.7.2.3

