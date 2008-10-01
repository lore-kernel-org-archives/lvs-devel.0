From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: Move IPVS to net/netfilter/ipvs
Date: Wed, 1 Oct 2008 16:07:26 +1000
Message-ID: <20081001060725.GA28433@verge.net.au>
References: <f4845fc0809190345k1d9f8ba6i53d891548ddb0565@mail.gmail.com> <20080921235355.GA1342@verge.net.au> <20080922000748.GE1342@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080922000748.GE1342@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, David Miller <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>

On Mon, Sep 22, 2008 at 10:07:50AM +1000, Simon Horman wrote:
> On Mon, Sep 22, 2008 at 09:53:56AM +1000, Simon Horman wrote:
> > On Fri, Sep 19, 2008 at 12:45:47PM +0200, Julius Volz wrote:
> > > Hi Horms,
> > > 
> > > I worked around the unrelated UML build problems for now and did the
> > > IPVS move from net/ipv4/ipvs to net/netfilter/ipvs, as discussed.
> > > Since the patch is huge (732K), I uploaded it rather than trying to
> > > include it in the mail:
> > > 
> > > http://www.mindbasket.com/ipvs/0001-IPVS-Move-IPVS-to-net-netfilter-ipvs.patch
> > > 
> > > The menuconfig option for IPVS is now also in the Netfilter submenu.
> > > Everything builds and runs ok here...
> > 
> > Hi Julius, this seems fine to me. Dave, Patrick, are you ok with this
> > change? If so I'll suck it into lvs-2.6 and send a pull request.
> 
> Here is the version of the patch that I have that applies
> against the lvs-next-2.6 branch of lvs-2.6, changeset
> "ipvs: Fix unused label warning" (8d5803bf6fbe5264000afc8c34bff08e8ecc023b)
> 
> http://www.vergenet.net/~horms/tmp/0001-IPVS-Move-IPVS-to-net-netfilter-ipvs.2.patch

Hi Patrick,

could you take a moment to look at this?
Unfortunately the patch is too long to post to the list
but it really is as simple as the description (below) claims.

I can handle the patch longness problem by pushing it into
lvs-2.6 and getting Dave to do a pull from there. But I'd
like to make sure that the move is ok with you first.

Thanks

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

From: Julius Volz <juliusv@google.com>

IPVS: Move IPVS to net/netfilter/ipvs

Since IPVS now has partial IPv6 support, this patch moves IPVS from
net/ipv4/ipvs to net/netfilter/ipvs. It's a result of:

$ git mv net/ipv4/ipvs net/netfilter

and adapting the relevant Kconfigs/Makefiles to the new path.

Signed-off-by: Julius Volz <juliusv@google.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

[ diff omitted ]
