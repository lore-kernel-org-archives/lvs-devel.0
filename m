Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 819DA32E146;
	Mon, 24 Nov 2025 21:21:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.190.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1764019321; cv=none; b=SKZqy2Z42Fsc0Q2mchOrhPAJLGusDSmL4TlRZTT0vaTq1OUIOZhnoyFhhnkZWSEj9lbP97bwq2ryWdb+3VDS4J3wyVLaKW4cGuRex6L0Dgl/v3/1RO+kJoB1fhKoO7976pSbFFP+D32PsdO0bFW8Z5p+ov93iBkDQqGCRikZqRs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1764019321; c=relaxed/simple;
	bh=aakfHxoAEPlA60nLQXSOmdN5r9K3gUcgNV+tnEfOfCU=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=ETGEhPrSC3q6fexORH1K63ZkdFgj/1CaA7fSWnqNDALaODMSRF0R9M6OHQHIpnuU0RvaPO1em5fpYAEN5f7NzmrAHcXVcJoj3yj50+Quxo7eWEEXn/EPF4NvmFL6awi00/OoLdW3PIII4gPtdhR2pNh5JarypKJEZAZEusW3s1M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=netfilter.org; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=kOhwo47g; arc=none smtp.client-ip=217.70.190.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="kOhwo47g"
Received: from netfilter.org (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with ESMTPSA id 67365602AA;
	Mon, 24 Nov 2025 22:21:56 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1764019316;
	bh=oA4dlSdplT0Fv21SbfEb8Rkf8qLcSeXHQiYWV1NVxno=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=kOhwo47glxpG6dtGQiuecZ/iLJv3eCvoiZ8ZfyfAcDDpL5L/ydr362QrvkWmzZqxI
	 0maqCVKT1N3J+CREVfFTCYUH25dzU6P8+3D+aa7xJn1c2woy2E/kMxQeE5g/VZo4ut
	 hoRfHLI62vgziTMJTKSEq5pFaj355kiz0g7a0s3MO2IuyLGWxYClTNi2GJ+FGthofv
	 3vQ+FnqMuTXFO7ZEx++BTQRDC5wqFaoJ2ygw9aZRXgsV5VE733+RWrG5kK9lvEjhJH
	 2UvZNEonolKoFBKuMz5XENdge6Z94KX2WyxL+A05EaFsQ+/SQfWfoqGt3qXxCghhdL
	 RJQRnJ1hLTvbw==
Date: Mon, 24 Nov 2025 22:21:53 +0100
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Dust Li <dust.li@linux.alibaba.com>,
	Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: Re: [PATCHv6 net-next 10/14] ipvs: show the current conn_tab size to
 users
Message-ID: <aSTMcYl8bt6MLJ6o@calendula>
References: <20251019155711.67609-1-ja@ssi.bg>
 <20251019155711.67609-11-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20251019155711.67609-11-ja@ssi.bg>

On Sun, Oct 19, 2025 at 06:57:07PM +0300, Julian Anastasov wrote:
> As conn_tab is per-net, better to show the current hash table size
> to users instead of the ip_vs_conn_tab_size (max).
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  net/netfilter/ipvs/ip_vs_ctl.c | 36 +++++++++++++++++++++++++++++-----
>  1 file changed, 31 insertions(+), 5 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index c7683a9241e5..3dfc01ef1890 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -2743,10 +2743,16 @@ static void ip_vs_info_seq_stop(struct seq_file *seq, void *v)
>  
>  static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
>  {
> +	struct net *net = seq_file_net(seq);
> +	struct netns_ipvs *ipvs = net_ipvs(net);
> +
>  	if (v == SEQ_START_TOKEN) {
> +		struct ip_vs_rht *tc = rcu_dereference(ipvs->conn_tab);
> +		int csize = tc ? tc->size : 0;
> +
>  		seq_printf(seq,
>  			"IP Virtual Server version %d.%d.%d (size=%d)\n",
> -			NVERSION(IP_VS_VERSION_CODE), ip_vs_conn_tab_size);
> +			NVERSION(IP_VS_VERSION_CODE), csize);
>  		seq_puts(seq,
>  			 "Prot LocalAddress:Port Scheduler Flags\n");
>  		seq_puts(seq,
> @@ -3424,10 +3430,17 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
>  	switch (cmd) {
>  	case IP_VS_SO_GET_VERSION:
>  	{
> +		struct ip_vs_rht *t;
> +		int csize = 0;
>  		char buf[64];
>  
> +		rcu_read_lock();
> +		t = rcu_dereference(ipvs->conn_tab);
> +		if (t)
> +			csize = t->size;
> +		rcu_read_unlock();

here too, maybe add helper function?

>  		sprintf(buf, "IP Virtual Server version %d.%d.%d (size=%d)",
> -			NVERSION(IP_VS_VERSION_CODE), ip_vs_conn_tab_size);
> +			NVERSION(IP_VS_VERSION_CODE), csize);
>  		if (copy_to_user(user, buf, strlen(buf)+1) != 0) {
>  			ret = -EFAULT;
>  			goto out;
> @@ -3439,8 +3452,16 @@ do_ip_vs_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
>  	case IP_VS_SO_GET_INFO:
>  	{
>  		struct ip_vs_getinfo info;
> +		struct ip_vs_rht *t;
> +		int csize = 0;
> +
> +		rcu_read_lock();
> +		t = rcu_dereference(ipvs->conn_tab);
> +		if (t)
> +			csize = t->size;
> +		rcu_read_unlock();

... that can be used here?

>  		info.version = IP_VS_VERSION_CODE;
> -		info.size = ip_vs_conn_tab_size;
> +		info.size = csize;
>  		info.num_services =
>  			atomic_read(&ipvs->num_services[IP_VS_AF_INET]);
>  		if (copy_to_user(user, &info, sizeof(info)) != 0)
> @@ -4379,6 +4400,8 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
>  	int ret, cmd, reply_cmd;
>  	struct net *net = sock_net(skb->sk);
>  	struct netns_ipvs *ipvs = net_ipvs(net);
> +	struct ip_vs_rht *t;
> +	int csize;
>  
>  	cmd = info->genlhdr->cmd;
>  
> @@ -4446,10 +4469,13 @@ static int ip_vs_genl_get_cmd(struct sk_buff *skb, struct genl_info *info)
>  	}
>  
>  	case IPVS_CMD_GET_INFO:
> +		csize = 0;
> +		t = rcu_dereference(ipvs->conn_tab);
> +		if (t)
> +			csize = t->size;

... I found another candidate to use the helper here :)

If you add the helper function first, then I think this patch will be
super-small when switching to per-netns, because only the helper
function to get the size will need to be adjusted.

>  		if (nla_put_u32(msg, IPVS_INFO_ATTR_VERSION,
>  				IP_VS_VERSION_CODE) ||
> -		    nla_put_u32(msg, IPVS_INFO_ATTR_CONN_TAB_SIZE,
> -				ip_vs_conn_tab_size))
> +		    nla_put_u32(msg, IPVS_INFO_ATTR_CONN_TAB_SIZE, csize))
>  			goto nla_put_failure;
>  		break;
>  	}
> -- 
> 2.51.0
> 
> 
> 
