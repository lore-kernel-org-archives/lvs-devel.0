Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4649284E1C;
	Thu, 28 Nov 2024 11:19:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1732792752; cv=none; b=X/MR4R458++ZpSs48efFYzpW3dOMaLz/WWjqUcgBxWU4gubuYL0WsTz/leez02XwTMnEHNO1QJTjubO2Is4Z+Jow0QDAHYWtz7qCiCOS+mGudmGQ6R2Zd7CVSNMwQMgnaR/gWcD9+RFmhMJd35YwdKNdpRfiWX4Ruf4EE6YeNEo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1732792752; c=relaxed/simple;
	bh=UeZaCJrPRNOMMCTBxSYlt5tB19qDO3+mBAS1XVsGV0A=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=mexfi/zlez6bCxOhhsyNPTsRRHg3JPLbwR3AG8Ht4qLzoBJr+7ECCllaikw76BJpAKcjL8W+526W8EX9aMteaYuavBNi4X9CRl7q/HT2EMEJOSChJ81YV6mJPi+RRfKbjLYkBY1CFVHER0MA1i8d1/0bt/7UOiAvrQTYFfirIl0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=gSatPmu+; arc=none smtp.client-ip=193.238.174.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="gSatPmu+"
Received: from mg.ssi.bg (localhost [127.0.0.1])
	by mg.ssi.bg (Proxmox) with ESMTP id 1CA7481300;
	Thu, 28 Nov 2024 13:19:02 +0200 (EET)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.ssi.bg (Proxmox) with ESMTPS;
	Thu, 28 Nov 2024 13:19:00 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id DF85A302E72;
	Thu, 28 Nov 2024 13:18:49 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1732792731; bh=UeZaCJrPRNOMMCTBxSYlt5tB19qDO3+mBAS1XVsGV0A=;
	h=Date:From:To:cc:Subject:In-Reply-To:References;
	b=gSatPmu+YkuDPMzVzD08d01eTowkOx6BFD8bNfsIC9QiGnfTQeawdi4B87JHBAzs3
	 gIUbq85ZKcI0aJbVdQlEBaCNR/gkcDYK9Bru178+Nafv7zVYm+wnVcyY7SSiNWq9QC
	 ylYe0bSzxW9reJ7b67ZyY3wVGRk28GgZ24gcNItg=
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.17.1) with ESMTP id 4ASBIdhE024472;
	Thu, 28 Nov 2024 13:18:39 +0200
Date: Thu, 28 Nov 2024 13:18:39 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Paolo Abeni <pabeni@redhat.com>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org, llvm@lists.linux.dev,
        "David S. Miller" <davem@davemloft.net>,
        kernel test robot <lkp@intel.com>, Ruowen Qin <ruqin@redhat.com>,
        Jinghao Jia <jinghao7@illinois.edu>,
        Jozsef Kadlecsik <kadlec@netfilter.org>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Kees Cook <kees@kernel.org>, Nathan Chancellor <nathan@kernel.org>,
        Nick Desaulniers <ndesaulniers@google.com>,
        Bill Wendling <morbo@google.com>,
        Justin Stitt <justinstitt@google.com>
Subject: Re: [PATCH v3 net] ipvs: fix UB due to uninitialized stack access
 in ip_vs_protocol_init()
In-Reply-To: <70cd1035-07d8-4356-a53e-020d93c2515e@redhat.com>
Message-ID: <87fca918-403d-2fd5-576a-dfa730483fc2@ssi.bg>
References: <20241123094256.28887-1-jinghao7@illinois.edu> <70cd1035-07d8-4356-a53e-020d93c2515e@redhat.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Thu, 28 Nov 2024, Paolo Abeni wrote:

> On 11/23/24 10:42, Jinghao Jia wrote:
> > Under certain kernel configurations when building with Clang/LLVM, the
> > compiler does not generate a return or jump as the terminator
> > instruction for ip_vs_protocol_init(), triggering the following objtool
> > warning during build time:
> > 
> >   vmlinux.o: warning: objtool: ip_vs_protocol_init() falls through to next function __initstub__kmod_ip_vs_rr__935_123_ip_vs_rr_init6()
> > 
> > At runtime, this either causes an oops when trying to load the ipvs
> > module or a boot-time panic if ipvs is built-in. This same issue has
> > been reported by the Intel kernel test robot previously.
> > 
> > Digging deeper into both LLVM and the kernel code reveals this to be a
> > undefined behavior problem. ip_vs_protocol_init() uses a on-stack buffer
> > of 64 chars to store the registered protocol names and leaves it
> > uninitialized after definition. The function calls strnlen() when
> > concatenating protocol names into the buffer. With CONFIG_FORTIFY_SOURCE
> > strnlen() performs an extra step to check whether the last byte of the
> > input char buffer is a null character (commit 3009f891bb9f ("fortify:
> > Allow strlen() and strnlen() to pass compile-time known lengths")).
> > This, together with possibly other configurations, cause the following
> > IR to be generated:
> > 
> >   define hidden i32 @ip_vs_protocol_init() local_unnamed_addr #5 section ".init.text" align 16 !kcfi_type !29 {
> >     %1 = alloca [64 x i8], align 16
> >     ...
> > 
> >   14:                                               ; preds = %11
> >     %15 = getelementptr inbounds i8, ptr %1, i64 63
> >     %16 = load i8, ptr %15, align 1
> >     %17 = tail call i1 @llvm.is.constant.i8(i8 %16)
> >     %18 = icmp eq i8 %16, 0
> >     %19 = select i1 %17, i1 %18, i1 false
> >     br i1 %19, label %20, label %23
> > 
> >   20:                                               ; preds = %14
> >     %21 = call i64 @strlen(ptr noundef nonnull dereferenceable(1) %1) #23
> >     ...
> > 
> >   23:                                               ; preds = %14, %11, %20
> >     %24 = call i64 @strnlen(ptr noundef nonnull dereferenceable(1) %1, i64 noundef 64) #24
> >     ...
> >   }
> > 
> > The above code calculates the address of the last char in the buffer
> > (value %15) and then loads from it (value %16). Because the buffer is
> > never initialized, the LLVM GVN pass marks value %16 as undefined:
> > 
> >   %13 = getelementptr inbounds i8, ptr %1, i64 63
> >   br i1 undef, label %14, label %17
> > 
> > This gives later passes (SCCP, in particular) more DCE opportunities by
> > propagating the undef value further, and eventually removes everything
> > after the load on the uninitialized stack location:
> > 
> >   define hidden i32 @ip_vs_protocol_init() local_unnamed_addr #0 section ".init.text" align 16 !kcfi_type !11 {
> >     %1 = alloca [64 x i8], align 16
> >     ...
> > 
> >   12:                                               ; preds = %11
> >     %13 = getelementptr inbounds i8, ptr %1, i64 63
> >     unreachable
> >   }
> > 
> > In this way, the generated native code will just fall through to the
> > next function, as LLVM does not generate any code for the unreachable IR
> > instruction and leaves the function without a terminator.
> > 
> > Zero the on-stack buffer to avoid this possible UB.
> > 
> > Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> > Reported-by: kernel test robot <lkp@intel.com>
> > Closes: https://lore.kernel.org/oe-kbuild-all/202402100205.PWXIz1ZK-lkp@intel.com/
> > Co-developed-by: Ruowen Qin <ruqin@redhat.com>
> > Signed-off-by: Ruowen Qin <ruqin@redhat.com>
> > Signed-off-by: Jinghao Jia <jinghao7@illinois.edu>
> 
> @Pablo, @Simon, @Julian: recent ipvs patches landed either on the
> net(-next) trees or the netfiler trees according to a random (?) pattern.
> 
> What is your preference here? Should such patches go via netfilter or
> net? Or something else. FTR, I *think* netfilter should be the
> preferable target, but I'm open to other options.

	IPVS patches should go always via Netfilter trees.
It is my fault to tell people to use the 'net' tag, I'll
recommend the proper nf tree the next time. Sorry for the
confusion.

Regards

--
Julian Anastasov <ja@ssi.bg>

