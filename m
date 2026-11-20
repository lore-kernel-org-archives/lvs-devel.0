Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795198766;
	b=coE2Pjx4gkpyEZVak239dj4c+tXwi/GAP9BQcxIekhzcGm+yC4sebg/Eck4COJ7G2Zi+
	 VeqNt2Fe3Xwj3pTDHKdUYSPRNLeBbcImuM09sVDaK2T/fyjm2O+QwqHBy45JHrcnC9v+r
	 soR8X+j81q3AbvM3VlXlqyG8NGUxeWtMdalnBP+o6v6o1RDnp2Vdt0/DdSMK2FcUQDcXM
	 ozdMX3hgz7+DDtO/lmqUC2C7Lt0MIod7Aw1G0myOFXONEHFK4sRYjqMmx9KC+8DI3JMN0
	 mq65MsDbGjU4kHuhrc+5ui2hFBKaBoBKBXYn4X4xAvhRK1C+2foNC/UioFxFtxDReZg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795198766;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=0Se2BgcBICHHpenWI5YyQcemR/vbNVfPDexy+lHoP/k=;
	b=0uc01TmxpNIfkOY2mYJgZTRQHpSXo0+k1knXRQupbpeA0XUsGyFjY6t5hA2+y/dlsQu3
	 uEHMFB5cKks7nXvbzgQBp1EUn/natCbB2aVBpLdnaeH5sjWbiV7VP8HfMD9+8hBzYFOdK
	 DuOA/qofiDVMj3y9uAsJoW0A2j/h95J5RvvOIvk3h5n/ARVdpxvxtyfUe85IKWyxB8+wP
	 DE7fhYIaDQ4Rr1SNVn/lGoa35HPyjSAtBSvZIMX0EnJZA/TbX0Y/+lRCrnxjB+NJ40xpM
	 tLYLkNqNXeLYAdHCHMv0PYdNr2xrCZGSqw0kAvHJEwEc5ICJYO8Nn6D6iGYsnRtNtuA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b="LSkvrL7/";
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4FF3B606A8BF;
	Fri, 20 Nov 2026 18:19:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4FF3B606A8BF
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=LSkvrL7/
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id E039421FDB;
	Fri, 20 Nov 2026 20:19:22 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=0Se2BgcBICHHpenWI5YyQcemR/vbNVfPDexy+lHoP/k=; b=LSkvrL7/kLCG
	tam6bejtoOZmess8nnzfd+Tx+bJWKCVCFDl9u7WfzG9hrvMYvTnYZsp0O3ZQqwBW
	nT4ZCw4Fb3oy2NgzfJLUcqiig3qCOJZeJKTeiFgdOnLqkEXOOyr3JhzObFAFGXDZ
	QXoKePfkRKxD4TemGS7G9XISJs8GIz1fpKW+v8+ESzcAINDYzf9MQlClDmb++U1T
	/lunQq1qNFLevAM1OqoNSAqPu45MQQfYW4zQ3BAHbK2+lFGZTKO0WhoX5lMZ6aOL
	2Z9JXYxsW+GRDUG9RNy973XZnfJXX9DNpEmS/lbTUUqVMTW496HJQ5w0r2EKFhc2
	r4Ut7IoOLq7POGHNy8y8Sbzh9Y8tu+YNtdIt7QoAyu68kmcTv/0OXGan/oi85w3M
	fOM79rn8O31sv0ZL7Swr5AuoA5JCUUVi7q/If2+DzPZgQ9NKWtSo4EOuNN3qubbB
	OGED3IG0M/4KoTblM+jjHxvXkqlwuXl/gPi9KK7weX7P+/xuQspbeqsFCXQ2jC4j
	isTKmC1Z1Eublhgsm/SEZ9HOqj7L1pIGXu7w6nD5IEpn1yVMjDXd/8F/DQuQzYyt
	lJFuIhO1IY7DgKgB/KhP0unZu9PiXbcUQyRbE4NRcExOpNb1UQOhJPtdhnj2dn5R
	CGQjZQqm2Ts5zIRg0IlLTG/rnuQGc98=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 20 Nov 2026 20:19:22 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id B13F062424;
	Fri, 20 Nov 2026 20:19:21 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6AKIJKBN098631;
	Fri, 20 Nov 2026 20:19:20 +0200
Date: Fri, 20 Nov 2026 20:19:20 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH nf v5] ipvs: pass correct sk to update_pmtu and on
 tunneling
In-Reply-To: <20261119160650.133060-1-ja@ssi.bg>
Message-ID: <b08132bb-f09e-d74c-f930-c9e804daf4f8@ssi.bg>
References: <20261119160650.133060-1-ja@ssi.bg>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Thu, 19 Nov 2026, Julian Anastasov wrote:

> This commit fixes two cases of providing sk on tunneling,
> one to the update_pmtu handler and the second case is to
> the ip_local_out() call.
> 
> For local clients, we can see at LOCAL_OUT a netfilter hook's
> state->sk that is different from the protocol's skb->sk. This
> can be the case for tunnels where different sk is provided to
> ip_local_out. If such packet is then forwarded via IPVS tunnel
> we may need to provide state->sk to the update_pmtu handler,
> not skb->sk.
> 
> Fix that by passing the netfilter's hook state via the
> packet_xmit and conn_schedule handlers to call the update_pmtu
> handler with state->sk.
> 
> While here, change maybe_update_pmtu() to be family independent
> by using dst and do not request neigh confirm via the last
> update_pmtu arg because we do not generate the event based on
> remote signal.
> 
> Sashiko has some warnings for the update_pmtu handlers because
> we provide only sk, not skb:
> 
> - we do not provide skb because the handlers assume they are
> called from tunnel transmitters where skb->dev is present
> but for IPVS skb->dev is not set yet
> 
> - without skb, the zero destination address for unconnected
> sockets can be blindly used for FIB nexthop or route exceptions.
> So, we now restrict the sk to be for TCP_ESTABLISHED state
> where the sk is connected to destination address. All other
> sockets can receive the PMTU update via the ICMP replies.
> 
> - as we provide the original sk (from state->sk) for the original
> IP header, make sure we do not provide sk from one family to
> the update_pmtu handler for different family. Still, allow
> IPv4 packets to update PMTU for IPv6 dual sockets.
> 
> The second problem is that on tunnel forwarding we call
> ip_local_out() with skb->sk. As we push our own outer IP header
> in ip_vs_tunnel_xmit*(), the right thing is to provide NULL
> instead, as done by other tunnels (IPIP/SIT/GRE).
> 
> For consistency, even if we do not walk the netfilter hooks and
> just pass the packet with NF_ACCEPT, provide ip_vs_null_xmit_v6
> handler to properly indicate that we are sending IPv6 packet.
> Before now we used ip_vs_null_xmit for both families.
> 
> Link: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20261113011447.2357709-1-pablo%40netfilter.org
> Link: https://sashiko.dev/#/patchset/20261113121303.42549-1-ja%40ssi.bg
> Link: https://sashiko.dev/#/patchset/20261103152550.60449-1-ja%40ssi.bg
> Fixes: 79b16aadea32 ("udp_tunnel: Pass UDP socket down through udp_tunnel{, 6}_xmit_skb().")
> Fixes: 7026b1ddb6b8 ("netfilter: Pass socket pointer down through okfn().")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

	Dropping v5 after Sashiko review:

	https://sashiko.dev/#/patchset/20261119160650.133060-1-ja%40ssi.bg

	Just posted v6.

pw-bot: changes-requested

> ---
>  Changes in v5:
>  * Match the packet's daddr with the socket's connected address
>  * IPv6 dual sockets connected to IPv4 mapped address can be updated too
> 
>  Link to v4:
>  https://lore.kernel.org/all/20261113121303.42549-1-ja@ssi.bg/

Regards

--
Julian Anastasov <ja@ssi.bg>

