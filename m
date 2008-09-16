From: Simon Horman <horms@verge.net.au>
Subject: [patch 1/3] ipvs: only unlock in ip_vs_edit_service() if already locked
Date: Tue, 16 Sep 2008 17:13:19 +1000
Message-ID: <20080916071610.390873215@vergenet.net>
References: <20080916071318.939200044@vergenet.net>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline; filename=ip_vs_edit_service-out_unlock.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Julius Volz <juliusv@google.com>, Vince Busam <vbusam@google.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Sven Wegener <sven.wegener@stealer.net>

Jumping to out unlocks __ip_vs_svc_lock, but that lock is not taken until
after code that may jump to out.

This problem was detected by sparse.

make C=1
  CHECK   net/ipv4/ipvs/ip_vs_ctl.c
net/ipv4/ipvs/ip_vs_ctl.c:1332:2: warning: context imbalance in 'ip_vs_edit_service' - unexpected unlock

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: lvs-2.6/net/ipv4/ipvs/ip_vs_ctl.c
===================================================================
--- lvs-2.6.orig/net/ipv4/ipvs/ip_vs_ctl.c	2008-09-16 15:16:01.000000000 +1000
+++ lvs-2.6/net/ipv4/ipvs/ip_vs_ctl.c	2008-09-16 15:16:06.000000000 +1000
@@ -1305,7 +1305,7 @@ ip_vs_edit_service(struct ip_vs_service 
 		 */
 		if ((ret = ip_vs_unbind_scheduler(svc))) {
 			old_sched = sched;
-			goto out;
+			goto out_unlock;
 		}
 
 		/*
@@ -1324,12 +1324,13 @@ ip_vs_edit_service(struct ip_vs_service 
 			 */
 			ip_vs_bind_scheduler(svc, old_sched);
 			old_sched = sched;
-			goto out;
+			goto out_unlock;
 		}
 	}
 
-  out:
+  out_unlock:
 	write_unlock_bh(&__ip_vs_svc_lock);
+  out:
 
 	if (old_sched)
 		ip_vs_scheduler_put(old_sched);

-- 

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

