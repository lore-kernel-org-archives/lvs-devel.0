From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [patch v2] ipvs: IPv6 tunnel mode
Date: Fri, 1 Oct 2010 08:08:23 +0200
Message-ID: <1285913303.5670.122.camel@seasc0214>
References: <20100926133313.GA30560@verge.net.au>
	 <alpine.LFD.2.00.1009261721070.13702@u.domain.uli>
	 <1285767027.5670.51.camel@seasc0214>
	 <alpine.LFD.2.00.1010010056170.2209@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1010010056170.2209@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, Julius Volz <juliusv@google.com>

Hello

On Fri, 2010-10-01 at 00:55 +0200, Julian Anastasov wrote:
> 	Hello,
> 
> On Wed, 29 Sep 2010, Hans Schillstrom wrote:
> 
> > Hello
> > I think this patch should be stopped since it doesn't work in some
> > cases.
> 
>  	I think, the patch is still correct. May be we
> just need to create new patch to fix the remaining problems
> which are old (rt6i_dst use).
> 
> > There is also a bug in the patch.
> > ip6_route_output() returns a key as dest address
> > which can be a network and that's not a good dest address.
> > (It can be seen if the tunnel remote endpoint has to pass through an
> > router/gateway)
> 
>  	You are referring to rt6i_dst?

Yes

> 
> > @@ -750,8 +763,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb
> > ...
> > ...
> > -        ipv6_addr_copy(&iph->daddr, &rt->rt6i_dst.addr);
> > +        ipv6_addr_copy(&iph->daddr, &cp->dest->addr.in6);
> 
>  	I prefer not to risk with cp->dest, see below.
> May be ipv6_addr_copy(&iph->daddr, &cp->daddr.in6);
> is safer. But we still can add more checks for the
> daddr type one day when backup supports IPv6.
> 
> - both rt6_alloc_cow and rt6_alloc_clone copy our fl->fl6_dst
> into rt6i_dst. Only that CLONE_OFFLINK_ROUTE is not 1 and
> I'm not sure what happens with rt6i_dst in this
> case (ip6_pol_route). May be you see the route prefix there
> as set by ip6_route_add?

Yes, the destination network  

> 
> > The principle for it is wrong, it's more or less impossible to get the
> > expected address from ipv6_get_saddr_eval(), depending on your network
> > topology.
> >
> > Since there must be an address set on the remote/local pair for a IPv6
> > tunnel and you can't predict what source address you will get the
> > function is more or less useless.
> 
>  	Yes, for IPv6 I don't see option in tunnel to accept
> traffic from any remote address. This was not the case with
> IPv4. But the source address selection is rich enough.
> I don't know for any example settings for IPVS on IPv6
> but routes in IPv6 can have source address if CONFIG_IPV6_SUBTREES
> is defined (ip6_route_add). Still, the routing should be
> able to return valid source address. I don't know what
> settings you are using but looking at code I think the
> options are:
> 
> - assign source address for route
> 
> - add VIPs as deprecated addresses (prefered_lft=0). By this
> way we don't risk they to be autoselected as source in
> output routes because they are ignored in ipv6_get_saddr_eval
> at step IPV6_SADDR_RULE_PREFERRED
> 
>  	As result, the source address should be properly
> selected and our patch looks ok for the saddr part.

Yes you're right as usual :-) 
With "prefered_lft=0" src selection works in most cases now.
So this is not an issue any more.

> 
> > After spending a day single stepping through the IPv6 stack I'm more or
> > less sure that:
> > - The only way to get IPv6 tunnels to work in a predictable way is to
> > add a "tunnel source address" to the ipvsadm commad.
> 
>  	This is not possible for the case when cp->dest is
> NULL, eg. when connection using fwmarks is moved to backup
> server. But this does not happen because IPv6 is not supported
> for sync. If one day we add support in new sync format I'm
> sure there will be also fwmark and cp->dest will be valid
> for the tunneling method.
> 
> > What to do ?
> > - add a --tunsrc switch to ipvsadm  -i command ?
> > or
> > - Disable the IPv6 tunnel mode ?
> > or
> > - Leave it as is ?
> 
>  	This 3th option is better for the moment. I think,
> saddr is selected correctly, see ip6_dst_lookup() and
> ip6_dst_lookup_tail() in net/ipv6/ip6_output.c
> But if you think using ipv6_addr_copy(&iph->daddr, &cp->daddr.in6);
> is working then feel free to post a patch on top of
> the previous patch. Because other code in kernel uses
> resulting fl.fl6_dst, not rt6i_dst.

I prefer fl.fl6_dst right now since rt6i_dst gives a bad destination in
many cases.

I will do some more testing before posting the patch.
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>

