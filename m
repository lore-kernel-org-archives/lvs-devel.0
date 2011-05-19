From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ip_vs_ftp causing ip_vs oops on module load.
Date: Thu, 19 May 2011 23:13:44 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1105192235300.1589@ja.ssi.bg>
References: <20110518201915.GB20475@redhat.com> <201105190952.49006.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1105191139360.2171@ja.ssi.bg> <201105191219.22907.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201105191219.22907.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, Simon Horman <horms@verge.net.au>, Dave Jones <davej@redhat.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Wensong Zhang <wensong@linuxvirtualserver.org>


	Hello,

On Thu, 19 May 2011, Hans Schillstrom wrote:

> If we talk about the long term solution,
> applications that affects other netns should have their own data.
> ex. like the ftp, ports should be per netns
>     ipvsadm --appftp [port list]

	Yes, it is possible, if we find solution to
trigger register_ip_vs_app_inc() calls with such controls...
May be app have to export some method(s) for this to work.

> > 	While the protocols have controls that manipulate pernet
> > timeouts, the apps do not have such controls about app->timeouts.
> > May be we can remove app->timeouts to avoid confusion because
> > it was never implemented in user space. May be instead of this
> > fix we should restore the global ip_vs_app_list and all things in
> > ip_vs_app.c and ip_vs_ftp.c as before the netns changes?
> 
> Doesn't matter, just keep the patch as simple as possible
> while we discuss the long term solution.

	OK, then let's use this solution but with some changes...

> > > --- a/include/net/ip_vs.h
> > > +++ b/include/net/ip_vs.h
> > > @@ -797,7 +797,8 @@ struct netns_ipvs {
> > >  	struct list_head	rs_table[IP_VS_RTAB_SIZE];
> > >  	/* ip_vs_app */
> > >  	struct list_head	app_list;
> > > -
> > > +	/* ip_vs_ftp */
> > > +	struct ip_vs_app	*ftp_app;
> > >  	/* ip_vs_proto */
> > >  	#define IP_VS_PROTO_TAB_SIZE	32	/* must be power of 2 */
> > >  	struct ip_vs_proto_data *proto_data_table[IP_VS_PROTO_TAB_SIZE];
> > > diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> > > index 6b5dd6d..17afb09 100644
> > > --- a/net/netfilter/ipvs/ip_vs_ftp.c
> > > +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> > > @@ -411,25 +411,36 @@ static struct ip_vs_app ip_vs_ftp = {
> > >  static int __net_init __ip_vs_ftp_init(struct net *net)
> > >  {
> > >  	int i, ret;
> > > -	struct ip_vs_app *app = &ip_vs_ftp;
> > > +	struct ip_vs_app *app;
> > > +	struct netns_ipvs *ipvs = net_ipvs(net);
> > > +
> > > +	app = kmemdup(&ip_vs_ftp, sizeof(struct ip_vs_app), GFP_KERNEL);
> > > +	if (!app)
> > > +		return -ENOMEM;
> > > +	INIT_LIST_HEAD(&app->a_list);
> > > +	INIT_LIST_HEAD(&app->incs_list);
> > > +	INIT_LIST_HEAD(&app->p_list);

	No need to init a_list and p_list here. As for
INIT_LIST_HEAD(&app->incs_list), may be it is better to
be moved into register_ip_vs_app() before the mutex_lock
to avoid further problems.

> > > +	ipvs->ftp_app = app;
> > >  
> > >  	ret = register_ip_vs_app(net, app);
> > >  	if (ret)
> > > -		return ret;
> > > +		goto err_exit;
> > >  
> > >  	for (i=0; i<IP_VS_APP_MAX_PORTS; i++) {
> > >  		if (!ports[i])
> > >  			continue;
> > >  		ret = register_ip_vs_app_inc(net, app, app->protocol, ports[i]);
> > >  		if (ret)
> > > -			break;
> > > +			goto err_unreg;
> > >  		pr_info("%s: loaded support on port[%d] = %d\n",
> > >  			app->name, i, ports[i]);
> > >  	}
> > > +	return 0;
> > >  
> > > -	if (ret)
> > > -		unregister_ip_vs_app(net, app);
> > > -
> > > +err_unreg:
> > > +	unregister_ip_vs_app(net, app);
> > > +err_exit:
> > > +	kfree(ipvs->ftp_app);
> > >  	return ret;
> > >  }
> > >  /*
> > > @@ -437,9 +448,7 @@ static int __net_init __ip_vs_ftp_init(struct net *net)
> > >   */
> > >  static void __ip_vs_ftp_exit(struct net *net)
> > >  {
> > > -	struct ip_vs_app *app = &ip_vs_ftp;
> > > -
> > > -	unregister_ip_vs_app(net, app);
> > > +	unregister_ip_vs_app(net, net_ipvs(net)->ftp_app);


	Add here kfree(ipvs->ftp_app);


> > >  }
> > >  
> > >  static struct pernet_operations ip_vs_ftp_ops = {

	If you agree with these changes then you have my ack.

Acked-by: Julian Anastasov <ja@ssi.bg>

