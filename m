Received: from ganesha.gnumonks.org (ganesha.gnumonks.org [213.95.27.120])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 04DF519924E;
	Thu, 28 Nov 2024 12:12:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.27.120
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1732795967; cv=none; b=ZEZ8kRu2GnkMihHMfx8e00AhMlaFdPrLWVD5xgMNjYyyHH7V8KPsqd8rce2JaysDiSQg2y+t2nQedK1fUOJnsv8ImJwhoI2DOzjyTnGNfK10TKX4I9gupSX1QKpaeMyC1qSZEaYsqj80GWWCFf95nHNpSfeFam6A99h1TbLcIrA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1732795967; c=relaxed/simple;
	bh=TuOb665RSI48F19c1IWSP3kx/J14aZG+T0RK8WWALls=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=XxNXCduRXJDTidOlW7FKu33j78If6WXBBWpGK4krDTdvMQjxOW2bCeoP0vrATmda8Bd1iOH85TgSaLpN5elIGMJ10GooTfhuavPqXbjTxd03pfBjxUttm/IdEOaKVaDAJ3xuyG4gOqLoSIUvzoqQltPOiTr06bZ6cCG+UE+KYK4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org; spf=pass smtp.mailfrom=gnumonks.org; arc=none smtp.client-ip=213.95.27.120
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=netfilter.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gnumonks.org
Received: from [78.30.39.247] (port=48626 helo=gnumonks.org)
	by ganesha.gnumonks.org with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.94.2)
	(envelope-from <pablo@gnumonks.org>)
	id 1tGdNl-00FndA-5W; Thu, 28 Nov 2024 13:12:31 +0100
Date: Thu, 28 Nov 2024 13:12:28 +0100
From: Pablo Neira Ayuso <pablo@netfilter.org>
To: Julian Anastasov <ja@ssi.bg>
Cc: Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@verge.net.au>,
	netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	linux-kernel@vger.kernel.org, llvm@lists.linux.dev,
	"David S. Miller" <davem@davemloft.net>,
	kernel test robot <lkp@intel.com>, Ruowen Qin <ruqin@redhat.com>,
	Jinghao Jia <jinghao7@illinois.edu>,
	Jozsef Kadlecsik <kadlec@netfilter.org>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Kees Cook <kees@kernel.org>,
	Nathan Chancellor <nathan@kernel.org>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Bill Wendling <morbo@google.com>,
	Justin Stitt <justinstitt@google.com>
Subject: Re: [PATCH v3 net] ipvs: fix UB due to uninitialized stack access in
 ip_vs_protocol_init()
Message-ID: <Z0heLGWuOEkC2n35@calendula>
References: <20241123094256.28887-1-jinghao7@illinois.edu>
 <70cd1035-07d8-4356-a53e-020d93c2515e@redhat.com>
 <87fca918-403d-2fd5-576a-dfa730483fc2@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <87fca918-403d-2fd5-576a-dfa730483fc2@ssi.bg>
X-Spam-Score: -1.7 (-)

On Thu, Nov 28, 2024 at 01:18:39PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 28 Nov 2024, Paolo Abeni wrote:
> 
> > On 11/23/24 10:42, Jinghao Jia wrote:
> > > Under certain kernel configurations when building with Clang/LLVM, the
> > > compiler does not generate a return or jump as the terminator
> > > instruction for ip_vs_protocol_init(), triggering the following objtool
> > > warning during build time:
> > > 
> > >   vmlinux.o: warning: objtool: ip_vs_protocol_init() falls through to next function __initstub__kmod_ip_vs_rr__935_123_ip_vs_rr_init6()
> > > 
> > > At runtime, this either causes an oops when trying to load the ipvs
> > > module or a boot-time panic if ipvs is built-in. This same issue has
> > > been reported by the Intel kernel test robot previously.
> > > 
> > > Digging deeper into both LLVM and the kernel code reveals this to be a
> > > undefined behavior problem. ip_vs_protocol_init() uses a on-stack buffer
> > > of 64 chars to store the registered protocol names and leaves it
> > > uninitialized after definition. The function calls strnlen() when
> > > concatenating protocol names into the buffer. With CONFIG_FORTIFY_SOURCE
> > > strnlen() performs an extra step to check whether the last byte of the
> > > input char buffer is a null character (commit 3009f891bb9f ("fortify:
> > > Allow strlen() and strnlen() to pass compile-time known lengths")).
> > > This, together with possibly other configurations, cause the following
> > > IR to be generated:
> > > 
> > >   define hidden i32 @ip_vs_protocol_init() local_unnamed_addr #5 section ".init.text" align 16 !kcfi_type !29 {
> > >     %1 = alloca [64 x i8], align 16
> > >     ...
> > > 
> > >   14:                                               ; preds = %11
> > >     %15 = getelementptr inbounds i8, ptr %1, i64 63
> > >     %16 = load i8, ptr %15, align 1
> > >     %17 = tail call i1 @llvm.is.constant.i8(i8 %16)
> > >     %18 = icmp eq i8 %16, 0
> > >     %19 = select i1 %17, i1 %18, i1 false
> > >     br i1 %19, label %20, label %23
> > > 
> > >   20:                                               ; preds = %14
> > >     %21 = call i64 @strlen(ptr noundef nonnull dereferenceable(1) %1) #23
> > >     ...
> > > 
> > >   23:                                               ; preds = %14, %11, %20
> > >     %24 = call i64 @strnlen(ptr noundef nonnull dereferenceable(1) %1, i64 noundef 64) #24
> > >     ...
> > >   }
> > > 
> > > The above code calculates the address of the last char in the buffer
> > > (value %15) and then loads from it (value %16). Because the buffer is
> > > never initialized, the LLVM GVN pass marks value %16 as undefined:
> > > 
> > >   %13 = getelementptr inbounds i8, ptr %1, i64 63
> > >   br i1 undef, label %14, label %17
> > > 
> > > This gives later passes (SCCP, in particular) more DCE opportunities by
> > > propagating the undef value further, and eventually removes everything
> > > after the load on the uninitialized stack location:
> > > 
> > >   define hidden i32 @ip_vs_protocol_init() local_unnamed_addr #0 section ".init.text" align 16 !kcfi_type !11 {
> > >     %1 = alloca [64 x i8], align 16
> > >     ...
> > > 
> > >   12:                                               ; preds = %11
> > >     %13 = getelementptr inbounds i8, ptr %1, i64 63
> > >     unreachable
> > >   }
> > > 
> > > In this way, the generated native code will just fall through to the
> > > next function, as LLVM does not generate any code for the unreachable IR
> > > instruction and leaves the function without a terminator.
> > > 
> > > Zero the on-stack buffer to avoid this possible UB.
> > > 
> > > Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> > > Reported-by: kernel test robot <lkp@intel.com>
> > > Closes: https://lore.kernel.org/oe-kbuild-all/202402100205.PWXIz1ZK-lkp@intel.com/
> > > Co-developed-by: Ruowen Qin <ruqin@redhat.com>
> > > Signed-off-by: Ruowen Qin <ruqin@redhat.com>
> > > Signed-off-by: Jinghao Jia <jinghao7@illinois.edu>
> > 
> > @Pablo, @Simon, @Julian: recent ipvs patches landed either on the
> > net(-next) trees or the netfiler trees according to a random (?) pattern.
> > 
> > What is your preference here? Should such patches go via netfilter or
> > net? Or something else. FTR, I *think* netfilter should be the
> > preferable target, but I'm open to other options.
> 
> 	IPVS patches should go always via Netfilter trees.
> It is my fault to tell people to use the 'net' tag, I'll
> recommend the proper nf tree the next time. Sorry for the
> confusion.

No issue, I have applied this to nf.git, thanks for the clarification.
