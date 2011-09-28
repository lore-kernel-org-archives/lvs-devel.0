From: Simon Horman <horms@verge.net.au>
Subject: Re: [GIT PULL net-next] IPVS
Date: Thu, 29 Sep 2011 08:01:59 +0900
Message-ID: <20110928230158.GC16908@verge.net.au>
References: <1317027938-22053-1-git-send-email-horms@verge.net.au>
 <20110927081618.GA22655@1984>
 <20110928132802.GC7661@verge.net.au>
 <20110928214516.GE2761@1984>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110928214516.GE2761@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>

On Wed, Sep 28, 2011 at 11:45:16PM +0200, Pablo Neira Ayuso wrote:
> On Wed, Sep 28, 2011 at 10:28:03PM +0900, Simon Horman wrote:
> > On Tue, Sep 27, 2011 at 10:16:18AM +0200, Pablo Neira Ayuso wrote:
> > > On Mon, Sep 26, 2011 at 06:05:33PM +0900, Simon Horman wrote:
> > > > Hi,
> > > > 
> > > > with all the excitement of kernel.org being offline and a bunch of trees
> > > > likewise being offline I am a little unsure who should take this pull
> > > > request which is based on the current net-next tree. But I guess it should
> > > > be Patrick, Pablo or Dave.
> > > 
> > > I'll try to set up one tree in one of my servers along today, I'll
> > > send you the URI. We can use it until kernel.org comes back.
> > 
> > Thanks. Would you like me to rebase my tree on yours?
> 
> Thinking it well, and given that you'll have to send me more patches,
> I think it's a good idea if you rebase.

Good thinking. I have rebased my ipvs-next tree on your nf-next branch.

> BTW, please no need to Cc netfilter@vger.kernel.org, that list is for
> netfilter users, not for developers.

Thanks, notied.
