From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH ipvs,v2 00/18] Support v6 real servers in v4 pools and
 vice versa
Date: Fri, 15 Aug 2014 15:53:49 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1408151540040.3192@ja.home.ssi.bg>
References: <1408073021-24007-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1408073021-24007-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com


	Hello,

On Thu, 14 Aug 2014, Alex Gartrell wrote:

> At Facebook we use ipip forwarding to deliver packets from our layer 4 ipvs
> load balancers to our layer 7 proxies.  Today these layer 7 proxies are all
> dual stacked, so we can simply send v4 over v4 and v6 over v6.  In the
> future, we're going to have v6-only layer 7 load balancers (no internal v4
> address).  To deal with this, we'll forward v4 packets in v6 tunnels.  This
> patchset introduces the necessary functionality into ipvs.
> 
> The noteworthy limitation of this is that it is not compatible with state
> synchronization, so great care is taken to keep these things mutually
> exclusive.
> 
> This patchset includes changes that add an additional netlink attribute to
> destinations and changes that plumb the destination address family through
> parts of the code where it was assumed that it was the same as the service.
> Finally, there's a change that updates the transmit functions for tunneling
> to share common code and support v4 in v6 and vice versa.
> 
> Changes for v2:
> 
> Introduced crosses_local_route_boundary and update_pmtu functions and
> conditionally do the ip_hdr operations.  The latter means that df will be
> effectively zero when we forward an ipv6 packet over an ipv4 tunnel.
> 
> Additionally, I addressed Julian's other statements.
> 
> Alex Gartrell (9):
>   ipvs: Pass destination address family to ip_vs_trash_get_dest
>   ipvs: Supply destination address family to ip_vs_conn_new
>   ipvs: maintain a mixed_address_family_dest count
>   ipvs: prevent mixing heterogeneous pools and synchronization
>   ipvs: Supply skb_af to out_rt* functions
>   ipvs: Pull out crosses_local_route_boundary logic
>   ipvs: Pull out update_pmtu code
>   ipvs: Only do ip_hdr operations in *out_rt when skb_af is AF_INET
>   ipvs: support ipv4 in ipv6 and ipv6 in ipv4 tunnel forwarding
> 
> Julian Anastasov (9):
>   ipvs: address family of LBLC entry depends on svc family
>   ipvs: address family of LBLCR entry depends on svc family
>   ipvs: use correct address family in DH logs
>   ipvs: use correct address family in LC logs
>   ipvs: use correct address family in NQ logs
>   ipvs: use correct address family in RR logs
>   ipvs: use correct address family in SED logs
>   ipvs: use correct address family in SH logs
>   ipvs: use correct address family in WLC logs

	Great, here are some comments from me:

- as some patches are missing I'm not sure if some
of my notes for cp->af usage are addressed, eg. in
set_tcp_state.

Patch 1:
	- I guess this patch depends on patch 1 and 2 from v1, they are
	now missing. This patch looks like a fixed patch 3 from v1.

Patch 2:
	- looks ok

Patch 3:
	- old_af and new_af are not needed anymore

Patch 4:
	- it would be logically correct to take out the
	/* Temporary for consistency */ check and the
	IP_VS_CONN_F_TUNNEL check after
	/* Which connection types do we support? */ into another
	patch, not part of this patch. May be it can follow
	this patch or even it should be the last patch in this patchset.
	As result, current patch will include only the restriction
	for sync protocol and the last patch will enable the
	new feature.

Patch 5:
	- it is not very good to just add unused args to funcs,
	may be we should mix patch 5 and 6?

Patch 6:
	- scripts/checkpatch.pl warnings, may be renaming
	source_is_loopback to local_src can help. Make sure
	we do not exceed 80 columns.

	- in crosses_local_route_boundary() the check for
	old_rt_is_local should be inverted, it should be:

	if (!rt_mode_allow_redirect && !old_rt_is_local)

	- In the "We are crossing local and non-local addresses" message
	we can safely print the daddr because the family is constant for
	the function. We will not do it for source address because
	it is more complex (depends on skb family).

Patch 7:
	- I think, it should be safe to call
	skb_dst(skb)->ops->update_pmtu(skb_dst(skb), sk, NULL, mtu);
	in maybe_update_pmtu(), without any family checks.

	- scripts/checkpatch.pl warnings

Patch 8:
	- it looks like now icmp_send* calls should depend on skb_af,
	not on dest af. It means both __ip_vs_get_out_rt and
	__ip_vs_get_out_rt_v6 should use some new common function that
	will do "frag needed" checks for AF_INET skbs. It will also
	include the __mtu_check_toobig_v6 call, the IPv6 specific part.
	Then we have to provide 'ipvsh' as arg to __ip_vs_get_out_rt,
	it is already provided to __ip_vs_get_out_rt_v6.

	- "frag needed for %pI4" looks correct because df is set only
	for IPv4.

Patch 9:
	- we can use skb_af instead of version, right?

	- using of out_skb in ip_vs_prepare_tunneled_skb leads to
	errors (example: IPv6), better to use new_skb and to work
	only with skb.

	- ERR_PTR(ENOMEM) should be ERR_PTR(-ENOMEM)

	- the old iptunnel_handle_offloads call still remains in
	ip_vs_tunnel_xmit_v6, should be removed

	- __tun_gso_type_mask: only encaps_af should be used/checked?
	Or may be:
		if (encaps_af == AF_INET) {
			if (orig_af == AF_INET)
				return SKB_GSO_IPIP;
#ifdef CONFIG_IP_VS_IPV6
			if (orig_af == AF_INET6)
				return SKB_GSO_SIT;
#endif
		}
		...
		return 0;

	- iph->payload_len = ntohs(payload_len);
	should be iph->payload_len = htons(payload_len);

	- scripts/checkpatch.pl warnings

Regards

--
Julian Anastasov <ja@ssi.bg>
