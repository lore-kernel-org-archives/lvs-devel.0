From: Peter Christensen <pch@ordbogen.com>
Subject: [PATCH] ipvs: Fix panic due to non-linear skb
Date: Fri, 23 May 2014 10:54:16 +0200
Message-ID: <1400835256-5249-1-git-send-email-pch@ordbogen.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ordbogen.com;
	s=20130821; t=1400835261;
	bh=ehWvC80PMPYYdc+mlumQxkZg6BCdK0lV8v9WmqGI8AY=;
	h=From:To:Cc:Subject:Date:From;
	b=UshUasPzcFYv9yLwiHiQdKwyzm/epYn2UwmzF3++gvHvdrEVXUaPFRA+MAlDibYrp
	 KOvMyGWCZAMGyFpe2tnfs1e66zePnNjUYxTJvyze+IXoHmfGShxRbFmk9ehQ+co7sG
	 285qZjkoJcE/XRo57m0BsVs9eI4C1p2ZGg6fTtDQ=
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Peter Christensen <pch@ordbogen.com>

ICMP responses to IPIP packets are deencapsulated using __skb_pull, but if the
skb is non-linear, this may cause a panic. Instead, we use pskb_pull and
store relevant ICMP info in variables in case pskb_pull decides to reallocate.

kernel BUG at include/linux/skbuff.h:1430!
invalid opcode: 0000 [#1] SMP
Modules linked in:
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.10.40-director-15 #1
Hardware name: Dell Inc. PowerEdge C5220/0NVH5D, BIOS 2.0.3 06/22/2012
task: ffffffff816ea440 ti: ffffffff816da000 task.ti: ffffffff816da000
RIP: 0010:[<ffffffff81498a60>]  [<ffffffff81498a60>] ip_vs_in_icmp+0x610/0x620
RSP: 0018:ffff8807ffc03af0  EFLAGS: 00010287
RAX: 00000000000000ea RBX: ffff8807d5a3c300 RCX: 0000000000000000
RDX: 000000005ca90000 RSI: 0000000000000000 RDI: ffff8807d9778128
RBP: 0000000000000014 R08: 0000000000000000 R09: 0000000000000000
R10: ffff8807d5a3c300 R11: ffff8807dbb3f180 R12: ffff8807ffc03b40
R13: 0000000000000001 R14: 000000000000001c R15: ffff8807ffc03b38
FS:  0000000000000000(0000) GS:ffff8807ffc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffffffffff600400 CR3: 00000000016e5000 CR4: 00000000001407f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Stack:
ffff88070000011a ffffffff816dbfd8 ffff8807dbda2000 ffff8807dbb3f180
0000000000000014 00000044ffc03bd8 0100000000000030 ffffffff81740080
ffff8807d5a3c300 00000000a0050303 00401710ea000045 33f8905b30e8067a
Call Trace:
<IRQ>
[<ffffffff81498d9b>] ? ip_vs_in.constprop.28+0x2bb/0x450
[<ffffffff814992e2>] ? ip_vs_out.constprop.29+0x272/0x4c0
[<ffffffff814a9df0>] ? ip_rcv_finish+0x2e0/0x2e0
[<ffffffff814a9df0>] ? ip_rcv_finish+0x2e0/0x2e0
[<ffffffff8149255d>] ? nf_iterate+0x8d/0xc0
[<ffffffff814a9df0>] ? ip_rcv_finish+0x2e0/0x2e0
[<ffffffff814925fe>] ? nf_hook_slow+0x6e/0x130
[<ffffffff814a9df0>] ? ip_rcv_finish+0x2e0/0x2e0
[<ffffffff814aa042>] ? ip_local_deliver+0x52/0x90
[<ffffffff8146e322>] ? __netif_receive_skb_core+0x4b2/0x630
[<ffffffff81374e40>] ? macvlan_broadcast+0x150/0x150
[<ffffffff814713a4>] ? netif_receive_skb+0x24/0x80
[<ffffffff814720c8>] ? napi_gro_receive+0x98/0xd0
[<ffffffff813b81e0>] ? igb_poll+0x6c0/0xf40
[<ffffffff8146e322>] ? __netif_receive_skb_core+0x4b2/0x630
[<ffffffff81056ce5>] ? hrtimer_get_next_event+0xd5/0xe0
[<ffffffff81471671>] ? net_rx_action+0xf1/0x190
[<ffffffff81041b3e>] ? get_next_timer_interrupt+0x1be/0x250
[<ffffffff81068092>] ? do_timer+0x352/0x670
[<ffffffff8103b7c6>] ? __do_softirq+0xd6/0x1a0
[<ffffffff8107e23e>] ? handle_irq_event_percpu+0x7e/0x140
[<ffffffff815113fc>] ? call_softirq+0x1c/0x30
[<ffffffff81003c8d>] ? do_softirq+0x4d/0x80
[<ffffffff8103b9ae>] ? irq_exit+0x7e/0xa0
[<ffffffff81003afb>] ? do_IRQ+0x5b/0xd0
[<ffffffff8150fb2a>] ? common_interrupt+0x6a/0x6a
<EOI>
[<ffffffff81056a38>] ? __hrtimer_start_range_ns+0x1a8/0x360
[<ffffffff8143deb6>] ? cpuidle_enter_state+0x56/0xe0
[<ffffffff8143deb2>] ? cpuidle_enter_state+0x52/0xe0
[<ffffffff8143dfde>] ? cpuidle_idle_call+0x9e/0x140
[<ffffffff8100a6f9>] ? arch_cpu_idle+0x9/0x30
[<ffffffff810666f6>] ? cpu_startup_entry+0x86/0x160
[<ffffffff81761cf6>] ? start_kernel+0x2d9/0x2e4
[<ffffffff81761834>] ? repair_env_string+0x5b/0x5b
Code: 48 ec 83 f8 59 0f 42 c8 8b 44 24 30 0f c9 29 e8 83 e8 08 89 44 24 30 e9 27 fc ff ff 83 78 14 00 0f 84 8d fb ff ff e9 10 fd ff ff <0f> 0b 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 48 89 f1 8b b6
RIP  [<ffffffff81498a60>] ip_vs_in_icmp+0x610/0x620
RSP <ffff8807ffc03af0>
---[ end trace fb17b5b5910de306 ]---
Kernel panic - not syncing: Fatal exception in interrupt

Signed-off-by: Peter Christensen <pch@ordbogen.com>
---
 net/netfilter/ipvs/ip_vs_core.c |   22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 4f26ee4..8e20e12 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1300,6 +1300,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 	struct ip_vs_proto_data *pd;
 	unsigned int offset, offset2, ihl, verdict;
 	bool ipip;
+	__u8 protocol;
 
 	*related = 1;
 
@@ -1390,17 +1391,23 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 		goto out;
 	}
 
+	protocol = cih->protocol;
+
 	if (ipip) {
 		__be32 info = ic->un.gateway;
+		int type = ic->type;
+		int code = ic->code;
 
 		/* Update the MTU */
 		if (ic->type == ICMP_DEST_UNREACH &&
 		    ic->code == ICMP_FRAG_NEEDED) {
 			struct ip_vs_dest *dest = cp->dest;
 			u32 mtu = ntohs(ic->un.frag.mtu);
+			__be16 frag_off = cih->frag_off;
 
 			/* Strip outer IP and ICMP, go to IPIP header */
-			__skb_pull(skb, ihl + sizeof(_icmph));
+			if (pskb_pull(skb, ihl + sizeof(_icmph)) == NULL)
+				goto ignore_ipip;
 			offset2 -= ihl + sizeof(_icmph);
 			skb_reset_network_header(skb);
 			IP_VS_DBG(12, "ICMP for IPIP %pI4->%pI4: mtu=%u\n",
@@ -1408,7 +1415,7 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 			ipv4_update_pmtu(skb, dev_net(skb->dev),
 					 mtu, 0, 0, 0, 0);
 			/* Client uses PMTUD? */
-			if (!(cih->frag_off & htons(IP_DF)))
+			if (!(frag_off & htons(IP_DF)))
 				goto ignore_ipip;
 			/* Prefer the resulting PMTU */
 			if (dest) {
@@ -1427,12 +1434,13 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 		/* Strip outer IP, ICMP and IPIP, go to IP header of
 		 * original request.
 		 */
-		__skb_pull(skb, offset2);
+		if (pskb_pull(skb, offset2) == NULL)
+			goto ignore_ipip;
 		skb_reset_network_header(skb);
 		IP_VS_DBG(12, "Sending ICMP for %pI4->%pI4: t=%u, c=%u, i=%u\n",
 			&ip_hdr(skb)->saddr, &ip_hdr(skb)->daddr,
-			ic->type, ic->code, ntohl(info));
-		icmp_send(skb, ic->type, ic->code, info);
+			type, code, ntohl(info));
+		icmp_send(skb, type, code, info);
 		/* ICMP can be shorter but anyways, account it */
 		ip_vs_out_stats(cp, skb);
 
@@ -1444,8 +1452,8 @@ ignore_ipip:
 
 	/* do the statistics and put it back */
 	ip_vs_in_stats(cp, skb);
-	if (IPPROTO_TCP == cih->protocol || IPPROTO_UDP == cih->protocol ||
-	    IPPROTO_SCTP == cih->protocol)
+	if (IPPROTO_TCP == protocol || IPPROTO_UDP == protocol ||
+	    IPPROTO_SCTP == protocol)
 		offset += 2 * sizeof(__u16);
 	verdict = ip_vs_icmp_xmit(skb, cp, pp, offset, hooknum, &ciph);
 
-- 
1.7.10.4
