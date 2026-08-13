Received: from mail.netfilter.org (mail.netfilter.org [217.70.190.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C58272E7635;
	Thu, 13 Aug 2026 17:41:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.190.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786642864; cv=none; b=u75kYsU77zjKj62zirx7UFmbgW6zJH4glGFNdq9+2djw4HCMnHcp8gwOjSDVJfP9X6xdCotqMqwUq+Sa+Hss6BOM31eQusIALPWh8RRuUCXzNwA432mmLj8h4lQtuc7Bpa5xr8PKjhbou+ZCvEfzIaPpsSoO325VnkIYlq8GSRs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786642864; c=relaxed/simple;
	bh=7/oeYTMxCoxBfK83BCp14iQc3GFfOw8nWtzMxuTAzQs=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=IZUTBBzJ6f0KolkHg3jBpl5WKukFIIgeU/ylK8/bleijfYqXPbPNSaiv7RlApyW3RFkWYxFI1Xn1Mu7i8ksRyR0dZGGQj9vfB9E+cAF0xJal2/El82DME6zzg/ra9UNG4hXE34AQUsEfF2KNrD6TsI+HuTOmpGTzCsxQxEbth8w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=netfilter.org; dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b=oSezj7wW; arc=none smtp.client-ip=217.70.190.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netfilter.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netfilter.org header.i=@netfilter.org header.b="oSezj7wW"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netfilter.org;
	s=2025; t=1786642860;
	bh=w+57DC0DHZxHGukFIsiXKemMlhPHWYNHA9Y1zP2QivQ=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=oSezj7wW6N68kAPvA+mXeUrf6H8FzguMgosdjJR67+b2QzMf8PfLuTJav70AZNkIw
	 ewF4hMZM1kLfSWNn+/5ehyUD4RZ1AQzAcrMJRPX0y269pSy7fJLhpWLtggNxJVD7VV
	 YqJNaDoXAdocmz6WmRDcZZ+vhGv4nmdKJP88hst8UCqv3ns6feo9VIDhFhILROQsbN
	 t40KLcYIMe0C75k2kCM+qExpCmg2JFvBmDE/LxKg3RmQiqsV0o4UARCIIOlC5QCMc2
	 rOuKSDqvSA6rpmFaoDC8vmEHmP/bJ2keFg2C4nybcwFwpWKL5OCwrkVtM0fsjrlXR8
	 DmpSXjrHx+UOQ==
Received: from netfilter.org (mail-agni [217.70.190.124])
	by mail.netfilter.org (Postfix) with UTF8SMTPSA id 973D66007A;
	Thu, 13 Aug 2026 19:41:00 +0200 (CEST)
Date: Thu, 13 Aug 2026 19:40:58 +0200
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: Joas Antonio <joasantonio108@gmail.com>
Cc: horms@verge.net.au, ja@ssi.bg, fw@strlen.de, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] ipvs: fix integer overflow in ftp helper port/address
 parsing
Message-ID: <an4BqnWDOxU29kUS@chamomile>
References: <CAOCBhwHbcnuzP1fz=JLqeRA0xNU=QdqppeRy2y=wqhJR6k_VRQ@mail.gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAOCBhwHbcnuzP1fz=JLqeRA0xNU=QdqppeRy2y=wqhJR6k_VRQ@mail.gmail.com>

You have to indicate what tree this is targetted to, [PATCH] itself
goes to /dev/null. Please use [PATCH ipvs] instead.

On Thu, Aug 13, 2026 at 01:59:30PM -0300, Joas Antonio wrote:
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

Patch is garbled, mangled by MUA.

> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Signed-off-by: CyberSecurityUP <joasantonio108@gmail.com>

Use a real name in your Signed-off-by.

> ---
>  net/netfilter/ipvs/ip_vs_ftp.c | 10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> index b315c608f..9e3e005a8 100644
> --- a/net/netfilter/ipvs/ip_vs_ftp.c
> +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> @@ -102,7 +102,7 @@ static int ip_vs_ftp_get_addrport(char *data, char
> *data_limit,
>   char *s, c;
>   unsigned char p[6];
>   char edelim;
> - __u16 hport;
> + __u32 hport;
>   int i = 0;
> 
>   if (data_limit - data < plen) {
> @@ -144,7 +144,11 @@ static int ip_vs_ftp_get_addrport(char *data,
> char *data_limit,
>   return -1;
>   c = *data;
>   if (isdigit(c)) {
> - p[i] = p[i]*10 + c - '0';
> + unsigned int val = p[i] * 10 + c - '0';
> +
> + if (val > 255)
> + return -1;
> + p[i] = val;
>   } else if (c == ',' && i < 5) {
>   i++;
>   p[i] = 0;
> @@ -222,6 +226,8 @@ static int ip_vs_ftp_get_addrport(char *data, char
> *data_limit,
>   if (!isdigit(*s))
>   break;
>   hport = hport * 10 + *s - '0';
> + if (hport > 65535)
> + return -1;
>   }
>   if (s == data_limit || !hport || *s != edelim)
>   return -1;
> --
> 2.39.5 (Apple Git-154)
