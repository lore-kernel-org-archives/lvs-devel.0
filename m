From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [RFC PATCH 2/9] ipvs network name space aware
Date: Tue, 12 Oct 2010 16:36:48 +0200
Message-ID: <201010121636.49640.hans.schillstrom@ericsson.com>
References: <201010081316.54676.hans.schillstrom@ericsson.com> <4CB470FC.7070500@free.fr>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4CB470FC.7070500@free.fr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Daniel Lezcano <daniel.lezcano@free.fr>
Cc: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "horms@verge.net.au" <horms@verge.net.au>, "ja@ssi.bg" <ja@ssi.bg>, "wensong@linux-vs.org" <wensong@linux-vs.org>

On Tuesday 12 October 2010 16:30:20 Daniel Lezcano wrote:
> On 10/08/2010 01:16 PM, Hans Schillstrom wrote:
> > This part contains the include files
> > where include/net/netns/ip_vs.h is new and contains all moved vars.
> >
> > SUMMARY
> >
> >   include/net/ip_vs.h                     |  136 ++++---
> >   include/net/net_namespace.h             |    2 +
> >   include/net/netns/ip_vs.h               |  112 +++++
> >
> > Signed-off-by:Hans Schillstrom<hans.schillstrom@ericsson.com>
> > ---
> >    
> 
> Why are patch 1 and 2 the same ?
> 
> 
Cut & Paste error :-)

I'll resend patch 2


-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
