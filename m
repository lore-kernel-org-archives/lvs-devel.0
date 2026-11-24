Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795529516;
	b=n7kdw6iSaSazH5EWBOGNVFf5jMcnmI5yMIxHTrS/VmFHvyQ5nkTIDHjqUPYufRtKCpc7
	 akVy8Ap8i9+2eWbO8/HR8ZnB7KyUq8tYDTkcHOvrFeX6pYcFbP9Z6d0x17PYvioQcV9ED
	 jpFA0QMzIEPGlbMVBKau94uxigF4/etlUSGnhfPUSUihP1Ecr7Xw0BGaKwNAlIvW0VTMK
	 z9X4e0TZqkxYws5+9XW6lmnfb8H59OeBTJiZQqFgrJH/vGIMQXXVnXfkWOZ0sJ3JTyW97
	 EmFCyTP+dRlD7odj8EGQj+0xBhiLacKyv7AAnCS+P2O7YnkPr5UVL5/nMFciwbvX/YA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795529516;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=fvo2h3JIwZN7hWeBwmn0tLWx2GCJbisaKyHc3jsnWH4=;
	b=Yu9JjtiTa2KQn8BmNBBOzREXhBBqGrJerkZBuoxq0m0nqPFTFJW1ctTzMTXKd9yI+0LX
	 ruIQCnaMRUBtmNhcOP0/ByyYABoI03a+HXct2nBz3r8ANeZSffYCHzzdJqSkSDqaj5Rd2
	 SIF0RUfi3tRM+2UUFV1sRtwJMtKoCbKZQaztd4+0mNvHzPrzNH7l30wcu+pZyFQRzXwdG
	 HPMGsqjEk94B7l1R60s8+UGrfYVfxeeRduk91iNmZqdv6ipU4kaTgEFc7f5q5VmFYV23I
	 3QO6gpAo3cfY+Sitdnl2MeW2BLyTZunk4EDBwYK745eyM7FNkiq36j4lwdcqpHw85jA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=ULtsbGOe;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 57E8D606A32A;
	Tue, 24 Nov 2026 14:11:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 57E8D606A32A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=ULtsbGOe
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 86E2521FD0;
	Tue, 24 Nov 2026 16:11:53 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=fvo2h3JIwZN7hWeBwmn0tLWx2GCJbisaKyHc3jsnWH4=; b=ULtsbGOep7bS
	p/klpreRpLeW7SAy9DCZw3VmpRT2d+ieVt7ccca7TwUdvQmDOnyI2BhmnX8eQStC
	hvpn5v17uk9NuEU/T8MA+SjwLnNT7h/r8mzO1jvCGAAjgsmgU1eYbbRKAyuUJdeG
	TzHlajdPD0hlfBoHDTPaLfbFIXrm+L86+008Gsp2UIUViTwCvLTYpTW+qceL7PXO
	E3YsOD325zpo474F80ydKCIR1IKgWKIyTFopZHn/fKlWp37kXsgoJWxEZbUF7HL/
	DwokzUkIJ+PgRrwVTjuwPa05p+PkUKC/2n+MjGcY/q7f1MRO6dH6+4JqI2ZXY49T
	9IiYqZGifo0oy9cA2cMsZMfrcy1RBUwVup6kTVtGiENxLCuO+obWlXDOvoH2lgkT
	XrV/VjM3p3smgad/Fa0/Avr2wALOZEvos5CZ5+2hiAaw2KQmBSqW2NV8qWfmd4KO
	nWn4V0bgxjA0uVzEBRJmGaW86h6RhVkPHeJpMg5cvgj6xhDrV5ueQP+2u8PuB5Uo
	JOflLg0fIQqOXWmKlolysSZ0gSKKzmb320wWAStn9CgvgvqgHak2JE7p9lFzaFlR
	m+IxR6/Vq2Pz80FRp3qIazGww7qOFBG91D7lrKYR8ARJJHAB55LEfQ41b1bUxdts
	khSjxczWFMoy6e12MqcWk2kJOurCdPI=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 24 Nov 2026 16:11:53 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 1D59160992;
	Tue, 24 Nov 2026 16:11:53 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6AOEBnsS085119;
	Tue, 24 Nov 2026 16:11:49 +0200
Date: Tue, 24 Nov 2026 16:11:49 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Theodor Arsenij Larionov Trichkine <theodorlarionov@gmail.com>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Simon Horman <horms@verge.net.au>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org, coreteam@netfilter.org
Subject: Re: [PATCH nf v6] ipvs: ftp: do not link expectations to unconfirmed
 conntracks
In-Reply-To: <20261124085239.62750-1-theodorlarionov@gmail.com>
Message-ID: <fce2ed4e-5257-8b7b-b850-a434a7769553@ssi.bg>
References: <20261124085239.62750-1-theodorlarionov@gmail.com>
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

On Tue, 24 Nov 2026, Theodor Arsenij Larionov Trichkine wrote:

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
> the seqadj extension. This makes the conntrack check before the mangling
> redundant, so remove it.
> 
> Fixes: b25adce16064 ("ipvs: correct usage/allocation of seqadj ext in ipvs")
> Suggested-by: Julian Anastasov <ja@ssi.bg>
> Suggested-by: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: stable@vger.kernel.org
> Signed-off-by: Theodor Arsenij Larionov Trichkine <theodorlarionov@gmail.com>

	The patch looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
> v6: remove the conntrack check before the mangling and the 'mangled'
> variable, and unindent that block.
> v5: drop the second nf_ct_get().
> v4: check the conntrack at the start of ip_vs_ftp_out(). A server reply
> that fails the check is now dropped even when it is not a PASV/EPSV
> response. Without a conntrack, e.g. with a notrack rule, only PASV/EPSV
> replies were dropped before.
> Link to v5: https://lore.kernel.org/netfilter-devel/20261118151726.2509853-1-theodorlarionov@gmail.com/
> Link to v4: https://lore.kernel.org/netfilter-devel/20261117123944.270667-1-theodorlarionov@gmail.com/
> 
>  net/netfilter/ipvs/ip_vs_ftp.c | 45 +++++++++++++++++-----------------
>  1 file changed, 22 insertions(+), 23 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> index 44de99f4d187..c90f7a9e1452 100644
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
> @@ -382,29 +389,21 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
>  	}
>  	buf_len = strlen(buf);
>  
> -	ct = nf_ct_get(skb, &ctinfo);
> -	if (ct && !nf_ct_is_template(ct)) {
> -		bool mangled;
> -
> -		/* If mangling fails this function will return 0
> -		 * which will cause the packet to be dropped.
> -		 * Mangling can only fail under memory pressure,
> -		 * hopefully it will succeed on the retransmitted
> -		 * packet.
> -		 */
> -		mangled = nf_nat_mangle_tcp_packet(skb, ct, ctinfo,
> -						   ipvsh->len,
> -						   start - data,
> -						   end - start,
> -						   buf, buf_len);
> -		if (mangled) {
> -			ip_vs_nfct_expect_related(skb, ct, n_cp,
> -						  ipvsh->protocol, 0, 0);
> -			if (skb->ip_summed == CHECKSUM_COMPLETE)
> -				skb->ip_summed = CHECKSUM_UNNECESSARY;
> -			/* csum is updated */
> -			ret = 1;
> -		}
> +	/* If mangling fails this function will return 0
> +	 * which will cause the packet to be dropped.
> +	 * Mangling can only fail under memory pressure,
> +	 * hopefully it will succeed on the retransmitted
> +	 * packet.
> +	 */
> +	if (nf_nat_mangle_tcp_packet(skb, ct, ctinfo, ipvsh->len,
> +				     start - data, end - start,
> +				     buf, buf_len)) {
> +		ip_vs_nfct_expect_related(skb, ct, n_cp,
> +					  ipvsh->protocol, 0, 0);
> +		if (skb->ip_summed == CHECKSUM_COMPLETE)
> +			skb->ip_summed = CHECKSUM_UNNECESSARY;
> +		/* csum is updated */
> +		ret = 1;
>  	}
>  
>  	/* Not setting 'diff' is intentional, otherwise the sequence
> -- 
> 2.34.1

Regards

--
Julian Anastasov <ja@ssi.bg>

