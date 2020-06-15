From: YangYuxi <yx.atom1@gmail.com>
Subject: [PATCH] ipvs: avoid drop first packet by reusing conntrack
Date: Mon, 15 Jun 2020 22:35:33 +0800
Message-ID: <20200615143533.GA26989@VM_111_229_centos>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :content-transfer-encoding:user-agent;
        bh=1ZlRIXdBSvQHhi5bZmtFn3RECL0gCLJpVvAo6R/4ZhM=;
        b=cRVo8Ts90LpXrwKk8ehREP9WWD2Rc+h7+JoQj1LNOx90vQQ2hPymmegNbzVIETCehk
         voiqXVRAJCSRfjOjzXVRL4LlxS1DyyithB+Hw2OpHSTWldQY7L6xhGp5+/S9v9NXkSgs
         CkQ8hJCnP9mRmstgBKXL8jlEAHz18OcemUToDwnPfNwyjE4x57pq782Rfwv62HS3/Lbr
         OXo9lXeDz6gk40KGbuapGR3Cbvnf8OCPLqkzeEk2VtylJGz2oUP4J/OO7a/4AeWgkz7x
         mrXaaV8D27jnw8TMOdQReO88pTOvHe+IsSQLZBKKggBwv/Z8Wzn71yMGQtyT1T7m409U
         BSgw==
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

The above processing has no problems except for passive FTP and
connmarks (state matching (-m state)). So, ipvs should give
users the right to choose，when FTP or connmarks is not used,
they can choose a high performance one processing logical by
setting net.ipv4.vs.conn_reuse_old_conntrack=1. It is necessary
because most business scenarios (such as kubernetes) are not
used FTP and connmark, but these services are very sensitive
to TCP short connection latency.

This patch has been verified on our thousands of kubernets
node servers on Tencent Inc.

Signed-off-by: YangYuxi <yx.atom1@gmail.com>
---
 include/net/ip_vs.h             | 11 +++++++++++
 net/netfilter/ipvs/ip_vs_core.c | 10 ++++++++--
 net/netfilter/ipvs/ip_vs_ctl.c  |  2 ++
 3 files changed, 21 insertions(+), 2 deletions(-)

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
index aa6a603a2425..0b89c872ea46 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2066,7 +2066,7 @@ static int ip_vs_in_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
 
 	conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
 	if (conn_reuse_mode && !iph.fragoffs && is_new_conn(skb, &iph) && cp) {
-		bool uses_ct = false, resched = false;
+		bool uses_ct = false, resched = false, drop = false;
 
 		if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
 		    unlikely(!atomic_read(&cp->dest->weight))) {
@@ -2086,10 +2086,16 @@ static int ip_vs_in_icmp_v6(struct netns_ipvs *ipvs, struct sk_buff *skb,
 		}
 
 		if (resched) {
+			if (uses_ct) {
+				if (likely(sysctl_conn_reuse_old_conntrack(ipvs)))
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

