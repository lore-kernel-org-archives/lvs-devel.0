From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [*v3 PATCH 14/22] IPVS: netns awareness to ip_vs_sync
Date: Sun, 2 Jan 2011 10:47:30 +0100
Message-ID: <201101021047.31268.hans@schillstrom.com>
References: <1293706266-27152-1-git-send-email-hans@schillstrom.com> <1293706266-27152-15-git-send-email-hans@schillstrom.com> <20101231004433.GA14681@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101231004433.GA14681@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: ja@ssi.bg, daniel.lezcano@free.fr, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Hans Schillstrom <hans.schillstrom@ericsson.com>


On Friday, December 31, 2010 01:44:33 Simon Horman wrote:
> On Thu, Dec 30, 2010 at 11:50:58AM +0100, hans@schillstrom.com wrote:
> > From: Hans Schillstrom <hans.schillstrom@ericsson.com>
> > 
> > All global variables moved to struct ipvs,
> > most external changes fixed (i.e. init_net removed)
> > in sync_buf create  + 4 replaced by sizeof(struct..)
> 
> [ snip ]
> 
> > diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> > index 0454a11..5d6e250 100644
> > --- a/net/netfilter/ipvs/ip_vs_core.c
> > +++ b/net/netfilter/ipvs/ip_vs_core.c
> > @@ -1477,6 +1477,8 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
> >  	struct ip_vs_proto_data *pd;
> >  	struct ip_vs_conn *cp;
> >  	int ret, restart, pkts;
> > +	struct net *net;
> 
> The line above adds a duplicate declaration of net as
> just before the diff-context starts there is
> 
> 	struct net *net = NULL;
> 
I'll remove that
