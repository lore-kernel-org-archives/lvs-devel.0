Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E89F1154C0F
	for <lvs-devel@vger.kernel.org>; Sun, 12 Jan 2025 21:24:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1736717050; cv=none; b=X/vR0HZPnM/abNuaEkTMclbS65nW96LALzSkE0IvLufijPXpW1Kr+q94IUpkVyKj5IkKHO4qtZLXZcAG6PyYLJO497lFHWoDyZ17pZqgdCjxXPrOzt9R8mHN50ssRf5ma36djohYp26BO1qzcJYQBbU0n5jpXSjtHqsVYJ/p3UY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1736717050; c=relaxed/simple;
	bh=93i4j4jftJkNix9Wa1PM163cb0MzRCnJgNfVmUUySow=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=AiZu8TQYrAdIcTVQSy0j7XvN1JiM1iwpPntQoxOMdLYyOvVSSl6Q1T7FaCEASBLuLZ9IfLWQB943jYvvHN0vNocxHvbbv0fkQbxXKIdX7K2hOo68jYwgHGL7hK4fc5SYwD0x21Io8clWGDdSIxcOmMrFcGYit9arX/kGuLEO2+w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=jnKjFauM; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="jnKjFauM"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 0FD18236FA;
	Sun, 12 Jan 2025 23:18:54 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=NLK64RaCxw1Xb9E9i9JDqkR3sRmgB0tyONkS1s/r6Mo=; b=jnKjFauMV0mQ
	hHOJZT2DY/Ib6yQsIm7h3O8VLCpEb1EqgDTKOakgWeYhWXo/imyuJqq7rxlqnstP
	AQ4ca47R+ET9e9PnKKBCOxSUMju5mZYTGTk2u/j+CCxf4+Pqi65ttzhzu1fNdKuB
	jgyPkeG9lHrH4hP6BLmWlq48/nNjDxSpIKa4Ckspe7nZgN7hVZ9w1RpZ4OnfKZG5
	sPFCUAi9T5v700MlM7uFcI1/cb210N/bIqZ9PZwqzcHB4OXs1WXDg3/9oSoI0c3Y
	r30tBbz+RuzZMA1exHosZroQaObn7ph6iywDp0LnnK68Rn63IokLRgVsKzhrqyAm
	1W/h2Z15wmpJkv6oY6O+Gkhxoy/niy7LpsWwCC+RYc8MN67HElCgCbt6clNOMEPC
	/5Duv0/W+FQw0+QUtKL1CXAwLnX8phu1w0kbWSlcO/gXRdpbH4tQVXB9/AK5Re3l
	usNVC/p6R8zoj5sb/6kUocxXsaFWB2APe4gw1BcfmYi1wqxyyfQsQedUP73jqJDd
	9uksAfAZvnD8bh8PTm6PovBRVlX+C6107rQnIGJqoapofiFv29/GO8VgCGFeCn2B
	rNO53fFrmsT4tqH+BOhw1FUPmhOUCZSuk7PJSAvQXzVMTzfTi0faPhCLCHySmYUS
	Qnf+oq3ZPMTwhp9JRiw7OPlnWZMWMQc=
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sun, 12 Jan 2025 23:18:53 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id 9CF7115EA3;
	Sun, 12 Jan 2025 23:18:52 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.17.1) with ESMTP id 50CLIhQw042117;
	Sun, 12 Jan 2025 23:18:44 +0200
Date: Sun, 12 Jan 2025 23:18:43 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Jeremy Sowden <azazel@debian.org>
cc: LVS Devel <lvs-devel@vger.kernel.org>
Subject: Re: [PATCH ipvsadm 2/5] ipvsadm: fix ambiguous usage error message
In-Reply-To: <20250112200333.3180808-3-azazel@debian.org>
Message-ID: <67c5c2f3-5a47-b636-96f5-f088019170d7@ssi.bg>
References: <20250112200333.3180808-1-azazel@debian.org> <20250112200333.3180808-3-azazel@debian.org>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Sun, 12 Jan 2025, Jeremy Sowden wrote:

> If `-6` is used without `-f`, the usage error message is "-6 used before -f",
> which can be misconstrued as warning that both options were used but in the
> wrong order.
> 
> Change the option-parsing to allow `-6` to appear before `-f` and the error-
> message in the case that `-6` was used without `-f`.
> 
> Link: http://bugs.debian.org/610596
> Signed-off-by: Jeremy Sowden <azazel@debian.org>
> ---
>  ipvsadm.c | 17 ++++++++++-------
>  1 file changed, 10 insertions(+), 7 deletions(-)
> 
> diff --git a/ipvsadm.c b/ipvsadm.c
> index 42f31a20e596..889128017bd1 100644
> --- a/ipvsadm.c
> +++ b/ipvsadm.c
> @@ -523,7 +523,7 @@ static int
>  parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
>  	      unsigned long long *options, unsigned int *format)
>  {
> -	int c, parse;
> +	int c, parse, ipv6 = 0;
>  	poptContext context;
>  	char *optarg = NULL, sched_flags_arg[128];
>  	struct poptOption options_table[] = {
> @@ -829,12 +829,7 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
>  			*format |= FMT_EXACT;
>  			break;
>  		case '6':
> -			if (ce->svc.fwmark) {
> -				ce->svc.af = AF_INET6;
> -				ce->svc.netmask = 128;
> -			} else {
> -				fail(2, "-6 used before -f\n");
> -			}
> +			ipv6 = 1;
>  			break;
>  		case 'o':
>  			set_option(options, OPTC_ONEPACKET);
> @@ -935,6 +930,14 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
>  		return -1;
>  	}
>  
> +	if (ipv6) {
> +		if (ce->svc.fwmark) {
> +			ce->svc.af = AF_INET6;

	As ce->svc.af is set later after all options are processed,
the -M option will always see AF_INET in ce->svc.af ...

> +			ce->svc.netmask = 128;

	Now we override the value from -M, so we can not do
this here.

> +		} else
> +			fail(2, "-6 used without -f\n");
> +	}
> +
>  	if (ce->cmd == CMD_TIMEOUT) {
>  		char *optarg1, *optarg2;
>  
> -- 
> 2.45.2

Regards

--
Julian Anastasov <ja@ssi.bg>

