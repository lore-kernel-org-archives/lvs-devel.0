From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: use explicitly signed chars
Date: Wed, 26 Oct 2022 18:01:09 +0300 (EEST)
Message-ID: <bb93406f-6935-deee-22e4-c4b4be55bc60@ssi.bg>
References: <20221026123216.1575440-1-Jason@zx2c4.com> <4cc36ff5-46fd-c2b3-3292-d6369337fec1@ssi.bg> <Y1lEebYfRwrtliDL@zx2c4.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Y1lEebYfRwrtliDL@zx2c4.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, Simon Horman <horms@verge.net.au>, stable@vger.kernel.org


	Hello,

On Wed, 26 Oct 2022, Jason A. Donenfeld wrote:

> On Wed, Oct 26, 2022 at 05:20:03PM +0300, Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Wed, 26 Oct 2022, Jason A. Donenfeld wrote:
> > 
> > > The `char` type with no explicit sign is sometimes signed and sometimes
> > > unsigned. This code will break on platforms such as arm, where char is
> > > unsigned. So mark it here as explicitly signed, so that the
> > > todrop_counter decrement and subsequent comparison is correct.
> > > 
> > > Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> > > Cc: Julian Anastasov <ja@ssi.bg>
> > > Cc: Simon Horman <horms@verge.net.au>
> > > Cc: stable@vger.kernel.org
> > > Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
> > 
> > 	Looks good to me for -next, thanks!
> 
> This is actually net.git material, not net-next.git material,
> considering it fixes a bug on arm and many other archs, and is marked
> with a stable@ tag.

	OK. As algorithm is not SMP safe, the problem is
not just for the first 256 packets on these platforms.

Regards

--
Julian Anastasov <ja@ssi.bg>

