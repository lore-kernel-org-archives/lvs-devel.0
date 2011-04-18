From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: unregister_netdevice: waiting for lo to become free. Usage count = 8
Date: Mon, 18 Apr 2011 12:43:30 +0200
Message-ID: <201104181243.30613.hans@schillstrom.com>
References: <201104150901.47214.hans@schillstrom.com> <alpine.LFD.2.00.1104152229450.1730@ja.ssi.bg> <201104180810.27198.hans@schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <201104180810.27198.hans@schillstrom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

Hello
On Monday, April 18, 2011 08:10:26 Hans Schillstrom wrote:
> On Friday, April 15, 2011 22:11:32 Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Fri, 15 Apr 2011, Hans Schillstrom wrote:
> > 
> > > Hello Julian
> > > 
> > > I'm trying to fix the cleanup process when a namespace get "killed",
> > > which is a new feature for ipvs. However an old problem appears again
> > > 
> > > When there has been traffic trough ipvs where the destination is unreachable
> > > the usage count on loopback dev increases one for every packet....
[snip]

> > 
> > > Do you have an idea why  this happens in the ipvs case ?
> > 
> > 	Do you see with debug level 3 the "Removing destination"
> > messages. Only real servers can hold dest->dst_cache reference
> > for dev which can be a problem because the real servers are not
> > deleted immediately - on traffic they are moved to trash
> > list. 

Actually I forgot to tell there is a need for a
ip_vs_service_cleanup() due to above.
Do you see any drawbacks with it ?

/*
 *	Delete service by {netns} in the service table.
 */
static void ip_vs_service_cleanup(struct net *net)
{
	unsigned hash;
	struct ip_vs_service *svc, *tmp;

	EnterFunction(2);
	/* Check for "full" addressed entries */
	for (hash = 0; hash<IP_VS_SVC_TAB_SIZE; hash++) {
		write_lock_bh(&__ip_vs_svc_lock);
		list_for_each_entry_safe(svc, tmp, &ip_vs_svc_table[hash],
					 s_list) {
			if (net_eq(svc->net, net)) {
				ip_vs_svc_unhash(svc);
				__ip_vs_del_service(svc);
			}
		}
		list_for_each_entry_safe(svc, tmp, &ip_vs_svc_fwm_table[hash],
					 f_list) {
			if (net_eq(svc->net, net)) {
				ip_vs_svc_unhash(svc);
				__ip_vs_del_service(svc);
			}
		}
		write_unlock_bh(&__ip_vs_svc_lock);
	}
	LeaveFunction(2);
}

Called just after the __ip_vs_control_cleanup_sysctl()

static void __net_exit __ip_vs_control_cleanup(struct net *net)
{
	struct netns_ipvs *ipvs = net_ipvs(net);

	ip_vs_trash_cleanup(net);
	ip_vs_stop_estimator(net, &ipvs->tot_stats);
	__ip_vs_control_cleanup_sysctl(net);
	ip_vs_service_cleanup(net);
	proc_net_remove(net, "ip_vs_stats_percpu");
	proc_net_remove(net, "ip_vs_stats");
	proc_net_remove(net, "ip_vs");
	free_percpu(ipvs->tot_stats.cpustats);
}


> > But ip_vs_trash_cleanup() should remove any left
> > structures. You should check in debug that all servers are
> > deleted. If all real server structures are freed but
> > problem remains we should look more deeply in the
> > dest->dst_cache usage. DR or NAT is used?
> 
> I have got some wise words from Eric, 
> i.e. moved all ipvs register/unregister from subsys to device 
> that solved plenty of my issues
> (Thanks Eric)
> 
> I'll will post a Patch later on regarding this.
> 
> > 
> > 	I assume cleanup really happens in this order:
> > 
> > ip_vs_cleanup():
> > 	nf_unregister_hooks()
> 
> This will not happens in a namespace since nf_unregister_hooks() is not per netns.
> We might need a flag but I don't think so, further test will show....
> 
> > 	...
> > 	ip_vs_conn_cleanup()
> > 	...
> > 	ip_vs_control_cleanup()
> > 
> 
Regards
Hans
