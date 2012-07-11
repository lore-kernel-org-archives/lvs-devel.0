From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net] ipvs: fix oops in ip_vs_dst_event on rmmod
Date: Wed, 11 Jul 2012 09:52:01 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1207110943330.1758@ja.ssi.bg>
References: <1341682211-4751-1-git-send-email-ja@ssi.bg> <20120710084629.GB27117@verge.net.au> <alpine.LFD.2.00.1207102230360.1882@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1207102230360.1882@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Tue, 10 Jul 2012, Julian Anastasov wrote:

> On Tue, 10 Jul 2012, Simon Horman wrote:
> 
> > On Sat, Jul 07, 2012 at 08:30:11PM +0300, Julian Anastasov wrote:
> > > 	After commit 39f618b4fd95ae243d940ec64c961009c74e3333 (3.4)
> > > "ipvs: reset ipvs pointer in netns" we can oops in
> > > ip_vs_dst_event on rmmod ip_vs because ip_vs_control_cleanup
> > > is called after the ipvs_core_ops subsys is unregistered and
> > > net->ipvs is NULL. Fix it by exiting early from ip_vs_dst_event
> > > if ipvs is NULL. It is safe because all services and dests
> > > for the net are already freed.
> > 
> > Hi Julian,
> > 
> > have you observed this oops or is it theoretical?
> > I ask because it effects if I should submit this change for
> > inclusion in 3.5 and 3.4-stable or just queue it up for 3.6.
> 
> 	Yes, oops happened to me. I'm not sure how I missed
> it while creating the mentioned change. Please, queue it
> for stable kernels.

	I now see why I didn't noticed it.

commit 7d3d43dab4e978d8d9ad1acf8af15c9b1c4b0f0f
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Fri Apr 6 15:33:35 2012 +0000

    net: In unregister_netdevice_notifier unregister the netdevices.

	It seems I tested with tree without this change,
there is 18-19 days gap. It oopses because now on
unregister_netdevice_notifier we get NETDEV_UNREGISTER.
At least, we now know the reason...

> > >  1 files changed, 3 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> > > index dd811b8..b4a21d9 100644
> > > --- a/net/netfilter/ipvs/ip_vs_ctl.c
> > > +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> > > @@ -1521,11 +1521,12 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
> > >  {
> > >  	struct net_device *dev = ptr;
> > >  	struct net *net = dev_net(dev);
> > > +	struct netns_ipvs *ipvs = net_ipvs(net);
> > >  	struct ip_vs_service *svc;
> > >  	struct ip_vs_dest *dest;
> > >  	unsigned int idx;
> > >  
> > > -	if (event != NETDEV_UNREGISTER)
> > > +	if (event != NETDEV_UNREGISTER || !ipvs)
> > >  		return NOTIFY_DONE;
> > >  	IP_VS_DBG(3, "%s() dev=%s\n", __func__, dev->name);
> > >  	EnterFunction(2);
> > > @@ -1551,7 +1552,7 @@ static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
> > >  		}
> > >  	}
> > >  
> > > -	list_for_each_entry(dest, &net_ipvs(net)->dest_trash, n_list) {
> > > +	list_for_each_entry(dest, &ipvs->dest_trash, n_list) {
> > >  		__ip_vs_dev_reset(dest, dev);
> > >  	}
> > >  	mutex_unlock(&__ip_vs_mutex);
> > > -- 
> > > 1.7.3.4

Regards

--
Julian Anastasov <ja@ssi.bg>
