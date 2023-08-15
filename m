From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: fix racy memcpy in proc_do_sync_threshold
Date: Tue, 15 Aug 2023 05:53:43 +0300 (EEST)
Message-ID: <359e4898-01fe-775f-d6a5-753caa585642@ssi.bg>
References: <B556FD7B-3190-4C8F-BA83-FC5C147FEAE1@gmail.com>
Mime-Version: 1.0
Return-path: <netdev+bounces-27553-gl-netdev-2=m.gmane-mx.org@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1692068026; bh=W+Z0WTspsdbpobGPJx4v2/IEO37df2Pimxz6FZTRsNE=;
	h=Date:From:To:cc:Subject:In-Reply-To:References;
	b=TxeJO+ezb/1Wg1XWK+Ukj/7m27bcaURRNEeMnmJPVOkj2TNxLakBZs35qdLh0Yq0o
	 KkCIiZa2vVNK47+s7XUCZCUbfgJ7hXKgufxg0HhnJyM+MspOxpt6k/AwfLPNb26xo4
	 /SFxFbRVCj4TYu8jmeL6Aa2iJgeDnFhnGNlJnzPQ=
In-Reply-To: <B556FD7B-3190-4C8F-BA83-FC5C147FEAE1@gmail.com>
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:netdev+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:netdev+unsubscribe@vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sishuai Gong <sishuai.system@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, Linux Kernel Network Developers <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, netfilter-devel@vger.kernel.org


	Hello,

On Thu, 10 Aug 2023, Sishuai Gong wrote:

> When two threads run proc_do_sync_threshold() in parallel,
> data races could happen between the two memcpy():
> 
> Thread-1			Thread-2
> memcpy(val, valp, sizeof(val));
> 				memcpy(valp, val, sizeof(val));
> 
> This race might mess up the (struct ctl_table *) table->data,
> so we add a mutex lock to serilize them, as discussed in [1].
> 
> [1] https://archive.linuxvirtualserver.org/html/lvs-devel/2023-08/msg00031.html
> 
> Signed-off-by: Sishuai Gong <sishuai.system@gmail.com>

	Looks good to me for net/nf, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_ctl.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 62606fb44d02..4bb0d90eca1c 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1876,6 +1876,7 @@ static int
>  proc_do_sync_threshold(struct ctl_table *table, int write,
>  		       void *buffer, size_t *lenp, loff_t *ppos)
>  {
> +	struct netns_ipvs *ipvs = table->extra2;
>  	int *valp = table->data;
>  	int val[2];
>  	int rc;
> @@ -1885,6 +1886,7 @@ proc_do_sync_threshold(struct ctl_table *table, int write,
>  		.mode = table->mode,
>  	};
>  
> +	mutex_lock(&ipvs->sync_mutex);
>  	memcpy(val, valp, sizeof(val));
>  	rc = proc_dointvec(&tmp, write, buffer, lenp, ppos);
>  	if (write) {
> @@ -1894,6 +1896,7 @@ proc_do_sync_threshold(struct ctl_table *table, int write,
>  		else
>  			memcpy(valp, val, sizeof(val));
>  	}
> +	mutex_unlock(&ipvs->sync_mutex);
>  	return rc;
>  }
>  
> @@ -4321,6 +4324,7 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
>  	ipvs->sysctl_sync_threshold[0] = DEFAULT_SYNC_THRESHOLD;
>  	ipvs->sysctl_sync_threshold[1] = DEFAULT_SYNC_PERIOD;
>  	tbl[idx].data = &ipvs->sysctl_sync_threshold;
> +	tbl[idx].extra2 = ipvs;
>  	tbl[idx++].maxlen = sizeof(ipvs->sysctl_sync_threshold);
>  	ipvs->sysctl_sync_refresh_period = DEFAULT_SYNC_REFRESH_PERIOD;
>  	tbl[idx++].data = &ipvs->sysctl_sync_refresh_period;
> -- 
> 2.39.2 (Apple Git-143)

Regards
