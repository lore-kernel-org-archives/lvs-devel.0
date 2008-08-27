From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH RFC 00/24] IPVS: Add first IPv6 support to IPVS
Date: Wed, 27 Aug 2008 15:59:26 +1000
Message-ID: <20080827055924.GA3816@verge.net.au>
References: <1219248931-15064-1-git-send-email-juliusv@google.com> <20080821011715.GG19235@verge.net.au> <f4845fc0808210259n2b4bbd41tb0a93c49592a2029@mail.gmail.com> <20080821212948.GB4407@verge.net.au> <f4845fc0808211501y188b0ae9ie7aacb2f52c3dcd8@mail.gmail.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f4845fc0808211501y188b0ae9ie7aacb2f52c3dcd8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com, Sven Wegener <sven.wegener@stealer.net>

On Fri, Aug 22, 2008 at 12:01:19AM +0200, Julius Volz wrote:
> On Thu, Aug 21, 2008 at 11:29 PM, Simon Horman <horms@verge.net.au> wrote:
> > On Thu, Aug 21, 2008 at 11:59:44AM +0200, Julius Volz wrote:
> >> There shouldn't be any fundamental restrictions, it's just a piece of
> >> the puzzle that I could easily leave out of the picture for now.
> >>
> >> I haven't studied the sync daemon closely yet, but one thing I was
> >> briefly wondering about was whether we should just blow up the
> >> addresses in struct ip_vs_sync_conn to be of type union nf_inet_addr
> >> (probably not acceptable, wasting too much bandwidth for v4 entries)
> >> or how to send differently sized entries based on the IP version in a
> >> clean way. But it sounds like you'd want to redesign a lot of that
> >> anyways? I'm glad to help with anything, I just don't know this code
> >> as well as you or Sven, but I'll study it more. Maybe you can share
> >> some ideas on the extensibility you want to see?
> >
> > What I was thinking is that any change
> 
> Hm, I think you forgot to finish this sentence ;)
> 
> > Here are a few thoughts I have had in my breif overview of the code so far
> > - mainly just simple style things. If any of my comments are obviously
> > stupid, please just say so as I haven't got to the end of the series yet
> > and I'm sure some of my questions are answered in the code.
> 
> Thanks for looking at this, no problem. I know it's a bit much to
> digest, but I think there is no smaller part that I could post that is
> useful in itself already.
> 
> > [PATCH RFC 01/24] IPVS: Add genetlink interface definitions to ip_vs.h
> > [PATCH RFC 02/24] IPVS: Add genetlink interface implementation
> >
> > * Already in lvs-2.6. Are there any changes?
> 
> No, those are just exactly what I sent you before. I included them
> because I was basing it on net-2.6.
> 
> Btw., David just announced that he opened net-next-2.6, so perhaps he
> could pull the changes from your tree into that now?

Yes, I hope so.

> > [PATCH RFC 02/24] IPVS: Add genetlink interface implementation
> >
> > * What is IP_VS = IPV6 ?
> 
> (IPV6 = y || IP_VS = IPV6) means that this option will only be visible
> if either CONFIG_IPV6 is set to Y or if both CONFIG_IPV6 and
> CONFIG_IP_VS are modules (if both are off, the whole submenu will be
> hidden). So CONFIG_IPV6 has to be set at least as high as CONFIG_IP_VS
> for this option to be visible.

Thanks, that was confusing me.

> > [PATCH RFC 04/24] IPVS: Change IPVS data structures to support IPv6 addresses
> >
> > * Indentation of af in struct ip_vs_conn seems inconsistent with other
> >  elements.
> 
> Yeah, it's broken like this in the original and I kept it like that so
> that things would still line up (because I didn't want to add noise by
> touching the neighboring lines just for whitespace fixes). I could
> just send a small whitespace fix to you before.

Ok

> > [PATCH RFC 05/24] IPVS: Add general v4/v6 helper functions / data structures
> >
> > * Use of p ? a : b construct in ip_vs_addr_equal() seems a bit aquard.
> >  How about
> >
> > static inline int ip_vs_addr_equal(int af, const union nf_inet_addr *a,
> >                                   const union nf_inet_addr *b)
> > {
> > #ifdef CONFIG_IP_VS_IPV6
> >        if (af == AF_INET)
> >                return ipv6_addr_equal(&a->in6, &b->in6);
> > #endif
> >        return a->ip == b->ip;
> > }
> 
> Right, that is nicer! With AF_INET6 in that if-condition, of course.

Yeah, of course, I meant AF_INET6.
