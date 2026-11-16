Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794854896;
	b=mrnwgtiTdpLAZoAczRrnJWomf8kFmouNxN424jNW+YBjq/Xnlw6jpD1it9i4Cgin1ke+
	 NpwqGL67y0R1JQR+36rviwo7xq+csGFsxu8YLqLRIPVI8Qadu4q2B/N4mrp8Y2vTI6qll
	 JJFWhhyDdhz52T5+mQGdO4kqlWC4L5WhDBA3pOWXWSSfTsCbZ9P88N8l9daqSJ62CxJEF
	 +06XDpb6QwRHvuOVK/2Ob+RveMwbf60Sthky+cCIupED6kTrYS2/LN+juPMfCdaKRCXTE
	 dWTFFaGaZ0kE0pLhFsggZqiLyaaIJGLccKP5aDxwKrWMUA69+/1WRKhNf513IxKvobQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794854896;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=GyA/FrB7iGytTyKmZYu5bx6WXQLhnH+dbx83tfTfnog=;
	b=TRNHdHfZ4PDmoaL9wRDzl5W5gEY4bfXHFB7tt8Ce9cFbu/b14NJhX91ewDGsnAB87Ck8
	 TF3Kw+ZZ8cbig292X0KqWjg36Sansu9YrurqJAKIRD0sZeF5/B96XlGhafv0DPhuUDuka
	 6vIJf9rxQsHnW/9NatFK7gKgHW5a5CYvsBKZeUIm9Sg6lQhl56yOdsI98wmhgsKtkgxBF
	 R4n8wCxTRvrbtWKqhkPIkuj0eYVl/svmrT+vE6HKU2g2+0QhXrl50/GRgGskAQ0S3lt45
	 eeojsxv/DLjxnSSkHCmLRhAFcH57J/lhilCbnEjUrzyAJnMQcc58xBSDJjdpOmefwrw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=7ZAUZJ5b;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 20C35606A32C;
	Mon, 16 Nov 2026 18:48:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 20C35606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=7ZAUZJ5b
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id C0C2B21B52;
	Mon, 16 Nov 2026 20:48:11 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=GyA/FrB7
	iGytTyKmZYu5bx6WXQLhnH+dbx83tfTfnog=; b=7ZAUZJ5bZrViRzz3IPdNSI+k
	ZTbsScCCxoiOnfTzgwl4RmeVLH7Xy24G5JE3K7q+uczdkGLykGt4ykNorR6HC5fP
	iumhSrTIxm7IfIXyyhGxFPKCpbVmvIWib/5+MBlJuqBLJzERbcKl48uBvdgb+Fmx
	BnmA0HFZRiKXZvbn2+u+RMbzCjXCwOklWz5hyj4DwFr2PRlUhtox6QCKTDvTtWBc
	Fb4840XGKXqDX1CrZhl8FN/BwVIjm+y8ocmjTIJQ7XRaregNQECR5gxI2gtKuReD
	rFJSDuIK35xuRYpDFGdZZ3W55SnJI7pkbcApLeKYHpP1Ifn1xOyUE1Do2XZQLl4o
	n2gycg9XvWEM9a7c6TMK2jZ+UcBKxfozCrEe5rAdQEVtvLYtKA7z0JRJpeNwe5iM
	yyoj+PCj55+XlrI0vgElqJQ6J6n46I3AxOORmLIeW5fAi/qsnK10fpMhGcMuHH73
	a7zo9PnE08it3x4sQfnxyE4ODzxSC1LlirBW+ZGGjY6dF3+qvSlbBNMU6rgb2GE8
	Y+WM9HtWHsXTP01zey3xB+wpvo7onYk5CBYcm19hU7iBZZEHIf7jMO6XQWclyPCj
	NceFWqMivsENIiiruJQqzOWGdE1RTRYqqI/ximMG1Stg4DV39swMgtnlvVNZUyeO
	XUStMtFJN7jjdtpMjw4=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 16 Nov 2026 20:48:11 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 5A268600D7;
	Mon, 16 Nov 2026 20:48:11 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6AGIm9E8110174;
	Mon, 16 Nov 2026 20:48:09 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 6AGIm6o1110169;
	Mon, 16 Nov 2026 20:48:06 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Yalagada Pavan Kumar <pavankumaryalagada@gmail.com>,
        Wei Wang <weiwan@google.com>
Subject: [PATCH nf] ipvs: do not delay the dst_release calls
Date: Mon, 16 Nov 2026 20:47:58 +0200
Message-ID: <20261116184758.110151-1-ja@ssi.bg>
X-Mailer: git-send-email 2.56.1
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

syzbot is reporting [1] for a crash when IPVS initiates delayed
dst_release calls from its pernet subsys cleanup handler.

Yalagada Pavan Kumar proposed a new rcu_barrier() to be added
but the problem is different: the FIB layer started to replace
the dst->dev with a blackhole_netdev before the NETDEV_DOWN
event is delivered to the ip_vs_dst_event() handler. As
ip_vs_forget_dev() matches the dst->dev and not the ifindex,
IPVS can miss the event and to defer the dst_release() call
from the pernet device phase to the pernet subsys phase
where ip6_route_net_exit() already destroyed the per-CPU
destination counters.

Fix the dst_release delays in two ways:

1. Cache the ifindex together with the dst and match it on
NETDEV_DOWN event to protect against dst->dev being replaced
with blackhole_netdev. As result, dst_release will not be
left for the dest server removal. This problem can delay the
dst_release for long time if the used device was marked down
independently and not used actively in IPVS before the dest
server is removed.

2. Do not call dst_release from our own RCU callback, dst_release
uses its own RCU callback to destroy the dst, so we can call it
immediately. This allows rcu_barrier to destroy the dst during
the pernet device cleanup.

[1]
BUG: unable to handle page fault for address: ffff8880d456e000
PGD 1d131067 P4D 1d131067 PUD 0
Oops: Oops: 0000 [#1] SMP KASAN NOPTI
CPU: 1 UID: 0 PID: 0 Comm: swapper/1 Tainted: G             L      syzkaller #0 PREEMPT(full)
Tainted: [L]=SOFTLOCKUP
Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS 1.16.3-debian-1.16.3-2 04/01/2014
RIP: 0010:percpu_counter_add_batch+0x4b/0x230 lib/percpu_counter.c:98
Code: 8d 45 58 48 89 c2 48 89 44 24 08 48 b8 00 00 00 00 00 fc ff df 48 c1 ea 03 80 3c 02 00 0f 85 9f 01 00 00 4d 8b 65 58 4c 89 ff <65> 49 63 2c 24 4a 8d 54 35 00 48 89 6c 24 10 48 89 eb 48 89 d0 48
RSP: 0018:ffffc900006b0d68 EFLAGS: 00010246
RAX: dffffc0000000000 RBX: ffff88803e0cf400 RCX: 0000000000000101
RDX: 1ffff11007045bab RSI: ffffffff85702e00 RDI: 0000000000000020
RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000003 R11: 0000000000000001 R12: 0000000000000000
R13: ffff88803822dd00 R14: ffffffffffffffff R15: 0000000000000020
FS:  0000000000000000(0000) GS:ffff8880d456e000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffff8880d456e000 CR3: 0000000025b53000 CR4: 0000000000352ef0
DR0: 0000000000000010 DR1: 00000000fffffffd DR2: 400000000001001d
DR3: fffffffffffffff6 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Call Trace:
 <IRQ>
 dst_entries_add include/net/dst_ops.h:59 [inline]
 dst_count_dec net/core/dst.c:163 [inline]
 dst_count_dec net/core/dst.c:160 [inline]
 dst_release net/core/dst.c:177 [inline]
 dst_release+0x2aa/0x330 net/core/dst.c:166
 ip_vs_dest_dst_rcu_free+0x32/0x50 net/netfilter/ipvs/ip_vs_ctl.c:1081
 rcu_do_batch kernel/rcu/tree.c:2650 [inline]
 rcu_core+0x5f0/0x1220 kernel/rcu/tree.c:2919
 handle_softirqs+0x216/0xa20 kernel/softirq.c:669
 __do_softirq kernel/softirq.c:703 [inline]
 invoke_softirq kernel/softirq.c:542 [inline]
 __irq_exit_rcu+0x178/0x220 kernel/softirq.c:786
 irq_exit_rcu+0x9/0x30 kernel/softirq.c:809
 instr_sysvec_apic_timer_interrupt arch/x86/kernel/apic/apic.c:1062 [inline]
 sysvec_apic_timer_interrupt+0xa3/0xc0 arch/x86/kernel/apic/apic.c:1062
 </IRQ>
 <TASK>

Reported-by: syzbot+84e27adb95fd2a1fe9bb@syzkaller.appspotmail.com
Fixes: 95c47f9cf5e0 ("ipv4: call dst_dev_put() properly")
Cc: Wei Wang <weiwan@google.com>
Cc: Yalagada Pavan Kumar <pavankumaryalagada@gmail.com>
Cc: stable@vger.kernel.org
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/ip_vs.h             |  3 ++-
 net/netfilter/ipvs/ip_vs_ctl.c  | 14 ++++------
 net/netfilter/ipvs/ip_vs_xmit.c | 45 +++++++++++++++++++++++++--------
 3 files changed, 42 insertions(+), 20 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 398d748f01ec..289e4c7ae5ee 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -964,6 +964,7 @@ struct ip_vs_service {
 struct ip_vs_dest_dst {
 	struct dst_entry	*dst_cache;	/* destination cache entry */
 	u32			dst_cookie;
+	int			dst_ifindex;	/* dev ifindex or 0 */
 	union nf_inet_addr	dst_saddr;
 	struct rcu_head		rcu_head;
 };
@@ -2007,7 +2008,7 @@ int ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		    struct ip_vs_protocol *pp, unsigned int toff,
 		    const struct nf_hook_state *state,
 		    struct ip_vs_iphdr *ciph);
-void ip_vs_dest_dst_rcu_free(struct rcu_head *head);
+void ip_vs_dest_dst_rcu_free(struct ip_vs_dest_dst *dest_dst);
 
 #ifdef CONFIG_IP_VS_IPV6
 int ip_vs_null_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index ce9fe20d6106..b0b8b4f770f8 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1072,14 +1072,10 @@ struct ip_vs_dest *ip_vs_find_dest(struct netns_ipvs *ipvs, int svc_af, int dest
 	return dest;
 }
 
-void ip_vs_dest_dst_rcu_free(struct rcu_head *head)
+void ip_vs_dest_dst_rcu_free(struct ip_vs_dest_dst *dest_dst)
 {
-	struct ip_vs_dest_dst *dest_dst = container_of(head,
-						       struct ip_vs_dest_dst,
-						       rcu_head);
-
 	dst_release(dest_dst->dst_cache);
-	kfree(dest_dst);
+	kfree_rcu(dest_dst, rcu_head);
 }
 
 /* Release dest_dst and dst_cache for dest in user context */
@@ -1090,7 +1086,7 @@ static void __ip_vs_dst_cache_reset(struct ip_vs_dest *dest)
 	old = rcu_dereference_protected(dest->dest_dst, 1);
 	if (old) {
 		RCU_INIT_POINTER(dest->dest_dst, NULL);
-		call_rcu(&old->rcu_head, ip_vs_dest_dst_rcu_free);
+		ip_vs_dest_dst_rcu_free(old);
 	}
 }
 
@@ -2246,13 +2242,13 @@ void ip_vs_service_nets_cleanup(struct list_head *net_list)
 
 /* Put all references for device (dst_cache) */
 static inline void
-ip_vs_forget_dev(struct ip_vs_dest *dest, struct net_device *dev)
+ip_vs_forget_dev(struct ip_vs_dest *dest, const struct net_device *dev)
 {
 	struct ip_vs_dest_dst *dest_dst;
 
 	spin_lock_bh(&dest->dst_lock);
 	dest_dst = rcu_dereference_protected(dest->dest_dst, 1);
-	if (dest_dst && dest_dst->dst_cache->dev == dev) {
+	if (dest_dst && dest_dst->dst_ifindex == dev->ifindex) {
 		IP_VS_DBG_BUF(3, "Reset dev:%s dest %s:%u ,dest->refcnt=%d\n",
 			      dev->name,
 			      IP_VS_DBG_ADDR(dest->af, &dest->addr),
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index c777493eee74..cdbab1e81635 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -70,7 +70,7 @@ static inline void ip_vs_dest_dst_free(struct ip_vs_dest_dst *dest_dst)
  */
 static inline void
 __ip_vs_dst_set(struct ip_vs_dest *dest, struct ip_vs_dest_dst *dest_dst,
-		struct dst_entry *dst, u32 dst_cookie)
+		struct dst_entry *dst, int oif, u32 dst_cookie)
 {
 	struct ip_vs_dest_dst *old;
 
@@ -79,12 +79,13 @@ __ip_vs_dst_set(struct ip_vs_dest *dest, struct ip_vs_dest_dst *dest_dst,
 
 	if (dest_dst) {
 		dest_dst->dst_cache = dst;
+		dest_dst->dst_ifindex = oif;
 		dest_dst->dst_cookie = dst_cookie;
 	}
 	rcu_assign_pointer(dest->dest_dst, dest_dst);
 
 	if (old)
-		call_rcu(&old->rcu_head, ip_vs_dest_dst_rcu_free);
+		ip_vs_dest_dst_rcu_free(old);
 }
 
 static inline struct ip_vs_dest_dst *
@@ -331,9 +332,11 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 {
 	struct net *net = ipvs->net;
 	struct ip_vs_dest_dst *dest_dst;
+	struct net_device *rt_dev;
 	struct rtable *rt;			/* Route to the other host */
 	int mtu;
 	int local, noref = 1;
+	int oif;
 
 	if (dest) {
 		dest_dst = __ip_vs_dst_check(dest);
@@ -345,25 +348,35 @@ __ip_vs_get_out_rt(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 			dest_dst = ip_vs_dest_dst_alloc();
 			spin_lock_bh(&dest->dst_lock);
 			if (!dest_dst) {
-				__ip_vs_dst_set(dest, NULL, NULL, 0);
+				__ip_vs_dst_set(dest, NULL, NULL, 0, 0);
 				spin_unlock_bh(&dest->dst_lock);
 				goto err_unreach;
 			}
 			rt = do_output_route4(net, dest->addr.ip, rt_mode,
 					      &dest_dst->dst_saddr.ip);
 			if (!rt) {
-				__ip_vs_dst_set(dest, NULL, NULL, 0);
+				__ip_vs_dst_set(dest, NULL, NULL, 0, 0);
 				spin_unlock_bh(&dest->dst_lock);
 				ip_vs_dest_dst_free(dest_dst);
 				goto err_unreach;
 			}
+			rt_dev = dst_dev_rcu(&rt->dst);
+			if (rt_dev) {
+				if (rt_dev != blackhole_netdev)
+					oif = rt_dev->ifindex;
+				else
+					oif = 0;
+			} else {
+				oif = -1;
+			}
 			/* It is forbidden to attach dest->dest_dst if
 			 * device is going down or if server is removed and
 			 * stored in dest_trash.
 			 */
-			if (!rt_dev_is_down(dst_dev_rcu(&rt->dst)) &&
+			if (!rt_dev_is_down(dst_dev_rcu(&rt->dst)) && oif &&
 			    dest->cflags & IP_VS_DEST_CF_AVAILABLE)
-				__ip_vs_dst_set(dest, dest_dst, &rt->dst, 0);
+				__ip_vs_dst_set(dest, dest_dst, &rt->dst, oif,
+						0);
 			else
 				noref = 0;
 			spin_unlock_bh(&dest->dst_lock);
@@ -505,10 +518,12 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 {
 	struct net *net = ipvs->net;
 	struct ip_vs_dest_dst *dest_dst;
+	struct net_device *rt_dev;
 	struct rt6_info *rt;			/* Route to the other host */
 	struct dst_entry *dst;
 	int mtu;
 	int local, noref = 1;
+	int oif;
 
 	if (dest) {
 		dest_dst = __ip_vs_dst_check(dest);
@@ -522,7 +537,7 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 			dest_dst = ip_vs_dest_dst_alloc();
 			spin_lock_bh(&dest->dst_lock);
 			if (!dest_dst) {
-				__ip_vs_dst_set(dest, NULL, NULL, 0);
+				__ip_vs_dst_set(dest, NULL, NULL, 0, 0);
 				spin_unlock_bh(&dest->dst_lock);
 				goto err_unreach;
 			}
@@ -530,20 +545,30 @@ __ip_vs_get_out_rt_v6(struct netns_ipvs *ipvs, int skb_af, struct sk_buff *skb,
 						      &dest_dst->dst_saddr.in6,
 						      do_xfrm, rt_mode);
 			if (!dst) {
-				__ip_vs_dst_set(dest, NULL, NULL, 0);
+				__ip_vs_dst_set(dest, NULL, NULL, 0, 0);
 				spin_unlock_bh(&dest->dst_lock);
 				ip_vs_dest_dst_free(dest_dst);
 				goto err_unreach;
 			}
 			rt = dst_rt6_info(dst);
 			cookie = rt6_get_cookie(rt);
+			rt_dev = dst_dev_rcu(dst);
+			if (rt_dev) {
+				if (rt_dev != blackhole_netdev)
+					oif = rt_dev->ifindex;
+				else
+					oif = 0;
+			} else {
+				oif = -1;
+			}
 			/* It is forbidden to attach dest->dest_dst if
 			 * device is going down or if server is removed and
 			 * stored in dest_trash.
 			 */
-			if (!rt_dev_is_down(dst_dev_rcu(&rt->dst)) &&
+			if (!rt_dev_is_down(dst_dev_rcu(&rt->dst)) && oif &&
 			    dest->cflags & IP_VS_DEST_CF_AVAILABLE)
-				__ip_vs_dst_set(dest, dest_dst, &rt->dst, cookie);
+				__ip_vs_dst_set(dest, dest_dst, &rt->dst, oif,
+						cookie);
 			else
 				noref = 0;
 			spin_unlock_bh(&dest->dst_lock);
-- 
2.56.1


