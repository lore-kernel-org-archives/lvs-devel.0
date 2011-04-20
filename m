From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [PATCH 3/3] IPVS: init and cleanup restructuring.
Date: Wed, 20 Apr 2011 14:00:09 +0200
Message-ID: <201104201400.10175.hans@schillstrom.com>
References: <1303226705-29178-1-git-send-email-hans@schillstrom.com> <1303226705-29178-3-git-send-email-hans@schillstrom.com> <20110419231234.GE6418@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20110419231234.GE6418@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: ja@ssi.bg, ebiederm@xmission.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, hans.schillstrom@ericsson.com

On Wednesday, April 20, 2011 01:12:34 Simon Horman wrote:
> On Tue, Apr 19, 2011 at 05:25:05PM +0200, Hans Schillstrom wrote:
> > This patch tries to restore the initial init and cleanup
> > sequences that was before name space patch.
[snip]
> perhaps enable or active would be names that fits better with the
> schemantics used.  Using a bool might also make things more obvious.

I'll use enable
> 
[snip]
> 
> Can we just remove ip_vs_app_init() and ip_vs_app_cleanup() as
> they no longer do anything? Likewise with other init and cleanup
> functions below.

I will add a "final" patch that removes empty functions,
(They are nice to have during the review, to keep track of the order in different contexts)

> 
> > diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> > index 36cd5ea..f8d6702 100644
> > --- a/net/netfilter/ipvs/ip_vs_conn.c
> > +++ b/net/netfilter/ipvs/ip_vs_conn.c
> > @@ -1251,30 +1251,30 @@ int __net_init __ip_vs_conn_init(struct net *net)
> >  {
> >  	struct netns_ipvs *ipvs = net_ipvs(net);
> > 
> > +	EnterFunction(2);
> >  	atomic_set(&ipvs->conn_count, 0);
> > 
> >  	proc_net_fops_create(net, "ip_vs_conn", 0, &ip_vs_conn_fops);
> >  	proc_net_fops_create(net, "ip_vs_conn_sync", 0, &ip_vs_conn_sync_fops);
> > +	LeaveFunction(2);
> >  	return 0;
> >  }
> 
> Does adding these EnterFunction() and LeaveFunction() calls
> restore some previous behaviour? If not, I think they should at the very
> least be in a separate patch. Likewise for similar changes below.
> 

I can remove them if you want, (but they are nice for debugging)

[snip]
> 
> While I do prefer labels to be in column 0, putting those changes
> here is rather a lot of noise. Could you put them in a separate patch?

OK it will be patch no 1 later on

Regards
Hans
