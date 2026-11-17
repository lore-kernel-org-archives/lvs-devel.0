Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=217.70.190.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794920047;
	b=1I2Y/29f7Iw2PvNiyTUFW0zxqhliW15YCNgbSadqkEIwIqeMWxl11F+6k+d7NNh6SWaS
	 xbtncoPbiSLr4YPA1WNLhi3nHUUopUhLEy/4KvN5m5xLcg9wBCYhPoCiT0IvDDSB+z+Ms
	 uAsf2soix4IvrlROxOaOt1QhCdqIwA/qoxR422qyMfWl56hhSnBHERt9bqczoFNzOc5uJ
	 sW924YH/BtQeHDXNfLKDeFHKULj0ahw8Lo9bV0Kqn7V2zrLhKpXACclccvAkOiLfJwWcU
	 474wiygVpgfoaPspdiA4aB+FFc3/0m2KPy1HT3JwhVt4jdX7U3WxN+A4rwUCzJjUP9Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794920047;
	h=DMARC-Filter:DKIM-Signature:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spam-Status:X-Spam-Checker-Version;
	bh=eI4v4Pwt8zW5jhRZ+0jVRE7KfXbV0/cmik9BOGR0Yqo=;
	b=FUAwAgaqyNDEx/ipuYxRG5uSpeTJ0eQ8AqOQDLJajZPkRpT7yKkDZoymEexOz/oSJGLm
	 lcU6arKNWTszRXrXOY5pBIA4jtRU1lAqob5M/QeB8wPXlZHowA9Mgm77Kr8YAtm1hdeGT
	 0memGOaREoWn7deBrSoU2ztjOseWLhHFH2zxKcDukH1MFJv+FDq015t3gCduECWuyNNMV
	 UaY4egi8NY2jubBQoy3HyycHrEM8Uun/zFRHcB4LTXNEeDzI14Md4QDV0Zo5NQFpDt2Tg
	 DHRleYxRX8t7j36jO4OdCZYMu5OfQen8jdGG9SxQuB9NYhw0N12ClFJTrQ3/ymZDlVw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=netfilter.org;
	spf=pass smtp.mailfrom=netfilter.org;
	dkim=pass header.d=netfilter.org header.i=@netfilter.org header.a=rsa-sha256 header.s=2025 header.b=oaFrGsXW;
	arc=none smtp.remote-ip=217.70.190.124
Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id C0E2A606A323;
	Tue, 17 Nov 2026 12:54:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C0E2A606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.a=rsa-sha256 header.s=2025 header.b=oaFrGsXW
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1794920044;
	bh=eI4v4Pwt8zW5jhRZ+0jVRE7KfXbV0/cmik9BOGR0Yqo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=oaFrGsXWIgeyLnLgGbpYxFgKVK83DmGH2NwRb5GwxYqApi830U96EufCWr9FkWpSg
	 rNI6UGzp7Mgf2RbyuyV7FobYqKwOQ0pwCOJog2yh3G8gIXzme7EXkoZ4oDOFv2vJwd
	 52/PuPWt683AThlJe4JKrfBDmDAuQye+zJoKTriUQ0XNtsglURWNteRJXgI4mjCHIG
	 wX0xt3GKDksoBHJQH5vF+TnaZXlCpcf0rvxDhZNiUOAs/G8fWneBwLy0Av50p+jaA6
	 s8tVKAaMx0vHUCmhG6OKT4ZO0Mk/jD8tQTZ/FUT2N4CGVXOQIvUFqXFiNkK6VYXGxY
	 PtnIU5D72rPbA==
Received: from netfilter.org (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with UTF8SMTPSA id 23FD260060;
	Tue, 17 Nov 2026 13:54:04 +0100 (CET)
Date: Tue, 17 Nov 2026 13:54:01 +0100
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: Theodor Arsenij Larionov Trichkine <theodorlarionov@gmail.com>
Cc: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>,
	Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, coreteam@netfilter.org
Subject: Re: [PATCH nf v4] ipvs: ftp: do not link expectations to unconfirmed
 conntracks
Message-ID: <avxOaXd5lY8TxRBn@chamomile>
References: <20261117123944.270667-1-theodorlarionov@gmail.com>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20261117123944.270667-1-theodorlarionov@gmail.com>

On Tue, Nov 17, 2026 at 03:39:44PM +0300, Theodor Arsenij Larionov Trichkine wrote:
> ip_vs_ftp_out() can link an expectation to an unconfirmed conntrack. A
> later extension add on the same packet, such as seqadj in
> ip_vs_update_conntrack() or NAT, then reallocates ct->ext and leaves the
> expectation pointing into the freed area:
> 
>   BUG: KASAN: slab-use-after-free in nf_ct_unlink_expect_report+0x490/0x4c0
>   Write of size 8 at addr ffff888004dd4e48 by task syz.2.17/649
> 
> Check the conntrack at the start of ip_vs_ftp_out() and drop the packet
> unless the conntrack is confirmed, is not a template and has the seqadj
> extension that ip_vs_update_conntrack() adds on the first packet.
> 
> Fixes: b25adce16064 ("ipvs: correct usage/allocation of seqadj ext in ipvs")
> Suggested-by: Julian Anastasov <ja@ssi.bg>
> Suggested-by: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: stable@vger.kernel.org
> Signed-off-by: Theodor Arsenij Larionov Trichkine <theodorlarionov@gmail.com>
> ---
> v4: check the conntrack at the start of ip_vs_ftp_out(), as suggested
> by Julian. A server reply that fails the check is now dropped even when
> it is not a PASV/EPSV response. Without a conntrack, e.g. with a notrack
> rule, only PASV/EPSV replies were dropped before.
> v3: https://lore.kernel.org/netfilter-devel/20261116101506.98853-1-theodorlarionov@gmail.com/
> 
>  net/netfilter/ipvs/ip_vs_ftp.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> index 44de99f4d187..216be082162f 100644
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

Given you are fetching the ct earlier, this later re-fetch can go
away?

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 9e3e005a8263..31c1e4b21b51 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -367,7 +367,6 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
        }
        buf_len = strlen(buf);
 
-       ct = nf_ct_get(skb, &ctinfo);
        if (ct) {
                bool mangled;
 
> +
>  	/* Linear packets are much easier to deal with. */
>  	if (skb_ensure_writable(skb, skb->len))
>  		return 0;
> -- 
> 2.34.1 
