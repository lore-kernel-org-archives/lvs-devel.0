From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH 00/12] ipvs: changes for local server and local client
Date: Thu, 21 Oct 2010 15:09:41 +0200
Message-ID: <201010211509.42629.hans.schillstrom@ericsson.com>
References: <alpine.LFD.2.00.1010171607550.20665@ja.ssi.bg> <alpine.LFD.2.00.1010182259500.1763@ja.ssi.bg> <20101021092114.GA11154@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101021092114.GA11154@verge.net.au>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>

HOn Thursday 21 October 2010 11:21:14 Simon Horman wrote:
> On Mon, Oct 18, 2010 at 11:08:00PM +0300, Julian Anastasov wrote:
> >
> > 	Hello,
> >
> > On Mon, 18 Oct 2010, Hans Schillstrom wrote:
> >
> > >>Not tested: IPv6. I'll need help here from people with IPv6 setups.
> > >>
> > >
> > >I can help you with some IPv6 testing this week.
> >
> > 	Thanks in advance
> >
> > >I would be nice to change the IPv6 address print format from %pI6 to %pI6c to get a more compact debug output.
> >
> > 	Yes, may be in following cleanup patches because the
> > IPVS debugging needs improvement.
>
> Hi,
>
> I am happy with this series.
> Do either of you have any objections in me sending
> it to Patrick for merging. The merge window is now open,
> but hopefully we can still get this into 2.6.37-rc1 if we move quickly.
>
Hi,
I'm also happy with it, a basic sanity check for IPv6 performed


--
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
