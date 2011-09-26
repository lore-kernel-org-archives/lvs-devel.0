From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [PATCH 0/4] IPVS: sysctl Documentation and Various Clean-Ups
Date: Mon, 26 Sep 2011 08:43:17 +0200
Message-ID: <201109260843.18257.hans@schillstrom.com>
References: <1317000233-11169-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1317000233-11169-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

Hello Simon

On Monday, September 26, 2011 03:23:49 Simon Horman wrote:
> Hi,
> 
> patch one of this series adds some missing entries to the sysctl
> documentation. Julian, I would appreciate a review of this change.
> 
> The remaining three patches are minor code clean-ups flagged
> by gcc 4.6.1.
> 
> My intention for this post is to solicit review.
> I intend to post a pull request separately at a later date.
> 

Your patches looks fine to me,
you can have mine ack as well

Acked-by Hans Schillstrom <hans@schillstrom.com>

I have two small pending patches,  Deadlock and lockdep fixes. 
Hopefully the patches will be ready this week. The deadlock is a tricky bastard to fix. 

Regards
Hans
