From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] IPVS: Move IPVS to net/netfilter/ipvs
Date: Mon, 22 Sep 2008 10:07:50 +1000
Message-ID: <20080922000748.GE1342@verge.net.au>
References: <f4845fc0809190345k1d9f8ba6i53d891548ddb0565@mail.gmail.com> <20080921235355.GA1342@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080921235355.GA1342@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, David Miller <davem@davemloft.net>, Patrick Hardy <kaber@trash.net>

On Mon, Sep 22, 2008 at 09:53:56AM +1000, Simon Horman wrote:
> On Fri, Sep 19, 2008 at 12:45:47PM +0200, Julius Volz wrote:
> > Hi Horms,
> > 
> > I worked around the unrelated UML build problems for now and did the
> > IPVS move from net/ipv4/ipvs to net/netfilter/ipvs, as discussed.
> > Since the patch is huge (732K), I uploaded it rather than trying to
> > include it in the mail:
> > 
> > http://www.mindbasket.com/ipvs/0001-IPVS-Move-IPVS-to-net-netfilter-ipvs.patch
> > 
> > The menuconfig option for IPVS is now also in the Netfilter submenu.
> > Everything builds and runs ok here...
> 
> Hi Julius, this seems fine to me. Dave, Patrick, are you ok with this
> change? If so I'll suck it into lvs-2.6 and send a pull request.

Here is the version of the patch that I have that applies
against the lvs-next-2.6 branch of lvs-2.6, changeset
"ipvs: Fix unused label warning" (8d5803bf6fbe5264000afc8c34bff08e8ecc023b)

http://www.vergenet.net/~horms/tmp/0001-IPVS-Move-IPVS-to-net-netfilter-ipvs.2.patch

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

