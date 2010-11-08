From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [RFC PATCH]  ipvs: skb defrag for L7 helpers
Date: Mon, 8 Nov 2010 22:56:03 +0100
Message-ID: <201011082256.04343.hans@schillstrom.com>
References: <201011081551.56681.hans.schillstrom@ericsson.com> <20101108214346.GA6502@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101108214346.GA6502@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, Julian Anastasov <ja@ssi.bg>, LVS-Devel <lvs-devel@vger.kernel.org>


On Monday, November 08, 2010 22:43:46 Simon Horman wrote:
> On Mon, Nov 08, 2010 at 03:51:56PM +0100, Hans Schillstrom wrote:
> > Hello
> > I have been struggling with SIP for a while ....
> > L7 helpers like sip needs skb defrag
> > ex virtio only copies the first 128 byte into the skb (incl mac hdr)
> > in that case Call-Id will never be found.
> > 
> > There is a skb_find_text() that might be used insead of this, but it requires some changes in ip_vs_pe_sip.c
> 
> Thanks for tracking that down!
> 
> > Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_pe.c b/net/netfilter/ipvs/ip_vs_pe.c
> > index e99f920..c0ac69a 100644
> > --- a/net/netfilter/ipvs/ip_vs_pe.c
> > +++ b/net/netfilter/ipvs/ip_vs_pe.c
> > @@ -76,6 +72,24 @@ struct ip_vs_pe *ip_vs_pe_getbyname(const char *name)
> >  	return pe;
> >  }
> > 
> > +/* skb defrag for L7 helpers */
> > +char *ip_vs_skb_defrag(struct sk_buff *skb, int offset, int len)
> > +{
> > +	char *p = kmalloc(skb->len, GFP_ATOMIC);
> > +	if (!p)
> > +		goto err;
> > +	if (skb_copy_bits(skb, offset, p, len))
> > +		goto err;
> > +	IP_VS_DBG(10, "IPVS defrag: offs:%d len:%d\n", offset, len);
> > +	return p;
> > +
> > +err:
> > +	if (p)
> > +		kfree(p);
> > +	return NULL;
> > +}
> > +EXPORT_SYMBOL_GPL(ip_vs_skb_defrag);
> > +
> >  /* Register a pe in the pe list */
> >  int register_ip_vs_pe(struct ip_vs_pe *pe)
> >  {
> > diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
> > index b8b4e96..78caa83 100644
> > --- a/net/netfilter/ipvs/ip_vs_pe_sip.c
> > +++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
> > @@ -71,6 +71,7 @@ ip_vs_sip_fill_param(struct ip_vs_conn_param *p, struct sk_buff *skb)
> >  	struct ip_vs_iphdr iph;
> >  	unsigned int dataoff, datalen, matchoff, matchlen;
> >  	const char *dptr;
> > +	int fr;
> > 
> >  	ip_vs_fill_iphdr(p->af, skb_network_header(skb), &iph);
> > 
> > @@ -85,21 +86,30 @@ ip_vs_sip_fill_param(struct ip_vs_conn_param *p, struct sk_buff *skb)
> > 
> >  	dptr = skb->data + dataoff;
> >  	datalen = skb->len - dataoff;
> > -
> > +	fr = 0;
> > +	if(  skb_shinfo(skb)->nr_frags ) {
> 
> >From a style point of view the line above should probably be:
> 
> 	if (skb_shinfo(skb)->nr_frags) {

I have to remind my self all time about that, but some times ...

> 
> > +		dptr = ip_vs_skb_defrag(skb, dataoff, datalen);
> > +		if (!dptr)
> > +			return -EINVAL;
> > +		fr = 1;
> > +	}
> 
> But I wonder if this logic can be rolld into ip_vs_skb_defrag(),
> perhaps using ERR_PTR() and friends. Then again, what you have
> may already be at least as clean as that idea.

I will have another look at it.

> 
> >  	if (get_callid(dptr, dataoff, datalen, &matchoff, &matchlen))
> > -		return -EINVAL;
> > +		goto err;
> > 
> >  	p->pe_data = kmalloc(matchlen, GFP_ATOMIC);
> >  	if (!p->pe_data)
> > -		return -ENOMEM;
> > +		goto err;
> > 
> >  	/* N.B: pe_data is only set on success,
> >  	 * this allows fallback to the default persistence logic on failure
> >  	 */
> >  	memcpy(p->pe_data, dptr + matchoff, matchlen);
> >  	p->pe_data_len = matchlen;
> > -
> >  	return 0;
> > +err:
> > +	if (fr)
> > +		kfree(dptr);
> > +	return -EINVAL;
> >  }
> > 
> >  static bool ip_vs_sip_ct_match(const struct ip_vs_conn_param *p,
> > diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> > index a6421e6..08bd547 100644
> > --- a/include/net/ip_vs.h
> > +++ b/include/net/ip_vs.h
> > @@ -817,6 +817,7 @@ void ip_vs_unbind_pe(struct ip_vs_service *svc);
> >  int register_ip_vs_pe(struct ip_vs_pe *pe);
> >  int unregister_ip_vs_pe(struct ip_vs_pe *pe);
> >  struct ip_vs_pe *ip_vs_pe_getbyname(const char *name);
> > +extern char *ip_vs_skb_defrag(struct sk_buff *skb, int offset, int len);
> 
> Personally I'm not a fan of the extern keyword.

I am :-)
I'll remove it

> 
> >  static inline void ip_vs_pe_get(const struct ip_vs_pe *pe)
> >  {
> > 
> > --
> > Regards
> > Hans Schillstrom <hans.schillstrom@ericsson.com>
> > 
