From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ip_vs_sh: fix build
Date: Wed, 29 May 2013 22:31:19 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305292219170.1951@ja.ssi.bg>
References: <51A611CF02000078000D99A6@nat28.tlf.novell.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <51A611CF02000078000D99A6@nat28.tlf.novell.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Beulich <JBeulich@suse.com>
Cc: wensong@linux-vs.org, horms@verge.net.au, pablo@netfilter.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org


	Hello,

On Wed, 29 May 2013, Jan Beulich wrote:

> kfree_rcu() requires offsetof(..., rcu_head) < 4096, which can get
> violated with a sufficiently high CONFIG_IP_VS_SH_TAB_BITS.
> 
> Signed-off-by: Jan Beulich <jbeulich@suse.com>
> 
> ---
>  net/netfilter/ipvs/ip_vs_sh.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- 3.10-rc3/net/netfilter/ipvs/ip_vs_sh.c
> +++ 3.10-rc3-ip_vs_sh-build/net/netfilter/ipvs/ip_vs_sh.c
> @@ -67,8 +67,8 @@ struct ip_vs_sh_bucket {
>  #define IP_VS_SH_TAB_MASK               (IP_VS_SH_TAB_SIZE - 1)
>  
>  struct ip_vs_sh_state {
> -	struct ip_vs_sh_bucket		buckets[IP_VS_SH_TAB_SIZE];
>  	struct rcu_head			rcu_head;
> +	struct ip_vs_sh_bucket		buckets[IP_VS_SH_TAB_SIZE];

	Your fix reminds me about the same problem
I noticed for LBLC (may be due to 10 bits) during development
but forgot to check the other schedulers. The same solution
is needed also for DH. OTOH, LBLC and LBLCR are correct.
Do you prefer to provide similar fix for ip_vs_dh.c or
I have to take care?

>  };
>  
>  /*

Regards

--
Julian Anastasov <ja@ssi.bg>
