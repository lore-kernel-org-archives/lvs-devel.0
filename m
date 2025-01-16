Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 89E3522FAC3
	for <lvs-devel@vger.kernel.org>; Thu, 16 Jan 2025 18:44:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1737053094; cv=none; b=GbD97vO/e3huywt96o3UtIu+1+GJflkioPX8l4oTlsTkdxrZ2EZ2wUquICFixswtut+4UL9RmlD7bLDOB8uTijtLqvv0aJVD9PZp/AtWOC3Piu88vbspc1Xxo8h/v3ZYna8pz35yekVnRYA+srcLh6KdZ3FFaZ9YH4L/xs3UwRk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1737053094; c=relaxed/simple;
	bh=wT9DuaF1zHeSSLunNpwXGYkttz/jPIXag3Zg0znsszI=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=WgsFgH982dtsCAxdevnN/VXGXfAdoJhhpaTplTu1C0kHOaueNzJ4O626pYZNbEtdMhYfd+nwH9+dTRUPvH+ygUsi8scgTee+Y3+A/dG37vx3JQNfrFMkyBTBP8Q67kjEmXL//Cuva1svGHyMAaWoM4lP2NwIW5jyL08V9SPeRjI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=V3k5UE1X; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="V3k5UE1X"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 3158E236F5;
	Thu, 16 Jan 2025 20:44:42 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=NEmIvwrLCYP4xUgiajeJ1nWH+/959WKlZIePL3JqCQE=; b=V3k5UE1XVN7l
	6CY9RueUThcPpEjJ5xkajJBXTxEeCElew1LRsZ7+DEVF6xxNRt0mBiTRRjqopF06
	7ZLk/g7TON9xqUWxCQm4afkWh33T0Vqz9EnUHkXNwsPISHGbeQM2SjhiJfbl5nry
	fmfi+S+gYFWgsPdiHERs2bTRA6uG3nkaCbChNLF9qQu5QUsDcvbpo2HSNOai7aym
	9AJ38re1c6ytHXqVBHMqT9dLP9shtai3GBErjGN9WruhaYfs41ZfpARlKIVkV2Xb
	O7hiPHorcOav7EVjjQrhAhiX1aVGy0ppbj5sWf55bEKIqLVl8zGNqF3cYKScyIrD
	mW7Wrudu65I6lqkQZTTym7+admke21ipBwX1iGKU9dVmgpV3J6eLkDTv8Y1LDcTY
	Js2U5t1Um5mYyRsOqtrgjS3eMCj66uNSMSNElJxgPCZJpmXx3+p0xjcBVVn61yk7
	/Zw+cgzRiKaZBhrypf3+V2ZOHdVuLN96Zx5VPH6R4t+Pbr0xwpP9ZaGPyOztNEh3
	qddLd2Jle2+1FDv7jc2T7NB44JfgA2JcD1mIHuxHQDj2sd7W0BXSp7BNMnsMPydS
	OPdYOa2E+8FFQ3LWaLinq0/WLcTD9yrGlMacifp4LrA03ZcEs6sa/MFayOssRKgS
	j4OeapgtkDfLJYAVDwYiYVpmCm8I9XQ=
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 16 Jan 2025 20:44:40 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id 7712415EA8;
	Thu, 16 Jan 2025 20:44:40 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.17.1) with ESMTP id 50GIiSZ5043600;
	Thu, 16 Jan 2025 20:44:31 +0200
Date: Thu, 16 Jan 2025 20:44:28 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Jeremy Sowden <azazel@debian.org>
cc: LVS Devel <lvs-devel@vger.kernel.org>, Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH ipvsadm v3 0/5] Debian package fixes
In-Reply-To: <20250115183311.3386192-1-azazel@debian.org>
Message-ID: <65ced269-1b69-3bd9-9ffc-807780e47e16@ssi.bg>
References: <20250115183311.3386192-1-azazel@debian.org>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Wed, 15 Jan 2025, Jeremy Sowden wrote:

> The Debian package of ipvsadm carries a few patches.  Some of them have
> been around for years.  None of them is specific to Debian, so I'm
> forwarding them upstream.
> 
> Patch 1 bumps the maximum weight accepted by ipvsadm.
> Patch 2 fixes an unclear usage error message.
> Patches 3-5 make some improvements to the Makefiles.
> 
> Changes since v2:
> 
> * Reformat the commit messages of patches 1, 2 & 5 according to the
>   kernel's preferred patch format.
> 
> Changes since v1:
> 
> * The previous version of patch 2 changed the logic of the option parsing
>   in such a way that using `-M` after `-6` no longer worked correctly.
>   Thisversion just rewords the error message.
> 
> Jeremy Sowden (5):
>   ipvsadm: increase maximum weight value
>   ipvsadm: fix ambiguous usage error message
>   Use variable for pkg-config in Makefiles
>   Support environmental and command-line `*FLAGS` variable in Makefiles
>   Make sure libipvs.a is built before ipvsadm

	Patchset looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

	Simon, please apply to the ipvsadm tree!

>  Makefile         | 19 +++++++++++--------
>  ipvsadm.8        |  2 +-
>  ipvsadm.c        |  4 ++--
>  libipvs/Makefile | 29 +++++++++++++++--------------
>  4 files changed, 29 insertions(+), 25 deletions(-)
> 
> -- 
> 2.45.2

Regards

--
Julian Anastasov <ja@ssi.bg>

