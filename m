From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [v2 PATCH 1/1] ipvs: kernel oops - do_ip_vs_get_ctl
Date: Thu, 26 Apr 2012 17:26:41 +0200
Message-ID: <20120426152641.GA21531@1984>
References: <1335419264-1225-1-git-send-email-hans.schillstrom@ericsson.com>
 <1335427841.3131.28.camel@t520>
 <20120426090520.GA5801@verge.net.au>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120426090520.GA5801@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, ja@ssi.bg, wensong@linux-vs.org, rohara@redhat.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans@schillstrom.com

On Thu, Apr 26, 2012 at 06:05:20PM +0900, Simon Horman wrote:
> On Thu, Apr 26, 2012 at 10:10:41AM +0200, Jesper Dangaard Brouer wrote:
> > On Thu, 2012-04-26 at 07:47 +0200, Hans Schillstrom wrote:
> > > Change order of init so netns init is ready
> > > when register ioctl and netlink.
> > > 
> > > Ver2 
> > > 	Whitespace fixes and __init added.
> > > 
> > > Reported-by: "Ryan O'Hara" <rohara@redhat.com>
> > > Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> > 
> > Looks good, interdiff says you fixed up things, and I have tested it
> > against the net tree, good work :-)
> > 
> > Is this a stable tree candidate?
> 
> Yes, I think so.
> 
> I now have the following 7 changes in my ipvs tree on kernel.org.
> 
> The last two are already in Pablo's net tree and I intend
> to send a pull request for the remaining 5 soon.

OK, then I'll wait for that pull request to pass these 7 patch batch
to davem if you make it anytime soon.

> It is my opinion that all 7 patches are stable tree material.

Little reminder: We can ask for this once they have hit Linus' tree.
