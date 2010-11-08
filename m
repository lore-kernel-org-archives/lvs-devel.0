From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [RFC PATCH]  ipvs: skb defrag for L7 helpers
Date: Mon, 8 Nov 2010 23:12:52 +0100
Message-ID: <201011082312.52821.hans@schillstrom.com>
References: <201011081551.56681.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1011082303050.1690@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1011082303050.1690@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, Simon Horman <horms@verge.net.au>, LVS-Devel <lvs-devel@vger.kernel.org>

On Monday, November 08, 2010 22:48:37 Julian Anastasov wrote:
> 
>  	Hello,
> 
> On Mon, 8 Nov 2010, Hans Schillstrom wrote:
> 
> > Hello
> > I have been struggling with SIP for a while ....
> > L7 helpers like sip needs skb defrag
> > ex virtio only copies the first 128 byte into the skb (incl mac hdr)
> > in that case Call-Id will never be found.
> >
> > There is a skb_find_text() that might be used insead of this, but it requires some changes in ip_vs_pe_sip.c
> >
> > Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> >
> > diff --git a/net/netfilter/ipvs/ip_vs_pe.c b/net/netfilter/ipvs/ip_vs_pe.c
> > index e99f920..c0ac69a 100644
> > --- a/net/netfilter/ipvs/ip_vs_pe.c
> > +++ b/net/netfilter/ipvs/ip_vs_pe.c
> > @@ -76,6 +72,24 @@ struct ip_vs_pe *ip_vs_pe_getbyname(const char *name)
> > 	return pe;
> > }
> >
> > +/* skb defrag for L7 helpers */
> > +char *ip_vs_skb_defrag(struct sk_buff *skb, int offset, int len)
> > +{
> > +	char *p = kmalloc(skb->len, GFP_ATOMIC);
> > +	if (!p)
> > +		goto err;
> > +	if (skb_copy_bits(skb, offset, p, len))
> > +		goto err;
> 
>  	Such copy already exists: skb_linearize(). If you
> are lucky it does not copy data. But for your case the
> copy should happen. In ip_vs_ftp we even use skb_make_writable
> because we change the payload.

I didn't see that one,  but skb_copy_bits is faster in the short run but in the end you still have a fragmented skb.
I think skb_linearize is better, Thanks.

> 
>  	May be ip_vs_sip_fill_param() should deliver the status
> from skb_linearize (-ENOMEM) after the iph.protocol != IPPROTO_UDP
> check. ip_vs_conn_fill_param_persist should return this
> error to ip_vs_sched_persist. What we need is ip_vs_sched_persist
> to have new argument 'int *ignored' just like ip_vs_schedule, so
> that we can return *ignored = 1 for the case when
> ip_vs_conn_fill_param_persist returns any kind of error.
> Even on ip_vs_conn_new failure we should return *ignored = 1.
> *ignored = 0 remains only for the case when no dest is
> selected.

OK, sounds like a good Idea
I add that to the patch

> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>

Regards
Hans
