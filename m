From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: ip_vs_ftp causing ip_vs oops on module load.
Date: Thu, 19 May 2011 12:19:21 +0200
Message-ID: <201105191219.22907.hans.schillstrom@ericsson.com>
References: <20110518201915.GB20475@redhat.com> <201105190952.49006.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1105191139360.2171@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1105191139360.2171@ja.ssi.bg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>
Cc: Simon Horman <horms@verge.net.au>, Dave Jones <davej@redhat.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Wensong Zhang <wensong@linuxvirtualserver.org>

On Thursday 19 May 2011 10:55:07 Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 19 May 2011, Hans Schillstrom wrote:
> 
> > I can reproduce the source of the problem,
> > use multiple netns and then unload the ftp module...
> > i.e. same list head used in multiple netns
> > 
> > This brings up a question:
> > - How should ftp be handled in a netns ? 
> > You might want to have it in one netns but not in another,
> > this requires changes to ipvsadm
> > 
> > A way of doing it could be a disable switch like --noftp [port,port]
> > i.e. do not break old apps.
> > 
> > Any other ideas ?
> > 
> > This patch solves the root problem, I'm not sure if this is the way to go
> > or if we should split the ip_vs_app struct ?
> 
> 	This patch is a fast fix but may be it is too late for it,
> after 2.6.39 is out. It seems we overlooked the apps when
> migrating to netns. I think, the apps do not need to be pernet.
> If one day application needs pernet context we can add such
> fields in the ipvs structure.

If we talk about the long term solution,
applications that affects other netns should have their own data.
ex. like the ftp, ports should be per netns
    ipvsadm --appftp [port list]

> 
> 	While the protocols have controls that manipulate pernet
> timeouts, the apps do not have such controls about app->timeouts.
> May be we can remove app->timeouts to avoid confusion because
> it was never implemented in user space. May be instead of this
> fix we should restore the global ip_vs_app_list and all things in
> ip_vs_app.c and ip_vs_ftp.c as before the netns changes?

Doesn't matter, just keep the patch as simple as possible
while we discuss the long term solution.

> 
> > If it's the way to go I can send it as a proper formated patch ...
> > (after some testing)
> > 
> > diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> > index 4fff432..481f856 100644
> > --- a/include/net/ip_vs.h
> > +++ b/include/net/ip_vs.h
> > @@ -797,7 +797,8 @@ struct netns_ipvs {
> >  	struct list_head	rs_table[IP_VS_RTAB_SIZE];
> >  	/* ip_vs_app */
> >  	struct list_head	app_list;
> > -
> > +	/* ip_vs_ftp */
> > +	struct ip_vs_app	*ftp_app;
> >  	/* ip_vs_proto */
> >  	#define IP_VS_PROTO_TAB_SIZE	32	/* must be power of 2 */
> >  	struct ip_vs_proto_data *proto_data_table[IP_VS_PROTO_TAB_SIZE];
> > diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> > index 6b5dd6d..17afb09 100644
> > --- a/net/netfilter/ipvs/ip_vs_ftp.c
> > +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> > @@ -411,25 +411,36 @@ static struct ip_vs_app ip_vs_ftp = {
> >  static int __net_init __ip_vs_ftp_init(struct net *net)
> >  {
> >  	int i, ret;
> > -	struct ip_vs_app *app = &ip_vs_ftp;
> > +	struct ip_vs_app *app;
> > +	struct netns_ipvs *ipvs = net_ipvs(net);
> > +
> > +	app = kmemdup(&ip_vs_ftp, sizeof(struct ip_vs_app), GFP_KERNEL);
> > +	if (!app)
> > +		return -ENOMEM;
> > +	INIT_LIST_HEAD(&app->a_list);
> > +	INIT_LIST_HEAD(&app->incs_list);
> > +	INIT_LIST_HEAD(&app->p_list);
> > +	ipvs->ftp_app = app;
> >  
> >  	ret = register_ip_vs_app(net, app);
> >  	if (ret)
> > -		return ret;
> > +		goto err_exit;
> >  
> >  	for (i=0; i<IP_VS_APP_MAX_PORTS; i++) {
> >  		if (!ports[i])
> >  			continue;
> >  		ret = register_ip_vs_app_inc(net, app, app->protocol, ports[i]);
> >  		if (ret)
> > -			break;
> > +			goto err_unreg;
> >  		pr_info("%s: loaded support on port[%d] = %d\n",
> >  			app->name, i, ports[i]);
> >  	}
> > +	return 0;
> >  
> > -	if (ret)
> > -		unregister_ip_vs_app(net, app);
> > -
> > +err_unreg:
> > +	unregister_ip_vs_app(net, app);
> > +err_exit:
> > +	kfree(ipvs->ftp_app);
> >  	return ret;
> >  }
> >  /*
> > @@ -437,9 +448,7 @@ static int __net_init __ip_vs_ftp_init(struct net *net)
> >   */
> >  static void __ip_vs_ftp_exit(struct net *net)
> >  {
> > -	struct ip_vs_app *app = &ip_vs_ftp;
> > -
> > -	unregister_ip_vs_app(net, app);
> > +	unregister_ip_vs_app(net, net_ipvs(net)->ftp_app);
> >  }
> >  
> >  static struct pernet_operations ip_vs_ftp_ops = {
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
