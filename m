From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC net-next] ipv6: Use destination address determined by IPVS
Date: Wed, 16 Oct 2013 11:13:06 +0900
Message-ID: <20131016021304.GA17801@verge.net.au>
References: <1381881751-6719-1-git-send-email-horms@verge.net.au>
 <1381882426.2045.85.camel@edumazet-glaptop.roam.corp.google.com>
 <20131016002807.GM22321@verge.net.au>
 <1381883949.2045.97.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1381883949.2045.97.camel@edumazet-glaptop.roam.corp.google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Mark Brooks <mark@loadbalancer.org>

On Tue, Oct 15, 2013 at 05:39:09PM -0700, Eric Dumazet wrote:
> On Wed, 2013-10-16 at 09:28 +0900, Simon Horman wrote:
> 
> > > I guess things like NFQUEUE could happen ?
> > 
> > Could you expand a little?
> 
> This was to point that between IPVS and ipv6 stack we might have a
> delay, and daddr was maybe pointed to a freed memory.
> 
> IP6CB only uses 24 bytes, so I think you would be safe adding 16 bytes.

That does seem very promising but while implementing it
I hit a problem.

struct tcp_skb_cb includes a field of type struct inet6_skb_parm.  And
expanding struct inet6_skb_parm by 16 bytes means that struct tcp_skb_cb is
now larger than 48 bytes and no longer fits in skb->cb.

Is it appropriate to grow skb->cb as the comment above struct tcp_skb_cb
suggests?
