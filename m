From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/2] netfilter: ipvs/SIP: handle ip_vs_fill_iph_skb_off
 failure
Date: Thu, 28 Jan 2016 08:39:14 +0900
Message-ID: <20160127233914.GA5183@verge.net.au>
References: <1453902749-3422685-1-git-send-email-arnd@arndb.de>
 <1453902749-3422685-2-git-send-email-arnd@arndb.de>
 <alpine.LFD.2.11.1601272241530.2353@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1453937957; bh=8wgq21aAbxFVlHgIIvUaevWR6D4IfOMNfqNtnebhruY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=qVo1cS1DDanZ3FMHGd/+SiM4NrGyZpsuPy3ixivQEanRiv8FgUo/TM99wetaUY8N/
	 MmisoyGdVVw8kVrWuyEc8e+V1n0MIGMiD90y3+3qQbj2jElhoxXcgYmc9ntoT1j1tM
	 iRCL/0QgydpyL7BLP/piLwMAKBtvYxMT+oWj0Gz8=
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1601272241530.2353@ja.home.ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Arnd Bergmann <arnd@arndb.de>, Wensong Zhang <wensong@linux-vs.org>, linux-arm-kernel@lists.infradead.org, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Wed, Jan 27, 2016 at 10:56:08PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Wed, 27 Jan 2016, Arnd Bergmann wrote:
> 
> > ip_vs_fill_iph_skb_off() may not find an IP header, and gcc has
> > determined that ip_vs_sip_fill_param() then incorrectly accesses
> > the protocol fields:
> > 
> > net/netfilter/ipvs/ip_vs_pe_sip.c: In function 'ip_vs_sip_fill_param':
> > net/netfilter/ipvs/ip_vs_pe_sip.c:76:5: error: 'iph.protocol' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> >   if (iph.protocol != IPPROTO_UDP)
> >      ^
> > net/netfilter/ipvs/ip_vs_pe_sip.c:81:10: error: 'iph.len' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> >   dataoff = iph.len + sizeof(struct udphdr);
> >           ^
> > 
> > This adds a check for the ip_vs_fill_iph_skb_off() return code
> > before looking at the ip header data returned from it.
> > 
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > Fixes: b0e010c527de ("ipvs: replace ip_vs_fill_ip4hdr with ip_vs_fill_iph_skb_off")
> 
> 	Looks ok to me,
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks, I have queued this up.

> 	but see below...
> 
> > ---
> >  net/netfilter/ipvs/ip_vs_pe_sip.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
> > index 1b8d594e493a..c4e9ca016a88 100644
> > --- a/net/netfilter/ipvs/ip_vs_pe_sip.c
> > +++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
> > @@ -70,10 +70,10 @@ ip_vs_sip_fill_param(struct ip_vs_conn_param *p, struct sk_buff *skb)
> >  	const char *dptr;
> >  	int retc;
> >  
> > -	ip_vs_fill_iph_skb(p->af, skb, false, &iph);
> > +	retc = ip_vs_fill_iph_skb(p->af, skb, false, &iph);
> >  
> >  	/* Only useful with UDP */
> > -	if (iph.protocol != IPPROTO_UDP)
> > +	if (!retc || iph.protocol != IPPROTO_UDP)
> >  		return -EINVAL;
> >  	/* todo: IPv6 fragments:
> >  	 *       I think this only should be done for the first fragment. /HS
> 
> 	There are other places like this where result is not
> checked because there is always a guarding skb_header_pointer
> check, i.e. ip_vs_fill_iph_skb* should not fail at such point.
> 
> 	Let us know you want to extend this patch with other such
> calls (including ip_vs_fill_iph_skb_icmp)? May be they will
> need return NF_ACCEPT. I guess, all such changes should be
> for the ipvs-next/net-next tree when it opens.

I would suggest making such changes incrementally on top of this one.
