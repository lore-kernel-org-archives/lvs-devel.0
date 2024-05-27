Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2DBFB15F41F;
	Mon, 27 May 2024 18:08:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1716833344; cv=none; b=Ihr65HHIXuYQ2nHJgn2PK6MPJHFdbv5yCygCei01QkXc5XliuPLMK2PXZx/WBAfT4m49mG5O3El1XCEobOJsXgOREjDcONJh17IUhjWpC0Oy6VI9/E9XzEa3eClpESkBI7qIH3wAWi/AWO3mlYZubAkiHfUmdJ1VXoNV62aFM/4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1716833344; c=relaxed/simple;
	bh=9MFvsjCLOxLQUeqYvox4UAHsYgXHt0OZSILjh79XzQw=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=vDTQQZUobltKkfAF6+0HEj8ClHHBUZvuSn2O4Su6ayTxk17270vWo/5GiE8Vm0gDmuLjukZ2iX943gI8m27xn9y1aeXjnJ2O795WErlOsYtJftOXQl1GvZYiseQhvtBVIrsbotOxg7pZrAAagbf8bRBw0zTHmoTZVGxnA0+Q5oM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=GlJDVE5q; arc=none smtp.client-ip=193.238.174.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="GlJDVE5q"
Received: from mg.ssi.bg (localhost [127.0.0.1])
	by mg.ssi.bg (Proxmox) with ESMTP id 407A635F2B;
	Mon, 27 May 2024 20:59:49 +0300 (EEST)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.ssi.bg (Proxmox) with ESMTPS;
	Mon, 27 May 2024 20:59:48 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id D5E36900442;
	Mon, 27 May 2024 20:59:44 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1716832785; bh=9MFvsjCLOxLQUeqYvox4UAHsYgXHt0OZSILjh79XzQw=;
	h=Date:From:To:cc:Subject:In-Reply-To:References;
	b=GlJDVE5qpBrmHj8Z7pNUmlXavoobwPcF5d7zxzCGcQWybi8S1fjopwnoyX98Renzd
	 qWdR0ZtM1u12YRrPg1pIBADW5aDGd3UbL1dWGClQALNXt5ZXlgaYmEEbOHAcrbm3ki
	 UWj5BGB2BvgMu3SLeh7y2Y5biZdAZp6xqZv7WXzA=
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.17.1) with ESMTP id 44RHxb7L058509;
	Mon, 27 May 2024 20:59:37 +0300
Date: Mon, 27 May 2024 20:59:37 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Ismael Luceno <iluceno@suse.de>
cc: linux-kernel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>,
        =?UTF-8?Q?Michal_Kube=C4=8Dek?= <mkubecek@suse.com>,
        Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        coreteam@netfilter.org
Subject: Re: [PATCH] ipvs: Avoid unnecessary calls to skb_is_gso_sctp
In-Reply-To: <20240523165445.24016-1-iluceno@suse.de>
Message-ID: <16cacbcd-2f4c-1dc1-ecf7-8c081c84c6aa@ssi.bg>
References: <20240523165445.24016-1-iluceno@suse.de>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-159640941-1716832778=:3498"

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-159640941-1716832778=:3498
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Thu, 23 May 2024, Ismael Luceno wrote:

> In the context of the SCTP SNAT/DNAT handler, these calls can only
> return true.
> 
> Ref: e10d3ba4d434 ("ipvs: Fix checksumming on GSO of SCTP packets")

	checkpatch.pl prefers to see the "commit" word:

Ref: commit e10d3ba4d434 ("ipvs: Fix checksumming on GSO of SCTP packets")

> Signed-off-by: Ismael Luceno <iluceno@suse.de>

	Looks good to me for nf-next, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> CC: Pablo Neira Ayuso <pablo@netfilter.org>
> CC: Michal Kubeček <mkubecek@suse.com>
> CC: Simon Horman <horms@verge.net.au>
> CC: Julian Anastasov <ja@ssi.bg>
> CC: lvs-devel@vger.kernel.org
> CC: netfilter-devel@vger.kernel.org
> CC: netdev@vger.kernel.org
> CC: coreteam@netfilter.org
> ---
>  net/netfilter/ipvs/ip_vs_proto_sctp.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> index 1e689c714127..83e452916403 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> @@ -126,7 +126,7 @@ sctp_snat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
>  	if (sctph->source != cp->vport || payload_csum ||
>  	    skb->ip_summed == CHECKSUM_PARTIAL) {
>  		sctph->source = cp->vport;
> -		if (!skb_is_gso(skb) || !skb_is_gso_sctp(skb))
> +		if (!skb_is_gso(skb))
>  			sctp_nat_csum(skb, sctph, sctphoff);
>  	} else {
>  		skb->ip_summed = CHECKSUM_UNNECESSARY;
> @@ -175,7 +175,7 @@ sctp_dnat_handler(struct sk_buff *skb, struct ip_vs_protocol *pp,
>  	    (skb->ip_summed == CHECKSUM_PARTIAL &&
>  	     !(skb_dst(skb)->dev->features & NETIF_F_SCTP_CRC))) {
>  		sctph->dest = cp->dport;
> -		if (!skb_is_gso(skb) || !skb_is_gso_sctp(skb))
> +		if (!skb_is_gso(skb))
>  			sctp_nat_csum(skb, sctph, sctphoff);
>  	} else if (skb->ip_summed != CHECKSUM_PARTIAL) {
>  		skb->ip_summed = CHECKSUM_UNNECESSARY;
> -- 
> 2.44.0

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-159640941-1716832778=:3498--

