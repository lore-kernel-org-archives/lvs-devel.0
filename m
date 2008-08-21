From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH RFC 19/24] IPVS: Add IPv6 support flag to schedulers
Date: Thu, 21 Aug 2008 11:48:15 +1000
Message-ID: <20080821014813.GH19235@verge.net.au>
References: <1219248931-15064-1-git-send-email-juliusv@google.com> <1219248931-15064-20-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1219248931-15064-20-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Wed, Aug 20, 2008 at 06:15:26PM +0200, Julius Volz wrote:
> Add 'supports_ipv6' flag to struct ip_vs_scheduler to indicate whether a
> scheduler supports IPv6. Set the flag to 1 in schedulers that work with
> IPv6, 0 otherwise. This flag is checked in a later patch while trying to
> add a service with a specific scheduler.

I wonder if there are some spare bits inside the flags
member of ip_vs_scheduler that could be used for this purpose?

Otherwise, I'm fine with this, we can juggle things around
later to use the other bits in supports_ipv6 for other things
if and when the need arises.

Here is a version that applies against lvs-2.6

From: Julius Volz <juliusv@google.com>

IPVS: Add IPv6 support flag to schedulers

Add 'supports_ipv6' flag to struct ip_vs_scheduler to indicate whether a
scheduler supports IPv6. Set the flag to 1 in schedulers that work with
IPv6, 0 otherwise. This flag is checked in a later patch while trying to
add a service with a specific scheduler.

Signed-off-by: Julius Volz <juliusv@google.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

--- 

 include/net/ip_vs.h         |    3 +++
 net/ipv4/ipvs/ip_vs_dh.c    |    3 +++
 net/ipv4/ipvs/ip_vs_lblc.c  |    3 +++
 net/ipv4/ipvs/ip_vs_lblcr.c |    3 +++
 net/ipv4/ipvs/ip_vs_lc.c    |    3 +++
 net/ipv4/ipvs/ip_vs_nq.c    |    3 +++
 net/ipv4/ipvs/ip_vs_rr.c    |    3 +++
 net/ipv4/ipvs/ip_vs_sed.c   |    3 +++
 net/ipv4/ipvs/ip_vs_sh.c    |    3 +++
 net/ipv4/ipvs/ip_vs_wlc.c   |    3 +++
 net/ipv4/ipvs/ip_vs_wrr.c   |    3 +++
 11 files changed, 33 insertions(+)

b8c297df2a43ab6a2143f6ec5ccfb4943231e1c5
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index f591d7d..66ca986 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -475,6 +475,9 @@ struct ip_vs_scheduler {
 	char			*name;		/* scheduler name */
 	atomic_t		refcnt;		/* reference counter */
 	struct module		*module;	/* THIS_MODULE/NULL */
+#ifdef CONFIG_IP_VS_IPV6
+	int			supports_ipv6;	/* scheduler has IPv6 support */
+#endif
 
 	/* scheduler initializing service */
 	int (*init_service)(struct ip_vs_service *svc);
diff --git a/net/ipv4/ipvs/ip_vs_dh.c b/net/ipv4/ipvs/ip_vs_dh.c
index fa66824..bb0d426 100644
--- a/net/ipv4/ipvs/ip_vs_dh.c
+++ b/net/ipv4/ipvs/ip_vs_dh.c
@@ -234,6 +234,9 @@ static struct ip_vs_scheduler ip_vs_dh_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_dh_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	0,
+#endif
 	.init_service =		ip_vs_dh_init_svc,
 	.done_service =		ip_vs_dh_done_svc,
 	.update_service =	ip_vs_dh_update_svc,
diff --git a/net/ipv4/ipvs/ip_vs_lblc.c b/net/ipv4/ipvs/ip_vs_lblc.c
index d2a43aa..2d2287d 100644
--- a/net/ipv4/ipvs/ip_vs_lblc.c
+++ b/net/ipv4/ipvs/ip_vs_lblc.c
@@ -522,6 +522,9 @@ static struct ip_vs_scheduler ip_vs_lblc_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_lblc_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	0,
+#endif
 	.init_service =		ip_vs_lblc_init_svc,
 	.done_service =		ip_vs_lblc_done_svc,
 	.schedule =		ip_vs_lblc_schedule,
diff --git a/net/ipv4/ipvs/ip_vs_lblcr.c b/net/ipv4/ipvs/ip_vs_lblcr.c
index 375a1ff..1da5e7f 100644
--- a/net/ipv4/ipvs/ip_vs_lblcr.c
+++ b/net/ipv4/ipvs/ip_vs_lblcr.c
@@ -722,6 +722,9 @@ static struct ip_vs_scheduler ip_vs_lblcr_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_lblcr_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	0,
+#endif
 	.init_service =		ip_vs_lblcr_init_svc,
 	.done_service =		ip_vs_lblcr_done_svc,
 	.schedule =		ip_vs_lblcr_schedule,
diff --git a/net/ipv4/ipvs/ip_vs_lc.c b/net/ipv4/ipvs/ip_vs_lc.c
index 2ad4e99..32e9ce7 100644
--- a/net/ipv4/ipvs/ip_vs_lc.c
+++ b/net/ipv4/ipvs/ip_vs_lc.c
@@ -83,6 +83,9 @@ static struct ip_vs_scheduler ip_vs_lc_scheduler = {
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_lc_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.schedule =		ip_vs_lc_schedule,
 };
 
diff --git a/net/ipv4/ipvs/ip_vs_nq.c b/net/ipv4/ipvs/ip_vs_nq.c
index 38adb1c..fa4cd7c 100644
--- a/net/ipv4/ipvs/ip_vs_nq.c
+++ b/net/ipv4/ipvs/ip_vs_nq.c
@@ -117,6 +117,9 @@ static struct ip_vs_scheduler ip_vs_nq_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_nq_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.schedule =		ip_vs_nq_schedule,
 };
 
diff --git a/net/ipv4/ipvs/ip_vs_rr.c b/net/ipv4/ipvs/ip_vs_rr.c
index f749291..f82719c 100644
--- a/net/ipv4/ipvs/ip_vs_rr.c
+++ b/net/ipv4/ipvs/ip_vs_rr.c
@@ -89,6 +89,9 @@ static struct ip_vs_scheduler ip_vs_rr_scheduler = {
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_rr_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.init_service =		ip_vs_rr_init_svc,
 	.update_service =	ip_vs_rr_update_svc,
 	.schedule =		ip_vs_rr_schedule,
diff --git a/net/ipv4/ipvs/ip_vs_sed.c b/net/ipv4/ipvs/ip_vs_sed.c
index 691a6a0..7d2f22f 100644
--- a/net/ipv4/ipvs/ip_vs_sed.c
+++ b/net/ipv4/ipvs/ip_vs_sed.c
@@ -118,6 +118,9 @@ static struct ip_vs_scheduler ip_vs_sed_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_sed_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.schedule =		ip_vs_sed_schedule,
 };
 
diff --git a/net/ipv4/ipvs/ip_vs_sh.c b/net/ipv4/ipvs/ip_vs_sh.c
index 7b979e2..12f9ccc 100644
--- a/net/ipv4/ipvs/ip_vs_sh.c
+++ b/net/ipv4/ipvs/ip_vs_sh.c
@@ -231,6 +231,9 @@ static struct ip_vs_scheduler ip_vs_sh_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list	 =		LIST_HEAD_INIT(ip_vs_sh_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	0,
+#endif
 	.init_service =		ip_vs_sh_init_svc,
 	.done_service =		ip_vs_sh_done_svc,
 	.update_service =	ip_vs_sh_update_svc,
diff --git a/net/ipv4/ipvs/ip_vs_wlc.c b/net/ipv4/ipvs/ip_vs_wlc.c
index 57b452b..8c596e7 100644
--- a/net/ipv4/ipvs/ip_vs_wlc.c
+++ b/net/ipv4/ipvs/ip_vs_wlc.c
@@ -106,6 +106,9 @@ static struct ip_vs_scheduler ip_vs_wlc_scheduler =
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_wlc_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.schedule =		ip_vs_wlc_schedule,
 };
 
diff --git a/net/ipv4/ipvs/ip_vs_wrr.c b/net/ipv4/ipvs/ip_vs_wrr.c
index 2f618dc..7ea92fe 100644
--- a/net/ipv4/ipvs/ip_vs_wrr.c
+++ b/net/ipv4/ipvs/ip_vs_wrr.c
@@ -213,6 +213,9 @@ static struct ip_vs_scheduler ip_vs_wrr_scheduler = {
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
 	.n_list =		LIST_HEAD_INIT(ip_vs_wrr_scheduler.n_list),
+#ifdef CONFIG_IP_VS_IPV6
+	.supports_ipv6 =	1,
+#endif
 	.init_service =		ip_vs_wrr_init_svc,
 	.done_service =		ip_vs_wrr_done_svc,
 	.update_service =	ip_vs_wrr_update_svc,
