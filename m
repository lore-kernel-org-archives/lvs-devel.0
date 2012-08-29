From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Re[3]: [PATCH 2/3] ipvs: Fix faulty IPv6 extension header 
 handling in IPVS
Date: Wed, 29 Aug 2012 11:37:14 +0200
Message-ID: <1346233034.3069.450.camel@localhost>
References: <mdaatbj.7a4274ea6c8f14ea15788c8953acb422@obelix.schillstrom.com>
	 <Pine.GSO.4.63.1208271401140.17922@stinky-local.trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.GSO.4.63.1208271401140.17922@stinky-local.trash.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: Hans Schillstrom <hans@schillstrom.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org

To Hans and Patrick,

On Mon, 2012-08-27 at 14:02 +0200, Patrick McHardy wrote:
> On Mon, 27 Aug 2012, Hans Schillstrom wrote:
> 
> >>>>
> >>>> On Mon, 20 Aug 2012, Jesper Dangaard Brouer wrote:
> >>>>
> >>>>> Based on patch from: Hans Schillstrom
> >>>>>
> >>>>> IPv6 headers must be processed in order of appearance,
> >>>>> neither can it be assumed that Upper layer headers is first.
> >>>>> If anything else than L4 is the first header IPVS will throw it.
> >>>>>
> >>>>> IPVS will write SNAT & DNAT modifications at a fixed pos which
> >>>>> will corrupt the message. Proper header position must be found
> >>>>> before writing modifying packet.
> >>>>>
> >>>>> This patch contains a lot of API changes.  This is done, to avoid
> >>>>> the costly scan of finding the IPv6 headers, via ipv6_find_hdr().
> >>>>> Finding the IPv6 headers is done as early as possible, and passed
> >>>>> on as a pointer "struct ip_vs_iphdr *" to the affected functions.
> >>>>
> >>>> How about we change netfilter to set up the skb's transport header
> >>>> at an early time so we can avoid all (most of) these header scans
> >>>> in netfilter?
> >>>
> >>> I think that would be great, maybe it should be global i.e. not only a netfilter issue.
> >>
> >> I think in most other cases the headers are supposed to be processed
> >> sequentially. One problem though - to be useful for netfilter/IPVS
> >> we'd also need to store the transport layer protocol somewhere.
> >
> > I guess that's the problem, adding it to the skb will not be popular ....
> > Right now I don't have a good solution, maybe a more generic netfilter ptr in the skb ...
> 
> I guess inet6_skb_parm will be at least slightly more popular than
> adding it to the skb itself. The netfilter pointers are all used for
> optional things, so we can't really add it to any of those.

Okay, but how do we go from here?

Hans, should this hold back the patch ("ipvs: Fix faulty IPv6 extension
header handling in IPVS").  Or should we pursue our patch, and circle
back later once e.g. Patrick have found a generic solution for IPv6
transport header handling?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer


