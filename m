From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [RFC PATCH 5/9] ipvs network name space aware
Date: Thu, 21 Oct 2010 13:42:41 +0200
Message-ID: <201010211342.42833.hans.schillstrom@ericsson.com>
References: <201010081317.04167.hans.schillstrom@ericsson.com> <20101021111644.GA25555@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101021111644.GA25555@verge.net.au>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "ja@ssi.bg" <ja@ssi.bg>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>

On Thursday 21 October 2010 13:16:47 Simon Horman wrote:
> On Fri, Oct 08, 2010 at 01:17:02PM +0200, Hans Schillstrom wrote:
> > This patch just contains ip_vs_ctl
> >
> > Signed-off-by:Hans Schillstrom <hans.schillstrom@ericsson.com>
> >
> > diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> > index ca8ec8c..7e99cbc 100644
> > --- a/net/netfilter/ipvs/ip_vs_ctl.c
> > +++ b/net/netfilter/ipvs/ip_vs_ctl.c
>
> [ snip ]
>
> > @@ -2680,10 +2664,15 @@ static int ip_vs_genl_dump_services(struct sk_buff *skb,
> >  	int idx = 0, i;
> >  	int start = cb->args[0];
> >  	struct ip_vs_service *svc;
> > -
> > +	struct net *net = skb->sk->sk_net;
>
> skb->sk->sk_net needs CONFIG_NS_NET.
> Is your plan for IPVS to unconditionally depend on CONFIG_NS_NET?
No.
> It would be nice to avoid that, but I fear it will be too messy.

Crap, I missed that.
I think a couple of inlines in ip_vs.h can do the job like;

static inline struct net * ipvs_sknet(struct sock *sk)
{
#ifdef CONFIG_NS_NET
	return sk->sk_net;
#else
	return init_net;
#endif
}

static inline struct net * ipvs_devnet(struct skb *skb)
{
#ifdef CONFIG_NS_NET
	return dev_net(skb->dev);
#else
	return init_net;
#endif
}

and use it like this
	struct net *net = ipvs_sknet(skb->sk);


> > +	struct netns_ipvs *ipvs;
> > +	if (!net)
> > +		net = dev_net(dev_net(skb->dev););

		net = ipvs_devnet(skb->dev);

> > +	BUG_ON(!net);
> > +	ipvs = net->ipvs;
> >  	mutex_lock(&__ip_vs_mutex);
> >  	for (i = 0; i < IP_VS_SVC_TAB_SIZE; i++) {
> > -		list_for_each_entry(svc, &ip_vs_svc_table[i], s_list) {
> > +		list_for_each_entry(svc, &ipvs->ctl_svc_table[i], s_list) {
> >  			if (++idx <= start)
> >  				continue;
> >  			if (ip_vs_genl_dump_service(skb, svc, cb) < 0) {
>
> [ snip ]
> --


--
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
