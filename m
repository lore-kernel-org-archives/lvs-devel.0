Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AC1853C0610;
	Fri, 14 Aug 2026 16:45:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786725922; cv=none; b=Va/Og+/z0SvXeoWtVsFizPvFEta4tMg5slQqjoCsoAlUwOqPDMrgi65Q4qrMjByd9gN/iSsEO4bvKQajvcrUKutSGOZ42kcFJx4uW23F5df38sqnGimHqNWg/aMgug7PCRjAAhG2adyn1gftGKgPdGb2ZnEBausKmo7reC320eY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786725922; c=relaxed/simple;
	bh=i97wqRxEuYgvW0GU1KHpu3c0BzFs9JJAJuGwUWJm9jM=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=CVCK7nbZiPnzf28AkA6arGkTvrsaECTkEy5E8FlDJjqbOEKVCNAOucKuXA2Mjqa1rcHvPwZeFcpCNSfoBLjPivEa77vBONT5ThQLh0ZOgnjL+WHWhdRf0TB6VrDMhxsF4fNkVW6zrXQ2K1bPR34WyQocKv3ItTh1HaY9omVR9OI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=1xMqX5KC; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="1xMqX5KC"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 51BA320679;
	Fri, 14 Aug 2026 19:45:04 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=6MWF3vNBbqdNiUcImcYTP+CIQAWlFlhRC2kEEqVGdMo=; b=1xMqX5KCnPy1
	+VGeguvzR4cagKl9iK3wJnb0bwhpt4L3gPA4vUWRpW4y0+OKUXCRTMetijxIgGaT
	LEy6n94TiCBjVTlNJqFhlukYY91q1xd8ANGIt/XZUvdXaBrUDeAm8kZIvUb5thQR
	tZu1av+8JU7nxHHfDFvkkLBFkVfth9XPpxleOT62F3Q027EuqUoffsZdgowYEQRz
	9qcatcH50LTeLJNM7Ej0mwKUcQhOq5dCgvNBkut2E1meOr0zBCtxOVjpRzUqqIZJ
	uDO0ZIY39GskoW+Sg1UizwKPlM4Kukiri7GqZUEEM85r50XDpXWiCs0jqrewkLeU
	bN3XLmq6iCQ7C+X2E5SCioIgfWGu3cLdm5hIn5LNQMhYA//FaCeNHnJ9tsGJeovN
	kzQYaPRiG69O7MQ7fBVJNDbYaRMeXxDwSNkhCL781KClO5MY/1rxaaJh5rCSIaJo
	Qf1mjEUiGZy6kJGl1Qxf/uvzkq8geykIxfJ7W3WUJPvIGUI89bzW93VL744xqM/g
	EWfScGjWkgm8JSziEPq4RLagsyz/Yo2zoakEtXN75FlIUYUGmINb8Hs9SRrwDeR/
	8OKf7ajmHQ4zysETv3ZO22epewBCaxi3P4qi4oWZFOglMjjc6d7yOXuJa1VOOxzH
	V/FQFTHCKUp6EqUmSJBlAHgNet6hxY4=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 14 Aug 2026 19:45:04 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 21065603AF;
	Fri, 14 Aug 2026 19:45:06 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 67EGip8R038282;
	Fri, 14 Aug 2026 19:44:52 +0300
Date: Fri, 14 Aug 2026 19:44:51 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Joas Antonio <joasantonio108@gmail.com>
cc: horms@verge.net.au, pablo@netfilter.org, fw@strlen.de,
        netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 ipvs] ipvs: fix integer overflow in ftp helper
 port/address parsing
In-Reply-To: <20260813183424.47522-1-joasantonio108@gmail.com>
Message-ID: <97c4a8a9-cebd-c2cd-7852-34e080d3fe23@ssi.bg>
References: <20260813183424.47522-1-joasantonio108@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Thu, 13 Aug 2026, Joas Antonio wrote:

> From: Joas Antonio dos Santos <joasantonio108@gmail.com>
> 
> ip_vs_ftp_get_addrport() accumulates decimal digits into a __u16
> (hport) and into unsigned char (p[]) without checking for overflow.
> A crafted FTP PASV/EPSV response with an over-long port or address
> octet wraps the value, so the helper configures the data connection
> with a truncated port/address.
> 
> The netfilter conntrack FTP helper had the same defect, fixed in
> commit 2b413fc689ba ("netfilter: nf_conntrack_ftp: avoid u16
> overflows"). Apply the equivalent fix here: widen the port accumulator
> to u32 and reject values above 65535, and reject address octets above
> 255.
> 
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Signed-off-by: Joas Antonio dos Santos <joasantonio108@gmail.com>

	Looks good to me for the nf tree, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
> v2: use real name in Signed-off-by, add subsystem tag to subject (per
>     Pablo Neira Ayuso)
> 
>  net/netfilter/ipvs/ip_vs_ftp.c | 10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> index b315c608f..9e3e005a8 100644
> --- a/net/netfilter/ipvs/ip_vs_ftp.c
> +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> @@ -102,7 +102,7 @@ static int ip_vs_ftp_get_addrport(char *data, char *data_limit,
>  	char *s, c;
>  	unsigned char p[6];
>  	char edelim;
> -	__u16 hport;
> +	__u32 hport;
>  	int i = 0;
>  
>  	if (data_limit - data < plen) {
> @@ -144,7 +144,11 @@ static int ip_vs_ftp_get_addrport(char *data, char *data_limit,
>  				return -1;
>  			c = *data;
>  			if (isdigit(c)) {
> -				p[i] = p[i]*10 + c - '0';
> +				unsigned int val = p[i] * 10 + c - '0';
> +
> +				if (val > 255)
> +					return -1;
> +				p[i] = val;
>  			} else if (c == ',' && i < 5) {
>  				i++;
>  				p[i] = 0;
> @@ -222,6 +226,8 @@ static int ip_vs_ftp_get_addrport(char *data, char *data_limit,
>  		if (!isdigit(*s))
>  			break;
>  		hport = hport * 10 + *s - '0';
> +		if (hport > 65535)
> +			return -1;
>  	}
>  	if (s == data_limit || !hport || *s != edelim)
>  		return -1;
> -- 
> 2.39.5 (Apple Git-154)

Regards

--
Julian Anastasov <ja@ssi.bg>

