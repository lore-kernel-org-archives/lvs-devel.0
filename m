Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C12FC2D023;
	Mon, 19 May 2025 20:19:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1747685972; cv=none; b=EX0QUMZ34Pee9B2Hh5zpmfyjW6jaFV1BPwoZhK8MLkfLOUIxhSehiMzjn2CcPzFe9PdeXPAnd95gQM4sOObZYCTDCyW56FJh+VqevohzVICEh4uq7oZZwxMwrg4KEQTJu4pUuaNBpQkSr2qH+iWbNsC/zqpRvNC9ku2ak5BrH4c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1747685972; c=relaxed/simple;
	bh=3uiADHrPNJCbR8kmV3bJDNN5BkrbXQw0XUyTwzxpZIk=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=UbWnI3AKL6uiP5YJWR2Q46y5ujK/BwnzSTqg0PSLTWQ0gpq1m885M7dY+Tj99iCJX/oS3X/jeGffaTBKkxmRC8w8+xXAx2E5HwCeBZyNNYZKNXeM8D9FUQA5787Uji99BbphjmCWM8/213+G8+SMmhsAFVkmcAvMyNC+7rStbqE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=nmz/RqPU; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="nmz/RqPU"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 65A3922CA7;
	Mon, 19 May 2025 23:11:19 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=IME1vTrXqk2EMehgvMvZYqjTXm8MrWZlF3kcCWEnmfA=; b=nmz/RqPU+rsA
	8OBYmSpS2fqQ6804LIbP6ATGRIVkqDwNOLL8NtV5xPtHkggcMwDx8L8b1uLdJ5vo
	kkK0o6A1p+LIignYuUtHFzciym4KZ0GvJFh/ApM4p8dVKcqTsgruj8aISDWyo9Q0
	XPizR3hPyIWaOz/89ehB3+GvFjSABrlXxEv2kH4L/GAa6NecnAqwlWN3DPaptuHs
	dKAmC9Qq3BBc1P2xy22qc0uuBmc7jShZNRXEuyR25SbRI2cjQ3bOP22R76awxAVy
	N4a+ZDh2sj/8Lr6VEaehDaVAU0G1TsgZVlTqTsCGjLG/2B6UKoeMAmUYRpAgkqFo
	prbPhvmsSYxcX0mmp4IQvcLpeTKn1qjgE06hKOjMuAraFMm60KfPWmQDnkKRiCmG
	InH0auE5xHXqXdLidOv5GR8b40tsHzCp+LnUUVSdpWym8akG4pjuGKPDt2Nn+vTI
	3Bj8KpdE4GPu4YD/kwOVTwzVuxM8PR3YLGOz3Fl8AceoBzCEOYwMUazWUu07xihl
	4lY0y0JMdylRKLi7smfwfEuoWeIC+wU/xkLWVj5BZuMbdVrmTcUumVqTwJ5f5hiO
	WXSouIK3PDOUmkokXE2JS6xLteY8kuGMhaE/U4/T9y96M/xkIPFgKjFSMXpaJGM6
	PXxxRnSZ+8kZfCDmTzyF4q/h92IELyg=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 19 May 2025 23:11:17 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 4A84B6050E;
	Mon, 19 May 2025 23:11:17 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.17.1) with ESMTP id 54JKB9Ma066499;
	Mon, 19 May 2025 23:11:09 +0300
Date: Mon, 19 May 2025 23:11:09 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Duan Jiong <djduanjiong@gmail.com>
cc: pablo@netfilter.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Subject: Re: [PATCH] ipvs: skip ipvs snat processing when packet dst is not
 vip
In-Reply-To: <20250519103203.17255-1-djduanjiong@gmail.com>
Message-ID: <aef5ec1d-c62f-9a1c-c6f3-c3e275494234@ssi.bg>
References: <20250519103203.17255-1-djduanjiong@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

	Adding lvs-devel@ to CC...

On Mon, 19 May 2025, Duan Jiong wrote:

> Now suppose there are two net namespaces, one is the server and
> its ip is 192.168.99.4, the other is the client and its ip
> is 192.168.99.5, and the other is configured with ipvs vip
> 192.168.99.6 in the host net namespace, configuring ipvs with
> the backend 192.168.99.5.
> 
> Also configure
> iptables -t nat -A POSTROUTING -p TCP -j MASQUERADE
> to avoid packet loss when accessing with the specified
> source port.

	May be I don't quite understand why the MASQUERADE
rule is used...

> 
> First we use curl --local-port 15280 to specify the source port
> to access the vip, after the request is completed again use
> curl --local-port 15280 to specify the source port to access
> 192.168.99.5, this time the request will always be stuck in
> the main.
> 
> The packet sent by the client arrives at the server without
> any problem, but ipvs will process the packet back from the
> server with the wrong snat for vip, and at this time, since
> the client will directly rst after receiving the packet, the
> client will be stuck until the vip ct rule on the host
> times out.
> 
> Signed-off-by: Duan Jiong <djduanjiong@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_core.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index c7a8a08b7308..98abe4085a11 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1260,6 +1260,8 @@ handle_response(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
>  		unsigned int hooknum)
>  {
>  	struct ip_vs_protocol *pp = pd->pp;
> +	enum ip_conntrack_info ctinfo;
> +	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
>  
>  	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
>  		goto after_nat;
> @@ -1270,6 +1272,12 @@ handle_response(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
>  		goto drop;
>  
>  	/* mangle the packet */
> +	if (ct != NULL &&
> +	    hooknum == NF_INET_FORWARD &&
> +	    !ip_vs_addr_equal(af,
> +		    &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.dst.u3,
> +		    &cp->vaddr))
> +		return NF_ACCEPT;

	Such check will prevent SNAT for active FTP connections
because their original direction is from real server to client.
In which case ip_vs_addr_equal will see difference? When
Netfilter creates new connection for packet from real server?
It does not look good IPVS connection to be DNAT-ed but not
SNAT-ed.

	May be you can explain better what IPs/ports are present in
the transferred packets.

>  	if (pp->snat_handler &&
>  	    !SNAT_CALL(pp->snat_handler, skb, pp, cp, iph))
>  		goto drop;
> -- 
> 2.32.1 (Apple Git-133)

Regards

--
Julian Anastasov <ja@ssi.bg>

