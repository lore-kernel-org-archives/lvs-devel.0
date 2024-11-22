Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 325371AB535;
	Fri, 22 Nov 2024 11:43:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1732275806; cv=none; b=Dxoca8psruYuQmLTu8gZ1q7WQz0HLu7Pig0IJVnD3mn0P4JMoxpZ/ccwntdVBHcSzHIjyJUqqw/GDSdxIY1UlPDQwGJiYDVmCfQ3fNBV188I+zPixoM3bRrGaUZ0DYMHlPuH7QkTiBrO8TI8XB6/u4HeuFwWjFph0oUmbXKxG3k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1732275806; c=relaxed/simple;
	bh=vLEMZZRV6Tb/GSrZfvxdj8fXkAKkDZRU/uiNN4sVXnw=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=nhc95oLQcFu769hZUxah7KpmDPaEsOWyG0FhHmCo1bYwB3Wh4L708owiC+xrPiGSa8RIzc3nNVQ5IWJ0Q0m2/AiaRu6z4eP7q+d6NZ4MRN1cGlcwmViz0RBwQVm0uSVMnnv7bQC2eCnnWIMelh2lZZEHH8gSSRvupOPYFGPoOCU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=PP3qrNcO; arc=none smtp.client-ip=193.238.174.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="PP3qrNcO"
Received: from mg.ssi.bg (localhost [127.0.0.1])
	by mg.ssi.bg (Proxmox) with ESMTP id 0F9E28106A;
	Fri, 22 Nov 2024 13:43:21 +0200 (EET)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.ssi.bg (Proxmox) with ESMTPS;
	Fri, 22 Nov 2024 13:43:20 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id 29C52302A21;
	Fri, 22 Nov 2024 13:43:08 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1732275790; bh=vLEMZZRV6Tb/GSrZfvxdj8fXkAKkDZRU/uiNN4sVXnw=;
	h=Date:From:To:cc:Subject:In-Reply-To:References;
	b=PP3qrNcOkyDUcGvZn+zKDbEho8Gtjcv16SQIk2tpMRqH1FEMVi78J/uU/OJnfxRIf
	 4atHzQYHf8CA6Tr2qPV0U5W3dWvRvcZzFvj0a81kb+Rrr7VOD2FaKt/wu7UwUfFrVN
	 5MbQBOSv4xwK7ZKalc9/3QHQjDhsBrHxYWPGWQW4=
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.17.1) with ESMTP id 4AMBh5tV027561;
	Fri, 22 Nov 2024 13:43:05 +0200
Date: Fri, 22 Nov 2024 13:43:05 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Jinghao Jia <jinghao7@illinois.edu>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@netfilter.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, Nathan Chancellor <nathan@kernel.org>,
        Nick Desaulniers <ndesaulniers@google.com>,
        Bill Wendling <morbo@google.com>,
        Justin Stitt <justinstitt@google.com>, Kees Cook <kees@kernel.org>,
        netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org, llvm@lists.linux.dev,
        kernel test robot <lkp@intel.com>, Ruowen Qin <ruqin@redhat.com>
Subject: Re: [PATCH v2 net] ipvs: fix UB due to uninitialized stack access
 in ip_vs_protocol_init()
In-Reply-To: <20241122045257.27452-1-jinghao7@illinois.edu>
Message-ID: <c65f0110-f5bf-c841-710e-2932cceec25a@ssi.bg>
References: <20241122045257.27452-1-jinghao7@illinois.edu>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Thu, 21 Nov 2024, Jinghao Jia wrote:

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
> This gives later passes (SCCP, in particular) more DCE opportunities by
> propagating the undef value further, and eventually removes everything
> after the load on the uninitialized stack location:
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
> Changelog:
> ---

	You can not add --- before the following headers.
'git am file.patch' can show the result of applying the patch.

> v1 -> v2:
> v1: https://lore.kernel.org/lkml/20241111065105.82431-1-jinghao7@illinois.edu/
> * Fix small error in commit message
> * Address Julian's feedback:
>   * Make this patch target the net tree rather than net-next
>   * Add a "Fixes" tag for the initial git commit
> 
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Reported-by: kernel test robot <lkp@intel.com>
> Closes: https://lore.kernel.org/oe-kbuild-all/202402100205.PWXIz1ZK-lkp@intel.com/
> Co-developed-by: Ruowen Qin <ruqin@redhat.com>
> Signed-off-by: Ruowen Qin <ruqin@redhat.com>
> Signed-off-by: Jinghao Jia <jinghao7@illinois.edu>
> ---

	Please send v3, you can move your changelog here,
after the above ---

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

