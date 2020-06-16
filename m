From: YangYuxi <yx.atom1@gmail.com>
Subject: [PATCH] ipvs: avoid drop first packet by reusing conntrack
Date: Tue, 16 Jun 2020 16:28:56 +0800
Message-ID: <20200616082856.GA22668@VM_111_229_centos>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :content-transfer-encoding:user-agent;
        bh=ee7JBA4N+BXx5f1zTvLNBRShtRkjIFThGXMYifBNrAc=;
        b=tGwUKJJP8WXY/P5hsPZn8pNVezAGaIgdZt9w3AW6VLNxdX7DYTJzHzl0q+G1bZtnWe
         S0mVgam1f+VxKz/ei3gUKeGEDJDnmM0LqIOzN7pUynBKXv3XPIZOeUkF8mu8zbV6Z5ZN
         vzeIVjJm7Ej4BiybplDSWMhXvJj6/NQxr6k6REuKykFZ2YeLGMj+Umq0R2o3jqUeS8kY
         dx7Pxq3mWNeGLEuT1SUHhZNpmCh7qgSaK4ubN4aPsEqM6dOE5aBHcddvpWXuJOH/L9qO
         etFha9VDAnKVp5CXgXaLva3YdxlZ0tjL7rPPfyHKOgQigLI5QmDivClue/BZmgx3143F
         ECEA==
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, davem@davemloft.net, kuba@kernel.org
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, yx.atom1@gmail.com

Since 'commit f719e3754ee2 ("ipvs: drop first packet to
redirect conntrack")', when a new TCP connection meet
the conditions that need reschedule, the first syn packet
is dropped, this cause one second latency for the new
connection, more discussion about this problem can easy
search from google, such as:

1)One second connection delay in masque
https://marc.info/?t=151683118100004&r=1&w=2

2)IPVS low throughput #70747
https://github.com/kubernetes/kubernetes/issues/70747

3)Apache Bench can fill up ipvs service proxy in seconds #544
https://github.com/cloudnativelabs/kube-router/issues/544

4)Additional 1s latency in `host -> service IP -> pod`
https://github.com/kubernetes/kubernetes/issues/90854

5)kube-proxy ipvs conn_reuse_mode setting causes errors
with high load from single client
https://github.com/kubernetes/kubernetes/issues/81775

The root cause is when the old session is expired, the
conntrack related to the session is dropped by
ip_vs_conn_drop_conntrack. The code is as follows:
```
static void ip_vs_conn_expire(struct timer_list *t)
{
...

     if ((cp->flags & IP_VS_CONN_F_NFCT) &&
         !(cp->flags & IP_VS_CONN_F_ONE_PACKET)) {
             /* Do not access conntracks during subsys cleanup
              * because nf_conntrack_find_get can not be used after
              * conntrack cleanup for the net.
              */
             smp_rmb();
             if (ipvs->enable)
                     ip_vs_conn_drop_conntrack(cp);
     }
...
}
```
As shown in the code, only when condition (cp->flags & IP_VS_CONN_F_NFCT)
is true, the function ip_vs_conn_drop_conntrack will be called.

So we optimize this by following steps (Administrators
can choose the following optimization by setting
net.ipv4.vs.conn_reuse_old_conntrack=1):
1) erase the IP_VS_CONN_F_NFCT flag (it is safely because
   no packets will use the old session)
2) call ip_vs_conn_expire_now to release the old session,
   then the related conntrack will not be dropped
3) then ipvs unnecessary to drop the first syn packet, it
   just continue to pass the syn packet to the next process,
   create a new ipvs session, and the new session will related
   to the old conntrack(which is reopened by conntrack as a new
   one), the next whole things is just as normal as that the old
   session isn't used to exist.

The above processing has no problems except for passive FTP,
for passive FTP situation, ipvs can judging from
condition (atomic_read(&cp->n_control)) and condition (cp->control).
So, for other conditions(means not FTP), ipvs should give users
the right to choose，they can choose a high performance one processing
logical by setting net.ipv4.vs.conn_reuse_old_conntrack=1. It is necessary
because most business scenarios (such as kubernetes) are very sensitive
to TCP short connection latency.

This patch has been verified on our thousands of kubernets
node servers on Tencent Inc.

Signed-off-by: YangYuxi <yx.atom1@gmail.com>
---
 Documentation/networking/ipvs-sysctl.rst | 23 +++++++++++++++++++++++
 include/net/ip_vs.h                      | 11 +++++++++++
 net/netfilter/ipvs/ip_vs_core.c          | 11 +++++++++--
 net/netfilter/ipvs/ip_vs_ctl.c           |  2 ++
 4 files changed, 45 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/ipvs-sysctl.rst b/Documentation/networking/ipvs-sysctl.rst
index be36c4600e8f..1c8eac824d2b 100644
--- a/Documentation/networking/ipvs-sysctl.rst
+++ b/Documentation/networking/ipvs-sysctl.rst
@@ -50,6 +50,29 @@ conn_reuse_mode - INTEGER
 	balancer in Direct Routing mode. This bit helps on adding new
 	real servers to a very busy cluster.
 
+conn_reuse_old_conntrack - BOOLEAN
+	- 0 - disabled
+	- not 0 - enabled (default)
+
+	If set, when a new TCP syn packet hit an old ipvs connection
+	table and need reschedule to a new dest: if
+		1) the packet use conntrack
+		2) the old ipvs connection table is not a master control
+		   connection (E.g the command connection of passived FTP)
+		3) the old ipvs connection table been not controlled by any
+		   connections (E.g the data connection of passived FTP)
+	ipvs Will not release the old conntrack, just let the conntrack
+	reopen the old session as it is a new one. This is an optimization
+	option selectable by the system administrator.
+
+	If not set, when a new TCP syn packet hit an old ipvs connection
+	table and need reschedule to a new dest: if
+		1) the packet use conntrack
+	ipvs just drop this syn packet, expire the old connection by timer.
+	This will cause the client tcp syn to retransmit.
+
+	Only has effect when conn_reuse_mode not 0.
+
 conntrack - BOOLEAN
 	- 0 - disabled (default)
 	- not 0 - enabled
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 83be2d93b407..052fa87d2a44 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -928,6 +928,7 @@ struct netns_ipvs {
 	int			sysctl_pmtu_disc;
 	int			sysctl_backup_only;
 	int			sysctl_conn_reuse_mode;
+	int			sysctl_conn_reuse_old_conntrack;
 	int			sysctl_schedule_icmp;
 	int			sysctl_ignore_tunneled;
 
@@ -1049,6 +1050,11 @@ static inline int sysctl_conn_reuse_mode(struct netns_ipvs *ipvs)
 	return ipvs->sysctl_conn_reuse_mode;
 }
 
+static inline int sysctl_conn_reuse_old_conntrack(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_conn_reuse_old_conntrack;
+}
+
 static inline int sysctl_schedule_icmp(struct netns_ipvs *ipvs)
 {
 	return ipvs->sysctl_schedule_icmp;
@@ -1136,6 +1142,11 @@ static inline int sysctl_conn_reuse_mode(struct netns_ipvs *ipvs)
 	return 1;
 }
 
+static inline int sysctl_conn_reuse_old_conntrack(struct netns_ipvs *ipvs)
+{
+	return 1;
+}
+
 static inline int sysctl_schedule_icmp(struct netns_ipvs *ipvs)
 {
 	return 0;
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index aa6a603a2425..d1e9af6b5792 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2066,7 +2066,7 @@ static int ip_vs_in_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
 
 	conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
 	if (conn_reuse_mode && !iph.fragoffs && is_new_conn(skb, &iph) && cp) {
-		bool uses_ct = false, resched = false;
+		bool uses_ct = false, resched = false, drop = false;
 
 		if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
 		    unlikely(!atomic_read(&cp->dest->weight))) {
@@ -2086,10 +2086,17 @@ static int ip_vs_in_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
 		}
 
 		if (resched) {
+			if (uses_ct) {
+				if (unlikely(!atomic_read(&cp->n_control) && !cp->control) &&
+				    likely(sysctl_conn_reuse_old_conntrack(ipvs)))
+					cp->flags &= ~IP_VS_CONN_F_NFCT;
+				else
+					drop = true;
+			}
 			if (!atomic_read(&cp->n_control))
 				ip_vs_conn_expire_now(cp);
 			__ip_vs_conn_put(cp);
-			if (uses_ct)
+			if (drop)
 				return NF_DROP;
 			cp = NULL;
 		}
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 412656c34f20..eeb87994c21f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -4049,7 +4049,9 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 	tbl[idx++].data = &ipvs->sysctl_pmtu_disc;
 	tbl[idx++].data = &ipvs->sysctl_backup_only;
 	ipvs->sysctl_conn_reuse_mode = 1;
+	ipvs->sysctl_conn_reuse_old_conntrack = 1;
 	tbl[idx++].data = &ipvs->sysctl_conn_reuse_mode;
+	tbl[idx++].data = &ipvs->sysctl_conn_reuse_old_conntrack;
 	tbl[idx++].data = &ipvs->sysctl_schedule_icmp;
 	tbl[idx++].data = &ipvs->sysctl_ignore_tunneled;
 
-- 
1.8.3.1

