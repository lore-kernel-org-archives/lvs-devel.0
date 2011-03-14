From: Simon Horman <horms@verge.net.au>
Subject: Re: [GIT PULL nf-next-2.6] IPVS
Date: Tue, 15 Mar 2011 08:13:27 +0900
Message-ID: <20110314231327.GE2788@verge.net.au>
References: <1300056261-14709-1-git-send-email-horms@verge.net.au>
 <4D7E5BBE.7060702@trash.net>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D7E5BBE.7060702@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, Hans Schillstrom <hans@schillstrom.com>, Julian Anastasov <ja@ssi.bg>

On Mon, Mar 14, 2011 at 07:17:34PM +0100, Patrick McHardy wrote:
> On 13.03.2011 23:44, Simon Horman wrote:
> > Hi Patrick,
> > 
> > please consider pulling
> > git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git master
> > to get the following changes.
> > 
> > Jesper Juhl (1):
> >       Fix variable assignment in ip_vs_notrack
> > 
> > Julian Anastasov (2):
> >       ipvs: avoid lookup for fwmark 0
> >       ipvs: remove _bh from percpu stats reading
> > 
> > Shan Wei (1):
> >       netfilter:ipvs: use kmemdup
> > 
> >  include/net/ip_vs.h               |    2 +-
> >  net/netfilter/ipvs/ip_vs_ctl.c    |    8 +++++---
> >  net/netfilter/ipvs/ip_vs_est.c    |    8 ++++----
> >  net/netfilter/ipvs/ip_vs_pe_sip.c |    9 ++++-----
> >  net/netfilter/ipvs/ip_vs_sync.c   |    3 +--
> >  5 files changed, 15 insertions(+), 15 deletions(-)
> 
> The pull contained quite a lot of other changes. I'm undoing the
> pull for now, please resubmit the patches you actually want me to
> pull. Thanks!

Sorry about that. I will double check things but
the list below looks like the second request that I sent out
yesterday.

> 
> Jesper Juhl (1):
>       Fix variable assignment in ip_vs_notrack
> 
> Julian Anastasov (8):
>       ipvs: avoid lookup for fwmark 0
>       ipvs: remove _bh from percpu stats reading
>       ipvs: move struct netns_ipvs
>       ipvs: reorganize tot_stats
>       ipvs: properly zero stats and rates
>       ipvs: remove unused seqcount stats
>       ipvs: optimize rates reading
>       ipvs: rename estimator functions
> 
> Patrick McHardy (1):
>       Merge branch 'master' of git://git.kernel.org/.../horms/lvs-test-2.6
> 
> Shan Wei (1):
>       netfilter:ipvs: use kmemdup
> 
> Simon Horman (14):
>       IPVS: Add ip_vs_route_me_harder()
>       IPVS: Add sysctl_snat_reroute()
>       IPVS: Add sysctl_nat_icmp_send()
>       IPVS: Add {sysctl_sync_threshold,period}()
>       IPVS: Add sysctl_sync_ver()
>       IPVS: Add sysctl_expire_nodest_conn()
>       IPVS: Add expire_quiescent_template()
>       IPVS: Conditinally use sysctl_lblc{r}_expiration
>       IPVS: ip_vs_todrop() becomes a noop when CONFIG_SYSCTL is undefined
>       IPVS: Conditional ip_vs_conntrack_enabled()
>       IPVS: Minimise ip_vs_leave when CONFIG_SYSCTL is undefined
>       IPVS: Conditionally define and use ip_vs_lblc{r}_table
>       IPVS: Add __ip_vs_control_{init,cleanup}_sysctl()
>       IPVS: Conditionally include sysctl members of struct netns_ipvs
> 
