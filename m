From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [nf-next PATCH v2] ipvs: fix build errors related to config
 option combinations
Date: Tue, 23 Oct 2012 10:42:41 +0200
Message-ID: <20121023084241.GA7079@1984>
References: <20121022192245.12620.84466.stgit@dragon>
 <20121023003314.GC5015@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121023003314.GC5015@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, fengguang.wu@intel.com, yuanhan.liu@linux.intel.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Hans Schillstrom <hans.schillstrom@ericsson.com>

On Tue, Oct 23, 2012 at 09:33:15AM +0900, Simon Horman wrote:
> On Mon, Oct 22, 2012 at 09:22:45PM +0200, Jesper Dangaard Brouer wrote:
> > Fix two build error introduced by commit 63dca2c0:
> >  "ipvs: Fix faulty IPv6 extension header handling in IPVS"
> > 
> > First build error was fairly trivial and can occur, when
> > CONFIG_IP_VS_IPV6 is disabled.
> > 
> > The second build error was tricky, and can occur when deselecting
> > both all Netfilter and IPVS, but selecting CONFIG_IPV6.  This is
> > caused by "kernel/sysctl_binary.c" including "net/ip_vs.h", which
> > includes "linux/netfilter_ipv6/ip6_tables.h" causing include
> > of "include/linux/netfilter/x_tables.h" which then cannot find
> > the typedef nf_hookfn.
> > 
> > Fix this by only including "linux/netfilter_ipv6/ip6_tables.h" in
> > case of CONFIG_IP_VS_IPV6 as its already used to guard the usage
> > of ipv6_find_hdr().
> 
> Thanks, I have verified both of these fixes and I will send a pull
> request ASAP.
> 
> I do wonder how we might get earlier test coverage of these kinds of problems.

David already mentioned that we (Netfilter/IPVS) should aim to reduce
the amount of ifdef pollution in the code. Sometimes it is possible in
a nice way by encapsulating code that depends on the feature in one
single file.

Sometimes it also requires some more thinking to make it that way (not
as easy as adding ifdef).

I think if we aim to that, we can avoid this sort of problems.
