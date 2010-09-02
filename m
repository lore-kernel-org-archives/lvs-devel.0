From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: avoid oops for passive FTP
Date: Thu, 2 Sep 2010 10:52:30 +0900
Message-ID: <20100902015229.GO8174@verge.net.au>
References: <Pine.LNX.4.58.1009020226350.14271@u.domain.uli>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.1009020226350.14271@u.domain.uli>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Thu, Sep 02, 2010 at 02:35:14AM +0300, Julian Anastasov wrote:
> 
> 	Fix Passive FTP problem in ip_vs_ftp:
> 
> - Do not oops in nf_nat_set_seq_adjust (adjust_tcp_sequence) when
> iptable_nat module is not loaded
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
> 
> 	This patch is for 2.6.36

Thanks, looks good. Are you ready for me to send this to netdev and Dave Miller?
Also, I know that you are working on the bigger picture for post 2.6.36,
but I think it would be worth getting this change into net-next now.
Likewise for the next patch.

Signed-off-by: Simon Horman <horms@verge.net.au>

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
