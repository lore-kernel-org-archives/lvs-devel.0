From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC v2] ipvs: allow transmit of GRO aggregated skbs
Date: Mon, 8 Nov 2010 22:19:55 +0800
Message-ID: <20101108141955.GA31649@gondor.apana.org.au>
References: <20101105135222.GA8714@verge.net.au> <20101105235411.GA2443@verge.net.au> <alpine.LFD.2.00.1011061608510.4009@ja.ssi.bg> <20101106142817.GA27212@verge.net.au> <20101108073149.GA31384@verge.net.au> <alpine.LFD.2.00.1011081104310.1687@ja.ssi.bg> <20101108114542.GF14454@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101108114542.GF14454@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <simon@horms.net>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Mon, Nov 08, 2010 at 08:45:42PM +0900, Simon Horman wrote:
>
> > 	Yes, I think we should check for !skb_is_gso(skb)
> > as it looks as correct check to avoid FRAG_NEEDED after GRO
> > but lets wait for confirmation from Herbert Xu.
> 
> Yes, lets try and get a word from Herbert Xu on this.

Yes skb_is_gso(skb) is the best for now.  It isn't 100% correct
as we should still be checking that the gso_size is less than
the MTU but we need to fix that elsewhere first.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
