Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7AF20363087;
	Tue, 14 Jul 2026 10:09:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784023794; cv=none; b=Rejo/ysr+TiSK3dHcngkGRjz6o6TP4tkwGYfM5HpN8suH0hy/hVx+UkNsRJGcvnGA9PajOLYkfX5tcwPML2tXa2dBih3VVEgUJoHlGV7GNcXw300RTvbtlR+/DKmEXZ6+dWpnHVp9qypTk5i35GcHNZqmAcfLIzK+pn6feh/7EY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784023794; c=relaxed/simple;
	bh=AwhWQwZIdhDYowsZED23b+HyCSp33e+jsV5Oadw84K8=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=CdEHbOoGNeDyvBQ+cc+/0MByZQa/Dp9onB1doYgehJKw2JpSJMWa5EtQuhd+r8y7xzYaVwSKOrrCHFDo21vEyfE9ZsUqoCSjAgoDF5xEtMDPStlFj8b4GHw988vMM9PDzuG0+kbCWeHZoybzHMHc255bibeHg8p/H2YGrdtRvRY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=EgjLR1r2; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="EgjLR1r2"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 5E84B2183F;
	Tue, 14 Jul 2026 13:09:40 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=y+xdjFun78KEbJtceb5flRkdjn/pQquFPOsjaYv5aZs=; b=EgjLR1r2SpWF
	sjsG+IQLCCiopfXCtAyMyto826op944BYTsIDjXnfoWp++H1aHDwL5j7WehjAI5b
	A1jNSY2j7X39VEJLqPnQljU+c+vaxd+XFU64gnY+X6/k/NfhQSlqpM2BPWkMym8R
	lmlDHi6AcDVT24GIWLCA33AerFfSdG/EyyE9c2cVZOGAvefrqPi1cOHjygKpRNi4
	EhTgnkU1lrYUn5Wu1Ezngo18w/WTFVAR8SP75uMxBKti5ueVMslomSUzOhhk+M8D
	eF3yNAKpkkBKEoNfC38wnffNQ3GHiWzKdagK6SPczc/VIQ8BIXRbyq/9WgIugiI5
	x2wmzKL0n3EqQ+TsySpEIoikppWtym9zSD5YpOuWj3OrAy62hr2UtmzMS8QXDr5p
	w3pNPPAW+sNEBZOcWFS1XUvusBzaM0BS7tQpkieHz3rUY7UvkdVkpEgV1rM2uGSR
	2+XJsazRvZhKjXWYQAGq82upm32vmZ6QvZbYQWPJd7crW7tKmJ5cE2ly7TIbbvwA
	VjQcQFKnvWoFisjssZ3DpSFOURdm/sWHV7iwBeUeJ1mPqJ7j/rnkkeAkfObDJodP
	hMCiadDhi55qTHSLPGsCjryzOquXMoemWUx4ydWb8u6z4eBqyfANkop9cL+DCx99
	JHJmw42aeK023R7UgaIo5tHG0W7ofBU=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 14 Jul 2026 13:09:40 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 9645160CE7;
	Tue, 14 Jul 2026 13:09:40 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66EA9Nah026347;
	Tue, 14 Jul 2026 13:09:26 +0300
Date: Tue, 14 Jul 2026 13:09:23 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Ren Wei <n05ec@lzu.edu.cn>
cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        horms@verge.net.au, pablo@netfilter.org, fw@strlen.de, phil@nwl.cc,
        kaber@trash.net, nick@loadbalancer.org, yuantan098@gmail.com,
        yifanwucs@gmail.com, tomapufckgml@gmail.com, bird@lzu.edu.cn,
        roxy520tt@gmail.com
Subject: Re: [PATCH v2 1/2] ipvs: do not propagate one-packet flag to synced
 conns
In-Reply-To: <36c8cc69242426e0bc6b618749052a5943735de3.1783917666.git.roxy520tt@gmail.com>
Message-ID: <a83874df-9bb3-150d-146a-905ed60fdf5e@ssi.bg>
References: <cover.1783917666.git.roxy520tt@gmail.com> <36c8cc69242426e0bc6b618749052a5943735de3.1783917666.git.roxy520tt@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 13 Jul 2026, Ren Wei wrote:

> From: Zhiling Zou <roxy520tt@gmail.com>
> 
> Synced connections can be created before their destination exists. When
> the destination is later added, ip_vs_bind_dest() copies connection flags
> from the destination into cp->flags.
> 
> IP_VS_CONN_F_ONE_PACKET connections are not synced. If a synced
> connection inherits IP_VS_CONN_F_ONE_PACKET while it is already hashed,
> expiry can treat it as a one-packet connection and skip unlinking the
> existing conn_tab node, leaving stale hash nodes pointing at a freed
> struct ip_vs_conn.
> 
> Drop IP_VS_CONN_F_ONE_PACKET from destination flags when binding synced
> connections.
> 
> Fixes: 26ec037f9841 ("IPVS: one-packet scheduling")
> Cc: stable@vger.kernel.org
> Reported-by: Yuan Tan <yuantan098@gmail.com>
> Reported-by: Yifan Wu <yifanwucs@gmail.com>
> Reported-by: Juefei Pu <tomapufckgml@gmail.com>
> Reported-by: Xin Liu <bird@lzu.edu.cn>
> Suggested-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Zhiling Zou <roxy520tt@gmail.com>
> Signed-off-by: Ren Wei <n05ec@lzu.edu.cn>

	Looks good to me for the nf tree, thanks!

	For this patch:

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
> Changes in v2:
> - Replace the v1 approach that preserved hash-related flags on late
>   destination binding.
> - Drop IP_VS_CONN_F_ONE_PACKET from conn_flags for synced connections,
>   because one-packet connections are not synchronized.
> - Leave forwarding method updates to the follow-up hn1 hashing fix in
>   patch 2.
> - Add Suggested-by for Julian's review suggestion.
> 
> v1 Link: https://lore.kernel.org/all/1b914f41d725bc064c9ba9830dc8169329737270.1782540466.git.roxy520tt@gmail.com/
> 
>  net/netfilter/ipvs/ip_vs_conn.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 6ed2622363f0..0682cec5f0a7 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -1014,6 +1014,9 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
>  	flags = cp->flags;
>  	/* Bind with the destination and its corresponding transmitter */
>  	if (flags & IP_VS_CONN_F_SYNC) {
> +		/* Synced conns are hashed, so they can not get this flag */
> +		conn_flags &= ~IP_VS_CONN_F_ONE_PACKET;
> +
>  		/* if the connection is not template and is created
>  		 * by sync, preserve the activity flag.
>  		 */
> -- 
> 2.43.0

Regards

--
Julian Anastasov <ja@ssi.bg>

