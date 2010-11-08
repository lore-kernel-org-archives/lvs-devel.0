From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC PATCH]  ipvs: skb defrag for L7 helpers
Date: Tue, 9 Nov 2010 07:23:54 +0900
Message-ID: <20101108222354.GE6502@verge.net.au>
References: <201011081551.56681.hans.schillstrom@ericsson.com>
 <alpine.LFD.2.00.1011082303050.1690@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1011082303050.1690@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, LVS-Devel <lvs-devel@vger.kernel.org>

On Mon, Nov 08, 2010 at 11:48:37PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 8 Nov 2010, Hans Schillstrom wrote:
> 
> >Hello
> >I have been struggling with SIP for a while ....
> >L7 helpers like sip needs skb defrag
> >ex virtio only copies the first 128 byte into the skb (incl mac hdr)
> >in that case Call-Id will never be found.
> >
> >There is a skb_find_text() that might be used insead of this, but it requires some changes in ip_vs_pe_sip.c
> >
> >Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> >
> >diff --git a/net/netfilter/ipvs/ip_vs_pe.c b/net/netfilter/ipvs/ip_vs_pe.c
> >index e99f920..c0ac69a 100644
> >--- a/net/netfilter/ipvs/ip_vs_pe.c
> >+++ b/net/netfilter/ipvs/ip_vs_pe.c
> >@@ -76,6 +72,24 @@ struct ip_vs_pe *ip_vs_pe_getbyname(const char *name)
> >	return pe;
> >}
> >
> >+/* skb defrag for L7 helpers */
> >+char *ip_vs_skb_defrag(struct sk_buff *skb, int offset, int len)
> >+{
> >+	char *p = kmalloc(skb->len, GFP_ATOMIC);
> >+	if (!p)
> >+		goto err;
> >+	if (skb_copy_bits(skb, offset, p, len))
> >+		goto err;
> 
> 	Such copy already exists: skb_linearize(). If you
> are lucky it does not copy data. But for your case the
> copy should happen. In ip_vs_ftp we even use skb_make_writable
> because we change the payload.

Good point.

> 	May be ip_vs_sip_fill_param() should deliver the status
> from skb_linearize (-ENOMEM) after the iph.protocol != IPPROTO_UDP
> check. ip_vs_conn_fill_param_persist should return this
> error to ip_vs_sched_persist. What we need is ip_vs_sched_persist
> to have new argument 'int *ignored' just like ip_vs_schedule, so
> that we can return *ignored = 1 for the case when
> ip_vs_conn_fill_param_persist returns any kind of error.
> Even on ip_vs_conn_new failure we should return *ignored = 1.
> *ignored = 0 remains only for the case when no dest is
> selected.

Agreed.

Somewhat off topic: the *ignored and *verdict parameters
seem to be a horrible way to pass this information around.
I think we can use ERR_PTR instead, though I'd have to
write the patch to see if that is true or not. If its
not perhaps we can have a small structure used as
the return value of ip_vs_schedule() and pp->conn_schedule().

	struct ip_vs_scheduler_status {
		ip_vs_conn *cp;
		int flag;
	}

However, I do wonder if the defrag change is stable material.
If so, I'll hold off on any re-working ideas.
