From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/2] ipvs: generalize app registration in netns
Date: Thu, 12 Jul 2012 23:04:04 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1207122301360.1831@ja.ssi.bg>
References: <1341966327-16606-1-git-send-email-horms@verge.net.au> <1341966327-16606-3-git-send-email-horms@verge.net.au> <20120712162209.GA21904@1984>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120712162209.GA21904@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>


	Hello,

On Thu, 12 Jul 2012, Pablo Neira Ayuso wrote:

> > +struct ip_vs_app *register_ip_vs_app(struct net *net, struct ip_vs_app *app)
> >  {
> >  	struct netns_ipvs *ipvs = net_ipvs(net);
> > -	/* increase the module use count */
> > -	ip_vs_use_count_inc();
> > +	struct ip_vs_app *a;
> > +	int err = 0;
> > +
> > +	if (!ipvs)
> > +		return ERR_PTR(-ENOENT);
> >  
> >  	mutex_lock(&__ip_vs_app_mutex);
> >  
> > -	list_add(&app->a_list, &ipvs->app_list);
> > +	list_for_each_entry(a, &ipvs->app_list, a_list) {
> > +		if (!strcmp(app->name, a->name)) {
> > +			err = -EEXIST;
> > +			break;
> > +		}
> > +	}
> > +	if (!err) {
> > +		a = kmemdup(app, sizeof(*app), GFP_KERNEL);
> > +		if (!a)
> > +			err = -ENOMEM;
> > +	}
> > +	if (!err) {
> > +		INIT_LIST_HEAD(&a->incs_list);
> > +		list_add(&a->a_list, &ipvs->app_list);
> > +		/* increase the module use count */
> > +		ip_vs_use_count_inc();
> > +	}
> 
> I think this code will look better if you use something like:
> 
> +		if (!strcmp(app->name, a->name)) {
> +			err = -EEXIST;
> +			goto err_unlock;
> +		}
> 
> err_unlock:
>         mutex_unlock(...)
> 
> >  
> >  	mutex_unlock(&__ip_vs_app_mutex);
> >  
> > -	return 0;
> > +	if (err)
> > +		return ERR_PTR(err);
> > +	return a;
> 
> For this three lines above, you can use:
> 
> return err ? return ERR_PTR(err) : a;

	Good point, sending v2 ...

Regards

--
Julian Anastasov <ja@ssi.bg>
