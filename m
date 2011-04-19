From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 3/3] IPVS: init and cleanup restructuring.
Date: Wed, 20 Apr 2011 02:19:38 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1104200207340.1724@ja.ssi.bg>
References: <1303226705-29178-1-git-send-email-hans@schillstrom.com> <1303226705-29178-3-git-send-email-hans@schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1303226705-29178-3-git-send-email-hans@schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: horms@verge.net.au, ebiederm@xmission.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans.schillstrom@ericsson.com


	Hello,

On Tue, 19 Apr 2011, Hans Schillstrom wrote:

> This patch tries to restore the initial init and cleanup
> sequences that was before name space patch.
> 
> The number of calls to register_pernet_device have been
> reduced to one for the ip_vs.ko
> Schedulers still have their own calls.
> 
> This patch adds a function __ip_vs_service_cleanup()
> and a throttle or actually on/off switch for
> the netfilter hooks.
> 
> The nf hooks will be enabled when the first service is loaded
> and disabled when the last service is removed or when a
> name space exit starts.

	For me using _net suffix is more clear compared
to __ prefix for the pernet methods.

	For ip_vs_in: may be we can move the check here:

+	net = skb_net(skb);
+	if (net->ipvs->throttle)
+		return NF_ACCEPT;
 	ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 
 	/* Bad... Do not break raw sockets */

	It will save such checks later in ICMP funcs. But this
throttle idea looks dangerous for cleanup. It does not use RCU.
The readers can cache the 0 in throttle for long time.
May be by using register_pernet_device we are in list with other
devices and it is still possible some device used by
our dst_cache to be unregistered before IPVS or we to be
unregistered before such device and some race with throttle
to happen. throttle is good when enabling traffic with
the first virtual service, later it can slowly stop the traffic
but we can not rely on it during netns cleanup.

	So, there are 2 problems with the devices:

- if we use _device pernet registration we can see packets
in our netns during cleanup. I assume this is possible
when IPVS is unregistered before such devices.

- dests can cache dst and to hold the device after it is
unregistered in netns, obviously for very short time until
IPVS is later unregistered from netns. And for long time
if device is unregistered but netns remains.

	Also, in most of the cases svc->refcnt is above 0 because
dests can be in trash list. You should be lucky to delete the
service without any connections, only then ip_vs_svc_unhash can
see refcnt == 0.

	So, may be we have to use register_pernet_subsys (not
_device). We need just to register notifier with
register_netdevice_notifier and to catch NETDEV_UNREGISTER,
so that if any dest uses this device we have to release the dst:

	- lock mutex
	- for every dest (also in trash):
	spin_lock_bh(&dest->dst_lock);
	if (dest->dst_cache && dest->dst_cache->dev == unregistered_dev)
		ip_vs_dst_reset(dest);
	spin_unlock_bh(&dest->dst_lock);

	There are many examples for this, eg. net/core/fib_rules.c
Then we are sure on cleanup we can not see traffic for our net
because all devices are unregistered before us. We don't have
to rely on throttle to stop the traffic during cleanup. And
we do not hold devices after NETDEV_UNREGISTER.

	I can prepare such patch but in next days. We need such
code anyways because the dests can hold such dsts when no
traffic is present and we can see again this "waiting for %s" ...
message.

	throttle still can be used but now it can not stop
the traffic if connections exist.

	For __ip_vs_service_cleanup: it still has to use mutex.
Or we can avoid it by introducing ip_vs_unlink_service_nolock:
ip_vs_flush will look like your __ip_vs_service_cleanup and
will call ip_vs_unlink_service_nolock. ip_vs_unlink_service_nolock
will be called by ip_vs_flush and by ip_vs_unlink_service.
You can try such changes, if not, I'll prepare some patches
after 2-3 days.

Regards

--
Julian Anastasov <ja@ssi.bg>
