Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ADC5A4A3F23;
	Fri,  4 Sep 2026 13:51:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788529907; cv=none; b=V5ezTQXqHdXnPKqJRbIWMCBEnQ/qxtr8twkU/wUNySx2jID3YQZgnASrdcfPknMpTyMTpKZqsnNX4rjTi5kOeeVSSZ4IiB/1wyOJqN+KZz+d+IslzSUw2urZxMTWYwBBkRxYJXSN3TvmPp3nT7uBP0QuQFovORm46oTxA8gR5dw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788529907; c=relaxed/simple;
	bh=UP2AOMoFiDkqCZm9fPRYAQ9P/bwunRxSM8xSykBy0nE=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=V9oYlEVc0FJBjQXW6gt7invFIrlHNnQPaTsy8x90C2per0m+zqhueatoJon34fs+1Dm8UC6Se+0F/OImdxgpcxqRfUtc3HKHQg5QfrmiCvOOeh+wqGWexdmHOqfv5LSSPfsR+UyvJiurEAStvqYO7xRiOteDmynt9hLe2zXohrc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=kjBI7tEw; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="kjBI7tEw"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 9BE0921CCD;
	Fri, 04 Sep 2026 16:51:37 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=re5UvXCW6fX+YwiDYFoYO1WEu/C98eP8jKAhfROih0g=; b=kjBI7tEwrzc3
	2Uc3NxARVTC6A+3Q5Fj0GNgULfpGokuJ6Ad2pwdub0ntCwIeqn3bRnmYt7KHXsfc
	jpRLJuFW8ea5xSOw9WvGCwLbNqCZGQo9FNeTDcbZplZVIO5n6DIHtcTAHnoyFECf
	qhlbj/vhCtCQURv3C5vFJAX39MxnOJV/lg5XDe0BPUPENLrjAGg6nw8ems6MEbzo
	n92ut9i1lYAjurw4QLnKU9awQFyBnUxnmR05rSM0VOIThSTH6puT0Iiwb9TKxXpz
	bNQeELCmmLLt99ZbJI24nsbHGBjIuqEI4ZvsWRBBpP2BYY6NuRQSI59tPhOJTQ4n
	GSFvD/ukP1SscPcshQv78KSlSuxAbmIWPdLng7cxA8oOIR9h+VU/3XhH+pCLbxzE
	57rq3RZOObZL+bOvABk4PoVnz8jopBD4RFbiBmLW5iYidd41oglrX9CUTFf2pb5n
	yOU2SDARNng8RcOvN8eZp06zqVO9moeuOvfrfyYeIf6Oy7dHr1iZwqV/11PuPpEr
	tpj6YjIIKL7MrpxZuHGi9RDZcC6mQyOOeDJK162VTafGfgxs2pZsYbW0sCevinMF
	jhcbdCulo8EysPNFT0jahVNksvlJ0bS/CrEY2ovBm48aKPyi17eEgRTdxptR9IEv
	cVEsujMHfVGh4IwHT7momdgzhYvWDnI=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 04 Sep 2026 16:51:37 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 9A36760236;
	Fri,  4 Sep 2026 16:51:38 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 684DpWEu052369;
	Fri, 4 Sep 2026 16:51:34 +0300
Date: Fri, 4 Sep 2026 16:51:32 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Runyu Xiao <runyu.xiao@seu.edu.cn>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
        stable@vger.kernel.org, Jianhao Xu <jianhao.xu@seu.edu.cn>
Subject: Re: [PATCH net] ipvs: shut down destination trash timer on netns
 cleanup
In-Reply-To: <20260904071908.4052966-1-runyu.xiao@seu.edu.cn>
Message-ID: <98268ae8-1007-78c7-8124-2d37454d8b46@ssi.bg>
References: <20260904071908.4052966-1-runyu.xiao@seu.edu.cn>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Fri, 4 Sep 2026, Runyu Xiao wrote:

> ip_vs_dest_trash_expire() accesses the per-network-namespace IPVS state
> and rearms the destination trash timer while entries remain.  The
> cleanup path uses timer_delete_sync(), which waits for a running callback
> but still allows a racing callback to rearm the timer.

	timer_delete_sync() can safely stop timer if it
is rearmed by its callback: __timer_delete_sync() waits
the callback to finish (the callback can rearm it) and
then detach it if pending. There must be another call flow
that can rearm it later, otherwise this patch is not needed.

	During cleanup, we do not start the timer from
ip_vs_trash_put_dest(). May be I'm missing something?

> Use timer_shutdown_sync() when the per-network-namespace destination
> trash is finally cleaned up.  This prevents the callback from being
> queued again before the IPVS state is released.
> 
> Fixes: f2431e6e9255 ("IPVS: netns, trash handling")
> Cc: stable@vger.kernel.org
> Assisted-by: Codex:GPT-5
> Signed-off-by: Runyu Xiao <runyu.xiao@seu.edu.cn>
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 4c1c73944..0eb6cdb5f 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1192,7 +1192,7 @@ static void ip_vs_trash_cleanup(struct netns_ipvs *ipvs)
>  {
>  	struct ip_vs_dest *dest, *nxt;
>  
> -	timer_delete_sync(&ipvs->dest_trash_timer);
> +	timer_shutdown_sync(&ipvs->dest_trash_timer);
>  	/* No need to use dest_trash_lock */
>  	list_for_each_entry_safe(dest, nxt, &ipvs->dest_trash, t_list) {
>  		list_del(&dest->t_list);
> -- 
> 2.34.1

Regards

--
Julian Anastasov <ja@ssi.bg>

