From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] ipvs: info leak in __ip_vs_get_dest_entries()
Date: Fri, 7 Jun 2013 11:33:14 +0300
Message-ID: <20130607083314.GQ23987@mwanda>
References: <20130603090049.GA16171@debian>
 <20130604010327.GA23054@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130604010327.GA23054@verge.net.au>
Sender: netfilter-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, kernel-janitors@vger.kernel.org

On Mon, Jun 03, 2013 at 06:03:27PM -0700, Simon Horman wrote:
> On Mon, Jun 03, 2013 at 12:00:49PM +0300, Dan Carpenter wrote:
> > The entry struct has a 2 byte hole after ->port and another 4 byte
> > hole after ->stats.outpkts.  You must have CAP_NET_ADMIN in your
> > namespace to hit this information leak.
> 
> Hi Dan,
> 
> can I verify that it is actually possible to hit this and
> thus the patch is a -stable candidate?

This is a static checker fix.  To me it seems like it's obviously a
real info leak.

I'm not certain of the impact though.  CLONE_NEWNET requires
CAP_SYS_ADMIN but on the other hand people are making virtualization
products where they give everyone their own namespace with admin
privileges.

regards,
dan carpenter
