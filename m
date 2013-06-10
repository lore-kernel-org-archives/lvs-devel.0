From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [patch] ipvs: info leak in __ip_vs_get_dest_entries()
Date: Mon, 10 Jun 2013 14:58:22 +0200
Message-ID: <20130610125822.GA4968@localhost>
References: <20130603090049.GA16171@debian>
 <20130610083849.GD1563@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130610083849.GD1563@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, kernel-janitors@vger.kernel.org

On Mon, Jun 10, 2013 at 05:38:50PM +0900, Simon Horman wrote:
> On Mon, Jun 03, 2013 at 12:00:49PM +0300, Dan Carpenter wrote:
> > The entry struct has a 2 byte hole after ->port and another 4 byte
> > hole after ->stats.outpkts.  You must have CAP_NET_ADMIN in your
> > namespace to hit this information leak.
> > 
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> Pablo, could you take this directly into your tree.

Applied, thanks Simon.

> If possible for v3.10. It also appears to be relevant for stable.

Sure, will do.
