From: Alexander Frolkin <avf@eldamar.org.uk>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Thu, 13 Jun 2013 13:56:31 +0100
Message-ID: <20130613125631.GA31356@eldamar.org.uk>
References: <20130524120935.GL264@eldamar.org.uk>
 <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg>
 <20130524151408.GM264@eldamar.org.uk>
 <alpine.LFD.2.00.1305272251170.1728@ja.ssi.bg>
 <20130607081252.GC11902@eldamar.org.uk>
 <alpine.LFD.2.00.1306102222380.1773@ja.ssi.bg>
 <20130611083806.GA25531@eldamar.org.uk>
 <alpine.LFD.2.00.1306112240280.1709@ja.ssi.bg>
 <20130612141018.GC29327@eldamar.org.uk>
 <alpine.LFD.2.00.1306122244020.1773@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1306122244020.1773@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

Hi,

> > +{
> > +	__be16 port;
> > +	struct tcphdr _tcph, *th;
> > +	struct udphdr _udph, *uh;
> > +	sctp_sctphdr_t _sctph, *sh;
> > +
> > +	switch (svc->protocol) {
> 	Use iph->protocol instead of svc->protocol because not
> all services have correct protocol.

In order for this to work, I would have to change
ip_vs_fill_iph_addr_only in ip_vs_sh_schedule to ip_vs_fill_iph_skb (or
add an ip_vs_fill_iph_addr_proto_only function).  Obviously, I can do
this only when the flag is enabled.

I can also get it from skb, but that will make the code more
complicated.

What do you think?


Alex

