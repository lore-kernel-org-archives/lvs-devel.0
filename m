From: Tommi Rantala <tt.rantala@gmail.com>
Subject: [PATCH] ipvs: fix memory leak in ip_vs_ctl.c
Date: Thu,  7 May 2015 15:12:21 +0300
Message-ID: <1431000741-7599-1-git-send-email-tt.rantala@gmail.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=from:to:cc:subject:date:message-id;
        bh=yg22LFY8D0GkZdQTDnrZIFPA5/6XGEcRuq/Bu5zYmLk=;
        b=hT0gqtr8kMNyZSGAqkd4U8GZeu6kC+ESZeBqlGzTVJwQ/e9WenDpanX/SCq2IU4NGX
         FKeL+RDeoY8CrpUADifLRZJ6NHcpzGNv9od9pESGyKPG2cNOMckJ62jV1YZobcYFJuPG
         x770UgtUqyu1/uaf+l+HK2IRd1f0XZZoqyWlTq/A9a7KeFPcZ1MAH0nkHZ2Heu6blEbH
         rGtfkq9jXP0kVdv5OO42lxX6nXuHXKnCl2fwv/lmu5yHRWJxi3v4Q1IdWgqQ+lm7SOFy
         bUZddCDuQzWKccM8EJ8ja+NbP3Br0KacmVudke1d7f0A5D2DZvklvyXjqhjhRMehbMc0
         xw0g==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Tommi Rantala <tt.rantala@gmail.com>

Fix memory leak introduced in commit a0840e2e165a ("IPVS: netns,
ip_vs_ctl local vars moved to ipvs struct."):

unreferenced object 0xffff88005785b800 (size 2048):
  comm "(-localed)", pid 1434, jiffies 4294755650 (age 1421.089s)
  hex dump (first 32 bytes):
    bb 89 0b 83 ff ff ff ff b0 78 f0 4e 00 88 ff ff  .........x.N....
    04 00 00 00 a4 01 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff8262ea8e>] kmemleak_alloc+0x4e/0xb0
    [<ffffffff811fba74>] __kmalloc_track_caller+0x244/0x430
    [<ffffffff811b88a0>] kmemdup+0x20/0x50
    [<ffffffff823276b7>] ip_vs_control_net_init+0x1f7/0x510
    [<ffffffff8231d630>] __ip_vs_init+0x100/0x250
    [<ffffffff822363a1>] ops_init+0x41/0x190
    [<ffffffff82236583>] setup_net+0x93/0x150
    [<ffffffff82236cc2>] copy_net_ns+0x82/0x140
    [<ffffffff810ab13d>] create_new_namespaces+0xfd/0x190
    [<ffffffff810ab49a>] unshare_nsproxy_namespaces+0x5a/0xc0
    [<ffffffff810833e3>] SyS_unshare+0x173/0x310
    [<ffffffff8265cbd7>] system_call_fastpath+0x12/0x6f
    [<ffffffffffffffff>] 0xffffffffffffffff

Signed-off-by: Tommi Rantala <tt.rantala@gmail.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 4953267..285eae3 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3823,6 +3823,9 @@ static void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net)
 	cancel_work_sync(&ipvs->defense_work.work);
 	unregister_net_sysctl_table(ipvs->sysctl_hdr);
 	ip_vs_stop_estimator(net, &ipvs->tot_stats);
+
+	if (!net_eq(net, &init_net))
+		kfree(ipvs->sysctl_tbl);
 }
 
 #else
-- 
1.9.3

