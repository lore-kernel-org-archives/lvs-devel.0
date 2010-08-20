From: Simon Horman <horms@verge.net.au>
Subject: [patch nf-next] IPVS: convert __ip_vs_securetcp_lock to a spinlock
Date: Fri, 20 Aug 2010 23:52:08 +0900
Message-ID: <20100820145206.GA11781@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Stephen Hemminger <shemminger@vyatta.com>, Eric Dumazet <eric.dumazet@gmail.com>, Changli Gao <xiaosuo@gmail.com>, yao zhao <dragonlinux@gmail.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

Also rename __ip_vs_securetcp_lock to ip_vs_securetcp_lock.

Spinlock conversion was suggested by Eric Dumazet.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

--- 

Compile tested only

Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_ctl.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_ctl.c	2010-08-20 22:41:52.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_ctl.c	2010-08-20 23:29:49.000000000 +0900
@@ -61,7 +61,7 @@ static DEFINE_RWLOCK(__ip_vs_svc_lock);
 static DEFINE_RWLOCK(__ip_vs_rs_lock);
 
 /* lock for state and timeout tables */
-static DEFINE_RWLOCK(__ip_vs_securetcp_lock);
+static DEFINE_SPINLOCK(ip_vs_securetcp_lock);
 
 /* lock for drop entry handling */
 static DEFINE_SPINLOCK(__ip_vs_dropentry_lock);
@@ -204,7 +204,7 @@ static void update_defense_level(void)
 	spin_unlock(&__ip_vs_droppacket_lock);
 
 	/* secure_tcp */
-	write_lock(&__ip_vs_securetcp_lock);
+	spin_lock(&ip_vs_securetcp_lock);
 	switch (sysctl_ip_vs_secure_tcp) {
 	case 0:
 		if (old_secure_tcp >= 2)
@@ -238,7 +238,7 @@ static void update_defense_level(void)
 	old_secure_tcp = sysctl_ip_vs_secure_tcp;
 	if (to_change >= 0)
 		ip_vs_protocol_timeout_change(sysctl_ip_vs_secure_tcp>1);
-	write_unlock(&__ip_vs_securetcp_lock);
+	spin_unlock(&ip_vs_securetcp_lock);
 
 	local_bh_enable();
 }
