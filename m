From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH RFC 00/24] IPVS: Add first IPv6 support to IPVS
Date: Wed, 27 Aug 2008 17:09:52 +0200
Message-ID: <f4845fc0808270809nfd79798ob528778228645915@mail.gmail.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
	 <20080821011715.GG19235@verge.net.au>
	 <f4845fc0808210259n2b4bbd41tb0a93c49592a2029@mail.gmail.com>
	 <20080821212948.GB4407@verge.net.au>
	 <20080827071714.GA30536@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219849796; bh=4c5dsZ6p1Nv0kX/CmSVB1/uu1Jk=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=n3mSrosCAH6UEB+/FKx4k04p/4blcXW3
	VnnoIUyDMwSLRZ28w7Bgcnlqbf0U6eQKEacc6G4rMRZs5igqtVffuQ==
In-Reply-To: <20080827071714.GA30536@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com, Sven Wegener <sven.wegener@stealer.net>

On Wed, Aug 27, 2008 at 9:17 AM, Simon Horman wrote:
> Here is a second round of thoughts after having gone through the whole series.

Thanks for wading through this!

> [PATCH RFC 06/24] IPVS: Add debug macros for v4 and v6 address output
>
> * The #defines in ip_vs_dbg_addr seem a bit aquard.
>  Could it be rearanged liks this?
>
> static inline const char *ip_vs_dbg_addr(int af, char *buf, size_t buf_len,
>                                        const union nf_inet_addr *addr,
>                                        int *idx)
> {
>       int len;
> #ifdef CONFIG_IP_VS_IPV6
>       if (af == AF_INET6)
>               len = snprintf(&buf[*idx], buf_len - *idx, "[" NIP6_FMT "]",
>                              NIP6(addr->in6)) + 1;
>       else
> #endif
>               len = snprintf(&buf[*idx], buf_len - *idx, NIPQUAD_FMT,
>                              NIPQUAD(addr->ip)) + 1;
>
>       *idx += len;
>       return &buf[*idx - len];
> }

Yes, that looks nicer and more like the other cases!

> * The comment "/* Only use from within IP_VS_DBG_BUF() macro */"
>  should also mention usage inside IP_VS_ERR_BUF()

Right, thanks!

> * If IP_VS_DBG_ADDR() is used more than once inside a single
>  IP_VS_DBG_BUF() or IP_VS_ERR_BUF() call, won't ip_vs_dbg_buf
>  be set to the value one of the  calls to IP_VS_DBG_ADDR,
>  thus overwriting other calls and producing incorrect debugging
>  output?

No, the buffer can receive several strings (but it's limited in size,
so you have to be careful). An index to the current position in the
buffer is maintained in the 'idx' variable between multiple
IP_VS_DBG_ADDR calls used in the same outer macro.

In general, I'm a bit unsure if this kind of macro magic is acceptable
style, but it was the best way I could come up with to merge
alternating v4 and v6 output without too much code duplication.

> [PATCH RFC 15/24] IPVS: Add support for IPv6 entry output in procfs files
>
> * The netlink-aware ipvsadm code also seems to allow for dotted-quad
>  representation of ipv4 addresses in proc. Is that representation used
>  or planned to be used?

Good catch! No, I wasn't even aware of that feature in the new ipvsadm
(but now I see it). I think it should be removed because it is
effectively dead code (the existing v4 proc format shouldn't be
changed). Vince, do you agree?

> [PATCH RFC 17/24] IPVS: Make proc/net files output IPv6 entries
>
> * It might be cleaner to do:
>
> #ifdef CONFIG_IP_VS_IPV6
>        if (cp->af == AF_INET6)
>                seq_printf ...
>        else
> #endif
>                seq_printf ...

Yes, it's nicer this way around, I'll change that!

> General
>
> * You need to reorder and or merge patches such that after each
>  patch is applied the code will build and run. It is ok for
>  a patch to add code which isn't used until a later patch is applied.

Yes, I have found no nice way to achieve this yet :( At least not when
reworking the complete end result (one big patch) into smaller
patches, because there is so much interdependency and several logical
changes within the same hunks (or even lines). I might have to
manually do a step-by-step adding of the logical code features to get
this... I will try to work on that next.

> * Where possible please make lines <= 80 columns wide

Yes, I will check for that more strictly now (unless it really looks
nicer otherwise), thanks!

Julius

-- 
Julius Volz
Corporate Operations - SysOps

Google Switzerland GmbH

Identification No.:
CH-020.4.028.116-1
