From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 4.14 33/69] ipvs: call ip_vs_dst_notifier earlier than ipv6_dev_notf
Date: Wed,  5 Dec 2018 04:42:11 -0500
Message-ID: <20181205094247.6556-33-sashal@kernel.org>
References: <20181205094247.6556-1-sashal@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1544003110;
        bh=+71XqT/kHNtNtv25Xq4+IPsd8KD1z3DXcGFneNtV45s=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=xTSMl0KW+rLr9Dob30WOhf1KcVMkSkIxMYUIb3L2VKfDzVw95Y6eXDdrxH22uGV7J
         fzd6IF9wH9ePW3Ecq79GAbJyE6UlgiVJQJ4xaDoi4HoXtP56FLCNZr7jIsJjAxiq8h
         +Vg3Tr59psACT71aoT+7yeQK7beaPC8hkAtL34Qk=
In-Reply-To: <20181205094247.6556-1-sashal@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: stable@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Xin Long <lucien.xin@gmail.com>, Pablo Neira Ayuso <pablo@netfilter.org>, Sasha Levin <sashal@kernel.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

From: Xin Long <lucien.xin@gmail.com>

[ Upstream commit 2a31e4bd9ad255ee40809b5c798c4b1c2b09703b ]

ip_vs_dst_event is supposed to clean up all dst used in ipvs'
destinations when a net dev is going down. But it works only
when the dst's dev is the same as the dev from the event.

Now with the same priority but late registration,
ip_vs_dst_notifier is always called later than ipv6_dev_notf
where the dst's dev is set to lo for NETDEV_DOWN event.

As the dst's dev lo is not the same as the dev from the event
in ip_vs_dst_event, ip_vs_dst_notifier doesn't actually work.
Also as these dst have to wait for dest_trash_timer to clean
them up. It would cause some non-permanent kernel warnings:

  unregister_netdevice: waiting for br0 to become free. Usage count = 3

To fix it, call ip_vs_dst_notifier earlier than ipv6_dev_notf
by increasing its priority to ADDRCONF_NOTIFY_PRIORITY + 5.

Note that for ipv4 route fib_netdev_notifier doesn't set dst's
dev to lo in NETDEV_DOWN event, so this fix is only needed when
IP_VS_IPV6 is defined.

Fixes: 7a4f0761fce3 ("IPVS: init and cleanup restructuring")
Reported-by: Li Shuang <shuali@redhat.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Acked-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 327ebe786eeb..2f45c3ce77ef 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -4012,6 +4012,9 @@ static void __net_exit ip_vs_control_net_cleanup_sysctl(struct netns_ipvs *ipvs)
 
 static struct notifier_block ip_vs_dst_notifier = {
 	.notifier_call = ip_vs_dst_event,
+#ifdef CONFIG_IP_VS_IPV6
+	.priority = ADDRCONF_NOTIFY_PRIORITY + 5,
+#endif
 };
 
 int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
-- 
2.17.1

