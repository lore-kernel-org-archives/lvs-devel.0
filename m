Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AC42B2F6925;
	Mon, 24 Nov 2025 21:42:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.190.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1764020535; cv=none; b=glndZToDpRa/Tat34Hf32d5kCslMBXZlHq42rp+mZccTiatm6GB8Hy+YfS3Wrl8Pf3JvZEm2ngMTvXJJvD7jaQ3ylzVGsTU8O4FF5DxbshHtWcx/2k3ahlM6fPKQfhBS69qDjP7hAZ/A5xvxv3bIHBc4yBobMu0PHkiTU4VeBAg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1764020535; c=relaxed/simple;
	bh=9/Ity7LvHVvWjigLLbfh4AT8GUcv09LPya4ayWlqdRc=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=vFAeGkPbbpOoCAbuESZ5AbP8jbK52Rm9qCa5Z9zHC5bfIKyXuSS3ZQsQXUcSUDQGBY6s68bCX+WyXkROM9ZBxD1f2MD/o9RTFg8pLNcvDrATkYVZ5ravMdp3trgI/pxPiwKBV27lVGjkgWpALaF899WoOfQV550JcUDRQqSuYv0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=netfilter.org; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=JzOfrgY1; arc=none smtp.client-ip=217.70.190.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="JzOfrgY1"
Received: from netfilter.org (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with ESMTPSA id 78C7C60264;
	Mon, 24 Nov 2025 22:42:09 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1764020529;
	bh=+yHFVlfQ7o5U8Idi2L60mX5nQdoJtX3AEcps1wsNTWA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=JzOfrgY1PvKa0g8uO5CVG0L2kPELxfi6aijC3/rhmkwsKb6VBVmD3p9opsoWDaXWr
	 QjzwJuCqtVtVOajzlBQXQ0yY2E+2URX/l/6BTyGXErxu8AqP1YC6crXIasNAt/twiZ
	 UeAGdiSytqbMzq/YXNEg6ysWtig+yzu3VjENo2JHRyQB0B/ky4fXxxB/UlfWB8u2+h
	 jLSnB+6j1f8OOMediqyc9+qr9j1/s7YnCaFsc830lQ1RAzbG/vQlhk/a4kWOcvJLS4
	 X49NVKpeVMXf4Eiu4/QizoVzmEU5gxGXe1MRuxamlPH5JHc0fz20RSAt87ARKha2Gq
	 4p+UjBtrlk5rQ==
Date: Mon, 24 Nov 2025 22:42:06 +0100
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Dust Li <dust.li@linux.alibaba.com>,
	Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: Re: [PATCHv6 net-next 13/14] ipvs: add ip_vs_status info
Message-ID: <aSTRLowH5pHe-IvC@calendula>
References: <20251019155711.67609-1-ja@ssi.bg>
 <20251019155711.67609-14-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20251019155711.67609-14-ja@ssi.bg>

On Sun, Oct 19, 2025 at 06:57:10PM +0300, Julian Anastasov wrote:
> Add /proc/net/ip_vs_status to show current state of IPVS.

The motivation for this new /proc interface is to provide the output
for the users to help them decide when to shrink or grow the
hashtable, which is possible with the new sysctl knobs coming in 14/14
in this series.

> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  net/netfilter/ipvs/ip_vs_ctl.c | 145 +++++++++++++++++++++++++++++++++
>  1 file changed, 145 insertions(+)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 3dfc01ef1890..a508e9bdde73 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -2915,6 +2915,144 @@ static int ip_vs_stats_percpu_show(struct seq_file *seq, void *v)
>  
>  	return 0;
>  }
> +
> +static int ip_vs_status_show(struct seq_file *seq, void *v)
> +{
> +	struct net *net = seq_file_single_net(seq);
> +	struct netns_ipvs *ipvs = net_ipvs(net);
> +	unsigned int resched_score = 0;
> +	struct ip_vs_conn_hnode *hn;
> +	struct hlist_bl_head *head;
> +	struct ip_vs_service *svc;
> +	struct ip_vs_rht *t, *pt;
> +	struct hlist_bl_node *e;
> +	int old_gen, new_gen;
> +	u32 counts[8];
> +	u32 bucket;
> +	int count;
> +	u32 sum1;
> +	u32 sum;
> +	int i;
> +
> +	rcu_read_lock();
> +
> +	t = rcu_dereference(ipvs->conn_tab);
> +
> +	seq_printf(seq, "Conns:\t%d\n", atomic_read(&ipvs->conn_count));
> +	seq_printf(seq, "Conn buckets:\t%d (%d bits, lfactor %d)\n",
> +		   t ? t->size : 0, t ? t->bits : 0, t ? t->lfactor : 0);
> +
> +	if (!atomic_read(&ipvs->conn_count))
> +		goto after_conns;
> +	old_gen = atomic_read(&ipvs->conn_tab_changes);
> +
> +repeat_conn:
> +	smp_rmb(); /* ipvs->conn_tab and conn_tab_changes */
> +	memset(counts, 0, sizeof(counts));
> +	ip_vs_rht_for_each_table_rcu(ipvs->conn_tab, t, pt) {
> +		for (bucket = 0; bucket < t->size; bucket++) {
> +			DECLARE_IP_VS_RHT_WALK_BUCKET_RCU();
> +
> +			count = 0;
> +			resched_score++;
> +			ip_vs_rht_walk_bucket_rcu(t, bucket, head) {
> +				count = 0;
> +				hlist_bl_for_each_entry_rcu(hn, e, head, node)
> +					count++;
> +			}
> +			resched_score += count;
> +			if (resched_score >= 100) {
> +				resched_score = 0;
> +				cond_resched_rcu();
> +				new_gen = atomic_read(&ipvs->conn_tab_changes);
> +				/* New table installed ? */
> +				if (old_gen != new_gen) {
> +					old_gen = new_gen;
> +					goto repeat_conn;
> +				}
> +			}
> +			counts[min(count, (int)ARRAY_SIZE(counts) - 1)]++;
> +		}
> +	}
> +	for (sum = 0, i = 0; i < ARRAY_SIZE(counts); i++)
> +		sum += counts[i];
> +	sum1 = sum - counts[0];
> +	seq_printf(seq, "Conn buckets empty:\t%u (%lu%%)\n",
> +		   counts[0], (unsigned long)counts[0] * 100 / max(sum, 1U));
> +	for (i = 1; i < ARRAY_SIZE(counts); i++) {
> +		if (!counts[i])
> +			continue;
> +		seq_printf(seq, "Conn buckets len-%d:\t%u (%lu%%)\n",
> +			   i, counts[i],
> +			   (unsigned long)counts[i] * 100 / max(sum1, 1U));
> +	}
> +
> +after_conns:
> +	t = rcu_dereference(ipvs->svc_table);
> +
> +	count = ip_vs_get_num_services(ipvs);
> +	seq_printf(seq, "Services:\t%d\n", count);
> +	seq_printf(seq, "Service buckets:\t%d (%d bits, lfactor %d)\n",
> +		   t ? t->size : 0, t ? t->bits : 0, t ? t->lfactor : 0);
> +
> +	if (!count)
> +		goto after_svc;
> +	old_gen = atomic_read(&ipvs->svc_table_changes);
> +
> +repeat_svc:
> +	smp_rmb(); /* ipvs->svc_table and svc_table_changes */
> +	memset(counts, 0, sizeof(counts));
> +	ip_vs_rht_for_each_table_rcu(ipvs->svc_table, t, pt) {
> +		for (bucket = 0; bucket < t->size; bucket++) {
> +			DECLARE_IP_VS_RHT_WALK_BUCKET_RCU();
> +
> +			count = 0;
> +			resched_score++;
> +			ip_vs_rht_walk_bucket_rcu(t, bucket, head) {
> +				count = 0;
> +				hlist_bl_for_each_entry_rcu(svc, e, head,
> +							    s_list)
> +					count++;
> +			}
> +			resched_score += count;
> +			if (resched_score >= 100) {
> +				resched_score = 0;
> +				cond_resched_rcu();
> +				new_gen = atomic_read(&ipvs->svc_table_changes);
> +				/* New table installed ? */
> +				if (old_gen != new_gen) {
> +					old_gen = new_gen;
> +					goto repeat_svc;
> +				}
> +			}
> +			counts[min(count, (int)ARRAY_SIZE(counts) - 1)]++;
> +		}
> +	}
> +	for (sum = 0, i = 0; i < ARRAY_SIZE(counts); i++)
> +		sum += counts[i];
> +	sum1 = sum - counts[0];
> +	seq_printf(seq, "Service buckets empty:\t%u (%lu%%)\n",
> +		   counts[0], (unsigned long)counts[0] * 100 / max(sum, 1U));
> +	for (i = 1; i < ARRAY_SIZE(counts); i++) {
> +		if (!counts[i])
> +			continue;
> +		seq_printf(seq, "Service buckets len-%d:\t%u (%lu%%)\n",
> +			   i, counts[i],
> +			   (unsigned long)counts[i] * 100 / max(sum1, 1U));
> +	}
> +
> +after_svc:
> +	seq_printf(seq, "Stats thread slots:\t%d (max %lu)\n",
> +		   ipvs->est_kt_count, ipvs->est_max_threads);
> +	seq_printf(seq, "Stats chain max len:\t%d\n", ipvs->est_chain_max);
> +	seq_printf(seq, "Stats thread ests:\t%d\n",
> +		   ipvs->est_chain_max * IPVS_EST_CHAIN_FACTOR *
> +		   IPVS_EST_NTICKS);
> +
> +	rcu_read_unlock();
> +	return 0;
> +}
> +
>  #endif
>  
>  /*
> @@ -4835,6 +4973,9 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
>  				    ipvs->net->proc_net,
>  				    ip_vs_stats_percpu_show, NULL))
>  		goto err_percpu;
> +	if (!proc_create_net_single("ip_vs_status", 0, ipvs->net->proc_net,
> +				    ip_vs_status_show, NULL))
> +		goto err_status;
>  #endif
>  
>  	ret = ip_vs_control_net_init_sysctl(ipvs);
> @@ -4845,6 +4986,9 @@ int __net_init ip_vs_control_net_init(struct netns_ipvs *ipvs)
>  
>  err:
>  #ifdef CONFIG_PROC_FS
> +	remove_proc_entry("ip_vs_status", ipvs->net->proc_net);
> +
> +err_status:
>  	remove_proc_entry("ip_vs_stats_percpu", ipvs->net->proc_net);
>  
>  err_percpu:
> @@ -4870,6 +5014,7 @@ void __net_exit ip_vs_control_net_cleanup(struct netns_ipvs *ipvs)
>  	ip_vs_control_net_cleanup_sysctl(ipvs);
>  	cancel_delayed_work_sync(&ipvs->est_reload_work);
>  #ifdef CONFIG_PROC_FS
> +	remove_proc_entry("ip_vs_status", ipvs->net->proc_net);
>  	remove_proc_entry("ip_vs_stats_percpu", ipvs->net->proc_net);
>  	remove_proc_entry("ip_vs_stats", ipvs->net->proc_net);
>  	remove_proc_entry("ip_vs", ipvs->net->proc_net);
> -- 
> 2.51.0
> 
> 
> 
