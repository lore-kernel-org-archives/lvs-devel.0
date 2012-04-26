From: Simon Horman <horms@verge.net.au>
Subject: Re: [v2 PATCH 0/2] ipvs: netns avoid crash at netns init
Date: Thu, 26 Apr 2012 17:57:46 +0900
Message-ID: <20120426085744.GA3537@verge.net.au>
References: <1335426335-5093-1-git-send-email-hans.schillstrom@ericsson.com>
 <alpine.LFD.2.00.1204261126340.1879@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1204261126340.1879@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans@schillstrom.com

On Thu, Apr 26, 2012 at 11:30:00AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 26 Apr 2012, Hans Schillstrom wrote:
> 
> > Two simple patches that avoid crashes for no memory at netns init.
> > 
> > - Check return value of protocoll init.
> > - Null check of net-ipvs in shedulers.
> > 
> > 
> > Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> 
> 	Both patches look ok
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks, applied to ipvs.
