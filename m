Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 093253A1A55
	for <lvs-devel@vger.kernel.org>; Tue, 15 Sep 2026 17:20:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789492842; cv=none; b=X7iQlCzLPkNxBhBZ0qgJ3Pwmc+rDzZ6gM1SHsfUbQAbmj4Il+yJshSOWexBX5SCqhqICIzznOdoqEkZps/eINbTkRmLSCKEmitCbcDPsogWo3lpgOl6920iaJYJbzbrwZdmRHUJrU0SyFLcC/txykJ9tcClTbd8hYM6rpITCRgA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789492842; c=relaxed/simple;
	bh=TnpTVFsOS2DpHOA6eZtbqIcjsBDg3Dqk9jO0aIDedFI=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=GiTa2P8/APlv6NCkLo1O7Q0VgJkhFp6MoWuAHUt97YIZkz0lds1Btq+mcTDoFvadIUSwqwaFGCXqWJjHj80giKTDlobhQLfHH7fEs7ePcxXgjhqVTG50ClU1UGrUI1qF6Jd6G/z/poedEakQlmjHv/LJeuVv9EFCtGpMP8xrRYU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=um2x1YDS; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="um2x1YDS"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 261C9217B5;
	Tue, 15 Sep 2026 20:20:32 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=k+rMdoZwOHAQimwEhuncB+edlbRlknAhbI6kAl9fJCI=; b=um2x1YDSFtt1
	ozH0S68UF4UdHc/uDfCEE9oa8biYT2zr/Xc1xfJXWWoz6a8+Nq1pT5XyGDxo2gt1
	apbJ2FonHg4Rv5mer5bUR93Mnmjxyt/I9DTfVWWEe5Gv8fkeFESV3NwrOyZnukzU
	fy/Vh8MG1gKBtEmZMPNKtSrIMgjCKvbUpjlRy4ASUTLYG0CqBmTbka6PIdRCGTuW
	piiEuk2NOEzy9+mh3DfWGq8Rx+diM5VCdF6aztlsuMc2oDmBgmAkFTCvQxstQ9gs
	3Ko1H781+h4urarkYAT0fRYcPJt4jvX6vjC7k++8jYgI2ALvsiA9syNaSpYhJZEe
	EUE8IVUDdbtA0SwJdcfje/358SudR0oP2GGqP8IK5pEswvit1Hi+T7CpbeNtSj1a
	5Du67JJLdeEWRzXK+PLnYxSkMzqbNnlB2yz52OXtIRU2811SyKRmzIzqeeYc/D0J
	eJXNkaAnlxvcHbo7T8+c089MlLIO/DuNJUqn0HY9Yf/+39lfMeTn/TTgplew5TdM
	Heugj9T+JqHmfKP4ALVUG1VHShK8Tmw+b7EdDpQTEWYVWLZbfPkP+/ac+CSYvUi2
	W4Eewn1AEcV+59VIwRJVUfIZ2X2WZ39qvT9Pd/qthzWuQdNzU3glcOcbd1IQat9J
	hmSapS8LYLOc0VNCtvT3I0xxH1z6P6M=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 15 Sep 2026 20:20:31 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id A6C7B601AB;
	Tue, 15 Sep 2026 20:20:33 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68FHKQsI084382;
	Tue, 15 Sep 2026 20:20:30 +0300
Date: Tue, 15 Sep 2026 20:20:26 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Quentin Armitage <quentin@armitage.org.uk>
cc: lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] Document support of twos scheduler - leading spaces now
 resolved
In-Reply-To: <d4ef159477c479f99c8d4a2e3e817eb0451da4e1.camel@armitage.org.uk>
Message-ID: <998fa489-ba3f-2024-a172-21ae4688d75a@ssi.bg>
References: <d4ef159477c479f99c8d4a2e3e817eb0451da4e1.camel@armitage.org.uk>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 14 Sep 2026, Quentin Armitage wrote:

> The Linux kernel has supported the twos scheduler since v6.12. Make
> sure ipvsadm users know it exists.
> 
> Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>

	Looks good to me, thanks! Simon, please consider
for the ipvsadm tree.

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  SCHEDULERS | 2 +-
>  ipvsadm.8  | 5 +++++
>  2 files changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/SCHEDULERS b/SCHEDULERS
> index 06d3357..8ddef23 100644
> --- a/SCHEDULERS
> +++ b/SCHEDULERS
> @@ -1 +1 @@
> -rr|wrr|lc|wlc|lblc|lblcr|dh|sh|sed|nq|fo|ovf|mh
> +rr|wrr|lc|wlc|lblc|lblcr|dh|sh|sed|nq|fo|ovf|mh|twos
> diff --git a/ipvsadm.8 b/ipvsadm.8
> index 3d7541a..fe0f481 100644
> --- a/ipvsadm.8
> +++ b/ipvsadm.8
> @@ -286,6 +286,11 @@ server as it was before.
>  This scheduler has two flags: mh-fallback, which enables fallback to a
>  different server if the selected server was unavailable, and mh-port,
>  which adds the source port number to the hash computation.
> +.sp
> +\fBtwos\fR - random twos choice: the algorithm picks two random
> +servers based on weights then selects the server with the least
> +amount of connections normalized by weight. The algorithm avoids
> +the "herd behavior" problem.
>  .TP
>  .B -p, --persistent [\fItimeout\fP]
>  Specify that a virtual service is persistent. If this option is
> 
> --
> 2.55.0

Regards

--
Julian Anastasov <ja@ssi.bg>

