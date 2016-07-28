From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC] Routing loop handling in IP VS...
Date: Thu, 28 Jul 2016 23:21:41 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1607282228220.1949@ja.home.ssi.bg>
References: <1469697820.8467.11.camel@oc0624138382>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1469697820.8467.11.camel@oc0624138382>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dwip N. Banerjee" <dwip@linux.vnet.ibm.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Thu, 28 Jul 2016, Dwip N. Banerjee wrote:

> Problem:
> 
> A problem has been identified in a cluster environment using IPVS with 
> Direct Routing where multiple appliances can end up in the "active 
> forwarder/distributor" state simultaneously. As an "active distributor" 
> the appliance balances workload by forwarding packets to the group
> members. 
> Because "active distributors" also consider each other as group members 
> available to receive forwarded packets (i.e. the load balancers also
> front as real servers and are working in a HA mode with active/backup
> roles), the distributors may forward the same packet to each other
> forming a routing loop. 
> 
> While the immediate trigger in the aforesaid scenario is CPU starvation
> caused by lock contention leading to an active/active scenario (i.e. two
> instances both acting as "active" virtualservers), similar route loops
> in an ip_vs installation is possible through other means as well (e.g.
> http://marc.info/?l=linux-virtual-server&m=136008320907330&w=2).

	In some cases backup_only=1 can help, not if
modes do not change in time and both servers are set as
masters.

> As it stands now, there is no mitigation/damping mechanism available in
> ip_vs to limit the impact of the routing loop as described above. When
> the scenario occurs it leads to starvation and requires administrative
> network action on the cluster controller to terminate the routing loop
> and recover.
> 
> Although the situation described above was observed in a Virtual Server 
> with Direct Routing, it is just as applicable in Virtual Servers via NAT
> and IP Tunneling.
> 
> ip_vs does not decrement ip_ttl as standard routers do and as a result 
> does not have anything to protect itself from re-forwarding the same 
> packet an unbounded number of times. Standard IP routers always 
> decrement the IP TTL as required by rfc791, but ip_vs does not even 
> though ip_vs is acting as a specialized kind of IP router.
> 
> In a scenario where two ip_vs instances are forwarding to each other 
> (which admittedly should not happen but is not impossible, as 
> illustrated above), there is no way for the system to recover due to the
> persistence of the  route loop. The two hosts will forward the same 
> packet between each other at speed.
> 
> Test Case:
> It is possible to configure two ip_vs instances to forward to each other
> and cause it to starve the network.  The starvation itself makes it 
> impossible to recover from this situation since the communication 
> channel is blocked by the forwarding loop.
> 
> Proposed fix:
> Sample fix for Linux v4.7 which decrements the TTL when forwarding, is
> for the 
> Direct Routing Transmitter. 
> 
> 
> 
> ============================================================================
> 
> diff -Naur linux_4.7/net/netfilter/ipvs/ip_vs_xmit.c
> linux_ipvs_patch/net/netfilter/ipvs/ip_vs_xmit.c
> --- linux_4.7/net/netfilter/ipvs/ip_vs_xmit.c	2016-07-28
> 00:01:10.040974435 -0500
> +++ linux_ipvs_patch/net/netfilter/ipvs/ip_vs_xmit.c	2016-07-28
> 00:01:42.900977155 -0500
> @@ -1156,10 +1156,18 @@
>  	      struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
>  {
>  	int local;
> +	struct iphdr  *iph = ip_hdr(skb);
>  
>  	EnterFunction(10);
>  
>  	rcu_read_lock();
> +	if (iph->ttl <= 1) {
> +		/* Tell the sender its packet died... */
> +		__IP_INC_STATS(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_INHDRERRORS);
> +		icmp_send(skb, ICMP_TIME_EXCEEDED, ICMP_EXC_TTL, 0);
> +		goto tx_error;
> +	}
> +
>  	local = __ip_vs_get_out_rt(cp->ipvs, cp->af, skb, cp->dest,
> cp->daddr.ip,
>  				   IP_VS_RT_MODE_LOCAL |
>  				   IP_VS_RT_MODE_NON_LOCAL |
> @@ -1171,7 +1179,10 @@
>  		return ip_vs_send_or_cont(NFPROTO_IPV4, skb, cp, 1);
>  	}
>  
> -	ip_send_check(ip_hdr(skb));
> +	/* Decrease ttl */
> +	ip_decrease_ttl(iph);
> +
> +	ip_send_check(iph);

	OK, lets add TTL decrease. We write the IP header anyways,
so I guess the CPU write-back caching will hide the extra write
operation.

	Such change should also include:

- IPv6 solution: code from ip6_forward

- DR, TUN, ip_vs_bypass_xmit* and others that call
	__ip_vs_get_out_rt* funcs, this includes ICMP packets.
	Even better, hide the ttl <= 1 check in
	__ip_vs_get_out_rt* after the 'if (local) ... return local;'
	and before the MTU checks. ensure_mtu_is_adequate is
	a good example. As result, the ttl <= 1 should
	work only for the '!local' case.

- No need for !ip_vs_iph_icmp(ipvsh) checks as done in 
	ensure_mtu_is_adequate, icmp_send is smart enough
	to avoid sending ICMP to ICMP error.

- skb_make_writable guard as done in ip_vs_nat_xmit to ensure
	our change does not propagate to cloned packets,
	eg. causing tcpdump to see the decreased TTL.

>  	/* Another hack: avoid icmp_send in ip_fragment */
>  	skb->ignore_df = 1;
> 
> ==================================================================================
> 
> p.s. A similar fix may be made to the other modes too ( NAT, IP
> Tunneling, 
> ICMP Package transmitter).

	Yep. Let me know if you prefer to play and provide
a complete patch.

Regards

--
Julian Anastasov <ja@ssi.bg>
