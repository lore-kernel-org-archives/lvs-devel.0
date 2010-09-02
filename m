From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [patch net] ipvs: avoid oops for passive FTP
Date: Thu, 2 Sep 2010 23:52:16 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.1009022310030.2891@u.domain.uli>
References: <20100902090709.GA15401@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100902090709.GA15401@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>, Wensong Zhang <wensong@linux-vs.org>


	Hello,

On Thu, 2 Sep 2010, Simon Horman wrote:

> From: Julian Anastasov <ja@ssi.bg>
> 
> Fix Passive FTP problem in ip_vs_ftp:
> 
> - Do not oops in nf_nat_set_seq_adjust (adjust_tcp_sequence) when
>   iptable_nat module is not loaded
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> ---
> 
> Dave, this patch fixes a regression since 2.6.35 so please consider it for net.
> Julian has also found another regression, but the fix is a bit
> more complex so I have posted it to the netfilter list for review.

	Just to clarify that both patches for ip_vs_ftp are
only for code that come in 2.6.36-rc, 2.6.35 is ok and does
not need them.

	The other problem is that 2.6.36-rc comes with
requirement IPVS to keep netfilter conntracks for all
connections, eg. DirectRouting, not only for LVS-NAT (ip_vs_ftp).
I have a bigger patch to make the IPVS conntracking support
an option (enabled by default only for ip_vs_ftp) but
may be it is not appropriate for -rc series. So, for now
we are fixing just the fatal problems but the risk of
IPVS setups with low nf_conntrack_max value to stop
processing high loads remains without making the conntrack
support an option. Before now all conntracks were created
and destroyed for every packet and nf_conntrack_max,
even if low, probably is never reached.

> 	http://marc.info/?l=netfilter-devel&m=128339248723532&w=2
> 
> This change (and the other one) is also applicable to net-next, although
> there is some diff noise. Do you want me to resolve that and post a
> net-next version separately?
> 
> --- v2.6.36-rc2/linux/net/netfilter/ipvs/ip_vs_ftp.c	2010-09-02 00:45:54.000000000 +0300
> +++ linux/net/netfilter/ipvs/ip_vs_ftp.c	2010-09-02 02:12:52.000000000 +0300
> @@ -45,6 +45,7 @@
>  #include <linux/netfilter.h>
>  #include <net/netfilter/nf_conntrack.h>
>  #include <net/netfilter/nf_conntrack_expect.h>
> +#include <net/netfilter/nf_nat.h>
>  #include <net/netfilter/nf_nat_helper.h>
>  #include <linux/gfp.h>
>  #include <net/protocol.h>
> @@ -359,7 +360,7 @@ static int ip_vs_ftp_out(struct ip_vs_ap
>  		buf_len = strlen(buf);
>  
>  		ct = nf_ct_get(skb, &ctinfo);
> -		if (ct && !nf_ct_is_untracked(ct)) {
> +		if (ct && !nf_ct_is_untracked(ct) && nfct_nat(ct)) {
>  			/* If mangling fails this function will return 0
>  			 * which will cause the packet to be dropped.
>  			 * Mangling can only fail under memory pressure,

Regards

--
Julian Anastasov <ja@ssi.bg>
