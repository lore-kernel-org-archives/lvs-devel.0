From: Simon Horman <horms@verge.net.au>
Subject: Re: [GIT PULL nf-next 00/21] Second Round of IPVS Updates for v3.18
Date: Thu, 18 Sep 2014 09:27:17 +0900
Message-ID: <20140918002716.GA8189@verge.net.au>
References: <1410827675-3637-1-git-send-email-horms@verge.net.au>
 <20140916172556.GA21545@salvia>
 <alpine.LFD.2.11.1409170013440.3254@ja.home.ssi.bg>
 <20140917083041.GA4762@salvia>
 <20140917235628.GC600@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140917235628.GC600@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>

On Thu, Sep 18, 2014 at 08:56:29AM +0900, Simon Horman wrote:
> On Wed, Sep 17, 2014 at 10:30:41AM +0200, Pablo Neira Ayuso wrote:
> > On Wed, Sep 17, 2014 at 12:27:03AM +0300, Julian Anastasov wrote:
> > > 
> > > 	Hello,
> > > 
> > > On Tue, 16 Sep 2014, Pablo Neira Ayuso wrote:
> > > 
> > > > Hi Simon,
> > > > 
> > > > On Tue, Sep 16, 2014 at 09:34:14AM +0900, Simon Horman wrote:
> > > > > Hi Pablo,
> > > > > 
> > > > > please consider these IPVS updates for v3.18.
> > > > > 
> > > > > * Add simple weighted failover scheduler
> > > > >   - Thanks to Kenny Mathis
> > > > > * Support v6 real servers in v4 pools and vice versa
> > > > >   - Thanks to Alex Gartrell and Julian Anastasov
> > > > 
> > > > I need a slightly larger description of this series.
> > > > 
> > > > I think you can merge patches 13-19 too. They are mostly two liners
> > > > with a similar description, so they naturally belong to the same
> > > > logical change. I would like to reduce the patchbomb pull request for
> > > > David.
> > > 
> > > 	Good idea, done.
> > > 
> > > 	Simon, I'm attaching such patch that replaces all
> > > these "ipvs: use correct address family in * logs".
> > > It additionally changes the new ip_vs_fo.c scheduler
> > > and ip_vs_wrr.c which was missed.
> > 
> > Thanks Julian.
> > 
> > @Simon, I can manually apply this batch if that reduces your workload.
> > Please let me know what you prefer.
> > 
> > Still I'd really appreciate a longer series description that I can
> > include in the pull-request for David.
> 
> Hi Pablo,
> 
> I should be able to prepare and send a revised pull-request today.

I have now done so.
