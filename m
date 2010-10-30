From: Simon Horman <horms@verge.net.au>
Subject: Re: [RFC PATCH 1/4] IPVS: Prepare for transferring firewall marks
 (fwmark) to the backup daemon.
Date: Sat, 30 Oct 2010 11:40:20 +0900
Message-ID: <20101030024020.GD12842@verge.net.au>
References: <1288090823-31135-1-git-send-email-hans.schillstrom@ericsson.com>
 <20101028120847.GB16206@verge.net.au>
 <201010281451.55630.hans.schillstrom@ericsson.com>
 <201010281458.50533.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201010281458.50533.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "ja@ssi.bg" <ja@ssi.bg>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>

On Thu, Oct 28, 2010 at 02:58:50PM +0200, Hans Schillstrom wrote:
> Hello again
> On Thursday 28 October 2010 14:51:55 Hans Schillstrom wrote:
> [snip]
> >
> > I will prepare and send a version 2 of the patch set today, with
> > the comments included from you and Julian.
> >
> May I should wait, for the "sync_option" answer first,
> If it should be remove it will affect the patch ...

I think that you have already resent the patch series
and it is somewhere further down my inbox.

But in general I don't think there is any particular rush as
its going to be a long time before the 2.6.38 merge window opens up
and I'm not sure that anyone is doing significant LVS work outside
of sync and netns at this time.

