From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [nf-next PATCH] ipvs: fix build error when CONFIG_IP_VS_IPV6 is
 disabled
Date: Mon, 22 Oct 2012 21:24:57 +0200
Message-ID: <1350933897.22194.477.camel@localhost>
References: <20121022121711.31397.6231.stgit@dragon>
	 <Pine.LNX.4.64.1210221732480.3065@ask.diku.dk> <20121022163034.GA6698@1984>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20121022163034.GA6698@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Jesper Dangaard Brouer <hawk@diku.dk>, Simon Horman <horms@verge.net.au>, fengguang.wu@intel.com, yuanhan.liu@linux.intel.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Mon, 2012-10-22 at 18:30 +0200, Pablo Neira Ayuso wrote:
> On Mon, Oct 22, 2012 at 05:39:43PM +0200, Jesper Dangaard Brouer wrote:
> > 
> > Hi Pablo,
> > 
> > Argh - there is one more CONFIG option combi that can cause issues.
> > 
> >  *So hold off on this patch*
> > 
> > Which is related to including linux/netfilter_ipv6/ip6_tables.h
> > under CONFIG_IPV6 when CONFIG_NETFILTER is disabled, as
> > kernel/sysctl_binary.c include net/ip_vs.h.  I'll send a new patch
> > soon!
> 
> Ok, wait for it.

Posted with subj.:
 [nf-next PATCH v2] ipvs: fix build errors related to config option combinations

(Again, I'm very sorry for letting this slip through...)


