From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [v2 PATCH 0/6] IPVS: init and cleanup.
Date: Thu, 21 Apr 2011 00:36:34 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1104210023240.1695@ja.ssi.bg>
References: <1303324434-14024-1-git-send-email-hans@schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1303324434-14024-1-git-send-email-hans@schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: horms@verge.net.au, ebiederm@xmission.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans.schillstrom@ericsson.com


	Hello,

On Wed, 20 Apr 2011, Hans Schillstrom wrote:

> This patch series handles exit from a network name space.
> 
> REVISION
> 
> This is version 2
> 
> OVERVIEW
> Basically there was three faults in the netns implementation.
> - Kernel threads hold devices and preventing an exit.
> - dst cache holds references to devices.
> - Services was not always released.
> 
> Patch 1 & 3 contains the functionality
>       4 renames funcctions
>       5 removes empty functions
>       6 Debuging.
> 
> IMPLEMENTATION
> - Avoid to increment the usage counter for kernel threads.
>   this is done in the first patch.
> - Patch 3 tries to restore the cleanup order.
>   Add NETDEV_UNREGISTER notification for dst_reset
> 
> >From Julian -
> "For __ip_vs_service_cleanup: it still has to use mutex.
> Or we can avoid it by introducing ip_vs_unlink_service_nolock:
> ip_vs_flush will look like your __ip_vs_service_cleanup and
> will call ip_vs_unlink_service_nolock. ip_vs_unlink_service_nolock
> will be called by ip_vs_flush and by ip_vs_unlink_service."
> 
> I will give above another try later on see if I can get it to work.
> Right now ip_vs_service_net_cleanup() seems to work.
> 
> 
> An netns exit could look like this
> IPVS: Enter: __ip_vs_dev_cleanup, net/netfilter/ipvs/ip_vs_core.c
> IPVS: stopping master sync thread 1286 ...
> IPVS: stopping backup sync thread 1294 ...
> IPVS: Leave: __ip_vs_dev_cleanup, net/netfilter/ipvs/ip_vs_core.c
> IPVS: Enter: ip_vs_dst_event, net/netfilter/ipvs/ip_vs_ctl.c line
> IPVS: Leave: ip_vs_dst_event, net/netfilter/ipvs/ip_vs_ctl.c line
> ...
> IPVS: Enter: ip_vs_dst_event, net/netfilter/ipvs/ip_vs_ctl.c line
> IPVS: Leave: ip_vs_dst_event, net/netfilter/ipvs/ip_vs_ctl.c line
> IPVS: Enter: ip_vs_service_net_cleanup, net/netfilter/ipvs/ip_vs_ctl.c
> IPVS: __ip_vs_del_service: enter
> IPVS: Moving dest 192.168.1.6:0 into trash, dest->refcnt=43450
> ...
> IPVS: Moving dest 192.168.1.3:0 into trash, dest->refcnt=43449
> IPVS: __ip_vs_del_service: enter
> IPVS: Removing destination 0/[2003:0000:0000:0000:0000:0002:0000:0006]:80
> ...
> IPVS: Removing destination 0/[2003:0000:0000:0000:0000:0002:0000:0003]:80
> IPVS: Removing service 0/[2003:0000:0000:0000:0000:0002:0004:0100]:80 usecnt=0
> IPVS: Leave: ip_vs_service_net_cleanup, net/netfilter/ipvs/ip_vs_ctl.c
> IPVS: Enter: ip_vs_control_net_cleanup, net/netfilter/ipvs/ip_vs_ctl.c
> IPVS: Removing service 80/0.0.0.0:0 usecnt=0
> IPVS: Leave: ip_vs_control_net_cleanup, net/netfilter/ipvs/ip_vs_ctl.c
> IPVS: ipvs netns 8 released

	Notes only about PATCH 3/6:

- I was worried that throttle was used during cleanup
with the idea to stop traffic. But as now it is only an
optimization to avoid traffic to spend cycles in IPVS
code I'll suggest to use it without atomic operations.
It is not fatal if some packet does not see the disabling
immediately. So, may be using 'if (net_ipvs(net)->enable)'
is enough.

As result, there is no need to disable traffic in
__ip_vs_dev_cleanup, it is going to stop during
_device cleanup anyways.

- Please move check for 'enable' in ip_vs_in() before
ip_vs_fill_iphdr, this is the preferred place:

+	net = skb_net(skb);
+	if (!net_ipvs(net)->enable)
+		return NF_ACCEPT;
	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);

Note that only ip_vs_in, ip_vs_out and ip_vs_forward_icmp*
need check for 'enable'. Then we can remove them from
ip_vs_in_icmp*

- As device can change its name space it was mandatory we
to add support for NETDEV_UNREGISTER. As we are using
_subsys pernet operations I expect we to see NETDEV_UNREGISTER
while the _device pernet methods are called, so before
our _subsys cleanup.

We can see in log that ip_vs_dst_event() is called before
ip_vs_service_net_cleanup, i.e. before our subsys cleanup.
net/core/dev.c uses register_pernet_device(&default_device_ops)
to call NETDEV_UNREGISTER* during _device cleanup and
to move devices to init_net. So, it should be safe
to rely on NETDEV_UNREGISTER event while we are subsys.

- __ip_vs_service_cleanup needs to call ip_vs_flush after
converting to ip_vs_unlink_service_nolock.

- For ip_vs_dst_event: I prefer to put everything in this
function, the ip_vs_svc_reset is not needed (name is not
good too). For example:

	struct ip_vs_dest *dest;
	unsigned int hash;

	mutex_lock(&__ip_vs_mutex);
	/* No need to use rs_lock, the mutex protects the list */
	for (hash = 0; hash < IP_VS_RTAB_SIZE; hash++) {
		list_for_each_entry(dest, &ipvs->rs_table[hash], d_list) {
			__ip_vs_dev_reset(dest, dev);
		}
	}

	/* The mutex protects the trash list */
	list_for_each_entry(dest, &ipvs->dest_trash, n_list) {
		__ip_vs_dev_reset(dest, dev);
	}

	mutex_unlock(&__ip_vs_mutex);

	No need to use __ip_vs_svc_lock or rs_lock because we
do not change the lists, __ip_vs_dev_reset has the needed
dst_cache locking (dst_lock). I assume we can safely use our
__ip_vs_mutex from netdevice notifier.

Regards

--
Julian Anastasov <ja@ssi.bg>
