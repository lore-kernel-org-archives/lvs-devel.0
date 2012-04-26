From: Simon Horman <horms@verge.net.au>
Subject: Re: [v2 PATCH 1/1] ipvs: kernel oops - do_ip_vs_get_ctl
Date: Thu, 26 Apr 2012 18:05:20 +0900
Message-ID: <20120426090520.GA5801@verge.net.au>
References: <1335419264-1225-1-git-send-email-hans.schillstrom@ericsson.com>
 <1335427841.3131.28.camel@t520>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1335427841.3131.28.camel@t520>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, ja@ssi.bg, wensong@linux-vs.org, rohara@redhat.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans@schillstrom.com

On Thu, Apr 26, 2012 at 10:10:41AM +0200, Jesper Dangaard Brouer wrote:
> On Thu, 2012-04-26 at 07:47 +0200, Hans Schillstrom wrote:
> > Change order of init so netns init is ready
> > when register ioctl and netlink.
> > 
> > Ver2 
> > 	Whitespace fixes and __init added.
> > 
> > Reported-by: "Ryan O'Hara" <rohara@redhat.com>
> > Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
> 
> Looks good, interdiff says you fixed up things, and I have tested it
> against the net tree, good work :-)
> 
> Is this a stable tree candidate?

Yes, I think so.

I now have the following 7 changes in my ipvs tree on kernel.org.

The last two are already in Pablo's net tree and I intend
to send a pull request for the remaining 5 soon.

It is my opinion that all 7 patches are stable tree material.

ipvs: kernel oops - do_ip_vs_get_ctl
ipvs: take care of return value from protocol init_netns
ipvs: null check of net->ipvs in lblc(r) shedulers
ipvs: reset ipvs pointer in netns
ipvs: add check in ftp for initialized core
ipvs: fix crash in ip_vs_control_net_cleanup on unload
ipvs: Verify that IP_VS protocol has been registered


