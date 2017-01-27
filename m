From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2 net] net: free ip_vs_dest structs when refcnt=0
Date: Fri, 27 Jan 2017 09:07:38 +0100
Message-ID: <20170127080738.GD21195@verge.net.au>
References: <1485228269-21758-1-git-send-email-dwindsor@gmail.com>
 <alpine.LFD.2.11.1701262241280.3892@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1485504466; bh=NBdtOXVfNEsjnFOWkglvAq6HKSoN2167JAy+z/IPUXc=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=de3rmZ0FmvhTwYXWdYzuSzshBuYPVeon0XqxCXvQrgGemdvZeVTex+QQybVj8uvKK
         mjMW+PAjUjlD6rov3PqnUSz80aci+v9SSZYOmwLcxGLL5ej/3WQlT3euKKO60/V99V
         2fUFvHRe/PkvqSCwp8hcEo+j6juwb8sIoEasqJII=
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1701262241280.3892@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: David Windsor <dwindsor@gmail.com>, netdev@vger.kernel.org, kernel-hardening@lists.openwall.com, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, wensong@linux-vs.org, pablo@netfilter.org, keescook@chromium.org, elena.reshetova@intel.com, ishkamiel@gmail.com

On Thu, Jan 26, 2017 at 10:49:10PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 23 Jan 2017, David Windsor wrote:
> 
> > Currently, the ip_vs_dest cache frees ip_vs_dest objects when their
> > reference count becomes < 0.  Aside from not being semantically sound,
> > this is problematic for the new type refcount_t, which will be introduced
> > shortly in a separate patch. refcount_t is the new kernel type for
> > holding reference counts, and provides overflow protection and a
> > constrained interface relative to atomic_t (the type currently being
> > used for kernel reference counts).
> > 
> > Per Julian Anastasov: "The problem is that dest_trash currently holds
> > deleted dests (unlinked from RCU lists) with refcnt=0."  Changing
> > dest_trash to hold dest with refcnt=1 will allow us to free ip_vs_dest
> > structs when their refcnt=0, in ip_vs_dest_put_and_free().
> > 
> > Signed-off-by: David Windsor <dwindsor@gmail.com>
> 
> 	Thanks! I tested the first version and this one
> just adds the needed changes in comments, so
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Simon and Pablo, this is more appropriate for
> ipvs-next/nf-next. Please apply!

Pablo, would you mind taking this one directly into nf-next?

Signed-off-by: Simon Horman <horms@verge.net.au>

> 
> > ---
> >  include/net/ip_vs.h            | 2 +-
> >  net/netfilter/ipvs/ip_vs_ctl.c | 8 +++-----
> >  2 files changed, 4 insertions(+), 6 deletions(-)
> > 
> > diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> > index cd6018a..a3e78ad 100644
> > --- a/include/net/ip_vs.h
> > +++ b/include/net/ip_vs.h
> > @@ -1421,7 +1421,7 @@ static inline void ip_vs_dest_put(struct ip_vs_dest *dest)
> >  
> >  static inline void ip_vs_dest_put_and_free(struct ip_vs_dest *dest)
> >  {
> > -	if (atomic_dec_return(&dest->refcnt) < 0)
> > +	if (atomic_dec_and_test(&dest->refcnt))
> >  		kfree(dest);
> >  }
> >  
> > diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> > index 55e0169..5fc4836 100644
> > --- a/net/netfilter/ipvs/ip_vs_ctl.c
> > +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> > @@ -711,7 +711,6 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, int dest_af,
> >  		      dest->vport == svc->port))) {
> >  			/* HIT */
> >  			list_del(&dest->t_list);
> > -			ip_vs_dest_hold(dest);
> >  			goto out;
> >  		}
> >  	}
> > @@ -741,7 +740,7 @@ static void ip_vs_dest_free(struct ip_vs_dest *dest)
> >   *  When the ip_vs_control_clearup is activated by ipvs module exit,
> >   *  the service tables must have been flushed and all the connections
> >   *  are expired, and the refcnt of each destination in the trash must
> > - *  be 0, so we simply release them here.
> > + *  be 1, so we simply release them here.
> >   */
> >  static void ip_vs_trash_cleanup(struct netns_ipvs *ipvs)
> >  {
> > @@ -1080,11 +1079,10 @@ static void __ip_vs_del_dest(struct netns_ipvs *ipvs, struct ip_vs_dest *dest,
> >  	if (list_empty(&ipvs->dest_trash) && !cleanup)
> >  		mod_timer(&ipvs->dest_trash_timer,
> >  			  jiffies + (IP_VS_DEST_TRASH_PERIOD >> 1));
> > -	/* dest lives in trash without reference */
> > +	/* dest lives in trash with reference */
> >  	list_add(&dest->t_list, &ipvs->dest_trash);
> >  	dest->idle_start = 0;
> >  	spin_unlock_bh(&ipvs->dest_trash_lock);
> > -	ip_vs_dest_put(dest);
> >  }
> >  
> >  
> > @@ -1160,7 +1158,7 @@ static void ip_vs_dest_trash_expire(unsigned long data)
> >  
> >  	spin_lock(&ipvs->dest_trash_lock);
> >  	list_for_each_entry_safe(dest, next, &ipvs->dest_trash, t_list) {
> > -		if (atomic_read(&dest->refcnt) > 0)
> > +		if (atomic_read(&dest->refcnt) > 1)
> >  			continue;
> >  		if (dest->idle_start) {
> >  			if (time_before(now, dest->idle_start +
> > -- 
> > 2.7.4
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
