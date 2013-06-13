From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Thu, 13 Jun 2013 22:50:43 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1306132246270.1810@ja.ssi.bg>
References: <20130524120935.GL264@eldamar.org.uk> <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg> <20130524151408.GM264@eldamar.org.uk> <alpine.LFD.2.00.1305272251170.1728@ja.ssi.bg> <20130607081252.GC11902@eldamar.org.uk> <alpine.LFD.2.00.1306102222380.1773@ja.ssi.bg>
 <20130611083806.GA25531@eldamar.org.uk> <alpine.LFD.2.00.1306112240280.1709@ja.ssi.bg> <20130612141018.GC29327@eldamar.org.uk> <alpine.LFD.2.00.1306122244020.1773@ja.ssi.bg> <20130613125631.GA31356@eldamar.org.uk>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130613125631.GA31356@eldamar.org.uk>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Frolkin <avf@eldamar.org.uk>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Thu, 13 Jun 2013, Alexander Frolkin wrote:

> Hi,
> 
> > > +{
> > > +	__be16 port;
> > > +	struct tcphdr _tcph, *th;
> > > +	struct udphdr _udph, *uh;
> > > +	sctp_sctphdr_t _sctph, *sh;
> > > +
> > > +	switch (svc->protocol) {
> > 	Use iph->protocol instead of svc->protocol because not
> > all services have correct protocol.
> 
> In order for this to work, I would have to change
> ip_vs_fill_iph_addr_only in ip_vs_sh_schedule to ip_vs_fill_iph_skb (or
> add an ip_vs_fill_iph_addr_proto_only function).  Obviously, I can do
> this only when the flag is enabled.
> 
> I can also get it from skb, but that will make the code more
> complicated.
> 
> What do you think?

	May be I have to remove this ip_vs_fill_iph_addr_only
function, we should provide iph to schedulers. I'll post
patch this weekend.

Regards

--
Julian Anastasov <ja@ssi.bg>
