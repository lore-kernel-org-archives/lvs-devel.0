Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E3F6A1A6823;
	Thu,  2 Apr 2026 04:16:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775103370; cv=none; b=e2dtUZE8mPkZeqQniDx0w5ju3LLl5ikBKc3LFQ2AQRnxXlV06sVVjr5xbaZoFjR3P27HpSpSQFqNW/6sDZrsIWXGkawTCqOR2+4yOBdTOKu93l/oVZ4CeqjnnK/GMAVzbcpOtjIwlZO9oH7f3qynNevN2RgvMEQCwmWQxtUWcCA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775103370; c=relaxed/simple;
	bh=gHIgUb+WXUUS/4MXe6/38hstFBvLQ0zEzVt64OHLivs=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=KwmkxdZrN3oktTU/LeNuIexmM15r4odo1gDCHhqJ2kTKikBBmx/q+URW96ea/B7O+gKKSxpFoabtj5lsEcH6209t3C87jjKNI68OKVqd36bkeXfvQxVzNAw3qhCdYMX2k7Nhflf+DZomWQ4kLrUB2KJK6TiKFzaQAGgyyGnpdio=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=jykfM6Kg; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="jykfM6Kg"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id F1B2221C4C;
	Thu, 02 Apr 2026 07:16:01 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=njSLF/ZZEmv5OICffID2dF6iMd6nS7o+1cYNg0JfVaI=; b=jykfM6KgGIwJ
	CHUI5nTaCL4BL4y3NYxhXSQGmAA+LkMDQhqGeyjBm9+w4EwQyKevrzi4UqLx8yMp
	ekHJaGIs7bsBOURj+ifQvUkE6caEzIYUWs1AigGUZilhmngRqjyqO6CPgbqAE7WO
	3Fs4ytpK4XO4nKGld5ajE+Z3RFm2EusnWSmj3zAOV2pPIRlUTCzXSNPcb2fFmr9s
	g45je1GA2eMHUYurrHHVegg8OHKE6c3iipqzof3u7qX0AfBXJileg/hIJfrkmTnM
	M1Slz6SfcxM7zlFGXmQpwpE3bW7x/IPrHpoHb1Kezqud96+H4+pPdidKMQJ132h4
	2inFr9vPERA5vM8t7P37orLfhw06EL6x3zXQcRNcJE2Gas+BjRbIfDpEQBL5clp1
	bwqsxFbyLszl+EGWv5Gvaov6aU3hZNM5QI22rE5ZllqZ4QQHIgO0Z8F0GKv7Efpg
	gsHkYHKc1Zal/LxXx+oCNnjVJZFysdLhJtW+TsMMj3twdfpqXOwXil89Tk0N7awX
	nyTZU48wMtfigiRw1tP3WzN3a9dqqk+h5CVegIS68X/uHyDWHtF3IEtkqyqJwPg5
	NuGp4qIRcn1xicykLnVZrPSRbtieck7XS0K2y1LjnRUT56TSZmLumbVm21xjA9BZ
	zTQ9CxLEV9XbdKFKh69zDMD7BJRdirk=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 02 Apr 2026 07:16:00 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id B434B61B7F;
	Thu,  2 Apr 2026 07:15:58 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 6324Bjpk005987;
	Thu, 2 Apr 2026 07:11:45 +0300
Date: Thu, 2 Apr 2026 07:11:45 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Yingnan Zhang <342144303@qq.com>
cc: horms@verge.net.au, pablo@netfilter.org, fw@strlen.de, phil@nwl.cc,
        davem@davemloft.net, edumazet@google.com, kuba@kernel.org,
        pabeni@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH net] ipvs: fix MTU check for GSO packets in tunnel mode
In-Reply-To: <tencent_4A3E1C339C75D359093BE4F08648AFAA6009@qq.com>
Message-ID: <0e310bf2-0707-14d9-d8f2-18172875256d@ssi.bg>
References: <tencent_4A3E1C339C75D359093BE4F08648AFAA6009@qq.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Wed, 1 Apr 2026, Yingnan Zhang wrote:

> Currently, IPVS skips MTU checks for GSO packets by excluding them with
> the !skb_is_gso(skb) condition. This creates problems when IPVS tunnel
> mode encapsulates GSO packets with IPIP headers.
> 
> The issue manifests in two ways:
> 
> 1. MTU violation after encapsulation:
>    When a GSO packet passes through IPVS tunnel mode, the original MTU
>    check is bypassed. After adding the IPIP tunnel header, the packet
>    size may exceed the outgoing interface MTU, leading to unexpected
>    fragmentation at the IP layer.
> 
> 2. Fragmentation with problematic IP IDs:
>    When net.ipv4.vs.pmtu_disc=1 and a GSO packet with multiple segments
>    is fragmented after encapsulation, each segment gets a sequentially
>    incremented IP ID (0, 1, 2, ...). This happens because:
> 
>    a) The GSO packet bypasses MTU check and gets encapsulated
>    b) At __ip_finish_output, the oversized GSO packet is split into
>       separate SKBs (one per segment), with IP IDs incrementing
>    c) Each SKB is then fragmented again based on the actual MTU
> 
>    This sequential IP ID allocation differs from the expected behavior
>    and can cause issues with fragment reassembly and packet tracking.
> 
> Fix this by removing the GSO packet exception from the MTU check and
> properly validating GSO packets using skb_gso_validate_network_len().
> This function correctly validates whether the GSO segments will fit
> within the MTU after segmentation. If validation fails, send an ICMP
> Fragmentation Needed message to enable proper PMTU discovery.
> 
> Fixes: 4cdd34084d53 ("netfilter: nf_conntrack_ipv6: improve fragmentation handling")
> Signed-off-by: Yingnan Zhang <342144303@qq.com>
> ---
>  net/netfilter/ipvs/ip_vs_xmit.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
> index 3601eb86d..82f2e7a32 100644
> --- a/net/netfilter/ipvs/ip_vs_xmit.c
> +++ b/net/netfilter/ipvs/ip_vs_xmit.c
> @@ -232,8 +232,15 @@ static inline bool ensure_mtu_is_adequate(struct netns_ipvs *ipvs, int skb_af,
>  			return true;
>  
>  		if (unlikely(ip_hdr(skb)->frag_off & htons(IP_DF) &&
> -			     skb->len > mtu && !skb_is_gso(skb) &&
> +			     skb->len > mtu &&
>  			     !ip_vs_iph_icmp(ipvsh))) {
> +			if (skb_is_gso(skb)) {
> +				if (skb_gso_validate_network_len(skb, mtu))
> +					return true;
> +				icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
> +				IP_VS_DBG(1, "frag needed for %pI4\n", &ip_hdr(skb)->saddr);
> +				return false;
> +			}

	Also, as we duplicate code, this can be reorganized as follows:

 		if (unlikely(ip_hdr(skb)->frag_off & htons(IP_DF) &&
-			     skb->len > mtu && !skb_is_gso(skb) &&
-			     !ip_vs_iph_icmp(ipvsh))) {
+			     skb->len > mtu && !ip_vs_iph_icmp(ipvsh) &&
+			     !(skb_is_gso(skb) &&
+			       skb_gso_validate_network_len(skb, mtu)))) {
 			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 				  htonl(mtu));
 			IP_VS_DBG(1, "frag needed for %pI4\n",
Regards

--
Julian Anastasov <ja@ssi.bg>

