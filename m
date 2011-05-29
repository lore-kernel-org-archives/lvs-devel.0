From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/1] IPVS : bug in ip_vs_ftp, same list heaad used in all
 netns.
Date: Sun, 29 May 2011 11:10:20 +0900
Message-ID: <20110529021018.GL32395@verge.net.au>
References: <1306239065-17271-1-git-send-email-hans.schillstrom@ericsson.com>
 <4DDE8B3E.30009@netfilter.org>
 <20110526233744.GD2815@verge.net.au>
 <201105270724.24129.hans.schillstrom@ericsson.com>
 <20110527060409.GB24641@verge.net.au>
 <4DDF6FE5.507@netfilter.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4DDF6FE5.507@netfilter.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, "ja@ssi.bg" <ja@ssi.bg>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "hans@schillstrom.com" <hans@schillstrom.com>, David Miller <davem@davemloft.net>

On Fri, May 27, 2011 at 11:33:25AM +0200, Pablo Neira Ayuso wrote:
> On 27/05/11 08:04, Simon Horman wrote:
> > On Fri, May 27, 2011 at 07:24:22AM +0200, Hans Schillstrom wrote:
> >> On Friday 27 May 2011 01:37:45 Simon Horman wrote:
> >>> On Thu, May 26, 2011 at 07:17:50PM +0200, Pablo Neira Ayuso wrote:
> >>>> On 24/05/11 14:11, Hans Schillstrom wrote:
> >>>>> When ip_vs was adapted to netns the ftp application was not adapted
> >>>>> in a correct way.
> >>>>> However this is a fix to avoid kernel errors. In the long term another solution
> >>>>> might be chosen.  I.e the ports that the ftp appl, uses should be per netns.
> >>>>
> >>>> applied, thanks.
> >>>
> >>> Thanks Pablo.
> >>>
> >>> Hans, is this appropriate for -stable (i.e. 2.6.39.x) ?
> >>
> >> Yes it is.
> > 
> > Thanks.
> > 
> > Dave, can you handle that once this change makes
> > it into your tree?
> 
> http://permalink.gmane.org/gmane.linux.kernel.wireless.general/70374

Thanks, I missed that.
