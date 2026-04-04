Received: from Chamillionaire.breakpoint.cc (Chamillionaire.breakpoint.cc [91.216.245.30])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A2AEB21FF2A;
	Sat,  4 Apr 2026 10:30:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=91.216.245.30
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775298644; cv=none; b=Ae24M4k4X5h5S6HlF40sUSXBqnTfGK2ZPGCTA+JrKG+zrcHXmv2vdAW+ljVqVqA08Ga0n9L50HPl0oTeLTvsrV2uhq7tSLP6vk4xHRMSbWkWGwDI8BL7FNnTFFk/VE+fuRNWiAgoK9w4schDhHCwR5Pr5YEyJ30QN5wgATuH2bE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775298644; c=relaxed/simple;
	bh=hI9dqnIJc8IQyJStY2NgLgPuQaluZvf3AGEr83Pv3zw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=b42wosY2GwFo06bpuVM4W/h+f/6poRJREpi1y4y6fm2ViabdICLy1rJQBBE69P6R5BUZIOWfLO+Rck2MSojr0Mmz7NjS62N0/b08xjqqAkp9bAJ2O2a5VgarFOo71gohehciNBuNYS7jOzzkhrCwIQwvgbXSoWaXoazx645DNi8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=strlen.de; spf=pass smtp.mailfrom=strlen.de; arc=none smtp.client-ip=91.216.245.30
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=strlen.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=strlen.de
Received: by Chamillionaire.breakpoint.cc (Postfix, from userid 1003)
	id D50BE6079E; Sat, 04 Apr 2026 12:30:40 +0200 (CEST)
Date: Sat, 4 Apr 2026 12:30:40 +0200
From: Florian Westphal <fw@strlen.de>
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>,
	Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Dust Li <dust.li@linux.alibaba.com>,
	Jiejian Wu <jiejian@linux.alibaba.com>
Subject: Re: [PATCH nf-next 1/3] ipvs: show the current conn_tab size to users
Message-ID: <adDoUEwfuYpdGanf@strlen.de>
References: <20260323162523.44964-1-ja@ssi.bg>
 <20260323162523.44964-2-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260323162523.44964-2-ja@ssi.bg>

Julian Anastasov <ja@ssi.bg> wrote:
> As conn_tab is per-net, better to show the current hash table size
> to users instead of the ip_vs_conn_tab_size (max).
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  net/netfilter/ipvs/ip_vs_ctl.c | 26 ++++++++++++++++++++++----
>  1 file changed, 22 insertions(+), 4 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index b472e564b769..3129b15dadc2 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -281,6 +281,13 @@ static void est_reload_work_handler(struct work_struct *work)
>  	mutex_unlock(&ipvs->est_mutex);
>  }
>  
> +static int get_conn_tab_size(struct netns_ipvs *ipvs)
> +{
> +	struct ip_vs_rht *t = rcu_dereference(ipvs->conn_tab);
> +
> +	return t? t->size : 0;
> +}

Pablo suggest to make this self-contained so callers don't have to
handle rcu read lock:

static int get_conn_tab_size(struct netns_ipvs *ipvs)
{
	const struct ip_vs_rht *t;
	int size = 0;

	rcu_read_lock();
	t = rcu_dereference(ipvs->conn_tab);
	if (t)
		size = t->size;
	rcu_read_unlock();

	return size;
}
