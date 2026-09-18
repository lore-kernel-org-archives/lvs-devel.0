Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9C4C84D598C;
	Fri, 18 Sep 2026 16:54:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789750456; cv=none; b=mWaC7ckcV7pBCMEb0esbGg3VzMftmgChDCLJoVzqKc/2yTEMzWLzX6SOOQBozJXEZd7GyZcJeKjCA+i7r+Pe4q9dL4ENL3etspEUJpGKry35yqQtK7sqoeEz+hfeJQY7BCAMTNPOYMe9VeH0LQBZgScU8ZSpMraSYlWNq3GB/xg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789750456; c=relaxed/simple;
	bh=KFeniIOEWYrwIFzZgCOKiyP8UjZKQsHWd1Hp+R6o8vE=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=iw0SwNKMBj4tjZLnYXcSrjun/X+apz8odN3KacF7OjOR1N4xb8GMSq/m0beMLotFc9PktUa3L4lWly/LZ0aNE4cv+SiTMlF210lkmb5lXyuBhQY9IRoN7XPYhFKzMTzQeEHVQyexqBP8XMom0NjKQ4s1XxvnMhtvsIltbAI6x3Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=qqEL7LsY; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="qqEL7LsY"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 13ADF2139F;
	Fri, 18 Sep 2026 19:54:08 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=HnjYyCBikyh86u64wiZU6c8DIC6GJG3n9bj7L2qNiPs=; b=qqEL7LsYqO2w
	LdxpvLHnpyAKdJc/HxY9nmUCQne6PfVuPjFDKS124AO9elq8L+1uaU52F3kj9aRK
	HW/LqhmIKeip7vbZYC4SBzmB5G4uvD7Q+OAlFCPJsMV+9gzGWZKBaeZnUxI9/R/m
	xdnaCTy3ndj1rgpBGF4C8xT7aTU4snxyACmzZ7yTO9AfGNSWxcdAK73hbTBRC3Pv
	S2jcmrk0WoakKrYPozVvqo5lNSdEyTGc5iFok1cbdxu03vwUsOrgg47Ms+TiP7ZQ
	V1xte23QQozq9Qbiao/9OL77lbSSR7uFAvaJI1A/KUPOo2DwF3lVfRwdLssq/KoL
	DUy1tYDh6QUch86mtSMhbSExLSTRBrZzyPC/N5zirXZo4YSBaL1D+ZRX1SV2F1AK
	UPgrqIu+cXT89BDLAhTVbM0coNzbVSjHXp3sMmfSTs4pcVY9+ZbBTj/elVxt96vg
	D+JVp4xJBLYH5QX6xiCng8oNYu/MtP3qCxi9sl8yaRWRBnqGfGoTBzvFjyxmmpUw
	KKx6MmFFf39/J/ZK09djJl5mQ46bycV6GVSQvn4FoOkE4R+xW9jCUSGV4QOWc7rL
	0MHtrPcV4hqR70eX7253Q1ngvrZ4jD9ncUlxucM025QjiKEo9SDMtj940Lfihn7Y
	76OoWVatss7WX+GAbduTHj9jFaV/BJk=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 18 Sep 2026 19:54:07 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id CE1D560B6D;
	Fri, 18 Sep 2026 19:54:09 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68IGs749070156;
	Fri, 18 Sep 2026 19:54:07 +0300
Date: Fri, 18 Sep 2026 19:54:07 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Zihan Xi <zihanx@nebusec.ai>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH net v2 2/2] ipvs: reject FTP control ports as data
 ports
In-Reply-To: <20260917030301.5502-2-zihanx@nebusec.ai>
Message-ID: <7b561a02-461d-2320-75e4-241dd213d9f0@ssi.bg>
References: <cover.1789435989.git.zihanx@nebusec.ai> <20260917030301.5502-2-zihanx@nebusec.ai>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Thu, 17 Sep 2026, Zihan Xi wrote:

> ip_vs_ftp_out() creates a wildcard data connection from the
> server-advertised passive port. If that port is one of the configured FTP
> control ports, ip_vs_conn_new() binds the FTP helper to the new connection
> again. A subsequent wildcard lookup can then extend a controlled-connection
> chain.
> 
> Reject zero and configured control ports before creating passive
> connections. For active mode, reject a zero client port and a data port
> derived from a configured control port.
> 
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Cc: stable@vger.kernel.org
> Reported-by: Vega <vega@nebusec.ai>
> Assisted-by: LLM
> Co-developed-by: Luxing Yin <root@tr0jan.top>
> Signed-off-by: Luxing Yin <root@tr0jan.top>
> Signed-off-by: Zihan Xi <zihanx@nebusec.ai>

	Patch looks good to me for the nf tree, thanks!

Signed-off-by: Julian Anastasov <ja@ssi.bg>

> ---
> changes in v2:
>   - Reject the data port derived from a configured control port in
>     ip_vs_ftp_in() to cover the active-mode bypass.
>   - v1 Link:
>     https://lore.kernel.org/all/cover.1789110326.git.zihanx@nebusec.ai/
> 
>  net/netfilter/ipvs/ip_vs_ftp.c | 18 ++++++++++++++++++
>  1 file changed, 18 insertions(+)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> index 9e3e005a82635..4822a1a75212d 100644
> --- a/net/netfilter/ipvs/ip_vs_ftp.c
> +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> @@ -62,6 +62,17 @@ static unsigned short ports[IP_VS_APP_MAX_PORTS] = {21, 0};
>  module_param_array(ports, ushort, &ports_count, 0444);
>  MODULE_PARM_DESC(ports, "Ports to monitor for FTP control commands");
>  
> +static bool is_control_port(u16 port)
> +{
> +	unsigned int i;
> +
> +	for (i = 0; i < ports_count; i++) {
> +		if (ports[i] == port)
> +			return true;
> +	}
> +	return false;
> +}
> +
>  
>  static char *ip_vs_ftp_data_ptr(struct sk_buff *skb, struct ip_vs_iphdr *ipvsh)
>  {
> @@ -319,6 +330,10 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
>  		return 1;
>  	}
>  
> +	/* Do not redirect data to control ports */
> +	if (!port || is_control_port(ntohs(port)))
> +		return 0;
> +
>  	/* Now update or create a connection entry for it */
>  	{
>  		struct ip_vs_conn_param p;
> @@ -529,6 +544,9 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
>  		return 1;
>  	}
>  
> +	if (!port || is_control_port(ntohs(cp->vport) - 1))
> +		return 0;
> +
>  	/* Passive mode off */
>  	cp->app_data = (void *) IP_VS_FTP_ACTIVE;
>  
> -- 
> 2.43.0

Regards

--
Julian Anastasov <ja@ssi.bg>

