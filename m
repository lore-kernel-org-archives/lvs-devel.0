From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC net-next] ipv6: Use destination address determined by IPVS
Date: Wed, 16 Oct 2013 13:26:15 +0900
Message-ID: <20131016042615.GB22553@verge.net.au>
References: <1381881751-6719-1-git-send-email-horms@verge.net.au>
 <1381882426.2045.85.camel@edumazet-glaptop.roam.corp.google.com>
 <20131016002807.GM22321@verge.net.au>
 <1381883949.2045.97.camel@edumazet-glaptop.roam.corp.google.com>
 <20131016021304.GA17801@verge.net.au>
 <1381891259.2045.100.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1381891259.2045.100.camel@edumazet-glaptop.roam.corp.google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Mark Brooks <mark@loadbalancer.org>

On Tue, Oct 15, 2013 at 07:40:59PM -0700, Eric Dumazet wrote:
> On Wed, 2013-10-16 at 11:13 +0900, Simon Horman wrote:
> 
> > That does seem very promising but while implementing it
> > I hit a problem.
> > 
> > struct tcp_skb_cb includes a field of type struct inet6_skb_parm.  And
> > expanding struct inet6_skb_parm by 16 bytes means that struct tcp_skb_cb is
> > now larger than 48 bytes and no longer fits in skb->cb.
> > 
> > Is it appropriate to grow skb->cb as the comment above struct tcp_skb_cb
> > suggests?
> 
> Ah well...
> 
> No, its not appropriate to grow sk_buff by 16 bytes, sorry.
> 
> You could not change struct inet6_skb_parm, but define IP6CB as
> a compound 
> 
> struct ip6cb {
>    struct inet6_skb_parm foo;
>    struct in6_addr       bar;
> };

Thanks for your guidance, that possibility had occured to me too.
I'll rework the patch accordingly.
