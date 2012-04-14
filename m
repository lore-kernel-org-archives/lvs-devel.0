From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH v3 1/2] netfilter: ipvs: Verify that IP_VS protocol has been registered
Date: Sat, 14 Apr 2012 12:37:46 -0400
Message-ID: <1334421467-30313-1-git-send-email-levinsasha928@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=from:to:cc:subject:date:message-id:x-mailer;
        bh=ypQrn859mM3vLOQoB2cwCoIpyQxY5sBYvn4+QCGHXF8=;
        b=Ami+nbDf0qvpPt/izFlVhTAqu3Noe1lVGTL+8D7ekFyQuJGbN4GqZxU2YB+X3Khd2K
         HFrvTvxAkm3yOrKoOGXd1MUISPsJI5bGU6qRtzUEnZwaCao97n+o0xkJERExTh/X4Udq
         5wrSppk7CbaKSDNHlqakjn1QWhq7gNt68KqEjZNKWwkg0Vbkrr8MjQ3Pf5lnhOWvGW9y
         dmwiLs3pimWZeN8xTtpvgsThfnSS5GTKX3QdrgIfeW9BQjkJqQx1wBnzcKw9B6PJ7AUy
         /MNytrnlD3H1tOuipX/iyRiIRN4Bcg8UiFBIObHm8TjpbIy8i1A4XILffeLbweFrLYq4
         xfWQ==
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, kaber@trash.net, davem@davemloft.net
Cc: davej@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

The registration of a protocol might fail, there were no checks
and all registrations were assumed to be correct. This lead to
NULL ptr dereferences when apps tried registering.

For example:

[ 1293.226051] BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
[ 1293.227038] IP: [<ffffffff822aacb0>] tcp_register_app+0x60/0xb0
[ 1293.227038] PGD 391de067 PUD 6c20b067 PMD 0
[ 1293.227038] Oops: 0000 [#1] PREEMPT SMP
[ 1293.227038] CPU 1
[ 1293.227038] Pid: 19609, comm: trinity Tainted: G        W    3.4.0-rc1-next-20120405-sasha-dirty #57
[ 1293.227038] RIP: 0010:[<ffffffff822aacb0>]  [<ffffffff822aacb0>] tcp_register_app+0x60/0xb0
[ 1293.227038] RSP: 0018:ffff880038c1dd18  EFLAGS: 00010286
[ 1293.227038] RAX: ffffffffffffffc0 RBX: 0000000000001500 RCX: 0000000000010000
[ 1293.227038] RDX: 0000000000000000 RSI: ffff88003a2d5888 RDI: 0000000000000282
[ 1293.227038] RBP: ffff880038c1dd48 R08: 0000000000000000 R09: 0000000000000000
[ 1293.227038] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88003a2d5668
[ 1293.227038] R13: ffff88003a2d5988 R14: ffff8800696a8ff8 R15: 0000000000000000
[ 1293.227038] FS:  00007f01930d9700(0000) GS:ffff88007ce00000(0000) knlGS:0000000000000000
[ 1293.227038] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1293.227038] CR2: 0000000000000018 CR3: 0000000065dfc000 CR4: 00000000000406e0
[ 1293.227038] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1293.227038] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1293.227038] Process trinity (pid: 19609, threadinfo ffff880038c1c000, task ffff88002dc73000)
[ 1293.227038] Stack:
[ 1293.227038]  ffff880038c1dd48 00000000fffffff4 ffff8800696aada0 ffff8800694f5580
[ 1293.227038]  ffffffff8369f1e0 0000000000001500 ffff880038c1dd98 ffffffff822a716b
[ 1293.227038]  0000000000000000 ffff8800696a8ff8 0000000000000015 ffff8800694f5580
[ 1293.227038] Call Trace:
[ 1293.227038]  [<ffffffff822a716b>] ip_vs_app_inc_new+0xdb/0x180
[ 1293.227038]  [<ffffffff822a7258>] register_ip_vs_app_inc+0x48/0x70
[ 1293.227038]  [<ffffffff822b2fea>] __ip_vs_ftp_init+0xba/0x140
[ 1293.227038]  [<ffffffff821c9060>] ops_init+0x80/0x90
[ 1293.227038]  [<ffffffff821c90cb>] setup_net+0x5b/0xe0
[ 1293.227038]  [<ffffffff821c9416>] copy_net_ns+0x76/0x100
[ 1293.227038]  [<ffffffff810dc92b>] create_new_namespaces+0xfb/0x190
[ 1293.227038]  [<ffffffff810dca21>] unshare_nsproxy_namespaces+0x61/0x80
[ 1293.227038]  [<ffffffff810afd1f>] sys_unshare+0xff/0x290
[ 1293.227038]  [<ffffffff8187622e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 1293.227038]  [<ffffffff82665539>] system_call_fastpath+0x16/0x1b
[ 1293.227038] Code: 89 c7 e8 34 91 3b 00 89 de 66 c1 ee 04 31 de 83 e6 0f 48 83 c6 22 48 c1 e6 04 4a 8b 14 26 49 8d 34 34 48 8d 42 c0 48 39 d6 74 13 <66> 39 58 58 74 22 48 8b 48 40 48 8d 41 c0 48 39 ce 75 ed 49 8d
[ 1293.227038] RIP  [<ffffffff822aacb0>] tcp_register_app+0x60/0xb0
[ 1293.227038]  RSP <ffff880038c1dd18>
[ 1293.227038] CR2: 0000000000000018
[ 1293.379284] ---[ end trace 364ab40c7011a009 ]---
[ 1293.381182] Kernel panic - not syncing: Fatal exception in interrupt

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 net/netfilter/ipvs/ip_vs_proto.c |   27 ++++++++++++++++++---------
 1 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index f843a88..a62360e 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -59,9 +59,6 @@ static int __used __init register_ip_vs_protocol(struct ip_vs_protocol *pp)
 	return 0;
 }
 
-#if defined(CONFIG_IP_VS_PROTO_TCP) || defined(CONFIG_IP_VS_PROTO_UDP) || \
-    defined(CONFIG_IP_VS_PROTO_SCTP) || defined(CONFIG_IP_VS_PROTO_AH) || \
-    defined(CONFIG_IP_VS_PROTO_ESP)
 /*
  *	register an ipvs protocols netns related data
  */
@@ -86,7 +83,6 @@ register_ip_vs_proto_netns(struct net *net, struct ip_vs_protocol *pp)
 
 	return 0;
 }
-#endif
 
 /*
  *	unregister an ipvs protocol
@@ -316,22 +312,35 @@ ip_vs_tcpudp_debug_packet(int af, struct ip_vs_protocol *pp,
  */
 int __net_init ip_vs_protocol_net_init(struct net *net)
 {
+	int i, ret;
+	static struct ip_vs_protocol *protos[] = {
 #ifdef CONFIG_IP_VS_PROTO_TCP
-	register_ip_vs_proto_netns(net, &ip_vs_protocol_tcp);
+        &ip_vs_protocol_tcp,
 #endif
 #ifdef CONFIG_IP_VS_PROTO_UDP
-	register_ip_vs_proto_netns(net, &ip_vs_protocol_udp);
+	&ip_vs_protocol_udp,
 #endif
 #ifdef CONFIG_IP_VS_PROTO_SCTP
-	register_ip_vs_proto_netns(net, &ip_vs_protocol_sctp);
+	&ip_vs_protocol_sctp,
 #endif
 #ifdef CONFIG_IP_VS_PROTO_AH
-	register_ip_vs_proto_netns(net, &ip_vs_protocol_ah);
+	&ip_vs_protocol_ah,
 #endif
 #ifdef CONFIG_IP_VS_PROTO_ESP
-	register_ip_vs_proto_netns(net, &ip_vs_protocol_esp);
+	&ip_vs_protocol_esp,
 #endif
+	};
+
+	for (i = 0; i < ARRAY_SIZE(protos); i++) {
+		ret = register_ip_vs_proto_netns(net, protos[i]);
+		if (ret < 0)
+			goto cleanup;
+	}
 	return 0;
+
+cleanup:
+	ip_vs_protocol_net_cleanup(net);
+	return ret;
 }
 
 void __net_exit ip_vs_protocol_net_cleanup(struct net *net)
-- 
1.7.8.5

