From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Race over table->data in proc_do_sync_threshold()
Date: Thu, 10 Aug 2023 21:28:05 +0300 (EEST)
Message-ID: <790529ba-8887-004a-505e-3d552326e1f5@ssi.bg>
References: <B6988E90-0A1E-4B85-BF26-2DAF6D482433@gmail.com> <b4854287-cb97-27fb-053f-e52179c05e97@ssi.bg> <8D17F8D2-BF68-4BA4-8590-7DE1E71872A6@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
        t=1691692087; bh=GEpJwziKVMEJQjWFpY5qyjQHjnvAoeVbPjjlEWPqq04=;
        h=Date:From:To:cc:Subject:In-Reply-To:References;
        b=HK98ndvPoIcaT6VF+mmV5svMpJ84SuLMKKhkmMHoGMRREvr7Ja/MFNBKqvdwn6WSe
         RamfdBb0QP7TYlc7VWrrqDcbUDSzHOZLNtzVxbmbCi+pyFUgW9h+sb9nyDVlOBhlgc
         tiSb1bsVVEWZQQhCoeXkrM8TpjOruJOia7cQXKLM=
In-Reply-To: <8D17F8D2-BF68-4BA4-8590-7DE1E71872A6@gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sishuai Gong <sishuai.system@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, Linux Kernel Network Developers <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org


	Hello,

On Thu, 10 Aug 2023, Sishuai Gong wrote:

> Hello,
> 
> I am not familiar with the code but I would like to give it a try :).
> 
> It seems to me that replacing the second memcpy with WRITE_ONCE() 
> is not necessary as long as we still hold the lock. Otherwise is this close
> to what you suggest?

	Yes, just make it formatted according to
Documentation/process/submitting-patches.rst

	The mutex serializes writers but readers do not use this
mutex. Anyways, looks like kernel provides inline version of
memcpy which works correctly in our case by copying 4-byte integers.

> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 62606fb44d02..b4e22e30b896 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1876,6 +1876,7 @@ static int
>  proc_do_sync_threshold(struct ctl_table *table, int write,
>                        void *buffer, size_t *lenp, loff_t *ppos)
>  {
> +      struct netns_ipvs *ipvs = table->extra2;
>         int *valp = table->data;
>         int val[2];
>         int rc;
> @@ -1885,6 +1886,7 @@ proc_do_sync_threshold(struct ctl_table *table, int write,
>                 .mode = table->mode,
>         };
> 
> +      mutex_lock(&ipvs->sync_mutex);
>         memcpy(val, valp, sizeof(val));
>         rc = proc_dointvec(&tmp, write, buffer, lenp, ppos);
>         if (write) {
> @@ -1894,6 +1896,7 @@ proc_do_sync_threshold(struct ctl_table *table, int write,
>                 else
>                         memcpy(valp, val, sizeof(val));
>         }
> +      mutex_unlock(&ipvs->sync_mutex);
>         return rc;
>  }
> 
> @@ -4321,6 +4324,7 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
>         ipvs->sysctl_sync_threshold[0] = DEFAULT_SYNC_THRESHOLD;
>         ipvs->sysctl_sync_threshold[1] = DEFAULT_SYNC_PERIOD;
>         tbl[idx].data = &ipvs->sysctl_sync_threshold;
> +      tbl[idx].extra2 = ipvs;
>         tbl[idx++].maxlen = sizeof(ipvs->sysctl_sync_threshold);
>         ipvs->sysctl_sync_refresh_period = DEFAULT_SYNC_REFRESH_PERIOD;
>         tbl[idx++].data = &ipvs->sysctl_sync_refresh_period;
> 
> > On Aug 10, 2023, at 2:20 AM, Julian Anastasov <ja@ssi.bg> wrote:
> > 
> > 
> > Hello,
> > 
> > On Wed, 9 Aug 2023, Sishuai Gong wrote:
> > 
> >> Hi,
> >> 
> >> We observed races over (struct ctl_table *) table->data when two threads
> >> are running proc_do_sync_threshold() in parallel, as shown below:
> >> 
> >> Thread-1 Thread-2
> >> memcpy(val, valp, sizeof(val)); memcpy(valp, val, sizeof(val));
> >> 
> >> This race probably would mess up table->data. Is it better to add a lock?
> > 
> > We can put mutex_lock(&ipvs->sync_mutex) before the first
> > memcpy and to use two WRITE_ONCE instead of the second memcpy. But
> > this requires extra2 = ipvs in ip_vs_control_net_init_sysctl():
> > 
> > tbl[idx].data = &ipvs->sysctl_sync_threshold;
> > + tbl[idx].extra2 = ipvs;
> > 
> > Will you provide patch?

Regards

--
Julian Anastasov <ja@ssi.bg>

