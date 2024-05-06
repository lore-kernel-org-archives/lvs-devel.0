Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4F8B0158A2E;
	Mon,  6 May 2024 15:10:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1715008225; cv=none; b=rgS7iJcbC+rdvIWBY9P5XQ+hdFijNbSNX/JaBtMsZK351fEJey57KZUWPAclbatThpNv2TMiFP7+PmHU/a7+ZBEwLsyxx0g3//cerVjA7RjU+9yQPKPUnstXPQHKYWBXtwJ5QcIdzBnwQO6v47IGrdw/4c6XQ2Pou5+LIN3CZro=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1715008225; c=relaxed/simple;
	bh=o3NLpDCX56xR1aoEOXwK+SJTzlGjlHNBo9hf9W3BY3g=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=nLLvHASsxbmgtds0QRlaFLCoINImfjPNls9uLkemXkC9/fCE/eooPrtc77Js0CRYmNzBoywPVxZu3Xz97QEmK0EfdK8YdIiOLaTVFytCDlX7+Dioq4rzLE1x3jOPWw9QbSfMpRGy3EB8GxY5JLE3PgtZWGJ3+xfHmLCTw4mSPuA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=EMgTAb78; arc=none smtp.client-ip=193.238.174.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="EMgTAb78"
Received: from mg.ssi.bg (localhost [127.0.0.1])
	by mg.ssi.bg (Proxmox) with ESMTP id 1AF1218691;
	Mon,  6 May 2024 18:10:12 +0300 (EEST)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.ssi.bg (Proxmox) with ESMTPS;
	Mon,  6 May 2024 18:10:11 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id C343C90029B;
	Mon,  6 May 2024 18:10:07 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1715008208; bh=o3NLpDCX56xR1aoEOXwK+SJTzlGjlHNBo9hf9W3BY3g=;
	h=Date:From:To:cc:Subject:In-Reply-To:References;
	b=EMgTAb78a/hMj2iIUDd4+im1E+d5ZN5X8lI0GMoAohzK6B79qaH5WBmR+U3B05IIc
	 vLXrsfCJ21hvQZcHLvmGsle1b7rZcYdxflDvdQDj6b512KvS4+2U8ANbXsX+J4/CTu
	 BqYuXdWz8F3/YdOA+EjqMZdlZQWzhzSVMSXwwCkk=
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.17.1/8.17.1) with ESMTP id 446F9xB1093238;
	Mon, 6 May 2024 18:10:00 +0300
Date: Mon, 6 May 2024 18:09:59 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Alexander Mikhalitsyn <aleksandr.mikhalitsyn@canonical.com>
cc: horms@verge.net.au, netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@netfilter.org>,
        Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v4 1/2] ipvs: add READ_ONCE barrier for
 ipvs->sysctl_amemthresh
In-Reply-To: <20240506141444.145946-1-aleksandr.mikhalitsyn@canonical.com>
Message-ID: <04e3e7bb-7f9f-816d-492f-1f17565719d8@ssi.bg>
References: <20240506141444.145946-1-aleksandr.mikhalitsyn@canonical.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 6 May 2024, Alexander Mikhalitsyn wrote:

> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: Simon Horman <horms@verge.net.au>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: Jozsef Kadlecsik <kadlec@netfilter.org>
> Cc: Florian Westphal <fw@strlen.de>
> Suggested-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Alexander Mikhalitsyn <aleksandr.mikhalitsyn@canonical.com>

	Looks good to me for net-next, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_ctl.c | 14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 50b5dbe40eb8..e122fa367b81 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -94,6 +94,7 @@ static void update_defense_level(struct netns_ipvs *ipvs)
>  {
>  	struct sysinfo i;
>  	int availmem;
> +	int amemthresh;
>  	int nomem;
>  	int to_change = -1;
>  
> @@ -105,7 +106,8 @@ static void update_defense_level(struct netns_ipvs *ipvs)
>  	/* si_swapinfo(&i); */
>  	/* availmem = availmem - (i.totalswap - i.freeswap); */
>  
> -	nomem = (availmem < ipvs->sysctl_amemthresh);
> +	amemthresh = max(READ_ONCE(ipvs->sysctl_amemthresh), 0);
> +	nomem = (availmem < amemthresh);
>  
>  	local_bh_disable();
>  
> @@ -145,9 +147,8 @@ static void update_defense_level(struct netns_ipvs *ipvs)
>  		break;
>  	case 1:
>  		if (nomem) {
> -			ipvs->drop_rate = ipvs->drop_counter
> -				= ipvs->sysctl_amemthresh /
> -				(ipvs->sysctl_amemthresh-availmem);
> +			ipvs->drop_counter = amemthresh / (amemthresh - availmem);
> +			ipvs->drop_rate = ipvs->drop_counter;
>  			ipvs->sysctl_drop_packet = 2;
>  		} else {
>  			ipvs->drop_rate = 0;
> @@ -155,9 +156,8 @@ static void update_defense_level(struct netns_ipvs *ipvs)
>  		break;
>  	case 2:
>  		if (nomem) {
> -			ipvs->drop_rate = ipvs->drop_counter
> -				= ipvs->sysctl_amemthresh /
> -				(ipvs->sysctl_amemthresh-availmem);
> +			ipvs->drop_counter = amemthresh / (amemthresh - availmem);
> +			ipvs->drop_rate = ipvs->drop_counter;
>  		} else {
>  			ipvs->drop_rate = 0;
>  			ipvs->sysctl_drop_packet = 1;
> -- 
> 2.34.1

Regards

--
Julian Anastasov <ja@ssi.bg>

