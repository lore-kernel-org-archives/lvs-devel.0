From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net] ipvs: use skb_to_full_sk() helper
Date: Sat, 14 Nov 2015 21:49:37 +0900
Message-ID: <20151114124936.GB14569@verge.net.au>
References: <06dc952f98f54da2c4d85b31e5fa9826@eikelenboom.it>
 <1447337353.22599.14.camel@edumazet-glaptop2.roam.corp.google.com>
 <b95f4a06d7d9b13849ad277128690436@eikelenboom.it>
 <1447348452.22599.28.camel@edumazet-glaptop2.roam.corp.google.com>
 <alpine.LFD.2.11.1511141333380.1496@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1447505378; bh=Kys321f1PRB++unb6ESrbHSDrgLEJ9vzBLwvslOOF9w=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=BZytst38UGslFpSplRpfLM8lDtDMOLIsK5Uv0biwgdxI/aBm+eeX1wWRvq4TjxZNZ
	 b9Z2MP3odeZTHyC8+lx9a196R19VwkbMPc4ncE2wybuMDUiInJWqPDTzPI2fhtcao9
	 VJHPhUMp8osinnOilFkBrjzAADxqPMD/D4WscvuU=
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1511141333380.1496@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, Julian Anastasov <ja@ssi.bg>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Sander Eikelenboom <linux@eikelenboom.it>, David Miller <davem@davemloft.net>, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>

[Attn Dave]
[Cc Pablo]

On Sat, Nov 14, 2015 at 01:37:46PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 12 Nov 2015, Eric Dumazet wrote:
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > SYNACK packets might be attached to request sockets.
> > 
> > Use skb_to_full_sk() helper to avoid illegal accesses to
> > inet_sk(skb->sk)
> > 
> > Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
> 
> 	Looks good, I guess Simon will take the patch for
> the ipvs tree.
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Dave,

It looks like this patch has a compile-time dependency on
54abc686c2d1 ("net: add skb_to_full_sk() helper and use it in
selinux_netlbl_skbuff_setsid()") which is currently present in
net but not nf. The latter tree is the usual path for IPVS fixes.

With the above in mind I think it would be easiest if you could
pick this patch up directly and add it to net with:

Acked-by: Simon Horman <horms@verge.net.au>

An alternative would be for Pablo to merge net into nf and
for me to then prepare a pull request for him. But it seems a bit
excessive for what otherwise appears to be a straightforward patch.

> > ---
> >  net/netfilter/ipvs/ip_vs_core.c |   16 ++++++++--------
> >  1 file changed, 8 insertions(+), 8 deletions(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> > index 1e24fff53e4b..f57b4dcdb233 100644
> > --- a/net/netfilter/ipvs/ip_vs_core.c
> > +++ b/net/netfilter/ipvs/ip_vs_core.c
> > @@ -1176,6 +1176,7 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
> >  	struct ip_vs_protocol *pp;
> >  	struct ip_vs_proto_data *pd;
> >  	struct ip_vs_conn *cp;
> > +	struct sock *sk;
> >  
> >  	EnterFunction(11);
> >  
> > @@ -1183,13 +1184,12 @@ ip_vs_out(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, in
> >  	if (skb->ipvs_property)
> >  		return NF_ACCEPT;
> >  
> > +	sk = skb_to_full_sk(skb);
> >  	/* Bad... Do not break raw sockets */
> > -	if (unlikely(skb->sk != NULL && hooknum == NF_INET_LOCAL_OUT &&
> > +	if (unlikely(sk && hooknum == NF_INET_LOCAL_OUT &&
> >  		     af == AF_INET)) {
> > -		struct sock *sk = skb->sk;
> > -		struct inet_sock *inet = inet_sk(skb->sk);
> >  
> > -		if (inet && sk->sk_family == PF_INET && inet->nodefrag)
> > +		if (sk->sk_family == PF_INET && inet_sk(sk)->nodefrag)
> >  			return NF_ACCEPT;
> >  	}
> >  
> > @@ -1681,6 +1681,7 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
> >  	struct ip_vs_conn *cp;
> >  	int ret, pkts;
> >  	int conn_reuse_mode;
> > +	struct sock *sk;
> >  
> >  	/* Already marked as IPVS request or reply? */
> >  	if (skb->ipvs_property)
> > @@ -1708,12 +1709,11 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
> >  	ip_vs_fill_iph_skb(af, skb, false, &iph);
> >  
> >  	/* Bad... Do not break raw sockets */
> > -	if (unlikely(skb->sk != NULL && hooknum == NF_INET_LOCAL_OUT &&
> > +	sk = skb_to_full_sk(skb);
> > +	if (unlikely(sk && hooknum == NF_INET_LOCAL_OUT &&
> >  		     af == AF_INET)) {
> > -		struct sock *sk = skb->sk;
> > -		struct inet_sock *inet = inet_sk(skb->sk);
> >  
> > -		if (inet && sk->sk_family == PF_INET && inet->nodefrag)
> > +		if (sk->sk_family == PF_INET && inet_sk(sk)->nodefrag)
> >  			return NF_ACCEPT;
> >  	}
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
