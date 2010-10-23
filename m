From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [rfc v2 00/10] ipvs network name space (netns) aware
Date: Sat, 23 Oct 2010 12:04:06 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010231147540.1949@ja.ssi.bg>
References: <20101022200934.822223308@joe.akashicho.tokyo.vergenet.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101022200934.822223308@joe.akashicho.tokyo.vergenet.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Hans Schillstrom <hans.schillstrom@ericsson.com>, Daniel Lezcano <daniel.lezcano@free.fr>, Wensong Zhang <wensong@linux-vs.org>


 	Hello,

On Fri, 22 Oct 2010, Simon Horman wrote:

> Hi Hans,
>
> this is a re-base of your patch-set against the current nf-next-2.6 tree,
> which includes all the changes currently queued for 2.6.37-rc1 and nothing
> else.
>
> I also removed the BUG_ON() statements and incorported various
> suggestions that were made in response to your original post.
>
> It is compile tested only (partly because I am in an areoplane).
>
> I have not re-split the patches into logical units.
> Having worked with these patches a bit, I really think
> that split needs to occur.
>
> For the benefit of others, your original cover email is below,
> updated as appropriate.
>
> -----
>
> This patch series adds network name space (netns) support to the LVS.
>
> REVISION
>
> This is version 2
>
> OVERVIEW
>
> The patch doesn't remove or add any functionality except for netns.
> For users that don't use network name space (netns) this patch is
> completely transparent.
>
> No it's possible to run LVS in a Linux container (see lxc-tools)
> i.e.  a light weight virtualization. For example it's possible to run
> one or several lvs on a real server in their own network name spaces.
>> From the LVS point of view it looks like it runs on it's own machine.
>
> IMPLEMENTATION
> Basic requirements for netns awareness
> - Global variables has to be moved to dyn. allocated memory.
>
> Most global variables now resides in a struct ipvs { } in netns/ip_vs.h.
> What is moved and what is not ?
>
> Some cache aligned locks are still in global, module init params and some debug_level.
>
> Algorithm files they are untouched.
>
> QUESTIONS
> Drop rate in ip_vs_ctl per netns or grand total ?

 	If different containers can have different memory limit
we should restrict their memory with per-ns limits
and variables, i.e. DoS logic per-ns.

> Should more lock variables be moved (or less) ?
>
> Include files,
> A new file added include/net/netns/ip_vs.h containg all netns specific data.
> include/net/net_namespce.h, pointer to "struct ipvs"  added.
> include/net/ip_vs.h a new struct added, and many prototypes changed.
>
> * ip_vs_core.c
> All netns init origins from this file - ip_vs_init()
>
> * ip_vs_conn.c
> Lock array for conn table is kept due to performance,
> (or am I wrong here ?).
> "static struct ip_vs_aligned_lock
> __ip_vs_conntbl_lock_array[CT_LOCKARRAY_SIZE] __cacheline_aligned;"
>
> * ip_vs_ctl.c
> drop_ rate is still global

 	May be should be per-ns

> TESTING
> This patch have been running for a month now with three LVS/machine
> one in root name-space and two in other name-space.
> Both IPv4 & IPv6 have been tested in all three modes DR/TUN and NAT
> Only a limited set of algos have been used (read rr).
>
> Backup have been there all the time and a switch has been performed a couple of times.
>
> Not tested yet:
> Drop level, DOS,  schedulers, performance ....
> Netns exit after usage of LVS (due to a bug in netdev/ipip somewhere tunl0 and

 	Main points:

- May be we have to use global table for connections and to
filter by cp->net

- We have to use ip_vs_proto_data_get in many places where
pp = ip_vs_proto_get(protocol) was used. Then when pp
is needed we can use pd->pp->XXX

- tcp_timeout_change should work with the new struct ip_vs_proto_data
 	so that tcp_state_table will go to pd->state_table
 	and set_tcp_state will get pd instead of pp

- ipvs_skbnet must be used only for traffic after the
 	check for !skb_dst(skb)

 	Other notes:

rfc v2 01/10:
 	set_state_timeout: infrastructure is there but never added
 		to ipvsadm. If we keep it, it should be per-ns
 	Functions that can use cp->net and do not need argument:
 		ip_vs_conn_fill_cport
 		ip_vs_tcp_conn_listen
 		ip_vs_bind_app?
 		ip_vs_unbind_app

rfc v2 02/10

rfc v2 03/10
 	ip_vs_conn_hash: use cp->net
 	ip_vs_conn_unhash: use cp->net
 	ip_vs_conn_fill_param_proto: use ipvs_skbnet(skb)
 	ip_vs_conn_fill_cport: use cp->net
 	ip_vs_try_bind_dest: use cp->net
 	ip_vs_check_template: use ct->net
 	ip_vs_conn_new: assign cp->net from p->net early before
 		using it for ip_vs_bind_app, etc
 	Why not using global ip_vs_conn_tab[], we have cp->net

rfc v2 04/10
 	ip_vs_in_stats: use cp->net
 	ip_vs_out_stats: use cp->net
 	ip_vs_conn_stats: use cp->net
 	ip_vs_sched_persist: use ipvs_skbnet
 	ip_vs_schedule: use ipvs_skbnet
 	handle_response_icmp: use ipvs_skbnet
 	handle_response: use cp->net
 	ip_vs_out: assign net with ipvs_skbnet after
 		'if (unlikely(!skb_dst(skb)))' check
 	ip_vs_in: assign net with ipvs_skbnet before if-block for
 		ip_vs_in_icmp_v6 after skb_dst check
 	ip_vs_sync_conn: use cp->net

rfc v2 05/10
 	ipvs_skbnet will be used only from skbs containing traffic,
 		i.e. replace dev_net(skb->dev) with ipvs_skbnet(skb)
 		when used for traffic

rfc v2 06/10
 	sysctl_drop_entry is per net but update_defense_level
 		changes global ip_vs_dropentry?
 	ip_vs_protocol_timeout_change: where is net? It must call
 		pp->timeout_change for every struct ip_vs_proto_data
 	ip_vs_genl_dump_services: DO NOT USE ipvs_skbnet, may be
 		from skb->sk? sock_net(skb->sk) ?
 	ip_vs_genl_dump_dests: DO NOT USE ipvs_skbnet
 	ip_vs_genl_set_cmd: DO NOT USE ipvs_skbnet
 	ip_vs_genl_get_cmd: DO NOT USE ipvs_skbnet

rfc v2 07/10

rfc v2 08/10
 	ip_vs_ftp_out: use ipvs_skbnet
 	ip_vs_ftp_in: use ipvs_skbnet

rfc v2 09/10
 	register_ip_vs_proto_netns result is not checked in
 		__ip_vs_protocol_init
 	ah_esp_conn_in_get: use ipvs_skbnet
 	ah_esp_conn_out_get: use ipvs_skbnet
 	sctp_conn_schedule: use ipvs_skbnet
 	set_sctp_state: use cp->net
 	sctp_app_conn_bind: use cp->net
 	tcp_conn_schedule: use ipvs_skbnet
 	set_tcp_state: use cp->net
 	tcp_app_conn_bind: use cp->net
 	ip_vs_tcp_conn_listen: use cp->net
 	udp_conn_schedule: use ipvs_skbnet
 	udp_app_conn_bind: use cp->net
 	udp_state_transition: use cp->net

rfc v2 10/10
 	ip_vs_sync_conn: use cp->net
 	ip_vs_nat_xmit*: ip_vs_conn_fill_cport should use cp->net

Regards

--
Julian Anastasov <ja@ssi.bg>
