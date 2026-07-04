Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1BA581FDA61;
	Sat,  4 Jul 2026 10:04:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783159473; cv=none; b=qvjNGyUx+c6wirs7+efczuljO7dyHgNvDGJNxMAbO3Jp4dr7c3Dl5UCWJX/iq8tnE+NW02vv8pX2xaqgHw/C1T1e0aaH3HSzvB4p8ewmFi1hdXjAW/CKK1IrbilqNcA47T8+7LmWjrClwDr5DZW4w6TG4PXdPn08fksD8vu8qmY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783159473; c=relaxed/simple;
	bh=PXZewadSxh5bHnchV6e5gUu1t7eTG1LrPDL4uSf4aog=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=Pvb/jmRRBcRtCkHDSDFI1B3s6R2oQSE+7IWUGIVbWgj211tXKm0iwC2yPym3j9sQoQqGq109JuxLsLn489GqlHJIyMwXNtLOwHemaVDzWuj7AUcR9KURCAo3OMHKh6XRJ9ejVui3jT7IGHCdk9MDz6igif9svvJRtMxXBnX4jxg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=dXSzWIe8; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="dXSzWIe8"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id B34A921065;
	Sat, 04 Jul 2026 13:04:23 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=sgzU2fQcHKOvLO7ZxfDpdhGNqDs8DXG+GmDEqTQccio=; b=dXSzWIe8jC5F
	h0pmJNtuKOZaOY63zwvcXmIx2JB0upkn89o9PF3WvPoPab7kQt30/sOVdeGRLgSa
	sAS+0tUEopMHbqfY0A1GzvPp/WfAnvG1se6LzUVD4xPxKlGnG+bFUxgW+9o144FN
	XwVyw6+T0S8AtqMW0N+2oLf0rc4XrKCFfK6uadq0iJnNpNgfFJT452M/y2UO+E9S
	HsR/P/+lGEKnyUnqKYsozl+2910y/F7YUHxTMEfW4ytbsRlR2oi5dVaz9KE6N+QF
	Yp7wbQ/O/hiee1wzmLr9KZ2H7G8qu0ls53MGp91AFJRnSZqTknVPjTAbgOU+MQV9
	AxKc9Ggvn1MIrSn3KCku/9lbLIgU5K35sa1RALekGkvEcC117WYAnY1422ThzzI7
	sfdJxjbnqxb5LDRTOas9aQzLoRBMGCr4E4vLY1KGVDH0jcX60zHOlXMMQVVWKlmu
	3eiMSCFI48aJ6d9mp6cAP1ZVKQbT6LryBlAmn8wIe2bCwgB0tkr/5vVJmhGqN3h3
	CIUFd3rkf7Od7ipaK/YDYBL1G03b7MbC2PXnXYH+T/WW8cRIw48rOFZH3qZoPSGD
	Ani5snr6TxUPNYNkZAUERaQDuDmSBMRqVXQVD6ANaEK8eecChvm9/ncInKSY9WnX
	sf/BYX8YCouMnh0SzqjmPX61ZKLcXeM=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 04 Jul 2026 13:04:23 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 84CB760820;
	Sat,  4 Jul 2026 13:04:11 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 664A3rFk007693;
	Sat, 4 Jul 2026 13:03:56 +0300
Date: Sat, 4 Jul 2026 13:03:53 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org, stable@vger.kernel.org,
        Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>,
        Ao Wang <wangao@seu.edu.cn>, Xuewei Feng <fengxw06@126.com>,
        Qi Li <qli01@tsinghua.edu.cn>, Ke Xu <xuke@tsinghua.edu.cn>
Subject: Re: [PATCH net v2] ipvs: fix PMTU for GUE/GRE tunnel ICMP errors
In-Reply-To: <20260702073430.67680-1-zhaoyz24@mails.tsinghua.edu.cn>
Message-ID: <3e6a69e0-7e17-6e07-8dbf-8a04f45e7adf@ssi.bg>
References: <20260702073430.67680-1-zhaoyz24@mails.tsinghua.edu.cn>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Thu, 2 Jul 2026, Yizhou Zhao wrote:

> When an ICMP Fragmentation Needed error is received for a tunneled IPVS
> connection, ip_vs_in_icmp() recomputes the MTU that the original packet
> can use by subtracting the tunnel overhead from the reported next-hop
> MTU.
> 
> The current code always subtracts sizeof(struct iphdr), which is only
> the IPIP overhead. For GUE and GRE tunnels, ipvs_udp_decap() and
> ipvs_gre_decap() already compute the additional tunnel header length,
> but that value is scoped to the decapsulation block and is lost before
> the ICMP_FRAG_NEEDED handling. As a result, the ICMP error sent back to
> the client advertises an MTU that is too large, so PMTUD can fail to
> converge for GUE/GRE-tunneled real servers.
> 
> With a reported next-hop MTU of 1400, a GUE tunnel currently returns
> 1380 to the client. The correct value is 1368:
> 
>   1400 - sizeof(struct iphdr) - sizeof(struct udphdr) -
>   sizeof(struct guehdr)
> 
> Hoist the tunnel header length into the main ip_vs_in_icmp() scope and
> subtract sizeof(struct iphdr) + ulen in the Fragmentation Needed path.
> The IPIP path keeps ulen as 0, so its existing 1400 - 20 = 1380 result
> is unchanged.
> 
> Fixes: 508f744c0de3 ("ipvs: strip udp tunnel headers from icmp errors")
> Cc: stable@vger.kernel.org
> Reported-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
> Reported-by: Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>
> Reported-by: Ao Wang <wangao@seu.edu.cn>
> Reported-by: Xuewei Feng <fengxw06@126.com>
> Reported-by: Qi Li <qli01@tsinghua.edu.cn>
> Reported-by: Ke Xu <xuke@tsinghua.edu.cn>
> Assisted-by: Claude-Code:GLM-5.2
> Signed-off-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>

	I'm late for this patch, in case there is another iteration:

Acked-by: Julian Anastasov <ja@ssi.bg>

	BTW, I prepared followup patch to add the needed pskb_may_pull()
as suggested by Sashiko:

https://sashiko.dev/#/patchset/20260702073430.67680-1-zhaoyz24%40mails.tsinghua.edu.cn

	I'll wait this patch to be applied before posting it...

> ---
> Changes in v2:
>   - Use the short first hunk context so patch applies without fuzz.
>   - Adjust Assisted-by to checkpatch's agent-name format.
>   - Suggested by Julian.
>   - Link to v1: https://lore.kernel.org/netdev/20260701065941.46249-1-zhaoyz24@mails.tsinghua.edu.cn/
> ---
>  net/netfilter/ipvs/ip_vs_core.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index d40b404c1bf6..906f2c361676 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1767,6 +1767,7 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
>  	bool tunnel, new_cp = false;
>  	union nf_inet_addr *raddr;
>  	char *outer_proto = "IPIP";
> +	int ulen = 0;
>  
>  	*related = 1;
>  
> @@ -1831,7 +1832,6 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
>  		   /* Error for our tunnel must arrive at LOCAL_IN */
>  		   (skb_rtable(skb)->rt_flags & RTCF_LOCAL)) {
>  		__u8 iproto;
> -		int ulen;
>  
>  		/* Non-first fragment has no UDP/GRE header */
>  		if (unlikely(cih->frag_off & htons(IP_OFFSET)))
> @@ -1936,8 +1936,8 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
>  				if (dest_dst)
>  					mtu = dst_mtu(dest_dst->dst_cache);
>  			}
> -			if (mtu > 68 + sizeof(struct iphdr))
> -				mtu -= sizeof(struct iphdr);
> +			if (mtu > 68 + sizeof(struct iphdr) + ulen)
> +				mtu -= sizeof(struct iphdr) + ulen;
>  			info = htonl(mtu);
>  		}
>  		/* Strip outer IP, ICMP and IPIP/UDP/GRE, go to IP header of

Regards

--
Julian Anastasov <ja@ssi.bg>

