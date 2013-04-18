From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 3/6] ipvs: fix sparse warnings in lblc and
 lblcr
Date: Thu, 18 Apr 2013 22:46:57 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1304182233370.1842@ja.ssi.bg>
References: <1366231850-22188-1-git-send-email-ja@ssi.bg> <1366231850-22188-4-git-send-email-ja@ssi.bg> <20130418114624.GC11486@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130418114624.GC11486@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>


	Hello,

On Thu, 18 Apr 2013, Simon Horman wrote:

> On Wed, Apr 17, 2013 at 11:50:47PM +0300, Julian Anastasov wrote:
> > 	kbuild test robot reports for sparse warnings in
> > commits c2a4ffb70eef39 ("ipvs: convert lblc scheduler to rcu")
> > and c5549571f975ab ("ipvs: convert lblcr scheduler to rcu").
> > 
> > 	Fix it by removing extra __rcu annotation.
> 
> Hi Julian,
> 
> perhaps only for my benefit, but could you explain
> why the annotations are unnecessary?

	IMHO, because __rcu should be used only for
pointers, not for struct hlist_head. The *list*_rcu
methods enforce __rcu internally for the pointers.

> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > ---
> >  net/netfilter/ipvs/ip_vs_lblc.c  |    2 +-
> >  net/netfilter/ipvs/ip_vs_lblcr.c |    2 +-
> >  2 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
> > index b2cc252..5ea26bd 100644
> > --- a/net/netfilter/ipvs/ip_vs_lblc.c
> > +++ b/net/netfilter/ipvs/ip_vs_lblc.c
> > @@ -104,7 +104,7 @@ struct ip_vs_lblc_entry {
> >   */
> >  struct ip_vs_lblc_table {
> >  	struct rcu_head		rcu_head;
> > -	struct hlist_head __rcu bucket[IP_VS_LBLC_TAB_SIZE];  /* hash bucket */
> > +	struct hlist_head	bucket[IP_VS_LBLC_TAB_SIZE];  /* hash bucket */
> >  	struct timer_list       periodic_timer; /* collect stale entries */
> >  	atomic_t                entries;        /* number of entries */
> >  	int                     max_size;       /* maximum size of entries */
> > diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
> > index feb9656..50123c2 100644
> > --- a/net/netfilter/ipvs/ip_vs_lblcr.c
> > +++ b/net/netfilter/ipvs/ip_vs_lblcr.c
> > @@ -284,7 +284,7 @@ struct ip_vs_lblcr_entry {
> >   */
> >  struct ip_vs_lblcr_table {
> >  	struct rcu_head		rcu_head;
> > -	struct hlist_head __rcu bucket[IP_VS_LBLCR_TAB_SIZE];  /* hash bucket */
> > +	struct hlist_head	bucket[IP_VS_LBLCR_TAB_SIZE];  /* hash bucket */
> >  	atomic_t                entries;        /* number of entries */
> >  	int                     max_size;       /* maximum size of entries */
> >  	struct timer_list       periodic_timer; /* collect stale entries */
> > -- 
> > 1.7.3.4

Regards

--
Julian Anastasov <ja@ssi.bg>
