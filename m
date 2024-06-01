Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8ED0E208C4;
	Sat,  1 Jun 2024 08:22:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1717230158; cv=none; b=mrPbpaek6j7cH9YUXWEkmUkU2zn1ZJeyEOIZGl6mHOEZrKcihJJ2ET5NY7j0ReAsmcqGYFYZ6kg+HSPIszp+wT6EMJYcAITCeNWU+yWUSkQXH9NrBVvsYXYKH1PBptTsznNVAZtPLoh+9eDyP3hbbV6ekUTK0xxe8iUjTfYDAOs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1717230158; c=relaxed/simple;
	bh=JLVzQUB0aSZj9RaOqI41nLym0rfT53TOTj5bWG0vSNw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=R9Ucri+IRs2MPepP2sb+GjspFRyfxInC7lZ3eCYq/BDGId3dfNxdMBh2bgSua0ASLNIyg5qkFTS7saaFneRs1/7HcL5/8Dr7adumvRpnkgRnVKWxx0Uah0f0URhs7J3yYEY5EpaMlAcKhy8hfdLf74P6r//u28OpsJYIpi2hhK0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ovsoJpri; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ovsoJpri"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1BD07C116B1;
	Sat,  1 Jun 2024 08:22:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1717230158;
	bh=JLVzQUB0aSZj9RaOqI41nLym0rfT53TOTj5bWG0vSNw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=ovsoJpri7gU/jksFE4nBfQJPMM9cquPrHOK4BrW+iOeh4K4BfiASUijafHNOFrTT2
	 pzd2LwHNqWAD3h+H4QPjVPGGarGS0EccXBgL2/qXatcpzikdwLlD0lhQMA1PCaD5Ax
	 rmfeOVxUzzAGlEk7SElpYJxH9ajoSPY+SpbxLyP+AXB+tq9t/sTX6hCVm+b70b4Vsw
	 AKbhN34DS0eOyclUdPdvI8C5f2wIZR4zBLtHuQ5zz6LWdARTgHCgzTEbstEkTI1UBo
	 qysivvmVgwVucs+Ss9ZrGTMzrd/5aj5UeV7H3cSD3kOMhXVwIfMEVUBKDin1Rb6iMv
	 G19ibKu13KA2Q==
Date: Sat, 1 Jun 2024 09:22:33 +0100
From: Simon Horman <horms@kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Ismael Luceno <iluceno@suse.de>, linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Michal =?utf-8?Q?Kube=C4=8Dek?= <mkubecek@suse.com>,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, coreteam@netfilter.org
Subject: Re: [PATCH] ipvs: Avoid unnecessary calls to skb_is_gso_sctp
Message-ID: <20240601082233.GW491852@kernel.org>
References: <20240523165445.24016-1-iluceno@suse.de>
 <16cacbcd-2f4c-1dc1-ecf7-8c081c84c6aa@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <16cacbcd-2f4c-1dc1-ecf7-8c081c84c6aa@ssi.bg>

On Mon, May 27, 2024 at 08:59:37PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 23 May 2024, Ismael Luceno wrote:
> 
> > In the context of the SCTP SNAT/DNAT handler, these calls can only
> > return true.
> > 
> > Ref: e10d3ba4d434 ("ipvs: Fix checksumming on GSO of SCTP packets")
> 
> 	checkpatch.pl prefers to see the "commit" word:
> 
> Ref: commit e10d3ba4d434 ("ipvs: Fix checksumming on GSO of SCTP packets")
> 
> > Signed-off-by: Ismael Luceno <iluceno@suse.de>
> 
> 	Looks good to me for nf-next, thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Likewise, looks good to me.

Acked-by: Simon Horman <horms@kernel.org>

...
