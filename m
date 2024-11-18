Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0239F26AD0;
	Mon, 18 Nov 2024 12:50:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1731934224; cv=none; b=clCNXHv/pkEtNGTVJ8pkGRXQsLPieaWnGK+55nnAGlxiyDPWvEyqDo0WQJ3OxuW990IjaSqNedzXCb/+HW7UiwOucvxFP94tsspTTAutu6u32XFbFt1S3XqQ72srkVfKdT4L8ZAas7kkwnBS/Nn+IaANT/h5MSGnJCl4aWtq00M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1731934224; c=relaxed/simple;
	bh=s58+oJpUcZU53E8zvr9EuG43vMWpmCCxA/lYnCWlie0=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=Hvmnk37iy0Th1NByTYlyvqG+J9gw9zP1U7VeWWd03TT7xSzTAVsjkiLFqmIvkHFl8IqdBHWfo+DgstntJcMwBwLPAIBDdq9tX8FCR4OYEqzPlSJ+Z9foXEGxVA0DcdJWaHJrZnId6fMq3XJbwZOYCqOnEMIHQaONlUEjv6e6rp0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=si6TuWGl; arc=none smtp.client-ip=193.238.174.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="si6TuWGl"
Received: from mg.ssi.bg (localhost [127.0.0.1])
	by mg.ssi.bg (Proxmox) with ESMTP id 3F034835D7;
	Mon, 18 Nov 2024 14:41:34 +0200 (EET)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.ssi.bg (Proxmox) with ESMTPS;
	Mon, 18 Nov 2024 14:41:33 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id 7D5553026AC;
	Mon, 18 Nov 2024 14:41:25 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1731933686; bh=s58+oJpUcZU53E8zvr9EuG43vMWpmCCxA/lYnCWlie0=;
	h=Date:From:To:cc:Subject:In-Reply-To:References;
	b=si6TuWGlYBk+G6fQqyuo9TlTiEl6043HtoNQHe+IIoPBtwwMj3UWFkDQyq2VSIaDo
	 +4GmqhYXrYKydei89Nsky+aPap/JMujkMQl2fi0XxSXBIb5TfnK492EcxKAjZ5X3Ba
	 elu5nyO9AmeHEQgX2MdmaFtExY9aP4Kpn2LjPuDU=
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.17.1) with ESMTP id 4AICfNOD034252;
	Mon, 18 Nov 2024 14:41:23 +0200
Date: Mon, 18 Nov 2024 14:41:23 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Jinghao Jia <jinghao7@illinois.edu>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@netfilter.org>,
        Nathan Chancellor <nathan@kernel.org>,
        Nick Desaulniers <ndesaulniers@google.com>,
        Bill Wendling <morbo@google.com>,
        Justin Stitt <justinstitt@google.com>, Kees Cook <kees@kernel.org>,
        netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel <linux-kernel@vger.kernel.org>, llvm@lists.linux.dev,
        kernel test robot <lkp@intel.com>, Ruowen Qin <ruqin@redhat.com>
Subject: Re: [PATCH] ipvs: fix UB due to uninitialized stack access in
 ip_vs_protocol_init()
In-Reply-To: <20241111065105.82431-1-jinghao7@illinois.edu>
Message-ID: <f97ef69b-a15e-03ab-5e24-c1dfd3c4542b@ssi.bg>
References: <20241111065105.82431-1-jinghao7@illinois.edu>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 11 Nov 2024, Jinghao Jia wrote:

> Under certain kernel configurations when building with Clang/LLVM, the
> compiler does not generate a return or jump as the terminator
> instruction for ip_vs_protocol_init(), triggering the following objtool
> warning during build time:
> 
>   vmlinux.o: warning: objtool: ip_vs_protocol_init() falls through to next function __initstub__kmod_ip_vs_rr__935_123_ip_vs_rr_init6()
> 
> At runtime, this either causes an oops when trying to load the ipvs
> module or a boot-time panic if ipvs is built-in. This same issue has
> been reported by the Intel kernel test robot previously.
> 
> Digging deeper into both LLVM and the kernel code reveals this to be a
> undefined behavior problem. ip_vs_protocol_init() uses a on-stack buffer
> of 64 chars to store the registered protocol names and leaves it
> uninitialized after definition. The function calls strnlen() when
> concatenating protocol names into the buffer. With CONFIG_FORTIFY_SOURCE
> strnlen() performs an extra step to check whether the last byte of the
> input char buffer is a null character (commit 3009f891bb9f ("fortify:
> Allow strlen() and strnlen() to pass compile-time known lengths")).
> This, together with possibly other configurations, cause the following
> IR to be generated:
> 
>   define hidden i32 @ip_vs_protocol_init() local_unnamed_addr #5 section ".init.text" align 16 !kcfi_type !29 {
>     %1 = alloca [64 x i8], align 16
>     ...
> 
>   14:                                               ; preds = %11
>     %15 = getelementptr inbounds i8, ptr %1, i64 63
>     %16 = load i8, ptr %15, align 1
>     %17 = tail call i1 @llvm.is.constant.i8(i8 %16)
>     %18 = icmp eq i8 %16, 0
>     %19 = select i1 %17, i1 %18, i1 false
>     br i1 %19, label %20, label %23
> 
>   20:                                               ; preds = %14
>     %21 = call i64 @strlen(ptr noundef nonnull dereferenceable(1) %1) #23
>     ...
> 
>   23:                                               ; preds = %14, %11, %20
>     %24 = call i64 @strnlen(ptr noundef nonnull dereferenceable(1) %1, i64 noundef 64) #24
>     ...
>   }
> 
> The above code calculates the address of the last char in the buffer
> (value %15) and then loads from it (value %16). Because the buffer is
> never initialized, the LLVM GVN pass marks value %16 as undefined:
> 
>   %13 = getelementptr inbounds i8, ptr %1, i64 63
>   br i1 undef, label %14, label %17
> 
> This gives later passes (SCCP, in particular) to more DCE opportunities
> by propagating the undef value further, and eventually removes
> everything after the load on the uninitialized stack location:
> 
>   define hidden i32 @ip_vs_protocol_init() local_unnamed_addr #0 section ".init.text" align 16 !kcfi_type !11 {
>     %1 = alloca [64 x i8], align 16
>     ...
> 
>   12:                                               ; preds = %11
>     %13 = getelementptr inbounds i8, ptr %1, i64 63
>     unreachable
>   }
> 
> In this way, the generated native code will just fall through to the
> next function, as LLVM does not generate any code for the unreachable IR
> instruction and leaves the function without a terminator.
> 
> Zero the on-stack buffer to avoid this possible UB.
> 
> Reported-by: kernel test robot <lkp@intel.com>
> Closes: https://lore.kernel.org/oe-kbuild-all/202402100205.PWXIz1ZK-lkp@intel.com/
> Co-developed-by: Ruowen Qin <ruqin@redhat.com>
> Signed-off-by: Ruowen Qin <ruqin@redhat.com>
> Signed-off-by: Jinghao Jia <jinghao7@illinois.edu>

	Looks good to me, thanks! I assume it is for
net-next/nf-next, right?

Acked-by: Julian Anastasov <ja@ssi.bg>

> ---
>  net/netfilter/ipvs/ip_vs_proto.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
> index f100da4ba3bc..a9fd1d3fc2cb 100644
> --- a/net/netfilter/ipvs/ip_vs_proto.c
> +++ b/net/netfilter/ipvs/ip_vs_proto.c
> @@ -340,7 +340,7 @@ void __net_exit ip_vs_protocol_net_cleanup(struct netns_ipvs *ipvs)
>  
>  int __init ip_vs_protocol_init(void)
>  {
> -	char protocols[64];
> +	char protocols[64] = { 0 };
>  #define REGISTER_PROTOCOL(p)			\
>  	do {					\
>  		register_ip_vs_protocol(p);	\
> @@ -348,8 +348,6 @@ int __init ip_vs_protocol_init(void)
>  		strcat(protocols, (p)->name);	\
>  	} while (0)
>  
> -	protocols[0] = '\0';
> -	protocols[2] = '\0';
>  #ifdef CONFIG_IP_VS_PROTO_TCP
>  	REGISTER_PROTOCOL(&ip_vs_protocol_tcp);
>  #endif
> -- 
> 2.47.0

Regards

--
Julian Anastasov <ja@ssi.bg>

