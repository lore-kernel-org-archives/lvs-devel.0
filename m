From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [PATCH 3/3] IPVS: init and cleanup restructuring.
Date: Wed, 20 Apr 2011 12:41:49 +0200
Message-ID: <201104201241.50176.hans@schillstrom.com>
References: <1303226705-29178-1-git-send-email-hans@schillstrom.com> <1303226705-29178-3-git-send-email-hans@schillstrom.com> <alpine.LFD.2.00.1104200207340.1724@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1104200207340.1724@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: horms@verge.net.au, ebiederm@xmission.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans.schillstrom@ericsson.com

On Wednesday, April 20, 2011 01:19:38 Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 19 Apr 2011, Hans Schillstrom wrote:
> 
> > This patch tries to restore the initial init and cleanup
> > sequences that was before name space patch.
> > 
> > The number of calls to register_pernet_device have been
> > reduced to one for the ip_vs.ko
> > Schedulers still have their own calls.
> > 
> > This patch adds a function __ip_vs_service_cleanup()
> > and a throttle or actually on/off switch for
> > the netfilter hooks.
> > 
> > The nf hooks will be enabled when the first service is loaded
> > and disabled when the last service is removed or when a
> > name space exit starts.
> 
> 	For me using _net suffix is more clear compared
> to __ prefix for the pernet methods.
> 
Sure I'll do that.

> 	For ip_vs_in: may be we can move the check here:
> 
> +	net = skb_net(skb);
> +	if (net->ipvs->throttle)
> +		return NF_ACCEPT;
>  	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
>  
>  	/* Bad... Do not break raw sockets */

Done

> 
> 	It will save such checks later in ICMP funcs. But this
> throttle idea looks dangerous for cleanup. It does not use RCU.
> The readers can cache the 0 in throttle for long time.
> May be by using register_pernet_device we are in list with other
> devices and it is still possible some device used by
> our dst_cache to be unregistered before IPVS or we to be
> unregistered before such device and some race with throttle
> to happen. throttle is good when enabling traffic with
> the first virtual service, later it can slowly stop the traffic
> but we can not rely on it during netns cleanup.

OK , I will revert back to register_pernet_subsys(),
and use one single register_pernet_device()  exit hook for :
 - the throttle to disable traffic
 - stop the kernel threads.

> 
> 	So, there are 2 problems with the devices:
> 
> - if we use _device pernet registration we can see packets
> in our netns during cleanup. I assume this is possible
> when IPVS is unregistered before such devices.
> 
> - dests can cache dst and to hold the device after it is
> unregistered in netns, obviously for very short time until
> IPVS is later unregistered from netns. And for long time
> if device is unregistered but netns remains.
> 
> 	Also, in most of the cases svc->refcnt is above 0 because
> dests can be in trash list. You should be lucky to delete the
> service without any connections, only then ip_vs_svc_unhash can
> see refcnt == 0.
> 
> 	So, may be we have to use register_pernet_subsys (not
> _device). We need just to register notifier with
> register_netdevice_notifier and to catch NETDEV_UNREGISTER,
> so that if any dest uses this device we have to release the dst:
> 
I made a quick test of the concept and it seems to work, 
(A mix of new and old connections at 1GB/s into 4 namespaces when killing them all)

> 	- lock mutex
> 	- for every dest (also in trash):
> 	spin_lock_bh(&dest->dst_lock);
> 	if (dest->dst_cache && dest->dst_cache->dev == unregistered_dev)
> 		ip_vs_dst_reset(dest);
> 	spin_unlock_bh(&dest->dst_lock);


Here is a what i did

static inline void
__ip_vs_dev_reset(struct ip_vs_dest *dest, struct net_device *dev)
{
	spin_lock_bh(&dest->dst_lock);
	if (dest->dst_cache && dest->dst_cache->dev == dev)
		ip_vs_dst_reset(dest);
	spin_unlock_bh(&dest->dst_lock);
}

static void ip_vs_svc_reset(struct ip_vs_service *svc, struct net_device *dev)
{
	struct ip_vs_dest *dest;

	list_for_each_entry(dest, &svc->destinations, n_list) {
		__ip_vs_dev_reset(dest, dev);
	}
}

static int ip_vs_dst_event(struct notifier_block *this, unsigned long event,
			    void *ptr)
{
	struct net_device *dev = ptr;
	struct net *net = dev_net(dev);
	struct ip_vs_service *svc;
	struct ip_vs_dest *dest;
	unsigned int idx;

	if (event != NETDEV_UNREGISTER)
		return NOTIFY_DONE;

	EnterFunction(2);
	mutex_lock(&__ip_vs_mutex);
	for (idx = 0; idx<IP_VS_SVC_TAB_SIZE; idx++) {
		write_lock_bh(&__ip_vs_svc_lock);
		list_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
			if (net_eq(svc->net, net))
				ip_vs_svc_reset(svc, dev);
		}
		list_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
			if (net_eq(svc->net, net))
				ip_vs_svc_reset(svc, dev);
		}
		write_unlock_bh(&__ip_vs_svc_lock);
	}

	list_for_each_entry(dest, &net_ipvs(net)->dest_trash, n_list) {
		__ip_vs_dev_reset(dest, dev);
	}
	mutex_unlock(&__ip_vs_mutex);
	LeaveFunction(2);
	return NOTIFY_DONE;
}

static struct notifier_block ip_vs_dst_notifier = {
	.notifier_call = ip_vs_dst_event,
};


int __init ip_vs_control_init(void)
...
	at the end
	ret = register_netdevice_notifier(&ip_vs_dst_notifier);
...

and an unregister_ of course.


> 
> 	There are many examples for this, eg. net/core/fib_rules.c
> Then we are sure on cleanup we can not see traffic for our net
> because all devices are unregistered before us. We don't have
> to rely on throttle to stop the traffic during cleanup. And
> we do not hold devices after NETDEV_UNREGISTER.
> 
> 	I can prepare such patch but in next days. We need such
> code anyways because the dests can hold such dsts when no
> traffic is present and we can see again this "waiting for %s" ...
> message.
> 
> 	throttle still can be used but now it can not stop
> the traffic if connections exist.
> 
> 	For __ip_vs_service_cleanup: it still has to use mutex.

OK I will try to use unlock methods, if it doesn't work use the mutex.

> Or we can avoid it by introducing ip_vs_unlink_service_nolock:
> ip_vs_flush will look like your __ip_vs_service_cleanup and
> will call ip_vs_unlink_service_nolock. ip_vs_unlink_service_nolock
> will be called by ip_vs_flush and by ip_vs_unlink_service.
> You can try such changes, if not, I'll prepare some patches
> after 2-3 days.
> 

Regards
Hans
