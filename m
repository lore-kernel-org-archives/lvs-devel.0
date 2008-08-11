From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: A couple of fixes and cleanups
Date: Mon, 11 Aug 2008 10:50:17 +1000
Message-ID: <20080811005016.GC19825@verge.net.au>
References: <1218366459-23971-1-git-send-email-sven.wegener@stealer.net> <alpine.LNX.1.10.0808102032180.12259@titan.stealer.net>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.1.10.0808102032180.12259@titan.stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sven Wegener <sven.wegener@stealer.net>
Cc: wensong@linux-vs.org, ja@ssi.bg, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

On Sun, Aug 10, 2008 at 08:35:48PM +0200, Sven Wegener wrote:
> On Sun, 10 Aug 2008, sven.wegener@stealer.net wrote:
> 
> > Hi guys,
> > 
> > here come a couple of fixes and cleanups for IPVS. Worth mentioning are the two
> > possible deadlock fixes. One introduced by my last sync daemon work, which
> > hasn't hit any stable kernel yet. The other one is in the estimator code and
> > goes back to at leat since we started working with git for the kernel. The
> > latter I think qualifies for -stable.
> > 
> > I've pushed the changes (8123b42..2e45552) based on davem's net tree here
> > 
> > 	git://git.stealer.net/linux-2.6.git stealer/ipvs/for-davem
> 
> I've included the register_ip_vs_protocol() annotation. Changes are now 
> 8123b42..7ead17b. Diffstat has changed slightly, but is probably not worth 
> posting again.

Hi Sven,

all these changes seem fine to me.

Acked-by: Simon Horman <horms@verge.net.au>

With regards to ip_vs_zero_stats(), it uses

   memset(stats, 0, (char *)&stats->lock - (char *)stats);

to clear stats and then calls ip_vs_zero_estimator(), which uses

   est->last_conns = 0;
   est->last_inpkts = 0;
   ...

to clear stats->est.

I wonder if it would be cleaner to either clear
stats->... directly in ip_vs_zero_stats(), or use
memset in ip_vs_zero_estimator()?

Something like this...

----------------------------------------------------------------

ipvs: Use memset to clear estimator

This makes the code in ip_vs_zero_estimator() a lot closer
to the style of its parent, ip_vs_zero_stats().

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: net-2.6/include/net/ip_vs.h
===================================================================
--- net-2.6.orig/include/net/ip_vs.h	2008-08-11 10:43:23.000000000 +1000
+++ net-2.6/include/net/ip_vs.h	2008-08-11 10:43:23.000000000 +1000
@@ -143,8 +143,6 @@ struct ip_vs_seq {
  *	IPVS statistics objects
  */
 struct ip_vs_estimator {
-	struct list_head	list;
-
 	u32			last_conns;
 	u32			last_inpkts;
 	u32			last_outpkts;
@@ -156,6 +154,8 @@ struct ip_vs_estimator {
 	u32			outpps;
 	u32			inbps;
 	u32			outbps;
+
+	struct list_head	list;
 };
 
 struct ip_vs_stats
Index: net-2.6/net/ipv4/ipvs/ip_vs_est.c
===================================================================
--- net-2.6.orig/net/ipv4/ipvs/ip_vs_est.c	2008-08-11 10:43:23.000000000 +1000
+++ net-2.6/net/ipv4/ipvs/ip_vs_est.c	2008-08-11 10:43:23.000000000 +1000
@@ -149,14 +149,5 @@ void ip_vs_zero_estimator(struct ip_vs_s
 	struct ip_vs_estimator *est = &stats->est;
 
 	/* set counters zero, caller must hold the stats->lock lock */
-	est->last_conns = 0;
-	est->last_inpkts = 0;
-	est->last_outpkts = 0;
-	est->last_inbytes = 0;
-	est->last_outbytes = 0;
-	est->cps = 0;
-	est->inpps = 0;
-	est->outpps = 0;
-	est->inbps = 0;
-	est->outbps = 0;
+	memset(est, 0, (char *)&est->list - (char *)est);
 }
