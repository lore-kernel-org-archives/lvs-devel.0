From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] b44: add 64 bit stats
Date: Sat, 21 Jul 2012 13:12:04 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1207211300460.1849@ja.ssi.bg>
References: <CABF+-6XaYk8qXnFNXF_+rQ144jyDFgFqDVKsuZv+S_0VZxBAvw@mail.gmail.com>  <1342337165.3265.10640.camel@edumazet-glaptop>  <CABF+-6XVCTDZedzcp-gWACYpG9NLmZUdwW2zsXC8WNKWk3dE5w@mail.gmail.com>  <1342759989.2626.5472.camel@edumazet-glaptop> 
 <1342761865.2626.5572.camel@edumazet-glaptop>  <CABF+-6Ubh6rSYV=L8-QV466XNo5OqCxA+4DRqXGdELhnSPkPZQ@mail.gmail.com>  <CABF+-6XGO0Qvqd1O-aY28kG1jV=L6eRcupnZpaimTunddPwL2A@mail.gmail.com> <1342847376.2626.8162.camel@edumazet-glaptop>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1342847376.2626.8162.camel@edumazet-glaptop>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Kevin Groeneveld <kgroeneveld@gmail.com>, netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>, lvs-devel@vger.kernel.org


	Hello,

On Sat, 21 Jul 2012, Eric Dumazet wrote:

> The writer sides might be run concurrently by several cpus, so
> u64_stats_update_begin(&sstats->syncp); are racy : a reader can
> be trapped forever.
> 
> > net/netfilter/ipvs/ip_vs_est.c
> > 
> 
> Same problem for this one, I think.
> 
> I CCed ipvs maintainers so that they can take a look.

	IPVS moved to percpu counters, i.e. even on 32-bit SMP
we do not use locks to protect the seqcounter:

commit b17fc9963f837ef1acfe36e193108fb16ed58647
Author: Hans Schillstrom <hans.schillstrom@ericsson.com>
Date:   Mon Jan 3 14:44:56 2011 +0100

    IPVS: netns, ip_vs_stats and its procfs

> > Do these need to be updated as well?  Looking at these files quickly
> > and with my limited knowledge of the kernel I am not sure if they
> > update the stats in a BH context or not.

	We have 2 kinds of readers:

- timer context (ip_vs_est.c): no _bh is used for fetch
- user context (ip_vs_ctl.c): _bh is used for fetch

> > Kevin
> 
> Thanks !

Regards

--
Julian Anastasov <ja@ssi.bg>
