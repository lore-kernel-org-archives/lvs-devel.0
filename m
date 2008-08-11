From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: A couple of fixes and cleanups
Date: Mon, 11 Aug 2008 17:19:14 +1000
Message-ID: <20080811071912.GA12605@verge.net.au>
References: <1218366459-23971-1-git-send-email-sven.wegener@stealer.net> <alpine.LNX.1.10.0808102032180.12259@titan.stealer.net> <20080811005016.GC19825@verge.net.au> <alpine.LNX.1.10.0808110821200.12259@titan.stealer.net> <20080811065647.GD1792@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080811065647.GD1792@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sven Wegener <sven.wegener@stealer.net>
Cc: wensong@linux-vs.org, ja@ssi.bg, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

On Mon, Aug 11, 2008 at 04:56:48PM +1000, Simon Horman wrote:
> On Mon, Aug 11, 2008 at 08:43:54AM +0200, Sven Wegener wrote:
> > On Mon, 11 Aug 2008, Simon Horman wrote:
> > 
> > > On Sun, Aug 10, 2008 at 08:35:48PM +0200, Sven Wegener wrote:
> > > > On Sun, 10 Aug 2008, sven.wegener@stealer.net wrote:
> > > > 
> > > > > Hi guys,
> > > > > 
> > > > > here come a couple of fixes and cleanups for IPVS. Worth mentioning are the two
> > > > > possible deadlock fixes. One introduced by my last sync daemon work, which
> > > > > hasn't hit any stable kernel yet. The other one is in the estimator code and
> > > > > goes back to at leat since we started working with git for the kernel. The
> > > > > latter I think qualifies for -stable.
> > > > > 
> > > > > I've pushed the changes (8123b42..2e45552) based on davem's net tree here
> > > > > 
> > > > > 	git://git.stealer.net/linux-2.6.git stealer/ipvs/for-davem
> > > > 
> > > > I've included the register_ip_vs_protocol() annotation. Changes are now 
> > > > 8123b42..7ead17b. Diffstat has changed slightly, but is probably not worth 
> > > > posting again.
> > > 
> > > Hi Sven,
> > > 
> > > all these changes seem fine to me.
> > > 
> > > Acked-by: Simon Horman <horms@verge.net.au>
> > > 
> > > With regards to ip_vs_zero_stats(), it uses
> > > 
> > >    memset(stats, 0, (char *)&stats->lock - (char *)stats);
> > > 
> > > to clear stats and then calls ip_vs_zero_estimator(), which uses
> > > 
> > >    est->last_conns = 0;
> > >    est->last_inpkts = 0;
> > >    ...
> > > 
> > > to clear stats->est.
> > > 
> > > I wonder if it would be cleaner to either clear
> > > stats->... directly in ip_vs_zero_stats(), or use
> > > memset in ip_vs_zero_estimator()?
> > 
> > Yeah, I wondered about the same. memset is probably simpler, but direct 
> > assignment makes it more obvious what is changed. Thinking about it, I'd 
> > prefer direct assignment, when not setting a complete structure to zero 
> > and there are not more than a handful lines needed to do it with direct 
> > assignment. But I'm fine with either way here. If we prefer the memset 
> > way, we should add a comment to both structures, saying that nobody should 
> > add anything non-statistic before the member we use to get the size.
> 
> To be honest I prefer direct assignment too. I think it is less fragile
> as the structures can be re-ordered without effecting how clear works.
> I'll post a (trivial) patch shortly.

And here it is...

--------------------------------------------------

ipvs: Explictly clear ip_vs_status members

In order to align the coding styles of ip_vs_zero_stats() and
its child-function ip_vs_zero_estimator(), clear ip_vs_status
members explicitlty rather than doing a limited memset().

This was chosen over modifying ip_vs_zero_estimator() to use
memset() as it is more robust against changes in members
in the relevant structures. memset() would be prefered if
all members of the structure were to be cleared.

Cc: Sven Wegener <sven.wegener@stealer.net>
Signed-off-by: Simon Horman <horms@verge.net.au>

Index: net-2.6/net/ipv4/ipvs/ip_vs_ctl.c
===================================================================
--- net-2.6.orig/net/ipv4/ipvs/ip_vs_ctl.c	2008-08-11 17:15:04.000000000 +1000
+++ net-2.6/net/ipv4/ipvs/ip_vs_ctl.c	2008-08-11 17:15:07.000000000 +1000
@@ -683,8 +683,21 @@ static void
 ip_vs_zero_stats(struct ip_vs_stats *stats)
 {
 	spin_lock_bh(&stats->lock);
-	memset(stats, 0, (char *)&stats->lock - (char *)stats);
+
+	stats->conns = 0;
+	stats->inpkts = 0;
+	stats->outpkts = 0;
+	stats->inbytes = 0;
+	stats->outbytes = 0;
+
+	stats->cps = 0;
+	stats->inpps = 0;
+	stats->outpps = 0;
+	stats->inbps = 0;
+	stats->outbps = 0;
+
 	ip_vs_zero_estimator(stats);
+
 	spin_unlock_bh(&stats->lock);
 }
 
