From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 1/2] IPVS Bug IPv6 extension header handling faulty.
Date: Thu, 23 Feb 2012 01:16:35 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1202222347030.1603@ja.ssi.bg>
References: <1329223689-19792-1-git-send-email-hans.schillstrom@ericsson.com> <1329223689-19792-2-git-send-email-hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1202220040001.1685@ja.ssi.bg> <201202220846.58599.hans@schillstrom.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201202220846.58599.hans@schillstrom.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, kaber@trash.net, pablo@netfilter.org


	Hello,

On Wed, 22 Feb 2012, Hans Schillstrom wrote:

> > 	May be there is no need ip_vs_fill_ip4hdr to initialize
> > the new fields that are IPv6 specific.
> 
> That's true  offs, fragoffs and flags can be skipped.
> Maybe fragoffs still should be set to zero... because it is used in some places
> I mean for future changes, (it's not needed today)

	I see, ip_vs_skb_hdr_ptr needs it.

> Like this place in ip_vs_in() 
> 
> if (unlikely(!cp) && !iph.fragoffs) {

	This is not going to work. You are trying to track
any locally delivered fragments. If cp is NULL it will crash.
There is no need to add check for !iph.fragoffs because
for iph.fragoffs != 0 we find cp with data from reasm,
I mean with ip_vs_skb_hdr_ptr.

> ip_vs_fill_ip4hdr() is not so heavily used :-) 
> (only in icmp and for fragments in ip_vs_out)

	ok, better to initialize at least fragoffs.

> > > +	iphdr->saddr.ip = iph->saddr;
> > > +	iphdr->daddr.ip = iph->daddr;
> > > +}
> > > +
> > 
> > > @@ -1379,8 +1347,8 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
> > >  	/* do the statistics and put it back */
> > >  	ip_vs_in_stats(cp, skb);
> > >  	if (IPPROTO_TCP == cih->protocol || IPPROTO_UDP == cih->protocol)
> > > -		offset += 2 * sizeof(__u16);
> > > -	verdict = ip_vs_icmp_xmit(skb, cp, pp, offset, hooknum);
> > > +		ciph.len += 2 * sizeof(__u16);
> > 
> > 	Can we avoid adding ports to ciph.len? May be we can
> > use the offset var and to provide it to ip_vs_icmp_xmit,
> > just like for IPv6 below.
> 
> Hmm, I don't think so, then offset needs to be updated before i.e. more code
> (ciph is a local var and it's not so expensive to use it.)
> 
> A change will be like this, 
> 
> 	ip_vs_fill_ip4hdr(cih, &ciph);
> 	ciph.len += offset;
> 	/* The embedded headers contain source and dest in reverse order */
> 	cp = pp->conn_in_get(AF_INET, skb, &ciph, 1);
> [snip]
> 	/* do the statistics and put it back */
> 	ip_vs_in_stats(cp, skb);
> +   offset = ciph.len;
> 	if (IPPROTO_TCP == cih->protocol || IPPROTO_UDP == cih->protocol)
> -		ciph.len += 2 * sizeof(__u16);
> +        offset += 2 * sizeof(__u16);
> -	verdict = ip_vs_icmp_xmit(skb, cp, pp, ciph.len, hooknum, &ciph);
> +	verdict = ip_vs_icmp_xmit(skb, cp, pp, offset, hooknum, &ciph);

	Yes, that is better. Because it is dangerous if
ip_vs_icmp_xmit tries to debug IP header in offset after ports,
we provide ciph there, it must be with valid len.

> > 	As for patch 2, it is dangerous to use skb_dst_copy
> > without checking for present dst. And I don't think skb_dst_drop
> > will be appropriate before every skb_dst_copy call.
> > 
> > 	Do you see any dst and mark in ip_vs_preroute_frag6?
> 
> No it's to early
> 
> > I mean, isn't nf_ct_frag6_output just passing all fragments
> > without any dst and mark? 
> 
> Yes that's why I need to copy them to the 2:nd and following frags.

	But IPVS is working in LOCAL_IN, even fragments will
come with dst because they will be delivered locally after
input routing. So, there is no need to assign dst. In
PREROUTING there will be dst for loopback traffic. The
other traffic will get input route before reaching IPVS.
And it is dangerous to replace dst for the reason that
ip_vs_preroute_frag6 does not know if reasm was tracked
by IPVS, it can be just some netfilter packet. May be
it is a good idea to set reasm->ipvs_property at
some place, so that we know the packets are tracked
by IPVS. Then we can restrict ip_vs_preroute_frag6 to
work only for IPVS traffic.

	If all fragments from netfilter do not come with mark
that is derived from first fragment, may be it is better
IPVS just to get it from reasm, not to modify skb->mark
for every fragment because that can damage the mark,
someone may need to use different mark for all fragments.
IPVS can add method ip_vs_skb_mark that will prefer
mark from reasm because we need the mark only from
first fragment for scheduling and routing. As result,
we can remove ip_vs_preroute_frag6.

> > May be everything depends on __ipv6_conntrack_in to track the reassembled packet? 
> > What happens if IPVS works without conntrack support?
> 
> No we don't need conntrack.
> This was the tricky and "hidden" part of the patch :-)
> I tried to describe it in part 0/2
> 
> The magic thing is done in other hooks
> skb->mark and skb_dst_copy() is copied from the first fragment
> to the re-assembled skb "reasm" (as a temp storage)
> which is visible for all the following fragments
> 
> 	if (!iph.fragoffs && skb_nfct_reasm(skb)) {
> 		struct sk_buff *reasm = skb_nfct_reasm(skb);
> 		/* Save route & fw mark to comming frags */
> 		reasm->mark = skb->mark;
> 		skb_dst_copy(reasm, skb);
> 	}

	I see, first fragment walks the stack starting
from nf_ct_frag6_output, it is transmitted, then the
following fragments are sent. OK but make sure we do
not leak skb->dst on skb_dst_copy because I suspect
that if fragments are sent over loopback they will come
on input with present dst. That is why ip6_rcv_finish
avoids input routing for local traffic. Do not replace
dst if it is already present, only the IPVS transmitters
should do it.

> In ip_vs_preroute_frag6() the dst and fw-mark will be restord
> to 2:nd and following frags.
> 
> 	if (!iphdr.fragoffs)
> 		return NF_ACCEPT;
> 	/* Copy stored mark & dst from ip_vs_in / out */
> 	skb->mark = reasm->mark;
> 	skb_dst_copy(skb, reasm);

	I see. Note that IPVS transmitters do not
modify skb->dst for loopback traffic, see IP_VS_XMIT.
So, if skb->dst is present you do not need to use
skb_dst_copy, the fragments will come with dst.

> > 	And what should be the goal? To pass all fragments
> > via IPVS SNAT/DNAT and transmitters? So, we must schedule/track
> > first fragment in IPVS and all other fragments should be routed
> > in the same way? 
> 
> Yes, that is how it works.
> skb_dst_copy() in PREROUTING  fix the routing into ip_vs since no
> ip6tables rules can do that because they only see fragments.

	But do we really need to copy dst from first fragment.
All following fragments are going to find cp with data from
first fragment. Then the transmitters should assign the same
skb->dst because we are routing for the same cp.

> > It is very difficult to mangle the packets if the fragments do not
> > come in single skb as for IPv4. We need to use something
> > like ip_defrag, is nf_ct_frag6_gather such analog?
> > After working with single skb we can send it to LOCAL_OUT for
> > fragmenting.
> 
> We are not allowed to do that according to RFC 2460
> "Note: 
>    unlike IPv4, fragmentation in IPv6 is performed only by source nodes, not by
>    routers along a packet's delivery path"

	Hm, I have to check what happens if we decide to
mangle payload. Also, note that now ip_vs_nat_xmit_v6
should try to NAT ports only for first fragment, is that
handled? For IPv4 ip_local_deliver calls ip_defrag and
IPVS does not need to defrag but for IPv6 we must be able
to route all fragments and to be careful what to mangle,
ports are only in first fragment, right?

Regards

--
Julian Anastasov <ja@ssi.bg>
