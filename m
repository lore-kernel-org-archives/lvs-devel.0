Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794764165;
	b=RuhJACAOi/5qb17zPD8ZkhumFy24ZtE2EcSXtQJVxGMUrvJf/sAMgi7fO48RDS0Ui0gH
	 rI1m2PCYKoI3jtY/lnIwME8Weau6SGxLJK7U1MlVXCANgE5FaYnAwHKG6nRtDgx/B8Zh3
	 vxRLuiiuZzeQhvFyvFvv5+W2TDxdCa1SRMztdNIbnRPaJC+7BoE/+N4A41IIC4xeXv+J1
	 rRUV5KdXooA+F3QJwEeV/X8fCCpap/J2NRX412SY2wLg+TQg7NU7U3m1bLw/NXPPVMmA7
	 4rRQ94WBZez0TzQSfruBZBHiYmREiUz8UgXpjoNp3gU+dCy3vBurvAENNE8dTCaYzHA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794764165;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=T6qOwflWea7KdLAIgTT9JTg1M9zGsAYbHIASp0wel+k=;
	b=4tIc90K4VpolnY/Myuxf97lEh2a80Z7+YeV+0z1g5PYSCR+peq5PQG2xLug3Z6IMkXu5
	 Xa8L35h1PVSD6b6sCqmOmfIU71f6vpvP1P+3J1PWzj6m2+KWelKPG65nXatNnid0y2Lvw
	 wKKe7MwqiIPofXnUATIszKxIvONm4TbOeE8mnb8o2tqu1B31Xhfr9HWv8PmApNg+sALS4
	 6jt9BmtxRrqGhoio3pHDJy+KUzkjLmbEivdFcXs3dyZ0xThSpbibuZ60mbEXoZEEnsFjO
	 cBGIlDuV43nq5X0JQaNg9kKwPtjbxr6uxrC3dKInwnd90VXbFGuGaXJyvL9WGco+D2w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=b7FNXJH9;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 34620606A323;
	Sun, 15 Nov 2026 17:36:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 34620606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=b7FNXJH9
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id D9AE321B52;
	Sun, 15 Nov 2026 19:36:00 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=T6qOwflWea7KdLAIgTT9JTg1M9zGsAYbHIASp0wel+k=; b=b7FNXJH9HoIT
	HTYvpgsgGyRXUn7zlNiDAI1YJ4WvslUZfU+jOlyVxlG2DyPynm6LTLtROWimtGc0
	HM48icwKxTj7CCIK8MYiMH85RxnDKEvN8/4cnqhZkCIaFAdNpJIitO0rWOGBXNoO
	pMnePOyh2QtXbomEz/DjeYkcjkIoyi6kSDxItDSnGO1AyMdZXqCiwDaQD4gTJyG1
	cvsLhubdqADDbmAjf26UXKNtumdSlKwA1viqddhXsi7u1kVHuA186DT99wyjvyN0
	k+81q5sZ2suIoMVUht8ZuiFkSwAiY5v4r3DOXbsxuKzna+BqbaQoK6udnM62l6FK
	Hb7vxKt+SMjYZHAdIBg7IsFappb44CpoGJ39YmMr5JqoxNvHLj+vfFwnjdLUduyq
	9PVfsDrRtTz7LVSFr+ob7T0Zqj8GU9t3nPYDbtD6HrnrQW9gZZ8AwcrRvVBfMOKG
	zy6g1+cJiGbHWCTlPGfM6HPewe+Z34Hxq+vuQtS5OHosK2YGqsX/dW3QIVedz2Ix
	MAchd098m8rUHqMniTuJVFMrECIURDXp5cnqYUxz65FIvwr3jMyNmcNaMlw7D9VR
	PSQTQAc+666dQz9BIOvVYIZ8IrgBcLD2jT3Es1tZXiuFWj235Kr0jdkoxVwWHNtJ
	m4oNMmgGUU+oFUscN6NEKZ4+2VpiHQ8=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sun, 15 Nov 2026 19:36:00 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 54EAE60FC3;
	Sun, 15 Nov 2026 19:36:00 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6AFHZwWV127726;
	Sun, 15 Nov 2026 19:35:58 +0200
Date: Sun, 15 Nov 2026 19:35:58 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH nf v4] ipvs: pass correct sk to update_pmtu and on
 tunneling
In-Reply-To: <20261113121303.42549-1-ja@ssi.bg>
Message-ID: <bb1aa08c-bc9e-9952-4e8e-82ef04fc196c@ssi.bg>
References: <20261113121303.42549-1-ja@ssi.bg>
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

On Fri, 13 Nov 2026, Julian Anastasov wrote:

> This commit fixes two cases of providing sk on tunneling,
> one to the update_pmtu handler and the second case is to
> the ip_local_out() call.
> 
> For local clients, we can see at LOCAL_OUT a netfilter hook's
> state->sk that is different from the protocol's skb->sk. This
> can be the case for UDP_TUNNEL where different sk is provided to
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
> where the sk is connected to destination address.
> 
> - as we provide the original sk (from state->sk) for the original
> IP header, make sure we do not provide sk from one family to
> the update_pmtu handler for different family.
> 
> The second problem is that on tunnel forwarding we call
> ip_local_out() with skb->sk. As we push our own outer IP header
> in ip_vs_tunnel_xmit*(), the right thing is to provide NULL
> instead.
> 
> For consistency, even if we do not walk the netfilter hooks and
> just pass the packet with NF_ACCEPT, provide ip_vs_null_xmit_v6
> handler to properly indicate that we are sending IPv6 packet.
> Before now we used ip_vs_null_xmit for both families.
> 
> Link: https://sashiko.dev/#/patchset/20261103152550.60449-1-ja%40ssi.bg
> Fixes: 79b16aadea32 ("udp_tunnel: Pass UDP socket down through udp_tunnel{, 6}_xmit_skb().")
> Fixes: 7026b1ddb6b8 ("netfilter: Pass socket pointer down through okfn().")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

	We can improve the restrictions for calling update_pmtu based on:

https://sashiko.dev/#/patchset/20261113121303.42549-1-ja%40ssi.bg

	Will prepare v5 in the following days...

pw-bot: changes-requested

> ---
>  Changes in v4
>  * reorder the code in ip_vs_bind_xmit and ip_vs_bind_xmit_v6 to
>    properly apply the change in ip_vs_bind_xmit_v6 as reported by
>    the kernel test robot:
>    https://lore.kernel.org/oe-kbuild-all/202611131204.pFzcf1WG-lkp@intel.com/
> 
>  Link to v3:
>  https://lore.kernel.org/all/20261111200942.83226-1-ja@ssi.bg/
> 
>  include/net/ip_vs.h                     |  45 +++++++---
>  net/netfilter/ipvs/ip_vs_conn.c         |  16 ++--
>  net/netfilter/ipvs/ip_vs_core.c         |  41 +++++----
>  net/netfilter/ipvs/ip_vs_proto_ah_esp.c |   2 +-
>  net/netfilter/ipvs/ip_vs_proto_sctp.c   |   5 +-
>  net/netfilter/ipvs/ip_vs_proto_tcp.c    |   5 +-
>  net/netfilter/ipvs/ip_vs_proto_udp.c    |   5 +-
>  net/netfilter/ipvs/ip_vs_xmit.c         | 114 ++++++++++++++++--------
>  8 files changed, 148 insertions(+), 85 deletions(-)

Regards

--
Julian Anastasov <ja@ssi.bg>

