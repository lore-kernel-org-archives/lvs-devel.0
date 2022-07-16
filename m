From: Simon Horman <horms@kernel.org>
Subject: Re: [PATCH] netfilter: ipvs: Use the bitmap API to allocate bitmaps
Date: Sat, 16 Jul 2022 11:12:44 +0200
Message-ID: <YtKBDApu3y4noIGC@vergenet.net>
References: <420d8b70560e8711726ff639f0a55364e212ff26.1656962678.git.christophe.jaillet@wanadoo.fr>
 <b69d7ba1-22f8-80c3-c870-debd7aaf4cea@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <b69d7ba1-22f8-80c3-c870-debd7aaf4cea@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Christophe JAILLET <christophe.jaillet@wanadoo.fr>, Pablo Neira Ayuso <pablo@netfilter.org>, linux-kernel <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

On Tue, Jul 05, 2022 at 01:05:54PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 4 Jul 2022, Christophe JAILLET wrote:
> 
> > Use bitmap_zalloc()/bitmap_free() instead of hand-writing them.
> > 
> > It is less verbose and it improves the semantic.
> > 
> > Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> 
> 	Looks good to me for -next! Thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Acked-by: Simon Horman <horms@verge.net.au>

