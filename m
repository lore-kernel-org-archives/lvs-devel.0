From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Only call init_service, update_service and
	done_service for schedulers if defined
Date: Thu, 14 Aug 2008 15:45:15 +1000
Message-ID: <20080814054513.GA26046@verge.net.au>
References: <alpine.LNX.1.10.0808140034210.12259@titan.stealer.net> <20080814044544.GB13993@verge.net.au> <alpine.LNX.1.10.0808140712050.12259@titan.stealer.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.1.10.0808140712050.12259@titan.stealer.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sven Wegener <sven.wegener@stealer.net>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg

On Thu, Aug 14, 2008 at 07:13:44AM +0200, Sven Wegener wrote:
> On Thu, 14 Aug 2008, Simon Horman wrote:
> 
> > On Thu, Aug 14, 2008 at 12:42:55AM +0200, Sven Wegener wrote:
> > > There are schedulers that only schedule based on data available in the service
> > > or destination structures and they don't need any persistent storage or
> > > initialization routine. These schedulers currently provide dummy functions for
> > > the init_service, update_service and/or done_service functions. For the
> > > init_service and done_service cases we already have code that only calls these
> > > functions, if the scheduler provides them. Do the same for the update_service
> > > case and remove the dummy functions from all schedulers.
> > 
> > I'm fine with this change, but it doesn't apply against net-2.6.
> 
> I forgot to rebase, it clashes with one of my last patches. Updated patch 
> below.

Thanks.

Acked-by: Simon Horman <horms@verge.net.au>

> >From 23f90ac1331e3cbb7a8ab2c2b4e573c69a48269c Mon Sep 17 00:00:00 2001
> From: Sven Wegener <sven.wegener@stealer.net>
> Date: Mon, 11 Aug 2008 19:36:06 +0000
> Subject: [PATCH] ipvs: Only call init_service, update_service and done_service for schedulers if defined
> 
> There are schedulers that only schedule based on data available in the service
> or destination structures and they don't need any persistent storage or
> initialization routine. These schedulers currently provide dummy functions for
> the init_service, update_service and/or done_service functions. For the
> init_service and done_service cases we already have code that only calls these
> functions, if the scheduler provides them. Do the same for the update_service
> case and remove the dummy functions from all schedulers.
> 
> Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
> ---
>  net/ipv4/ipvs/ip_vs_ctl.c   |   21 ++++++++++++---------
>  net/ipv4/ipvs/ip_vs_lblc.c  |    7 -------
>  net/ipv4/ipvs/ip_vs_lblcr.c |    7 -------
>  net/ipv4/ipvs/ip_vs_lc.c    |   21 ---------------------
>  net/ipv4/ipvs/ip_vs_nq.c    |   24 ------------------------
>  net/ipv4/ipvs/ip_vs_rr.c    |    7 -------
>  net/ipv4/ipvs/ip_vs_sed.c   |   24 ------------------------
>  net/ipv4/ipvs/ip_vs_wlc.c   |   24 ------------------------
>  8 files changed, 12 insertions(+), 123 deletions(-)
> 
> diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
> index 6379705..2475a64 100644
> --- a/net/ipv4/ipvs/ip_vs_ctl.c
> +++ b/net/ipv4/ipvs/ip_vs_ctl.c
> @@ -868,7 +868,8 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
>  		svc->num_dests++;
>  
>  		/* call the update_service function of its scheduler */
> -		svc->scheduler->update_service(svc);
> +		if (svc->scheduler->update_service)
> +			svc->scheduler->update_service(svc);
>  
>  		write_unlock_bh(&__ip_vs_svc_lock);
>  		return 0;
> @@ -898,7 +899,8 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
>  	svc->num_dests++;
>  
>  	/* call the update_service function of its scheduler */
> -	svc->scheduler->update_service(svc);
> +	if (svc->scheduler->update_service)
> +		svc->scheduler->update_service(svc);
>  
>  	write_unlock_bh(&__ip_vs_svc_lock);
>  
> @@ -948,7 +950,8 @@ ip_vs_edit_dest(struct ip_vs_service *svc, struct ip_vs_dest_user *udest)
>  	IP_VS_WAIT_WHILE(atomic_read(&svc->usecnt) > 1);
>  
>  	/* call the update_service, because server weight may be changed */
> -	svc->scheduler->update_service(svc);
> +	if (svc->scheduler->update_service)
> +		svc->scheduler->update_service(svc);
>  
>  	write_unlock_bh(&__ip_vs_svc_lock);
>  
> @@ -1011,12 +1014,12 @@ static void __ip_vs_unlink_dest(struct ip_vs_service *svc,
>  	 */
>  	list_del(&dest->n_list);
>  	svc->num_dests--;
> -	if (svcupd) {
> -		/*
> -		 *  Call the update_service function of its scheduler
> -		 */
> -		svc->scheduler->update_service(svc);
> -	}
> +
> +	/*
> +	 *  Call the update_service function of its scheduler
> +	 */
> +	if (svcupd && svc->scheduler->update_service)
> +			svc->scheduler->update_service(svc);
>  }
>  
>  
> diff --git a/net/ipv4/ipvs/ip_vs_lblc.c b/net/ipv4/ipvs/ip_vs_lblc.c
> index 7a6a319..4a14d06 100644
> --- a/net/ipv4/ipvs/ip_vs_lblc.c
> +++ b/net/ipv4/ipvs/ip_vs_lblc.c
> @@ -388,12 +388,6 @@ static int ip_vs_lblc_done_svc(struct ip_vs_service *svc)
>  }
>  
>  
> -static int ip_vs_lblc_update_svc(struct ip_vs_service *svc)
> -{
> -	return 0;
> -}
> -
> -
>  static inline struct ip_vs_dest *
>  __ip_vs_wlc_schedule(struct ip_vs_service *svc, struct iphdr *iph)
>  {
> @@ -542,7 +536,6 @@ static struct ip_vs_scheduler ip_vs_lblc_scheduler =
>  	.n_list =		LIST_HEAD_INIT(ip_vs_lblc_scheduler.n_list),
>  	.init_service =		ip_vs_lblc_init_svc,
>  	.done_service =		ip_vs_lblc_done_svc,
> -	.update_service =	ip_vs_lblc_update_svc,
>  	.schedule =		ip_vs_lblc_schedule,
>  };
>  
> diff --git a/net/ipv4/ipvs/ip_vs_lblcr.c b/net/ipv4/ipvs/ip_vs_lblcr.c
> index c234e73..46b8703 100644
> --- a/net/ipv4/ipvs/ip_vs_lblcr.c
> +++ b/net/ipv4/ipvs/ip_vs_lblcr.c
> @@ -572,12 +572,6 @@ static int ip_vs_lblcr_done_svc(struct ip_vs_service *svc)
>  }
>  
>  
> -static int ip_vs_lblcr_update_svc(struct ip_vs_service *svc)
> -{
> -	return 0;
> -}
> -
> -
>  static inline struct ip_vs_dest *
>  __ip_vs_wlc_schedule(struct ip_vs_service *svc, struct iphdr *iph)
>  {
> @@ -731,7 +725,6 @@ static struct ip_vs_scheduler ip_vs_lblcr_scheduler =
>  	.n_list =		LIST_HEAD_INIT(ip_vs_lblcr_scheduler.n_list),
>  	.init_service =		ip_vs_lblcr_init_svc,
>  	.done_service =		ip_vs_lblcr_done_svc,
> -	.update_service =	ip_vs_lblcr_update_svc,
>  	.schedule =		ip_vs_lblcr_schedule,
>  };
>  
> diff --git a/net/ipv4/ipvs/ip_vs_lc.c b/net/ipv4/ipvs/ip_vs_lc.c
> index ebcdbf7..2c3de1b 100644
> --- a/net/ipv4/ipvs/ip_vs_lc.c
> +++ b/net/ipv4/ipvs/ip_vs_lc.c
> @@ -20,24 +20,6 @@
>  #include <net/ip_vs.h>
>  
>  
> -static int ip_vs_lc_init_svc(struct ip_vs_service *svc)
> -{
> -	return 0;
> -}
> -
> -
> -static int ip_vs_lc_done_svc(struct ip_vs_service *svc)
> -{
> -	return 0;
> -}
> -
> -
> -static int ip_vs_lc_update_svc(struct ip_vs_service *svc)
> -{
> -	return 0;
> -}
> -
> -
>  static inline unsigned int
>  ip_vs_lc_dest_overhead(struct ip_vs_dest *dest)
>  {
> @@ -99,9 +81,6 @@ static struct ip_vs_scheduler ip_vs_lc_scheduler = {
>  	.refcnt =		ATOMIC_INIT(0),
>  	.module =		THIS_MODULE,
>  	.n_list =		LIST_HEAD_INIT(ip_vs_lc_scheduler.n_list),
> -	.init_service =		ip_vs_lc_init_svc,
> -	.done_service =		ip_vs_lc_done_svc,
> -	.update_service =	ip_vs_lc_update_svc,
>  	.schedule =		ip_vs_lc_schedule,
>  };
>  
> diff --git a/net/ipv4/ipvs/ip_vs_nq.c b/net/ipv4/ipvs/ip_vs_nq.c
> index 92f3a67..5330d5a 100644
> --- a/net/ipv4/ipvs/ip_vs_nq.c
> +++ b/net/ipv4/ipvs/ip_vs_nq.c
> @@ -37,27 +37,6 @@
>  #include <net/ip_vs.h>
>  
>  
> -static int
> -ip_vs_nq_init_svc(struct ip_vs_service *svc)
> -{
> -	return 0;
> -}
> -
> -
> -static int
> -ip_vs_nq_done_svc(struct ip_vs_service *svc)
> -{
> -	return 0;
> -}
> -
> -
> -static int
> -ip_vs_nq_update_svc(struct ip_vs_service *svc)
> -{
> -	return 0;
> -}
> -
> -
>  static inline unsigned int
>  ip_vs_nq_dest_overhead(struct ip_vs_dest *dest)
>  {
> @@ -137,9 +116,6 @@ static struct ip_vs_scheduler ip_vs_nq_scheduler =
>  	.refcnt =		ATOMIC_INIT(0),
>  	.module =		THIS_MODULE,
>  	.n_list =		LIST_HEAD_INIT(ip_vs_nq_scheduler.n_list),
> -	.init_service =		ip_vs_nq_init_svc,
> -	.done_service =		ip_vs_nq_done_svc,
> -	.update_service =	ip_vs_nq_update_svc,
>  	.schedule =		ip_vs_nq_schedule,
>  };
>  
> diff --git a/net/ipv4/ipvs/ip_vs_rr.c b/net/ipv4/ipvs/ip_vs_rr.c
> index 358110d..f749291 100644
> --- a/net/ipv4/ipvs/ip_vs_rr.c
> +++ b/net/ipv4/ipvs/ip_vs_rr.c
> @@ -32,12 +32,6 @@ static int ip_vs_rr_init_svc(struct ip_vs_service *svc)
>  }
>  
>  
> -static int ip_vs_rr_done_svc(struct ip_vs_service *svc)
> -{
> -	return 0;
> -}
> -
> -
>  static int ip_vs_rr_update_svc(struct ip_vs_service *svc)
>  {
>  	svc->sched_data = &svc->destinations;
> @@ -96,7 +90,6 @@ static struct ip_vs_scheduler ip_vs_rr_scheduler = {
>  	.module =		THIS_MODULE,
>  	.n_list =		LIST_HEAD_INIT(ip_vs_rr_scheduler.n_list),
>  	.init_service =		ip_vs_rr_init_svc,
> -	.done_service =		ip_vs_rr_done_svc,
>  	.update_service =	ip_vs_rr_update_svc,
>  	.schedule =		ip_vs_rr_schedule,
>  };
> diff --git a/net/ipv4/ipvs/ip_vs_sed.c b/net/ipv4/ipvs/ip_vs_sed.c
> index 77663d8..53f73be 100644
> --- a/net/ipv4/ipvs/ip_vs_sed.c
> +++ b/net/ipv4/ipvs/ip_vs_sed.c
> @@ -41,27 +41,6 @@
>  #include <net/ip_vs.h>
>  
>  
> -static int
> -ip_vs_sed_init_svc(struct ip_vs_service *svc)
> -{
> -	return 0;
> -}
> -
> -
> -static int
> -ip_vs_sed_done_svc(struct ip_vs_service *svc)
> -{
> -	return 0;
> -}
> -
> -
> -static int
> -ip_vs_sed_update_svc(struct ip_vs_service *svc)
> -{
> -	return 0;
> -}
> -
> -
>  static inline unsigned int
>  ip_vs_sed_dest_overhead(struct ip_vs_dest *dest)
>  {
> @@ -139,9 +118,6 @@ static struct ip_vs_scheduler ip_vs_sed_scheduler =
>  	.refcnt =		ATOMIC_INIT(0),
>  	.module =		THIS_MODULE,
>  	.n_list =		LIST_HEAD_INIT(ip_vs_sed_scheduler.n_list),
> -	.init_service =		ip_vs_sed_init_svc,
> -	.done_service =		ip_vs_sed_done_svc,
> -	.update_service =	ip_vs_sed_update_svc,
>  	.schedule =		ip_vs_sed_schedule,
>  };
>  
> diff --git a/net/ipv4/ipvs/ip_vs_wlc.c b/net/ipv4/ipvs/ip_vs_wlc.c
> index 9b0ef86..df7ad8d 100644
> --- a/net/ipv4/ipvs/ip_vs_wlc.c
> +++ b/net/ipv4/ipvs/ip_vs_wlc.c
> @@ -25,27 +25,6 @@
>  #include <net/ip_vs.h>
>  
>  
> -static int
> -ip_vs_wlc_init_svc(struct ip_vs_service *svc)
> -{
> -	return 0;
> -}
> -
> -
> -static int
> -ip_vs_wlc_done_svc(struct ip_vs_service *svc)
> -{
> -	return 0;
> -}
> -
> -
> -static int
> -ip_vs_wlc_update_svc(struct ip_vs_service *svc)
> -{
> -	return 0;
> -}
> -
> -
>  static inline unsigned int
>  ip_vs_wlc_dest_overhead(struct ip_vs_dest *dest)
>  {
> @@ -127,9 +106,6 @@ static struct ip_vs_scheduler ip_vs_wlc_scheduler =
>  	.refcnt =		ATOMIC_INIT(0),
>  	.module =		THIS_MODULE,
>  	.n_list =		LIST_HEAD_INIT(ip_vs_wlc_scheduler.n_list),
> -	.init_service =		ip_vs_wlc_init_svc,
> -	.done_service =		ip_vs_wlc_done_svc,
> -	.update_service =	ip_vs_wlc_update_svc,
>  	.schedule =		ip_vs_wlc_schedule,
>  };
>  
