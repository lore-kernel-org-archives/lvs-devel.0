From: Julian Anastasov <ja@ssi.bg>
Subject: Re: unregister_netdevice: waiting for lo to become free. Usage count
 = 8
Date: Tue, 19 Apr 2011 00:12:27 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1104182316060.1481@ja.ssi.bg>
References: <201104150901.47214.hans@schillstrom.com> <alpine.LFD.2.00.1104152229450.1730@ja.ssi.bg> <201104180810.27198.hans@schillstrom.com> <201104181243.30613.hans@schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201104181243.30613.hans@schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>


	Hello,

On Mon, 18 Apr 2011, Hans Schillstrom wrote:

> Actually I forgot to tell there is a need for a
> ip_vs_service_cleanup() due to above.
> Do you see any drawbacks with it ?

	May be ip_vs_service_cleanup() should call only
ip_vs_flush(), under __ip_vs_mutex.

> /*
>  *	Delete service by {netns} in the service table.
>  */
> static void ip_vs_service_cleanup(struct net *net)
> {
> 	unsigned hash;
> 	struct ip_vs_service *svc, *tmp;
> 
> 	EnterFunction(2);
> 	/* Check for "full" addressed entries */
> 	for (hash = 0; hash<IP_VS_SVC_TAB_SIZE; hash++) {
> 		write_lock_bh(&__ip_vs_svc_lock);
> 		list_for_each_entry_safe(svc, tmp, &ip_vs_svc_table[hash],
> 					 s_list) {
> 			if (net_eq(svc->net, net)) {
> 				ip_vs_svc_unhash(svc);
> 				__ip_vs_del_service(svc);
> 			}
> 		}
> 		list_for_each_entry_safe(svc, tmp, &ip_vs_svc_fwm_table[hash],
> 					 f_list) {
> 			if (net_eq(svc->net, net)) {
> 				ip_vs_svc_unhash(svc);
> 				__ip_vs_del_service(svc);
> 			}
> 		}
> 		write_unlock_bh(&__ip_vs_svc_lock);
> 	}
> 	LeaveFunction(2);
> }
> 
> Called just after the __ip_vs_control_cleanup_sysctl()

	Hm, no. ip_vs_service_cleanup() should be called
by ip_vs_cleanup() before or after nf_unregister_hooks().
The rule is that ip_vs_flush() should be called before
ip_vs_conn_flush() because after ip_vs_flush() no more
connections can be created and even if hooks are still
registered the packets can not create conns in the netns. Then
ip_vs_conn_flush() will remove all existing connections and
ip_vs_control_cleanup() can remove all real servers with
ip_vs_trash_cleanup(). I mean, per-netns calls.

	Also, may be all code that was called in old
kernels by ip_vs_cleanup() should be now called by
__ip_vs_cleanup(net), i.e. we can preserve the needed order
of all functions but now also per-netns. For example, for
ip_vs_ctl.c ip_vs_control_init() can remain as global but it
should not register ipvs_control_ops. Then we
can rename __ip_vs_control_init to ip_vs_control_init_net()
and to call it from __ip_vs_init(). I.e. all such files
will have global function and also _init_net and
_cleanup_net. Now there are many register_pernet_subsys()
calls and I'm not sure we preserve the needed order for
cleanup. Are the ->exit methods called in reverse order?
I don't see it in ops_exit_list() and we can not rely
on such registration order. I think, ip_vs_init() should
call global functions as now but __ip_vs_init() and
__ip_vs_cleanup() should call the _net methods in right
order.

Regards

--
Julian Anastasov <ja@ssi.bg>
