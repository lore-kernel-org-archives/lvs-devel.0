From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv3 16/24] IPVS: Add/adjust Netfilter hook functions and
	helpers for v6
Date: Fri, 5 Sep 2008 10:47:45 +1000
Message-ID: <20080905004743.GB22365@verge.net.au>
References: <1220363755-9854-1-git-send-email-juliusv@google.com> <1220363755-9854-17-git-send-email-juliusv@google.com> <20080903054359.GB16875@verge.net.au> <f4845fc0809030201x3961e795xdbdbe2c1060afb5@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f4845fc0809030201x3961e795xdbdbe2c1060afb5@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Wed, Sep 03, 2008 at 11:01:10AM +0200, Julius Volz wrote:
> On Wed, Sep 3, 2008 at 7:44 AM, Simon Horman <horms@verge.net.au> wrote:
> > On Tue, Sep 02, 2008 at 03:55:47PM +0200, Julius Volz wrote:
> >> Add Netfilter hook functions or modify existing ones, if possible, to
> >> process IPv6 packets. Some support functions are also added/modified for
> >> this. ip_vs_nat_icmp_v6() was already added in the patch that added the v6
> >> xmit functions, as it is called from one of them.
> >
> > Hi Julius,
> >
> > I was looking over this code a bit more closely to rebase someone
> > elses patch (which I intend to post very soon). I noticed two
> > minor things.
> >
> > 1) ipl doesn't seem to be needed in ip_vs_out_icmp() any more.
> >   But actually I'm quite ok with it staying there because the
> >   patch I was working on will need it.
> 
> ihl is still used for the length of the first IP header in the skb.
> The struct "ip_vs_iphdr ciph" is only used later, for the embedded IP
> header in the ICMP packet. It's needed because pp->conn_out_get()
> expects a pointer to this struct as a parameter. I hope that makes
> sense or did I miss something?

Sorry, my mistake. Yes, ihl is still used :-)

> > 2) I wonder if iph could be initialised earleir in ip_vs_out_icmp_v6()
> 
> I'll answer this below:
> 
> > [snip]
> >
> >> @@ -727,11 +759,117 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related)
> >
> >>       return verdict;
> >>  }
> >>
> >> -static inline int is_tcp_reset(const struct sk_buff *skb)
> >> +#ifdef CONFIG_IP_VS_IPV6
> >> +static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related)
> >> +{
> >> +     struct ipv6hdr *iph;
> >> +     struct icmp6hdr _icmph, *ic;
> >> +     struct ipv6hdr  _ciph, *cih;    /* The ip header contained
> >> +                                        within the ICMP */
> >> +     struct ip_vs_iphdr ciph;
> >> +     struct ip_vs_conn *cp;
> >> +     struct ip_vs_protocol *pp;
> >> +     unsigned int offset, verdict;
> >> +
> >> +     *related = 1;
> >> +
> >> +     /* reassemble IP fragments */
> >> +     if (ipv6_hdr(skb)->nexthdr == IPPROTO_FRAGMENT) {
> >> +             if (ip_vs_gather_frags_v6(skb, IP_DEFRAG_VS_OUT))
> >> +                     return NF_STOLEN;
> >> +     }
> >> +
> >> +     iph = ipv6_hdr(skb);
> >
> > Would it be worthwhile rearanging things so that iph is intialised
> > before "/* reassemble IP fragments */" and used instead
> > of ipv6_hdr(skb)->nexthdr in the if statement?
> 
> I followed the same structure as in the v4 version of ip_vs_out_icmp()
> here. I think this might be needed because ip_vs_gather_frags{_v6}
> changes the location of the IP header in the skb during reassembly?

Ok, that sounds reasonable. Perhaps someone could clarify the
behaviour of ip_vs_gather_frags{_v6}.

