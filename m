Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C70053C9457;
	Tue, 12 May 2026 20:51:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778619098; cv=none; b=lrGXalQQp9iQCj9+AELPkd0YS638b6/PMY0U+t6cpj6n3gkS2S2NNNAyHemqR+r3zKYtPkCjBPI5Em2wDhVoXuIgTc83d4q2p6vkhnsymZh/HCDZ5Q83HQQQ2hdJCInUF+HPBOtMFKs8WNJi7gsa1a58RjwTRJEgxq4sQRizY6Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778619098; c=relaxed/simple;
	bh=/EjZjm4abdmBihzVZ9pe8y4+Cm42FFHB9YXjeWIVazY=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=QuT0G2avc6MDum3+Scb09py1ebyRUXFBpwPiqjmNFZFw4Q+kplFgMH6WacxYu4yTjV15+f3yN4mNg3UWEXbhiO3O5SlYvGaieqNXch4tsnDCXVJ8JGnGU7/Ms6+UxEdFPmsFnVxI9dH+Z70tFIAdAWZjAc/opWpGiMFOEFwS5rQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=DVI3RW6k; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="DVI3RW6k"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 2F35F2105C;
	Tue, 12 May 2026 23:51:30 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=G8WMFhOVZAw6ew4FNICjSvBmHsGDOLIOjnkrhMlvXWw=; b=DVI3RW6kEYq8
	WQ5QaKXFnsJMdhfGlvdOOu9J0SXitpKa+D51ABSuNUbNpob4sUs5sRc1xhktHrsW
	oodmevMt/M+WIq91OSEfG1qMeP6HSEPKj64MoPjNxpH+CBCQOEuBxDkaQ8lR69fE
	2dDtNC9k0jTDdeB47P7XL5KWo0dDTXSdfq/ikfP0Oh/Tu9g8YnsAbFFtd8mFl4bm
	KfCefWxyWAV0UvspHnYo4s051J2ZUSapV7PYqppyNT88isXIXllYKyTsMGJBEVr6
	JtG2KkdGNyMdS1USlAWm0dIghHALrk87PGuaq/wWMMKfcduTM3HhBzUbsq/XS0aV
	fjidNdnsoDxaYh4wGfd8S2XtbDJxscWd5e9Jd8onrZ/7ugSd9S9PDyP9Ofsfn7lw
	NiDTuCNC1/meWNkULXem7H3SYuRjGrlptooEFr2Ab8v7ZBSlI0abbJ6FZWWNfjYd
	tVisMZgmz1hIz+aASiipR8d8KCu+L4fptml/jTngobF92Nlzy9AcrWLSB6zlerpj
	ZDEU2cf2oRNbZjAel4DLbG3RjTgUuEVQBWaol+N4b5yXgjY/dW6J9v8/PwQLBGte
	CyuzrQgEa19/ivOs+lrxtqEZyLEfJ2WhkrOTOwsaIfAz5z+m9zYkGhpoeOuK/Ofk
	aG1o3OvEgDxbER87Dc5+astclCOEdXU=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 12 May 2026 23:51:30 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 9A6DC60A24;
	Tue, 12 May 2026 23:51:30 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.1) with ESMTP id 64CKpNw0084581;
	Tue, 12 May 2026 23:51:23 +0300
Date: Tue, 12 May 2026 23:51:23 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Florian Westphal <fw@strlen.de>
cc: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org
Subject: Re: [PATCH nf-next v2] netfilter: add option for GCOV profiling
In-Reply-To: <20260512182946.32687-1-fw@strlen.de>
Message-ID: <383b4900-e709-5f3d-ce8e-c608aad85f8a@ssi.bg>
References: <20260512182946.32687-1-fw@strlen.de>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Tue, 12 May 2026, Florian Westphal wrote:

> Similar to a few other subsystems: add a new config toggle to
> enable netfilter gcov profiling in netfilter, including ebtables,
> arptables and so on.
> 
> ipset and ipvs gain their own, dedicated toggles.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

	Looks good to me, thanks!

For IPVS:

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  v2: add dedicated toggles for ipvs and ipset;
>  I am currently not collecting profile data for these two.
> 
>  If you prefer to keep them under single switch thats fine,
>  just lmk.
> 
>  net/bridge/netfilter/Makefile | 4 ++++
>  net/ipv4/netfilter/Makefile   | 4 ++++
>  net/ipv6/netfilter/Makefile   | 4 ++++
>  net/netfilter/Kconfig         | 8 ++++++++
>  net/netfilter/Makefile        | 4 ++++
>  net/netfilter/ipset/Kconfig   | 9 +++++++++
>  net/netfilter/ipset/Makefile  | 3 +++
>  net/netfilter/ipvs/Kconfig    | 9 +++++++++
>  net/netfilter/ipvs/Makefile   | 3 +++
>  9 files changed, 48 insertions(+)
> 
> diff --git a/net/bridge/netfilter/Makefile b/net/bridge/netfilter/Makefile
> index b9a1303da977..af0c903aa4ac 100644
> --- a/net/bridge/netfilter/Makefile
> +++ b/net/bridge/netfilter/Makefile
> @@ -38,3 +38,7 @@ obj-$(CONFIG_BRIDGE_EBT_SNAT) += ebt_snat.o
>  # watchers
>  obj-$(CONFIG_BRIDGE_EBT_LOG) += ebt_log.o
>  obj-$(CONFIG_BRIDGE_EBT_NFLOG) += ebt_nflog.o
> +
> +ifdef CONFIG_GCOV_PROFILE_NETFILTER
> +GCOV_PROFILE := y
> +endif
> diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
> index 85502d4dfbb4..dbfb1c4739a8 100644
> --- a/net/ipv4/netfilter/Makefile
> +++ b/net/ipv4/netfilter/Makefile
> @@ -51,3 +51,7 @@ obj-$(CONFIG_IP_NF_ARP_MANGLE) += arpt_mangle.o
>  obj-$(CONFIG_IP_NF_ARPFILTER) += arptable_filter.o
>  
>  obj-$(CONFIG_NF_DUP_IPV4) += nf_dup_ipv4.o
> +
> +ifdef CONFIG_GCOV_PROFILE_NETFILTER
> +GCOV_PROFILE := y
> +endif
> diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
> index 66ce6fa5b2f5..72902d8005ad 100644
> --- a/net/ipv6/netfilter/Makefile
> +++ b/net/ipv6/netfilter/Makefile
> @@ -43,3 +43,7 @@ obj-$(CONFIG_IP6_NF_MATCH_SRH) += ip6t_srh.o
>  obj-$(CONFIG_IP6_NF_TARGET_NPT) += ip6t_NPT.o
>  obj-$(CONFIG_IP6_NF_TARGET_REJECT) += ip6t_REJECT.o
>  obj-$(CONFIG_IP6_NF_TARGET_SYNPROXY) += ip6t_SYNPROXY.o
> +
> +ifdef CONFIG_GCOV_PROFILE_NETFILTER
> +GCOV_PROFILE := y
> +endif
> diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
> index 682c675125fc..f71ff98eb5d0 100644
> --- a/net/netfilter/Kconfig
> +++ b/net/netfilter/Kconfig
> @@ -1648,6 +1648,14 @@ config NETFILTER_XT_MATCH_U32
>  
>  endif # NETFILTER_XTABLES
>  
> +config GCOV_PROFILE_NETFILTER
> +	bool "Enable GCOV profiling for netfilter"
> +	depends on GCOV_KERNEL
> +	help
> +	  Enable GCOV profiling for netfilter to check which functions/lines
> +	  are executed.
> +
> +	  If unsure, say N.
>  endmenu
>  
>  source "net/netfilter/ipset/Kconfig"
> diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
> index 6bfc250e474f..f0751ca302c6 100644
> --- a/net/netfilter/Makefile
> +++ b/net/netfilter/Makefile
> @@ -240,3 +240,7 @@ obj-$(CONFIG_IP_VS) += ipvs/
>  
>  # lwtunnel
>  obj-$(CONFIG_LWTUNNEL) += nf_hooks_lwtunnel.o
> +
> +ifdef CONFIG_GCOV_PROFILE_NETFILTER
> +GCOV_PROFILE := y
> +endif
> diff --git a/net/netfilter/ipset/Kconfig b/net/netfilter/ipset/Kconfig
> index b1ea054bb82c..6c4d54758106 100644
> --- a/net/netfilter/ipset/Kconfig
> +++ b/net/netfilter/ipset/Kconfig
> @@ -175,4 +175,13 @@ config IP_SET_LIST_SET
>  
>  	  To compile it as a module, choose M here.  If unsure, say N.
>  
> +config GCOV_PROFILE_IPSET
> +	bool "Enable GCOV profiling for ipset"
> +	depends on GCOV_KERNEL
> +	help
> +	  Enable GCOV profiling for ipset to check which functions/lines
> +	  are executed.
> +
> +	  If unsure, say N.
> +
>  endif # IP_SET
> diff --git a/net/netfilter/ipset/Makefile b/net/netfilter/ipset/Makefile
> index a445a6bf4f11..4f48df5406cd 100644
> --- a/net/netfilter/ipset/Makefile
> +++ b/net/netfilter/ipset/Makefile
> @@ -29,3 +29,6 @@ obj-$(CONFIG_IP_SET_HASH_NETPORTNET) += ip_set_hash_netportnet.o
>  
>  # list types
>  obj-$(CONFIG_IP_SET_LIST_SET) += ip_set_list_set.o
> +ifdef CONFIG_GCOV_PROFILE_IPSET
> +GCOV_PROFILE := y
> +endif
> diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
> index c203252e856d..7724cb44e6de 100644
> --- a/net/netfilter/ipvs/Kconfig
> +++ b/net/netfilter/ipvs/Kconfig
> @@ -349,4 +349,13 @@ config	IP_VS_PE_SIP
>  	help
>  	  Allow persistence based on the SIP Call-ID
>  
> +config GCOV_PROFILE_IPVS
> +	bool "Enable GCOV profiling for IPVS"
> +	depends on GCOV_KERNEL
> +	help
> +	  Enable GCOV profiling for IPVS to check which functions/lines
> +	  are executed.
> +
> +	  If unsure, say N.
> +
>  endif # IP_VS
> diff --git a/net/netfilter/ipvs/Makefile b/net/netfilter/ipvs/Makefile
> index bb5d8125c82a..8e4cc67ad39d 100644
> --- a/net/netfilter/ipvs/Makefile
> +++ b/net/netfilter/ipvs/Makefile
> @@ -43,3 +43,6 @@ obj-$(CONFIG_IP_VS_FTP) += ip_vs_ftp.o
>  
>  # IPVS connection template retrievers
>  obj-$(CONFIG_IP_VS_PE_SIP) += ip_vs_pe_sip.o
> +ifdef CONFIG_GCOV_PROFILE_IPVS
> +GCOV_PROFILE := y
> +endif
> -- 
> 2.53.0

Regards

--
Julian Anastasov <ja@ssi.bg>

