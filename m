From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next v4] net: ipvs: add sysctl_run_estimation to
 support disable estimation
Date: Thu, 7 Oct 2021 19:53:32 +0200
Message-ID: <YV80HOzv+2oV4ppf@salvia>
References: <20210820053752.11508-1-dust.li@linux.alibaba.com>
 <5f590b6-4668-19fe-b768-15125f48df1e@ssi.bg>
 <20211002085929.GA27500@vergenet.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20211002085929.GA27500@vergenet.net>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, Dust Li <dust.li@linux.alibaba.com>, Wensong Zhang <wensong@linux-vs.org>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>

On Sat, Oct 02, 2021 at 10:59:29AM +0200, Simon Horman wrote:
> On Sat, Aug 21, 2021 at 11:41:50AM +0300, Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Fri, 20 Aug 2021, Dust Li wrote:
> > 
> > > estimation_timer will iterate the est_list to do estimation
> > > for each ipvs stats. When there are lots of services, the
> > > list can be very large.
> > > We found that estimation_timer() run for more then 200ms on a
> > > machine with 104 CPU and 50K services.
> > > 
> > > yunhong-cgl jiang report the same phenomenon before:
> > > https://www.spinics.net/lists/lvs-devel/msg05426.html
> > > 
> > > In some cases(for example a large K8S cluster with many ipvs services),
> > > ipvs estimation may not be needed. So adding a sysctl blob to allow
> > > users to disable this completely.
> > > 
> > > Default is: 1 (enable)
> > > 
> > > Cc: yunhong-cgl jiang <xintian1976@gmail.com>
> > > Signed-off-by: Dust Li <dust.li@linux.alibaba.com>
> > 
> > 	Looks good to me, thanks!
> > 
> > Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> Likwewise, thanks. And sorry for the delay.
> 
> Acked-by: Simon Horman <horms@verge.net.au>
> 
> Pablo, could you consider picking this up?

Applied, thanks.
