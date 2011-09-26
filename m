From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 0/4] IPVS: sysctl Documentation and Various Clean-Ups
Date: Mon, 26 Sep 2011 17:33:56 +0900
Message-ID: <20110926083355.GB13373@verge.net.au>
References: <1317000233-11169-1-git-send-email-horms@verge.net.au>
 <201109260843.18257.hans@schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201109260843.18257.hans@schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

On Mon, Sep 26, 2011 at 08:43:17AM +0200, Hans Schillstrom wrote:
> Hello Simon
> 
> On Monday, September 26, 2011 03:23:49 Simon Horman wrote:
> > Hi,
> > 
> > patch one of this series adds some missing entries to the sysctl
> > documentation. Julian, I would appreciate a review of this change.
> > 
> > The remaining three patches are minor code clean-ups flagged
> > by gcc 4.6.1.
> > 
> > My intention for this post is to solicit review.
> > I intend to post a pull request separately at a later date.
> > 
> 
> Your patches looks fine to me,
> you can have mine ack as well
> 
> Acked-by Hans Schillstrom <hans@schillstrom.com>
> 
> I have two small pending patches,  Deadlock and lockdep fixes. 
> Hopefully the patches will be ready this week. The deadlock is a tricky bastard to fix. 

Ok. I will try and send a pull request to Patrick before then,
but feel free to send the patches any time. Do you expect
they will be -stable material?
