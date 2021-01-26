From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v6] ipvs: add weighted random twos choice algorithm
Date: Tue, 26 Jan 2021 01:04:52 +0100
Message-ID: <20210126000452.GA29052@salvia>
References: <c97fced3-b6b7-ba40-274c-7a5749bbe48a@ssi.bg>
 <20210106190242.1044489-1-darby.payne@gmail.com>
 <c13462ca-37ce-1112-f73c-40d3e612482@ssi.bg>
 <20210124104524.GG576@vergenet.net>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20210124104524.GG576@vergenet.net>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, dpayne <darby.payne@gmail.com>, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org

On Sun, Jan 24, 2021 at 11:45:24AM +0100, Simon Horman wrote:
> On Wed, Jan 06, 2021 at 09:25:47PM +0200, Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Wed, 6 Jan 2021, dpayne wrote:
> > 
> > > Adds the random twos choice load-balancing algorithm. The algorithm will
> > > pick two random servers based on weights. Then select the server with
> > > the least amount of connections normalized by weight. The algorithm
> > > avoids the "herd behavior" problem. The algorithm comes from a paper
> > > by Michael Mitzenmacher available here
> > > http://www.eecs.harvard.edu/~michaelm/NEWWORK/postscripts/twosurvey.pdf
> > > 
> > > Signed-off-by: dpayne <darby.payne@gmail.com>
> > 
> > 	Looks good to me for -next, thanks!
> > 
> > Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> Sorry for the delay,
> 
> Acked-by: Simon Horman <horms@verge.net.au>

Applied, thanks.
