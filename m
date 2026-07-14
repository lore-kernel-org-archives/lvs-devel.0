Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4FBC03655EA;
	Tue, 14 Jul 2026 11:17:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784027829; cv=none; b=d0J4IwHezLQG+WwXx6cQcoPjUASvq84Ns352ag7R3NdLFN0yl3frYtGrywLZkvnZd4P8gKkXqt6255QEXOBb5CJH4OBiqK2IONyh7IJ+L3TWn09fQA+HLJPDu+Uucrix7/SvUwxYm5chCsn4Jee7lUHKvbuPialNjjHHXjjENwA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784027829; c=relaxed/simple;
	bh=3sznWqZahOX3dGYSqEcnCcyFoW7K0dYNJqYsNgXlrQo=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=AW8QCMnlRcP2FXyYMKCfLvQq6cwVGJ8t8qfHacNdiuKLnWNiGSgZQ944nwLSSWC4fuNfJ/lk9QchtEFQbTghYp/uWJXMyBSqfcgvkbZ4X1VC7xYM+B3TeEyLyiKbY5GUuvj3NA2/dII4M+H0w4DJIoEhvkUXHe0XCYOKDmAGj5A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=h3/bqy6Q; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="h3/bqy6Q"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id AB82821B1A;
	Tue, 14 Jul 2026 14:16:59 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=2AYue9V/xyYnT/GTe0/pexAq27BPH889PPznAkkDRSE=; b=h3/bqy6Q+bNL
	5yzOKQCLasFLLpACDDqR4QAxUh8X2ODepl2qoDbZ+5+66XDBsg+smwvwVdE7Rxrk
	4WCHKT1kzq/nqtfv+meobmEbZLw9CSIE9OB2Xq4se8jiFghyEVZJ9cpSN/i8xei5
	5JvkSCfxvPTtAWC+UY8S8VdO6kJyZYK1i4ibyWVGskNZtUIXEtruJsCZCxptWXaN
	ADigaVN5Cveniav4QM3K9GXbfsD3F8Cf/+HkTWe4wUET8bASQ49+ZVIn37gj0Zu+
	UMaiom3K8UH3+b/UpeSh5zDTlixYcTzSi1un7fKzR+NuEbG1v5sFzwIXESMQQrNm
	jn5VlwjxzAjjK1PtKP9TBWe0EzZb6qB1zDsugyD+9uSRHcIjO3KzD3sADphCxwBq
	2XPAYZYyRQJmrBsbhgnOxf5pFmjsUn8gXgPttg7ndAuGANlIduFa10o5UWcMcCEs
	2G6/05MvN0QRUcUZ6ErpiWGY2SZMmcC6KJoN4m6M5qCEz6IEnjaTH3jtB8pA1rcV
	4uk76FTb61SoSEqVN7H/kj0gctuj+00PjSf/nnThnQOkOiTKkEy0j1/XjFHxIvST
	OQ4QVhxd7Njv5z8KGaex4L04hePOYdEz7Qi7hi6ZPdygneU68KvHj09hPEyyJT+P
	tJrcPj25NyLYUj8qhWRGZk/l9PkiQCk=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 14 Jul 2026 14:16:59 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 310F0608A4;
	Tue, 14 Jul 2026 14:17:00 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66EBGrHQ029875;
	Tue, 14 Jul 2026 14:16:54 +0300
Date: Tue, 14 Jul 2026 14:16:53 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
cc: David Ahern <dsahern@kernel.org>, Ido Schimmel <idosch@nvidia.com>,
        Simon Horman <horms@verge.net.au>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, stable@vger.kernel.org,
        Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>,
        Ao Wang <wangao@seu.edu.cn>, Xuewei Feng <fengxw06@126.com>,
        Qi Li <qli01@tsinghua.edu.cn>, Ke Xu <xuke@tsinghua.edu.cn>
Subject: Re: [PATCH nf v3 2/2] ipvs: use bitops for destination overload
 state
In-Reply-To: <edc095e05c89cc6481613126de5f2a91ed601fa9.1783931964.git.zhaoyz24@mails.tsinghua.edu.cn>
Message-ID: <a82b528b-2710-3978-fc18-ef902fd903e1@ssi.bg>
References: <cover.1783931964.git.zhaoyz24@mails.tsinghua.edu.cn> <edc095e05c89cc6481613126de5f2a91ed601fa9.1783931964.git.zhaoyz24@mails.tsinghua.edu.cn>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hi Yizhou,

On Mon, 13 Jul 2026, Yizhou Zhao wrote:

> IPVS destination schedulers read the overload state from packet processing
> paths, while connection accounting and destination updates can change it
> concurrently. IP_VS_DEST_F_OVERLOAD currently shares dest->flags with
> IP_VS_DEST_F_AVAILABLE, so plain read-modify-write operations on the two
> independent states can race and lose either update.
> 
> KCSAN reports the race with the SH scheduler and an upper connection
> threshold configured:
> 
>   BUG: KCSAN: data-race in __ip_vs_update_dest / ip_vs_sh_schedule
> 
> IP_VS_DEST_F_AVAILABLE is changed under service_mutex. Keep it in the
> existing flags word, but move the overload state to a separate unsigned
> long and access it with bitops. Use test_bit() in scheduler paths and
> set_bit()/clear_bit() in ip_vs_dest_update_overload(). This serializes the
> overload bit accesses and prevents updates to the available and overload
> states from clobbering each other.
> 
> The destination flags are not exposed by the IPVS sockopt or netlink
> interfaces, so move their definitions out of the UAPI header. Place the
> new overload word next to weight, which keeps the existing flags,
> conn_flags and weight offsets unchanged. On x86-64 this grows struct
> ip_vs_dest from 472 to 480 bytes.
> 
> test_bit() does not add reader-side ordering. Schedulers can still observe
> stale destination state, as they could before this change; this does not
> provide a fresh cross-field snapshot.
> 
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Cc: stable@vger.kernel.org
> Reported-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
> Reported-by: Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>
> Reported-by: Ao Wang <wangao@seu.edu.cn>
> Reported-by: Xuewei Feng <fengxw06@126.com>
> Reported-by: Qi Li <qli01@tsinghua.edu.cn>
> Reported-by: Ke Xu <xuke@tsinghua.edu.cn>
> Assisted-by: Claude-Code:GLM-5.2
> Suggested-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
> ---
>  include/net/ip_vs.h              | 8 ++++++++
>  include/uapi/linux/ip_vs.h       | 6 ------
>  net/netfilter/ipvs/ip_vs_conn.c  | 7 ++++---
>  net/netfilter/ipvs/ip_vs_dh.c    | 4 ++--
>  net/netfilter/ipvs/ip_vs_fo.c    | 2 +-
>  net/netfilter/ipvs/ip_vs_lblc.c  | 4 ++--
>  net/netfilter/ipvs/ip_vs_lblcr.c | 8 ++++----
>  net/netfilter/ipvs/ip_vs_lc.c    | 2 +-
>  net/netfilter/ipvs/ip_vs_mh.c    | 2 +-
>  net/netfilter/ipvs/ip_vs_nq.c    | 2 +-
>  net/netfilter/ipvs/ip_vs_ovf.c   | 2 +-
>  net/netfilter/ipvs/ip_vs_rr.c    | 2 +-
>  net/netfilter/ipvs/ip_vs_sed.c   | 4 ++--
>  net/netfilter/ipvs/ip_vs_sh.c    | 2 +-
>  net/netfilter/ipvs/ip_vs_twos.c  | 4 ++--
>  net/netfilter/ipvs/ip_vs_wlc.c   | 4 ++--
>  net/netfilter/ipvs/ip_vs_wrr.c   | 2 +-
>  17 files changed, 34 insertions(+), 31 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 3fc864a320fb..5e8e55f82b04 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -36,6 +36,13 @@
>  #define IP_VS_HDR_INVERSE	1
>  #define IP_VS_HDR_ICMP		2
>  
> +/* Destination Server Flags */
> +#define IP_VS_DEST_F_AVAILABLE	0x0001		/* server is available */
> +
> +enum {
> +	IP_VS_DEST_FL_OVERLOAD,
> +};
> +
>  /* conn_tab limits (as per Kconfig) */
>  #define IP_VS_CONN_TAB_MIN_BITS	8
>  #if BITS_PER_LONG > 32
> @@ -976,6 +983,7 @@ struct ip_vs_dest {
>  	volatile unsigned int	flags;		/* dest status flags */

	Sashiko has some comments that we should fix somehow:

https://sashiko.dev/#/patchset/cover.1783931964.git.zhaoyz24%40mails.tsinghua.edu.cn

	One option is IP_VS_DEST_F_AVAILABLE to become
IP_VS_DEST_CF_AVAILABLE (CF=Config Flag)

>  	atomic_t		conn_flags;	/* flags to copy to conn */
>  	atomic_t		weight;		/* server weight */
> +	unsigned long		flags2;		/* dest status flags */

	unsigned long		cfg_flags;

	We then put IP_VS_DEST_CF_AVAILABLE in this new cache line
that most of the schedulers will not read until dest is selected.
DH even should not check the IP_VS_DEST_F_AVAILABLE flag,
only lblc/lblcr should use this flag.

	We can preserve IP_VS_DEST_F_OVERLOAD in 'flags',
even we may not need to use bitops if we start to use
spin_lock_bh(&dest->dst_lock), as this lock is already
present in the dest structure. See below...

>  	atomic_t		last_weight;	/* server latest weight */
>  	__u16			tun_type;	/* tunnel type */
>  	__be16			tun_port;	/* tunnel port */

> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index fa3fbd597f3f..2591f4e143f8 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -1006,7 +1006,7 @@ __always_inline void ip_vs_dest_update_overload(struct ip_vs_dest *dest)

	We can add new arg 'bool locked'. Also, we will
return false if caller should retry under lock.
It will happen when we change IP_VS_DEST_F_OVERLOAD and
require its changes to be synchronized with the
thresholds and the number of connections.

>  		goto unset;
>  	conns = ip_vs_dest_totalconns(dest);
>  	if (conns >= u) {
> -		dest->flags |= IP_VS_DEST_F_OVERLOAD;
> +		set_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2);


	if (conns >= u) {
		if (!locked)
			return false;
		dest->flags |= IP_VS_DEST_F_OVERLOAD;
		return true;
	}

>  		return;
>  	}
>  	/* Low threshold defaults to 75% of upper threshold */
> @@ -1015,7 +1015,8 @@ __always_inline void ip_vs_dest_update_overload(struct ip_vs_dest *dest)
>  		return;
>  
>  unset:
> -	dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
> +	if (test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2))
> +		clear_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2);

	if (dest->flags & IP_VS_DEST_F_OVERLOAD) {
		if (!locked)
			return false;
		dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
	}
	return true;

>  }
>  
>  /*
> @@ -1174,7 +1175,7 @@ static inline void ip_vs_unbind_dest(struct ip_vs_conn *cp)
>  		atomic_dec(&dest->persistconns);
>  	}
>  
> -	if (dest->flags & IP_VS_DEST_F_OVERLOAD)
> +	if (test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2))
>  		ip_vs_dest_update_overload(dest);

	if (dest->flags & IP_VS_DEST_F_OVERLOAD) {
		if (!ip_vs_dest_update_overload(dest, false)) {
			spin_lock_bh(&dest->dst_lock);
			ip_vs_dest_update_overload(dest, true);
			spin_unlock_bh(&dest->dst_lock);
		}
	}

	In __ip_vs_update_dest() we will always use lock:

		spin_lock_bh(&dest->dst_lock);
		WRITE_ONCE(dest->u_threshold, udest->u_threshold);
		WRITE_ONCE(dest->l_threshold, udest->l_threshold);
		ip_vs_dest_update_overload(dest, true);
		spin_unlock_bh(&dest->dst_lock);

	The goal is to avoid the lock for the common case
when flag does not change. What do you think?

Regards

--
Julian Anastasov <ja@ssi.bg>

