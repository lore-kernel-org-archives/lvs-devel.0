From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/3] ipvs: avoid rcu_barrier during netns cleanup
Date: Thu, 17 Oct 2013 17:30:04 +0900
Message-ID: <20131017083001.GA3775@verge.net.au>
References: <1381802507-7934-1-git-send-email-horms@verge.net.au>
 <1381802507-7934-3-git-send-email-horms@verge.net.au>
 <20131016104306.GA10288@localhost>
 <alpine.LFD.2.03.1310162231380.1917@ssi.bg>
 <20131017004939.GB21728@verge.net.au>
 <20131017081142.GA5324@localhost>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131017081142.GA5324@localhost>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>

On Thu, Oct 17, 2013 at 10:11:42AM +0200, Pablo Neira Ayuso wrote:
> On Thu, Oct 17, 2013 at 09:49:39AM +0900, Simon Horman wrote:
> > On Wed, Oct 16, 2013 at 10:52:14PM +0300, Julian Anastasov wrote:
> > > 
> > > 	Hello,
> > > 
> > > On Wed, 16 Oct 2013, Pablo Neira Ayuso wrote:
> > > 
> > > > I can enqueue this fix to nf if you like. No need to resend, I can
> > > > manually apply.
> > > > 
> > > > Let me know.
> > > 
> > > 	It is not critical. I waited weeks the net tree to be
> > > copied into net-next because it collides with the recent
> > > "ipvs: make the service replacement more robust" change in
> > > net tree :) But if a rcu_barrier in the netns cleanup looks
> > > scary enough you can push it to nf. IMHO, it just adds
> > > unneeded delay there.
> > 
> > If it is not critical I would prefer for it to travel through
> > nf-next. Though I do not feel strongly about this.
> 
> Will enqueue for nf-next.
> 
> I'd appreciate if you can recover the tradition of attaching a short
> evaluation in the cover letter as I do when I send pull requests to
> David. Thanks!

Sure, will do.
