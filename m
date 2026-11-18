Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795016122;
	b=BpdoUJcIfnAKaqQVOkWesOmOeP66C2dJiaZYlqQRd7nNhRsAggyCqOxjn1mr591oIAlf
	 ZcGjUgSLYcZ5nSy4exn7TPE1rvlWDp/GKUy7e5hpe7YQ2OE+crNH8IMVoXw0P/F2mviHX
	 tqlkOa6eQYE/QPt/VJbYZ9V0CGUPrsJKPcITea/zZ0OOjbSrtbVv7H+gQ1tBr2ASP5/lf
	 VRO0WIxUc1LciVZTPvOW4tsYgJwa6OVrLyrlcLWHYNgu9os+0UekSSy9XVQ+5eS23DqbZ
	 La6TWqZd95EhIczDYmLumats837RA4oks++DHcQC5b//FqrkhEKudx8iqGMO4oKnIbg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795016122;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=2JOgQsZtcfZfp5n0OL9wK42UVY0JMJIOIn5ME9tFFo0=;
	b=cRzXpXi0NeLH3woIGEg00xx3xLfnVKotqA3VUg2LXD6HXxwYlnOOfJsNYsqFFwzpVQww
	 IbGIAPGxLmH9HgeSCd3zKNTLL88RquEs0BZFThAv6lzxy8+tDmQU3VGf78fcXia3j+0Se
	 2TxAczvml1tA3Pkdmon6E+XEFMiXwHN6p3idglTTXDo0pzmaRPTnVMuahPEMvrrwvcfoF
	 OdmwXXZEOagjLpUd2R+uGJExPILFpQWqjZBmo5QjRmDpnbIfua4rCO70L3vgd8s4m9xY8
	 f5qVNJhMv03eRO3R+z/mRdRbwolJlDbgJYBL4abF1JPnpXAaGPtvYHoeNHI7HDGi7qw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=BLjMYauq;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 232D8606A31C;
	Wed, 18 Nov 2026 15:35:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 232D8606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=BLjMYauq
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 3C93621FD9;
	Wed, 18 Nov 2026 17:35:19 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=2JOgQsZtcfZfp5n0OL9wK42UVY0JMJIOIn5ME9tFFo0=; b=BLjMYauqVQSW
	tnMQ8k5DmqVfsFU0VQlQmqbI6x75Ohj0f/SlcUe8GFOxUroMCv7JqYLNDnhpc+i4
	0ArRVHJB5BupqP13kHBXDkp00yDMZU0zErMif+97wJMD/8hnr2d2zpESKldDdMSq
	XVTuWUImozBfKgMLoDvOWj0Srtj2KUraigDVgbg27bGpknqm6P7rljAG49YCzpBV
	TOnWpzTboZ+KLhR5L8rKZkHrOVSu7XIpLjfBogPWZfsbzLFoDEtRBwsoZZ7dDu5L
	NXn92cmJpTVckUVwNN6Q3kP51gdZKOJfsY9FsLkZ4iz5NYqE+5jV/Tn4lAhOiI3o
	OqsasnSbAPeRAiAZ/n8Tf4qAJuidyu2VKTBVpkMLEty611Id3JGIr1valdoSRPzb
	a7S78RGu5Ha4kbBwH9JPXw/5HUK0vZ6ZXhD0A6dUt9FDrLMpST7t5TlVFGNCjMpH
	oh9rOSKcxC5mCfU9LtlIzfQzQM5C8hsmmjwvYYHdp3XIDDzrUU6ddJBMOldjD8Ab
	jeoZ+HwlXjGn66OISWl3XwtNlQmbXJbD+Ed7RdjpLyIqBwOG/RC+S1wxX+z23FcX
	oOdvaziBGN0WV9Dv4wApTx640u2GrTwAweKb5VI3/bhkosjMeri+zYf/kR8BpKBX
	cr/eBDtmeCwBgycAi323j6pHqI6yA/8=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 18 Nov 2026 17:35:19 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id D14A3608B0;
	Wed, 18 Nov 2026 17:35:18 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6AIFZIui079866;
	Wed, 18 Nov 2026 17:35:18 +0200
Date: Wed, 18 Nov 2026 17:35:18 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Theodor Arsenij Larionov Trichkine <theodorlarionov@gmail.com>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Simon Horman <horms@verge.net.au>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org, coreteam@netfilter.org
Subject: Re: [PATCH nf v5] ipvs: ftp: do not link expectations to unconfirmed
 conntracks
In-Reply-To: <20261118151726.2509853-1-theodorlarionov@gmail.com>
Message-ID: <8d0623c6-a7a5-5fab-f233-3356468b78e2@ssi.bg>
References: <20261118151726.2509853-1-theodorlarionov@gmail.com>
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

On Wed, 18 Nov 2026, Theodor Arsenij Larionov Trichkine wrote:

> ip_vs_ftp_out() can link an expectation to an unconfirmed conntrack. A
> later extension add on the same packet, such as seqadj in
> ip_vs_update_conntrack() or NAT, then reallocates ct->ext and leaves the
> expectation pointing into the freed area:
> 
>   BUG: KASAN: slab-use-after-free in nf_ct_unlink_expect_report+0x490/0x4c0
>   Write of size 8 at addr ffff888004dd4e48 by task syz.2.17/649
> 
> Check the conntrack at the start of ip_vs_ftp_out() and drop the packet
> unless the conntrack is confirmed, is not a template and already carries
> the seqadj extension.
> 
> Fixes: b25adce16064 ("ipvs: correct usage/allocation of seqadj ext in ipvs")
> Suggested-by: Julian Anastasov <ja@ssi.bg>
> Suggested-by: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: stable@vger.kernel.org
> Signed-off-by: Theodor Arsenij Larionov Trichkine <theodorlarionov@gmail.com>
> ---
> v5: drop the second nf_ct_get().
> v4: check the conntrack at the start of ip_vs_ftp_out(). A server reply
> that fails the check is now dropped even when it is not a PASV/EPSV
> response. Without a conntrack, e.g. with a notrack rule, only PASV/EPSV
> replies were dropped before.
> Link to v4: https://lore.kernel.org/netfilter-devel/20261117123944.270667-1-theodorlarionov@gmail.com/
> 
>  net/netfilter/ipvs/ip_vs_ftp.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> index 44de99f4d187..cf640cba0b12 100644
> --- a/net/netfilter/ipvs/ip_vs_ftp.c
> +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> @@ -29,6 +29,7 @@
>  #include <linux/netfilter.h>
>  #include <net/netfilter/nf_conntrack.h>
>  #include <net/netfilter/nf_conntrack_expect.h>
> +#include <net/netfilter/nf_conntrack_seqadj.h>
>  #include <net/netfilter/nf_nat.h>
>  #include <net/netfilter/nf_nat_helper.h>
>  #include <linux/gfp.h>
> @@ -283,6 +284,12 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
>  	if (cp->state != IP_VS_TCP_S_ESTABLISHED)
>  		return 1;
>  
> +	ct = nf_ct_get(skb, &ctinfo);
> +	if (!ct || !nf_ct_is_confirmed(ct) || nf_ct_is_template(ct))
> +		return 0;
> +	if (!nfct_seqadj(ct))
> +		return 0;
> +
>  	/* Linear packets are much easier to deal with. */
>  	if (skb_ensure_writable(skb, skb->len))
>  		return 0;
> @@ -382,7 +389,6 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
>  	}
>  	buf_len = strlen(buf);
>  
> -	ct = nf_ct_get(skb, &ctinfo);
>  	if (ct && !nf_ct_is_template(ct)) {
>  		bool mangled;

	Just drop the 'mangled' var and unindent the code:

	/* If mangling fails this function will return 0 ...
	...
	if (nf_nat_mangle_tcp_packet(...
	    ... )) {
		ip_vs_nfct_expect_related(skb, ct, n_cp, ...
		...
		ret = 1;
	}

	because we do not need to check with nf_ct_is_template again.

Regards

--
Julian Anastasov <ja@ssi.bg>

