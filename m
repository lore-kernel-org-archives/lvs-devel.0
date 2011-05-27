From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH 1/1] IPVS : bug in ip_vs_ftp, same list heaad used in all netns.
Date: Fri, 27 May 2011 07:24:22 +0200
Message-ID: <201105270724.24129.hans.schillstrom@ericsson.com>
References: <1306239065-17271-1-git-send-email-hans.schillstrom@ericsson.com> <4DDE8B3E.30009@netfilter.org> <20110526233744.GD2815@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20110526233744.GD2815@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, "ja@ssi.bg" <ja@ssi.bg>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "hans@schillstrom.com" <hans@schillstrom.com>

On Friday 27 May 2011 01:37:45 Simon Horman wrote:
> On Thu, May 26, 2011 at 07:17:50PM +0200, Pablo Neira Ayuso wrote:
> > On 24/05/11 14:11, Hans Schillstrom wrote:
> > > When ip_vs was adapted to netns the ftp application was not adapted
> > > in a correct way.
> > > However this is a fix to avoid kernel errors. In the long term another solution
> > > might be chosen.  I.e the ports that the ftp appl, uses should be per netns.
> > 
> > applied, thanks.
> 
> Thanks Pablo.
> 
> Hans, is this appropriate for -stable (i.e. 2.6.39.x) ?

Yes it is.
-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
