From: Simon Horman <horms@verge.net.au>
Subject: Re: [rfc 1/3] ipvs: handle PARTIAL_CHECKSUM
Date: Mon, 8 Sep 2008 19:05:27 +1000
Message-ID: <20080908090525.GA855@verge.net.au>
References: <20080908020420.313463898@vergenet.net> <20080908021535.063462678@vergenet.net> <20080908072439.GA27257@gondor.apana.org.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080908072439.GA27257@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Herbert Xu <herbert@gondor.apana.org.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Siim =?iso-8859-1?B?UMO1ZGVy?= <siim@p6drad-teel.net>, Julian Anastasov <ja@ssi.bg>, Malcolm Turnbull <malcolm@loadbalancer.org>, Julius Volz <juliusv@google.com>, Vince Busam <vbusam@google.com>

On Mon, Sep 08, 2008 at 05:24:40PM +1000, Herbert Xu wrote:
> On Mon, Sep 08, 2008 at 12:04:21PM +1000, Simon Horman wrote:
> >
> >  	/* Adjust TCP checksums */
> > -	if (!cp->app && (tcph->check != 0)) {
> > +	if (skb->ip_summed == CHECKSUM_PARTIAL) {
> > +		tcp_partial_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
> > +					htonl(oldlen),
> > +					htonl(skb->len - tcphoff));
> 
> I don't know what cp->app is but should we be updating the checksum
> when it's set? The previous code seems to want to compute a full
> checksum instead.

Hi Herbert,

If cp->app is not present, then only the destiantion IP address
and possibly port will have been altered. If it is present,
then other parts of the packet may also have been altered.

In the case where (skb->ip_summed == CHECKSUM_PARTIAL)
as we are only concerned with checkumming the pseudo header,
the only changes that nat could make that we care about are the
address or the length. The latter may change if cp->app is set,
but I think that my code handles this in tcp_partial_csum_update().

So I think that is safe to use tcp_partial_csum_update() if
(skb->ip_summed == CHECKSUM_PARTIAL), regarless of if cp->app is set or not.
