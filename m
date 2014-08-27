From: Alex Gartrell <agartrell@fb.com>
Subject: Re: [PATCH ipvs,v2 00/18] Support v6 real servers in v4 pools and
 vice versa
Date: Wed, 27 Aug 2014 14:37:49 -0700
Message-ID: <53FE4FAD.2030008@fb.com>
References: <1408073021-24007-1-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1408151540040.3192@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=message-id : date : from :
 mime-version : to : cc : subject : references : in-reply-to : content-type
 : content-transfer-encoding; s=facebook;
 bh=UdOtmOWAjnMrDpvBZQO/UcylHbpcD8uaB50w6XlblwQ=;
 b=HE8vGLCoqNtWs9pRqI5LPX7AjCyMnjlY2Yw97V478K/C+/2oEh4IksTvK5E5xrK6Ms4n
 FsUCz+mWdZ6K/IrCBl5yt4CJSEPLLCN64SygMRicKXqtroyB1FdcIsV6z2b0vcBHAu+1
 9EcNG0Wm0fo7R+VvSKCPnRudzyMOgs7/uhY= 
In-Reply-To: <alpine.LFD.2.11.1408151540040.3192@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com

Hey,

Thanks again for your fantastic review, Julian.  As you mentioned, I 
omitted the first two patches.  I'll include them in v3 and be more 
careful in the future.

Additionally, I've done an interactive rebase wherein I exec make -j && 
./scripts/checkpatch.pl $(git format-patch) between every pick, so 
hopefully this will be less sloppy.  The only warnings were related to 
splitting string literals across lines, which is done elsewhere in the file.

I've implemented the requested changes and will do the functional tests. 
  If all goes well I will mail v3 this evening.

On 8/15/14 3:42 PM, Alex Gartrell wrote:> On Fri, 15 Aug 2014 15:53:49 +0300
 > Julian Anastasov <ja@ssi.bg> wrote:
 >
 >>
 >> 	Hello,
 >>
 >> On Thu, 14 Aug 2014, Alex Gartrell wrote:
 >>
 >>> At Facebook we use ipip forwarding to deliver packets from our
 >>> layer 4 ipvs load balancers to our layer 7 proxies.  Today these
 >>> layer 7 proxies are all dual stacked, so we can simply send v4 over
 >>> v4 and v6 over v6.  In the future, we're going to have v6-only
 >>> layer 7 load balancers (no internal v4 address).  To deal with
 >>> this, we'll forward v4 packets in v6 tunnels.  This patchset
 >>> introduces the necessary functionality into ipvs.
 >>>
 >>> The noteworthy limitation of this is that it is not compatible with
 >>> state synchronization, so great care is taken to keep these things
 >>> mutually exclusive.
 >>>
 >>> This patchset includes changes that add an additional netlink
 >>> attribute to destinations and changes that plumb the destination
 >>> address family through parts of the code where it was assumed that
 >>> it was the same as the service. Finally, there's a change that
 >>> updates the transmit functions for tunneling to share common code
 >>> and support v4 in v6 and vice versa.
 >>>
 >>> Changes for v2:
 >>>
 >>> Introduced crosses_local_route_boundary and update_pmtu functions
 >>> and conditionally do the ip_hdr operations.  The latter means that
 >>> df will be effectively zero when we forward an ipv6 packet over an
 >>> ipv4 tunnel.
 >>>
 >>> Additionally, I addressed Julian's other statements.
 >>>
 >>> Alex Gartrell (9):
 >>>    ipvs: Pass destination address family to ip_vs_trash_get_dest
 >>>    ipvs: Supply destination address family to ip_vs_conn_new
 >>>    ipvs: maintain a mixed_address_family_dest count
 >>>    ipvs: prevent mixing heterogeneous pools and synchronization
 >>>    ipvs: Supply skb_af to out_rt* functions
 >>>    ipvs: Pull out crosses_local_route_boundary logic
 >>>    ipvs: Pull out update_pmtu code
 >>>    ipvs: Only do ip_hdr operations in *out_rt when skb_af is AF_INET
 >>>    ipvs: support ipv4 in ipv6 and ipv6 in ipv4 tunnel forwarding
 >>>
 >>> Julian Anastasov (9):
 >>>    ipvs: address family of LBLC entry depends on svc family
 >>>    ipvs: address family of LBLCR entry depends on svc family
 >>>    ipvs: use correct address family in DH logs
 >>>    ipvs: use correct address family in LC logs
 >>>    ipvs: use correct address family in NQ logs
 >>>    ipvs: use correct address family in RR logs
 >>>    ipvs: use correct address family in SED logs
 >>>    ipvs: use correct address family in SH logs
 >>>    ipvs: use correct address family in WLC logs
 >>
 >> 	Great, here are some comments from me:
 >>
 >> - as some patches are missing I'm not sure if some
 >> of my notes for cp->af usage are addressed, eg. in
 >> set_tcp_state.

Yes you are right.  I forgot the first two patches.  Will include them in v3

 >> Patch 1:
 >> 	- I guess this patch depends on patch 1 and 2 from v1, they
 >> are now missing. This patch looks like a fixed patch 3 from v1.
 >>

Yeah that's right

 >> Patch 2:
 >> 	- looks ok
 >>
 >> Patch 3:
 >> 	- old_af and new_af are not needed anymore
 >>

Duh, thanks

 >> Patch 4:
 >> 	- it would be logically correct to take out the
 >> 	/* Temporary for consistency */ check and the
 >> 	IP_VS_CONN_F_TUNNEL check after
 >> 	/* Which connection types do we support? */ into another
 >> 	patch, not part of this patch. May be it can follow
 >> 	this patch or even it should be the last patch in this
 >> patchset. As result, current patch will include only the restriction
 >> 	for sync protocol and the last patch will enable the
 >> 	new feature.

I'll split this up and put it at the end.

 >> Patch 5:
 >> 	- it is not very good to just add unused args to funcs,
 >> 	may be we should mix patch 5 and 6?

Yeah, I was kind of afraid that it'd be confusing for people, but I 
think that the code is separate enough that it won't be.

 >> Patch 6:
 >> 	- scripts/checkpatch.pl warnings, may be renaming
 >> 	source_is_loopback to local_src can help. Make sure
 >> 	we do not exceed 80 columns.

Most embarrassing screw up :(

But yeah, these are just really unpleasantly long identifiers.  I'll 
either need to break the lines in weird ways or shorten identifiers or both.

 >>
 >> 	- in crosses_local_route_boundary() the check for
 >> 	old_rt_is_local should be inverted, it should be:
 >>
 >> 	if (!rt_mode_allow_redirect && !old_rt_is_local)

That's scary.  Good catch.

 >> 	- In the "We are crossing local and non-local addresses"
 >> message we can safely print the daddr because the family is constant
 >> for the function. We will not do it for source address because
 >> 	it is more complex (depends on skb family).

I'll add "daddr=" to each

 >>
 >> Patch 7:
 >> 	- I think, it should be safe to call
 >> 	skb_dst(skb)->ops->update_pmtu(skb_dst(skb), sk, NULL, mtu);
 >> 	in maybe_update_pmtu(), without any family checks.

Yeah, both route types have dst in the same place and I imagine that's 
by design.


 >> 	- scripts/checkpatch.pl warnings
 >>
 >> Patch 8:
 >> 	- it looks like now icmp_send* calls should depend on skb_af,
 >> 	not on dest af. It means both __ip_vs_get_out_rt and
 >> 	__ip_vs_get_out_rt_v6 should use some new common function that
 >> 	will do "frag needed" checks for AF_INET skbs. It will also
 >> 	include the __mtu_check_toobig_v6 call, the IPv6 specific
 >> part. Then we have to provide 'ipvsh' as arg to __ip_vs_get_out_rt,
 >> 	it is already provided to __ip_vs_get_out_rt_v6.
 >>

Yeah I was able to pull this out.

 >> 	- "frag needed for %pI4" looks correct because df is set only
 >> 	for IPv4.
 >>
 >> Patch 9:
 >> 	- we can use skb_af instead of version, right?

Yeah, I remembered fixing this but must have done this elsewhere.

 >>
 >> 	- using of out_skb in ip_vs_prepare_tunneled_skb leads to
 >> 	errors (example: IPv6), better to use new_skb and to work
 >> 	only with skb.

Yeah that's fair.  I was concerned about not attempting to kfree_skb skb 
which is why I made the change, but the fact that it made me miss 
something else convinces me that it's problematic.

 >>
 >> 	- ERR_PTR(ENOMEM) should be ERR_PTR(-ENOMEM)

Ah, that makes sense.  Thanks

 >>
 >> 	- the old iptunnel_handle_offloads call still remains in
 >> 	ip_vs_tunnel_xmit_v6, should be removed
 >>

*facepalm*

 >> 	- __tun_gso_type_mask: only encaps_af should be used/checked?
 >> 	Or may be:
 >> 		if (encaps_af == AF_INET) {
 >> 			if (orig_af == AF_INET)
 >> 				return SKB_GSO_IPIP;
 >> #ifdef CONFIG_IP_VS_IPV6
 >> 			if (orig_af == AF_INET6)
 >> 				return SKB_GSO_SIT;
 >> #endif

Can this just be else to spare the #ifdef lines?

 >> 		}
 >> 		...
 >> 		return 0;
 >>
 >> 	- iph->payload_len = ntohs(payload_len);
 >> 	should be iph->payload_len = htons(payload_len);
 >>

+1

 >> 	- scripts/checkpatch.pl warnings
 >>
 >> Regards
 >>
 >> --
 >> Julian Anastasov <ja@ssi.bg>
 >


