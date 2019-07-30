From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net v2] ipvs: Improve robustness to the ipvs sysctl
Date: Tue, 30 Jul 2019 22:29:26 +0300 (EEST)
Message-ID: <alpine.LFD.2.21.1907302226340.4897@ja.home.ssi.bg>
References: <1997375e-815d-137f-20c9-0829a8587ee9@huawei.com> <4a0476d3-57a4-50e0-cae8-9dffc4f4d556@huawei.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4a0476d3-57a4-50e0-cae8-9dffc4f4d556@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hujunwei <hujunwei4@huawei.com>
Cc: wensong@linux-vs.org, horms@verge.net.au, pablo@netfilter.org, kadlec@blackhole.kfki.hu, Florian Westphal <fw@strlen.de>, davem@davemloft.net, Florian Westphal <fw@strlen.de>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, Mingfangsen <mingfangsen@huawei.com>, wangxiaogang3@huawei.com, xuhanbing@huawei.com


	Hello,

On Tue, 30 Jul 2019, hujunwei wrote:

> From: Junwei Hu <hujunwei4@huawei.com>
> 
> The ipvs module parse the user buffer and save it to sysctl,
> then check if the value is valid. invalid value occurs
> over a period of time.
> Here, I add a variable, struct ctl_table tmp, used to read
> the value from the user buffer, and save only when it is valid.
> I delete proc_do_sync_mode and use extra1/2 in table for the
> proc_dointvec_minmax call.
> 
> Fixes: f73181c8288f ("ipvs: add support for sync threads")
> Signed-off-by: Junwei Hu <hujunwei4@huawei.com>

	Looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

	BTW, why ip_vs_zero_all everywhere? Due to old git version?

> ---
> V1->V2:
> - delete proc_do_sync_mode and use proc_dointvec_minmax call.
> ---
>  net/netfilter/ipvs/ip_vs_ctl.c | 69 +++++++++++++++++++++---------------------
>  1 file changed, 35 insertions(+), 34 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 060565e..7aed7b0 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1737,12 +1737,18 @@ static int ip_vs_zero_all(struct netns_ipvs *ipvs)
>  	int val = *valp;
>  	int rc;
> 
> -	rc = proc_dointvec(table, write, buffer, lenp, ppos);
> +	struct ctl_table tmp = {
> +		.data = &val,
> +		.maxlen = sizeof(int),
> +		.mode = table->mode,
> +	};
> +
> +	rc = proc_dointvec(&tmp, write, buffer, lenp, ppos);
>  	if (write && (*valp != val)) {
> -		if ((*valp < 0) || (*valp > 3)) {
> -			/* Restore the correct value */
> +		if (val < 0 || val > 3) {
> +			rc = -EINVAL;
> +		} else {
>  			*valp = val;
> -		} else {
>  			update_defense_level(ipvs);
>  		}
>  	}
> @@ -1756,33 +1762,20 @@ static int ip_vs_zero_all(struct netns_ipvs *ipvs)
>  	int *valp = table->data;
>  	int val[2];
>  	int rc;
> +	struct ctl_table tmp = {
> +		.data = &val,
> +		.maxlen = table->maxlen,
> +		.mode = table->mode,
> +	};
> 
> -	/* backup the value first */
>  	memcpy(val, valp, sizeof(val));
> -
> -	rc = proc_dointvec(table, write, buffer, lenp, ppos);
> -	if (write && (valp[0] < 0 || valp[1] < 0 ||
> -	    (valp[0] >= valp[1] && valp[1]))) {
> -		/* Restore the correct value */
> -		memcpy(valp, val, sizeof(val));
> -	}
> -	return rc;
> -}
> -
> -static int
> -proc_do_sync_mode(struct ctl_table *table, int write,
> -		     void __user *buffer, size_t *lenp, loff_t *ppos)
> -{
> -	int *valp = table->data;
> -	int val = *valp;
> -	int rc;
> -
> -	rc = proc_dointvec(table, write, buffer, lenp, ppos);
> -	if (write && (*valp != val)) {
> -		if ((*valp < 0) || (*valp > 1)) {
> -			/* Restore the correct value */
> -			*valp = val;
> -		}
> +	rc = proc_dointvec(&tmp, write, buffer, lenp, ppos);
> +	if (write) {
> +		if (val[0] < 0 || val[1] < 0 ||
> +		    (val[0] >= val[1] && val[1]))
> +			rc = -EINVAL;
> +		else
> +			memcpy(valp, val, sizeof(val));
>  	}
>  	return rc;
>  }
> @@ -1795,12 +1788,18 @@ static int ip_vs_zero_all(struct netns_ipvs *ipvs)
>  	int val = *valp;
>  	int rc;
> 
> -	rc = proc_dointvec(table, write, buffer, lenp, ppos);
> +	struct ctl_table tmp = {
> +		.data = &val,
> +		.maxlen = sizeof(int),
> +		.mode = table->mode,
> +	};
> +
> +	rc = proc_dointvec(&tmp, write, buffer, lenp, ppos);
>  	if (write && (*valp != val)) {
> -		if (*valp < 1 || !is_power_of_2(*valp)) {
> -			/* Restore the correct value */
> +		if (val < 1 || !is_power_of_2(val))
> +			rc = -EINVAL;
> +		else
>  			*valp = val;
> -		}
>  	}
>  	return rc;
>  }
> @@ -1860,7 +1859,9 @@ static int ip_vs_zero_all(struct netns_ipvs *ipvs)
>  		.procname	= "sync_version",
>  		.maxlen		= sizeof(int),
>  		.mode		= 0644,
> -		.proc_handler	= proc_do_sync_mode,
> +		.proc_handler	= proc_dointvec_minmax,
> +		.extra1		= SYSCTL_ZERO,
> +		.extra2		= SYSCTL_ONE,
>  	},
>  	{
>  		.procname	= "sync_ports",
> -- 
> 1.7.12.4

Regards
