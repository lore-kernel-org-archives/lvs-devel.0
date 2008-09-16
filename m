From: Simon Horman <horms@verge.net.au>
Subject: [patch 3/3] ipvs: add __aquire/__release annotations to ip_vs_info_seq_start/ip_vs_info_seq_stop
Date: Tue, 16 Sep 2008 17:13:21 +1000
Message-ID: <20080916071610.739703917@vergenet.net>
References: <20080916071318.939200044@vergenet.net>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline; filename=ip_vs_info_seq_start-__acquires-annotation.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Cc: Julius Volz <juliusv@google.com>, Vince Busam <vbusam@google.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Sven Wegener <sven.wegener@stealer.net>

This teaches sparse that the following are not problems:

make C=1
  CHECK   net/ipv4/ipvs/ip_vs_ctl.c
net/ipv4/ipvs/ip_vs_ctl.c:1793:14: warning: context imbalance in 'ip_vs_info_seq_start' - wrong count at exit
net/ipv4/ipvs/ip_vs_ctl.c:1842:13: warning: context imbalance in 'ip_vs_info_seq_stop' - unexpected unlock

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: lvs-2.6/net/ipv4/ipvs/ip_vs_ctl.c
===================================================================
--- lvs-2.6.orig/net/ipv4/ipvs/ip_vs_ctl.c	2008-09-16 15:32:45.000000000 +1000
+++ lvs-2.6/net/ipv4/ipvs/ip_vs_ctl.c	2008-09-16 15:36:48.000000000 +1000
@@ -1787,6 +1787,7 @@ static struct ip_vs_service *ip_vs_info_
 }
 
 static void *ip_vs_info_seq_start(struct seq_file *seq, loff_t *pos)
+__acquires(__ip_vs_svc_lock)
 {
 
 	read_lock_bh(&__ip_vs_svc_lock);
@@ -1840,6 +1841,7 @@ static void *ip_vs_info_seq_next(struct 
 }
 
 static void ip_vs_info_seq_stop(struct seq_file *seq, void *v)
+__releases(__ip_vs_svc_lock)
 {
 	read_unlock_bh(&__ip_vs_svc_lock);
 }

-- 

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

