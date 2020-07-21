From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] ipvs: add missing struct name in
 ip_vs_enqueue_expire_nodest_conns when CONFIG_SYSCTL is disabled
Date: Wed, 22 Jul 2020 01:20:07 +0200
Message-ID: <20200721232007.GA6367@salvia>
References: <20200717162450.1049-1-kim.andrewsy@gmail.com>
 <alpine.LFD.2.23.451.2007172032370.4536@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.23.451.2007172032370.4536@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Andrew Sy Kim <kim.andrewsy@gmail.com>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Randy Dunlap <rdunlap@infradead.org>, netdev@vger.kernel.org

On Fri, Jul 17, 2020 at 08:36:36PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Fri, 17 Jul 2020, Andrew Sy Kim wrote:
> 
> > Adds missing "*ipvs" to ip_vs_enqueue_expire_nodest_conns when
> > CONFIG_SYSCTL is disabled
> > 
> > Signed-off-by: Andrew Sy Kim <kim.andrewsy@gmail.com>
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Pablo, please apply this too.

I have squashed this fix and "ipvs: ensure RCU read unlock when
connection flushing and ipvs is disabled" into the original patch:

"ipvs: queue delayed work to expire no destination connections if
expire_nodest_conn=1"
