From: sven.wegener@stealer.net
Subject: [PATCH 5/9] ipvs: Initialize schedulers' struct list_head at compile time
Date: Sun, 10 Aug 2008 11:07:35 +0000
Message-ID: <1218366459-23971-6-git-send-email-sven.wegener@stealer.net>
References: <1218366459-23971-1-git-send-email-sven.wegener@stealer.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1218366459-23971-1-git-send-email-sven.wegener@stealer.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

From: Sven Wegener <sven.wegener@stealer.net>

No need to do it at runtime and this saves a couple of bytes in the text
section.

Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
---
 net/ipv4/ipvs/ip_vs_dh.c    |    2 +-
 net/ipv4/ipvs/ip_vs_lblc.c  |    2 +-
 net/ipv4/ipvs/ip_vs_lblcr.c |    2 +-
 net/ipv4/ipvs/ip_vs_lc.c    |    2 +-
 net/ipv4/ipvs/ip_vs_nq.c    |    2 +-
 net/ipv4/ipvs/ip_vs_rr.c    |    2 +-
 net/ipv4/ipvs/ip_vs_sed.c   |    2 +-
 net/ipv4/ipvs/ip_vs_sh.c    |    2 +-
 net/ipv4/ipvs/ip_vs_wlc.c   |    2 +-
 net/ipv4/ipvs/ip_vs_wrr.c   |    2 +-
 10 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_dh.c b/net/ipv4/ipvs/ip_vs_dh.c
index 8afc150..fa66824 100644
--- a/net/ipv4/ipvs/ip_vs_dh.c
+++ b/net/ipv4/ipvs/ip_vs_dh.c
@@ -233,6 +233,7 @@ static struct ip_vs_scheduler ip_vs_dh_scheduler =
 	.name =			"dh",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+	.n_list =		LIST_HEAD_INIT(ip_vs_dh_scheduler.n_list),
 	.init_service =		ip_vs_dh_init_svc,
 	.done_service =		ip_vs_dh_done_svc,
 	.update_service =	ip_vs_dh_update_svc,
@@ -242,7 +243,6 @@ static struct ip_vs_scheduler ip_vs_dh_scheduler =
 
 static int __init ip_vs_dh_init(void)
 {
-	INIT_LIST_HEAD(&ip_vs_dh_scheduler.n_list);
 	return register_ip_vs_scheduler(&ip_vs_dh_scheduler);
 }
 
diff --git a/net/ipv4/ipvs/ip_vs_lblc.c b/net/ipv4/ipvs/ip_vs_lblc.c
index 0efa3db..7a6a319 100644
--- a/net/ipv4/ipvs/ip_vs_lblc.c
+++ b/net/ipv4/ipvs/ip_vs_lblc.c
@@ -539,6 +539,7 @@ static struct ip_vs_scheduler ip_vs_lblc_scheduler =
 	.name =			"lblc",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+	.n_list =		LIST_HEAD_INIT(ip_vs_lblc_scheduler.n_list),
 	.init_service =		ip_vs_lblc_init_svc,
 	.done_service =		ip_vs_lblc_done_svc,
 	.update_service =	ip_vs_lblc_update_svc,
@@ -550,7 +551,6 @@ static int __init ip_vs_lblc_init(void)
 {
 	int ret;
 
-	INIT_LIST_HEAD(&ip_vs_lblc_scheduler.n_list);
 	sysctl_header = register_sysctl_paths(net_vs_ctl_path, vs_vars_table);
 	ret = register_ip_vs_scheduler(&ip_vs_lblc_scheduler);
 	if (ret)
diff --git a/net/ipv4/ipvs/ip_vs_lblcr.c b/net/ipv4/ipvs/ip_vs_lblcr.c
index 8e3bbeb..c234e73 100644
--- a/net/ipv4/ipvs/ip_vs_lblcr.c
+++ b/net/ipv4/ipvs/ip_vs_lblcr.c
@@ -728,6 +728,7 @@ static struct ip_vs_scheduler ip_vs_lblcr_scheduler =
 	.name =			"lblcr",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+	.n_list =		LIST_HEAD_INIT(ip_vs_lblcr_scheduler.n_list),
 	.init_service =		ip_vs_lblcr_init_svc,
 	.done_service =		ip_vs_lblcr_done_svc,
 	.update_service =	ip_vs_lblcr_update_svc,
@@ -739,7 +740,6 @@ static int __init ip_vs_lblcr_init(void)
 {
 	int ret;
 
-	INIT_LIST_HEAD(&ip_vs_lblcr_scheduler.n_list);
 	sysctl_header = register_sysctl_paths(net_vs_ctl_path, vs_vars_table);
 	ret = register_ip_vs_scheduler(&ip_vs_lblcr_scheduler);
 	if (ret)
diff --git a/net/ipv4/ipvs/ip_vs_lc.c b/net/ipv4/ipvs/ip_vs_lc.c
index ac9f08e..ebcdbf7 100644
--- a/net/ipv4/ipvs/ip_vs_lc.c
+++ b/net/ipv4/ipvs/ip_vs_lc.c
@@ -98,6 +98,7 @@ static struct ip_vs_scheduler ip_vs_lc_scheduler = {
 	.name =			"lc",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+	.n_list =		LIST_HEAD_INIT(ip_vs_lc_scheduler.n_list),
 	.init_service =		ip_vs_lc_init_svc,
 	.done_service =		ip_vs_lc_done_svc,
 	.update_service =	ip_vs_lc_update_svc,
@@ -107,7 +108,6 @@ static struct ip_vs_scheduler ip_vs_lc_scheduler = {
 
 static int __init ip_vs_lc_init(void)
 {
-	INIT_LIST_HEAD(&ip_vs_lc_scheduler.n_list);
 	return register_ip_vs_scheduler(&ip_vs_lc_scheduler) ;
 }
 
diff --git a/net/ipv4/ipvs/ip_vs_nq.c b/net/ipv4/ipvs/ip_vs_nq.c
index a46bf25..92f3a67 100644
--- a/net/ipv4/ipvs/ip_vs_nq.c
+++ b/net/ipv4/ipvs/ip_vs_nq.c
@@ -136,6 +136,7 @@ static struct ip_vs_scheduler ip_vs_nq_scheduler =
 	.name =			"nq",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+	.n_list =		LIST_HEAD_INIT(ip_vs_nq_scheduler.n_list),
 	.init_service =		ip_vs_nq_init_svc,
 	.done_service =		ip_vs_nq_done_svc,
 	.update_service =	ip_vs_nq_update_svc,
@@ -145,7 +146,6 @@ static struct ip_vs_scheduler ip_vs_nq_scheduler =
 
 static int __init ip_vs_nq_init(void)
 {
-	INIT_LIST_HEAD(&ip_vs_nq_scheduler.n_list);
 	return register_ip_vs_scheduler(&ip_vs_nq_scheduler);
 }
 
diff --git a/net/ipv4/ipvs/ip_vs_rr.c b/net/ipv4/ipvs/ip_vs_rr.c
index c8db12d..358110d 100644
--- a/net/ipv4/ipvs/ip_vs_rr.c
+++ b/net/ipv4/ipvs/ip_vs_rr.c
@@ -94,6 +94,7 @@ static struct ip_vs_scheduler ip_vs_rr_scheduler = {
 	.name =			"rr",			/* name */
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+	.n_list =		LIST_HEAD_INIT(ip_vs_rr_scheduler.n_list),
 	.init_service =		ip_vs_rr_init_svc,
 	.done_service =		ip_vs_rr_done_svc,
 	.update_service =	ip_vs_rr_update_svc,
@@ -102,7 +103,6 @@ static struct ip_vs_scheduler ip_vs_rr_scheduler = {
 
 static int __init ip_vs_rr_init(void)
 {
-	INIT_LIST_HEAD(&ip_vs_rr_scheduler.n_list);
 	return register_ip_vs_scheduler(&ip_vs_rr_scheduler);
 }
 
diff --git a/net/ipv4/ipvs/ip_vs_sed.c b/net/ipv4/ipvs/ip_vs_sed.c
index 2a7d313..77663d8 100644
--- a/net/ipv4/ipvs/ip_vs_sed.c
+++ b/net/ipv4/ipvs/ip_vs_sed.c
@@ -138,6 +138,7 @@ static struct ip_vs_scheduler ip_vs_sed_scheduler =
 	.name =			"sed",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+	.n_list =		LIST_HEAD_INIT(ip_vs_sed_scheduler.n_list),
 	.init_service =		ip_vs_sed_init_svc,
 	.done_service =		ip_vs_sed_done_svc,
 	.update_service =	ip_vs_sed_update_svc,
@@ -147,7 +148,6 @@ static struct ip_vs_scheduler ip_vs_sed_scheduler =
 
 static int __init ip_vs_sed_init(void)
 {
-	INIT_LIST_HEAD(&ip_vs_sed_scheduler.n_list);
 	return register_ip_vs_scheduler(&ip_vs_sed_scheduler);
 }
 
diff --git a/net/ipv4/ipvs/ip_vs_sh.c b/net/ipv4/ipvs/ip_vs_sh.c
index b8fdfac..7b979e2 100644
--- a/net/ipv4/ipvs/ip_vs_sh.c
+++ b/net/ipv4/ipvs/ip_vs_sh.c
@@ -230,6 +230,7 @@ static struct ip_vs_scheduler ip_vs_sh_scheduler =
 	.name =			"sh",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+	.n_list	 =		LIST_HEAD_INIT(ip_vs_sh_scheduler.n_list),
 	.init_service =		ip_vs_sh_init_svc,
 	.done_service =		ip_vs_sh_done_svc,
 	.update_service =	ip_vs_sh_update_svc,
@@ -239,7 +240,6 @@ static struct ip_vs_scheduler ip_vs_sh_scheduler =
 
 static int __init ip_vs_sh_init(void)
 {
-	INIT_LIST_HEAD(&ip_vs_sh_scheduler.n_list);
 	return register_ip_vs_scheduler(&ip_vs_sh_scheduler);
 }
 
diff --git a/net/ipv4/ipvs/ip_vs_wlc.c b/net/ipv4/ipvs/ip_vs_wlc.c
index 772c3cb..9b0ef86 100644
--- a/net/ipv4/ipvs/ip_vs_wlc.c
+++ b/net/ipv4/ipvs/ip_vs_wlc.c
@@ -126,6 +126,7 @@ static struct ip_vs_scheduler ip_vs_wlc_scheduler =
 	.name =			"wlc",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+	.n_list =		LIST_HEAD_INIT(ip_vs_wlc_scheduler.n_list),
 	.init_service =		ip_vs_wlc_init_svc,
 	.done_service =		ip_vs_wlc_done_svc,
 	.update_service =	ip_vs_wlc_update_svc,
@@ -135,7 +136,6 @@ static struct ip_vs_scheduler ip_vs_wlc_scheduler =
 
 static int __init ip_vs_wlc_init(void)
 {
-	INIT_LIST_HEAD(&ip_vs_wlc_scheduler.n_list);
 	return register_ip_vs_scheduler(&ip_vs_wlc_scheduler);
 }
 
diff --git a/net/ipv4/ipvs/ip_vs_wrr.c b/net/ipv4/ipvs/ip_vs_wrr.c
index 1d6932d..0d86a79 100644
--- a/net/ipv4/ipvs/ip_vs_wrr.c
+++ b/net/ipv4/ipvs/ip_vs_wrr.c
@@ -212,6 +212,7 @@ static struct ip_vs_scheduler ip_vs_wrr_scheduler = {
 	.name =			"wrr",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
+	.n_list =		LIST_HEAD_INIT(ip_vs_wrr_scheduler.n_list),
 	.init_service =		ip_vs_wrr_init_svc,
 	.done_service =		ip_vs_wrr_done_svc,
 	.update_service =	ip_vs_wrr_update_svc,
@@ -220,7 +221,6 @@ static struct ip_vs_scheduler ip_vs_wrr_scheduler = {
 
 static int __init ip_vs_wrr_init(void)
 {
-	INIT_LIST_HEAD(&ip_vs_wrr_scheduler.n_list);
 	return register_ip_vs_scheduler(&ip_vs_wrr_scheduler) ;
 }
 
-- 
1.5.6.4

