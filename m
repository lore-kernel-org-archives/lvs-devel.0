Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793628566;
	b=IYZ84/o8ZM7TrhMu2e3xOFrgQpF5zohXVBhejQaEwqDLVGXccbXICABlN9+rZLxEWiUU
	 ViCclifQYcE/6kCEJDCrDHNIeVUHtLXrNTSNUX/6/4tG2lmQ18RZ2A/nSwN6qAigRnTNZ
	 F+n/5kzyfqWa5aYpbYNtRqyjea9m1ckx9jLWndcw1QPddvS1QqqbSSO8Chp4dFc1prEl9
	 YqEieaSQXcHbcRe50tN9yeXSMxpZmUA04mY3pUXzMWb+wRmPx0aGByXsL7kzUrYAxAEz2
	 M+tEH6E0cRkei9RBrZ9RHWYZd2aqZevMrv08D+ikWPXDCBQgKHc6Y+iV0FW+hUMW/2A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793628566;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=fk5hKS/z7e4rz02SHNZkWeQor1IxFkSOfdAO225DaAI=;
	b=eWkf9mEjqc+gtvAJk2ExtPePZhmiDOaRmafmUbui1GYtshs31RSudOGFZp9zmNUgYscU
	 dTZJ2P9If5xloU+Ho0fTZ5g5Og0Ita5UChN6wovttd9X36iqD1kj/BSHmBem3N5djcQOU
	 feS3FIP1CSZ5bJIZ9pZiIBnedDKaw+XvtZbp6jO3XqUHu17eMuIRt5bcHPkTR/DCHXnO1
	 uEUNHtlkjpHbLhf2D+bqNPZdAYq0nhsDuEfx/hjS5rGreLcYhO3umD4pp1JdRp0F4jFKA
	 ICegZm8MEHv4XqYP2nbN8Pl+iYMY0YKhHgSJjPXURnOdtqnGZSP07dLhzRP1bOK0z9g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=mzMpEB0h;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 40B2C606A324;
	Mon,  2 Nov 2026 14:09:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 40B2C606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=mzMpEB0h
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id C83BA21F89;
	Mon, 02 Nov 2026 16:09:22 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=fk5hKS/z7e4rz02SHNZkWeQor1IxFkSOfdAO225DaAI=; b=mzMpEB0h+WXD
	lSDLGlLCrkNX/EZ37J9fDVfXBnKsSet2HF5Vmtb3p9vzchFGttaOzAbqSLMlxkDX
	c0ReF6enLbZCYQAfMsRuRRUJVaryfqk8rTG506RJ3a1gZk+6jdVZVkQuUrarqli+
	tS06Dryag+gAJa0r0N3gMtEWvvQLMWgUWvaiXhMdE9hk5CZip6QUWFhUOmY5y+1s
	at+Po9S8M3C/eyj9EvtpgccqkwLvDhVNyWM1mu+rfIHndDr2FlBM0XjY1LUlbfKo
	DzTawUCWGtUTm2wHN3SdjPnutzOIxr3jGay96OgFYEbTUunvqE0O+TVcHC4/gbil
	Sjst3cTudcvi0QGI7Zl8MVVQ5Ii/MYjoE3u/nc6RilB51mcsu+jUuKg3bz4XuuJa
	mr0bw6GEwstV3AsKTQ9GH/XoVU/07m5YBbhyI9VTUGbI4gyZnG9KLFCzfxTDcOAy
	HlIODK4JOzwCbE1z3eMAqiRuWdfdtcrIJs0wL2zimyfQzFRqceVZSsxyTovhRjVM
	1aawcifq8YCFY1O8j+eKusLN84W8MRm3a0ypu2Wr7cW9ihWoOx1A7WXzPkMfoc1Z
	/+uzEUh61PlqfsT0IZXuThuPxKj6C82mC9A2V/jn1p1Au3R7/hlzSO+xy7N5F3tX
	T1i68YzLjvC7oLImElr3sxm68OWbL3w=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 02 Nov 2026 16:09:22 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 4331560B9D;
	Mon,  2 Nov 2026 16:09:22 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6A2E9JAA059919;
	Mon, 2 Nov 2026 16:09:20 +0200
Date: Mon, 2 Nov 2026 16:09:19 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Yingjie Wang <1075151112@qq.com>
cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, horms@verge.net.au,
        pablo@netfilter.org, fw@strlen.de, phil@nwl.cc, davem@davemloft.net,
        edumazet@kernel.org, kuba@kernel.org, pabeni@redhat.com,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH net] ipvs: reject negative sync_refresh_period values
In-Reply-To: <tencent_C567615098D5B2A71811CFE5CB09C9FFC406@qq.com>
Message-ID: <7106debb-6452-1ca3-9ff8-506f119700f7@ssi.bg>
References: <tencent_C567615098D5B2A71811CFE5CB09C9FFC406@qq.com>
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

On Mon, 2 Nov 2026, Yingjie Wang wrote:

> net.ipv4.vs.sync_refresh_period is documented as an unsigned number of
> seconds.  proc_dointvec_jiffies() accepts a signed integer and converts
> it to jiffies before storing it in an unsigned int field.  Consequently,
> writing -1 stores UINT_MAX - HZ + 1 jiffies and bypasses the finite
> bound applied to ordinary positive writes.
> 
> This changes the behavior of ip_vs_sync_conn_needed().  With
> sync_threshold="0 1" (threshold 0, period 1) and
> sync_refresh_period=-1, only the first of twelve packets requests a
> sync message; the zero-refresh control requests all twelve.
> 
> Store the value in seconds, as documented, and convert it at the single
> consumer.  Use proc_douintvec_minmax() to reject negative input.  Cap the
> value at INT_MAX / HZ to preserve the prior jiffies range and avoid
> overflow in secs_to_jiffies().
> 
> The issue was reproduced on an affected 7.0 distribution kernel in a
> temporary network namespace.  A patched target kernel was built with W=1
> and exercised in QEMU; -1 is now rejected with EINVAL, zero and positive
> values retain their behavior, and the HZ=1000 boundary accepts 2147483
> while rejecting 2147484.
> 
> Fixes: 749c42b620a9 ("ipvs: reduce sync rate with time thresholds")
> Cc: stable@vger.kernel.org
> Signed-off-by: Yingjie Wang <1075151112@qq.com>
> ---
>  include/net/ip_vs.h            | 7 ++++---
>  net/netfilter/ipvs/ip_vs_ctl.c | 8 ++++++--
>  2 files changed, 10 insertions(+), 5 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 9a83bff32569..66f26c3d1f75 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -19,6 +19,7 @@
>  
>  #include <linux/compiler.h>
>  #include <linux/timer.h>
> +#include <linux/jiffies.h>

	This is not needed. The remaining part looks ok. Prefer
to use "nf" tag for IPVS patches.

>  #include <linux/bug.h>
>  
>  #include <net/checksum.h>
> @@ -1267,7 +1268,7 @@ struct netns_ipvs {
>  	int			sysctl_sloppy_sctp;
>  	int			sysctl_expire_quiescent_template;
>  	int			sysctl_sync_threshold[2];
> -	unsigned int		sysctl_sync_refresh_period;
> +	unsigned int		sysctl_sync_refresh_period; /* seconds */
>  	int			sysctl_sync_retries;
>  	int			sysctl_nat_icmp_send;
>  	int			sysctl_pmtu_disc;
> @@ -1335,7 +1336,7 @@ struct netns_ipvs {
>  #define DEFAULT_SYNC_VER	1
>  #define DEFAULT_SLOPPY_TCP	0
>  #define DEFAULT_SLOPPY_SCTP	0
> -#define DEFAULT_SYNC_REFRESH_PERIOD	(0U * HZ)
> +#define DEFAULT_SYNC_REFRESH_PERIOD	0U
>  #define DEFAULT_SYNC_RETRIES		0
>  #define IPVS_SYNC_WAKEUP_RATE	8
>  #define IPVS_SYNC_QLEN_MAX	(IPVS_SYNC_WAKEUP_RATE * 4)
> @@ -1363,7 +1364,7 @@ static inline int sysctl_sync_period(struct netns_ipvs *ipvs)
>  
>  static inline unsigned int sysctl_sync_refresh_period(struct netns_ipvs *ipvs)
>  {
> -	return READ_ONCE(ipvs->sysctl_sync_refresh_period);
> +	return secs_to_jiffies(READ_ONCE(ipvs->sysctl_sync_refresh_period));
>  }
>  
>  static inline int sysctl_sync_retries(struct netns_ipvs *ipvs)
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index ce9fe20d6106..82726b6b5e3a 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -2369,6 +2369,8 @@ static int ip_vs_zero_all(struct netns_ipvs *ipvs)
>  
>  #ifdef CONFIG_SYSCTL
>  
> +static unsigned int sync_refresh_period_max = INT_MAX / HZ;
> +
>  static int
>  proc_do_conn_max(const struct ctl_table *table, int write,
>  		 void *buffer, size_t *lenp, loff_t *ppos)
> @@ -2824,9 +2826,11 @@ static struct ctl_table vs_vars[] = {
>  	},
>  	{
>  		.procname	= "sync_refresh_period",
> -		.maxlen		= sizeof(int),
> +		.maxlen		= sizeof(unsigned int),
>  		.mode		= 0644,
> -		.proc_handler	= proc_dointvec_jiffies,
> +		.proc_handler	= proc_douintvec_minmax,

	It is sad that there is no proc_dointvec_jiffies_minmax

> +		.extra1		= SYSCTL_ZERO,
> +		.extra2		= &sync_refresh_period_max,
>  	},
>  	{
>  		.procname	= "sync_retries",
> 
> base-commit: cb284914e749388eef402938bdb3115fe1f6d337
> -- 
> 2.43.0

Regards

--
Julian Anastasov <ja@ssi.bg>

