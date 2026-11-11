Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794428186;
	b=UDajssv/NE3SWVd6njR4LKt13g9uqVBYlmO4NLIrKOb+UcDCKXXuiNH+7Q2Mj1s2SPe/
	 lAyhF8NG4rUXud/MSth0PB0xNBWkErNj4tRBmNr1wxIEvmQ/GlDh8iyBrF3OwB1HcgZKA
	 8WA4Kpl/ZrKK8s0TsleR2qImyncLxw67vHDWshvX6543sunWX9uLpZT03ouagzXxCoSYk
	 j3xAY80qDLvA/V4I6aYtwiKl4NIvd/h4VGvYT0gtdhZ72XBuucrgMED6SsqxddePnX96T
	 nX9+N1T6huG0uQB6N1rsvi22Rt5fV3QXIMr59HeQmU3xbnvciMkdHxGmtAS1OOpRQLA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794428186;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=Sw68+VFJWTPmZ8QOfcR0ktmagWnvJL/uJgWmtm4CXEo=;
	b=YOk8XUYo6MhKla30LvLCILcQSm4Z4dfWk+TNotM7LcF8rBfWRHPjfB6TZxeUKzjCgmqB
	 bnKi0d23ZsrY/2ECeqK+4NgMNek+b75JYJLdfarKsntjiCIndKMB02mvdrm9A9Q36fRSi
	 GdSpLJqbuCRo6aih/+pFe6PsD8fuxumP/qbALTD9JZ0TSeGyS5BNfnn7k6wnM0DWn6GwS
	 G4PWWoTnPXOqUxfomtAqiQHLe3tT7VKXBF3F5uAEj1leDiOfBbcmzHNQCUeAoaOzG96i1
	 ihmmLXDRFLEMUPfW7C4y+X3ZNS91mUrHKR65jiN4wJrDyTfvVR+VAGLuECJKsZvK/HA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=RhKq3st9;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 652AF606A336;
	Wed, 11 Nov 2026 20:16:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 652AF606A336
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=RhKq3st9
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id D4F9E21FFD;
	Wed, 11 Nov 2026 22:16:23 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=Sw68+VFJWTPmZ8QOfcR0ktmagWnvJL/uJgWmtm4CXEo=; b=RhKq3st97x0S
	biRCkCCufwojiwp8oaKXsUXhmPoX+aPTsc3VwswV5bGaoGgJubNCTQPxlRIrv/Hl
	4oMbwcp5N5l9WIhMDOu9fru1AzCS5pHnfw+dWxpYJWXfUP/tGDt+dNvvZ6sXv88A
	KY8cXJFJvEJ2IGWUi9iMZQckLs32mNT+aa0y3jUWdG0Dz1imXI5YA8mgoux6/3kB
	5RP4fmCWaMoBuCZ6JqN/QmIDTkLAZec1wgKNxxSPLoSmSbqCPfHV/e+NGEyFnN/G
	+GbkCUnw4PE+CWYc4yLSfAK65ru4BS/6Zu33aN76YiJwgF89TJsxbMnXVIBh6Rs1
	2+kNT1oXd4JT6KnAk+VmZm+fuESqHEgy+QhTAxkwDsConjPfF9LuGtKoYHuk3Vpo
	jCPKd1qpeP88Mav1c8KqqgzyZZ8TDkpITSkNlb/kZY55ZBePGLx+aRx0UpUDPLgs
	+m5mjwTHX7IDIgC8bAofStjog0lHwA8ZWX2UEJcObCZpNPuuyYJ+y37vut4S4OGd
	wp88kgwBRcFyF/iIDKkze97yhs+hvXj4SWc0nqAmFtRxSvXfpZmnLvl2SWom8E5W
	CmykJUnXU83PYESFRNDgveXE230c0vu9xE7yNiXxKfLMU8IhbH5xnS6rnFdlRxQb
	1EzCd6rEO41Xax+rrczUj9agoKp0RSM=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 11 Nov 2026 22:16:23 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 3BFB560214;
	Wed, 11 Nov 2026 22:16:23 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6ABKGL3V083613;
	Wed, 11 Nov 2026 22:16:21 +0200
Date: Wed, 11 Nov 2026 22:16:21 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH nf v2] ipvs: pass correct sk to update_pmtu and on
 tunneling
In-Reply-To: <20261103152550.60449-1-ja@ssi.bg>
Message-ID: <d3d1522f-bb49-5412-0a96-af3930a626e2@ssi.bg>
References: <20261103152550.60449-1-ja@ssi.bg>
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

On Tue, 3 Nov 2026, Julian Anastasov wrote:

> This commit fixes two cases of providing sk on tunneling,
> one to the update_pmtu handler and the second case is to
> the ip_local_out() call.
> 
> For local clients, we can see at LOCAL_OUT a netfilter hook's
> state->sk that is different from the protocol's skb->sk. This
> can be the case for UDP_TUNNEL where different sk is provided to
> ip_local_out. If such packet is then forwarded via IPVS tunnel
> we may need to provide state->sk to the update_pmtu handler.
> 
> Fix that by passing the netfilter's hook state via the
> packet_xmit and conn_schedule handlers to call the update_pmtu
> handler with state->sk instead of skb->sk.
> 
> While here, change maybe_update_pmtu() to be family independent
> by using dst and do not request neigh confirm via the last
> update_pmtu arg because we do not generate the event based on
> remote signal.
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
> Fixes: 79b16aadea32 ("udp_tunnel: Pass UDP socket down through udp_tunnel{, 6}_xmit_skb().")
> Fixes: 7026b1ddb6b8 ("netfilter: Pass socket pointer down through okfn().")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

	Dropping v2, we have some problems to address:

https://sashiko.dev/#/patchset/20261103152550.60449-1-ja%40ssi.bg

	v3 was just sent.

pw-bot: changes-requested

Regards

--
Julian Anastasov <ja@ssi.bg>

