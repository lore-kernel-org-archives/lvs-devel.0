From: Hans Schillstrom <hans@schillstrom.com>
Subject: [PATCH 2/6] IPVS: labels at pos 0
Date: Wed, 20 Apr 2011 20:33:50 +0200
Message-ID: <1303324434-14024-3-git-send-email-hans@schillstrom.com>
References: <1303324434-14024-1-git-send-email-hans@schillstrom.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1303324434-14024-1-git-send-email-hans@schillstrom.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: horms@verge.net.au, ja@ssi.bg, ebiederm@xmission.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: hans.schillstrom@ericsson.com, Hans Schillstrom <hans@schillstrom.com>

Put goto labels at the beginig of row
acording to coding style example.

Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
---
 net/netfilter/ipvs/ip_vs_core.c |   10 +++++-----
 net/netfilter/ipvs/ip_vs_ctl.c  |    8 ++++----
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index a0791dc..d536b51 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1388,7 +1388,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 		verdict = NF_DROP;
 	}
 
-  out:
+out:
 	__ip_vs_conn_put(cp);
 
 	return verdict;
@@ -1955,14 +1955,14 @@ static int __init ip_vs_init(void)
 
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
 	unregister_pernet_subsys(&ipvs_core_ops);	/* free ip_vs struct */
 	return ret;
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index ae47090..a31a70c 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1327,9 +1327,9 @@ ip_vs_edit_service(struct ip_vs_service *svc, struct ip_vs_service_user_kern *u)
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
@@ -2387,7 +2387,7 @@ __ip_vs_get_service_entries(struct net *net,
 			count++;
 		}
 	}
-  out:
+out:
 	return ret;
 }
 
@@ -2625,7 +2625,7 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 		ret = -EINVAL;
 	}
 
-  out:
+out:
 	mutex_unlock(&__ip_vs_mutex);
 	return ret;
 }
-- 
1.7.2.3

