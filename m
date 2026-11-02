Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793627644;
	b=EBT2P1mArrVxQYsEEIAurH1skd7ASs1q3+5zcd8HCubSMBK3XD5aw205/GXtwBkXQg2G
	 q6U9OfqjGOdiBhRynAWzkKq3/0icIxtJZ4ly2nIkd2Hwz/bktpWVO7kkDlnbClpEngDEa
	 aQBmBQOQssMngmEVIFttLjCILumAILzPZqjO8zHrJFt+Vxkxu+DWD2SUo+EQcb6le2uBc
	 nYL255W2MIVxBP+e2U8FRtnuz3e7YxxsUWdbYm+WSyPAtgZMROj9jylL87WN6FYMuXlN1
	 O1W/CjAyRfRUYd7TzWMXEDHm3FSkzmVeBu5xKtNu0MtcPlOL7x0msfky4DYn5y3anWw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793627644;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=qiFpuA7RWkkGkHy1fqN15ah46fr+RUcj2Ci5g9oEtT4=;
	b=VXO9mD1nA5OhvhgJYyRjaIh/OwP65By7+qXfOdhG3UX6hEdh+/QFTraqOxzTpbetBFJb
	 pz3I1UYYohmXs09i6jIwkr648OWkfmnmCfzDmH4Z/543vsNedaqZWGQ3M8ZcAqN3hmp3Q
	 esIhZLvR6Z/kaQ6iAOthbl+q8S5WGuR/hh/mHNr/3zPuvxRZ/irK2PfCpRnba3/nLy/LH
	 nyNUQuL6OO2rsQvFaemueedWTRy4GXUYsHnC2Tmt7Ofpz3JatLRKBuy3nh25+JBfIrsm0
	 sZZtJ1+VCjVBY7Ub5+Kv4+MIsLcpyw3ABLscyDLRpMIdpsV+3vwAxKD014OfidKMEzQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=Vj1f1t3D;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7F1E6606A32E;
	Mon,  2 Nov 2026 13:54:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 7F1E6606A32E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=Vj1f1t3D
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 3896821F81;
	Mon, 02 Nov 2026 15:53:59 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=qiFpuA7RWkkGkHy1fqN15ah46fr+RUcj2Ci5g9oEtT4=; b=Vj1f1t3DOmog
	kMf0cTDwlRTjzBQa6lnIf4TLK8HRfvWCtcrSCj/niFblfd6MlNsWcuQhtachSPNw
	vUIfmo9WCtsTL6hwwInbs+WCawajvZ5qkSgmX2tjeBUhxbe9x+XSolvlurSRpAFj
	lF8xeHwRdDdzCVkMDvbsW09m8iReiABlKvHKBx7YP6fYYSJ6N4vybhjsCz7ypVEp
	qgBuEkLFgBTZ0q2gt68SNOUwjxGeT/kVHFUUR90Xe3MJLmpWcKK8fxweTS+GR8bV
	WPGHAQ7f5nlBqsz2AVfApyqKbB6w/Fmo4PjNyvLtkJ8qqF76XCM6OhQs3OxXWcKn
	ejfeR7anOjUNCee3byxewBGJrQCLaPya8X5dmGyiuofgG85DrFdFhtU0NkkWSVOo
	aCLmZCkep85+qVPwc2VgKO2lhRCICUrkCDEUb2lRZF1wqBmO2gWC4y0CY6GRIoqy
	CWh0m5Nhds25/PbSMsPVXn3YqtmVXjY8KzOVCha0yaSbGsE4UyoiPBG8s9cw5196
	YZrQUtqQK/weoYKFYj7I+8FjiulWe+5dlhQSeqehL7jPhRkQXMqLp642oexsUXf6
	A9ktorW+hskW3lARCEY2HtPDccTTO8dG8/4sxdpSYd4q0mFt7rV4frXzYQ2YXbs+
	4EFYZTSL3DQ4QoSKnMvcyBw48kEiHxk=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 02 Nov 2026 15:53:59 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 7105360CB3;
	Mon,  2 Nov 2026 15:53:58 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6A2DrqUE058237;
	Mon, 2 Nov 2026 15:53:53 +0200
Date: Mon, 2 Nov 2026 15:53:52 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Yingjie Wang <x-professor@outlook.com>
cc: "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "horms@verge.net.au" <horms@verge.net.au>,
        "pablo@netfilter.org" <pablo@netfilter.org>,
        "fw@strlen.de" <fw@strlen.de>, "phil@nwl.cc" <phil@nwl.cc>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "edumazet@kernel.org" <edumazet@kernel.org>,
        "kuba@kernel.org" <kuba@kernel.org>,
        "pabeni@redhat.com" <pabeni@redhat.com>,
        "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
        "coreteam@netfilter.org" <coreteam@netfilter.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH nf v2] ipvs: avoid wrapping persistent service timeouts
In-Reply-To: <969309eb180c2e577dd6bb54a7d28afcbb2efeb3.1793513714.git.x-professor@outlook.com>
Message-ID: <dd093f06-b80d-72b5-0f10-886aa1f5e25b@ssi.bg>
References: <969309eb180c2e577dd6bb54a7d28afcbb2efeb3.1793513714.git.x-professor@outlook.com>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Sun, 1 Nov 2026, Yingjie Wang wrote:

> ip_vs_add_service() and ip_vs_edit_service() convert an unchecked u32
> timeout from seconds to jiffies with u->timeout * HZ. Both operands are
> unsigned int, so values above UINT_MAX / HZ wrap.
> 
> With HZ=1000, 4294968 seconds becomes 704 jiffies and is reported back
> as 0 seconds. Persistence templates copy svc->timeout, so their timer is
> armed for 0.7 seconds and a client can be moved to another real server
> long before the configured timeout.
> 
> ipvsadm limits service persistence and protocol timeouts to 31 days.
> Enforce the same limit in the kernel and reject larger values with
> -EINVAL. Convert accepted values through a common helper that clamps
> them to MAX_JIFFY_OFFSET / HZ on 32-bit systems. Use the helper for
> timeouts received from the synchronization protocol as well, since those
> values do not pass through the service configuration checks.
> 
> Change the service timeout and protocol timeout tables to unsigned long
> because they store jiffies. With HZ=1000, 31 days is 2678400000 jiffies,
> which does not fit in the signed int used by the protocol tables. This
> also allows the global protocol timeout interface to represent the full
> 31-day range on 64-bit systems.
> 
> The overflow was reproduced in an x86-64 QEMU guest with HZ=1000. A
> persistent one-packet UDP service was set to 4294968 seconds, and two
> datagrams sent 1.5 seconds apart were directed to different real servers
> after the template expired.
> 
> On the x86-64 test kernel with HZ=1000, 2678401-second service timeouts
> were accepted and 4294968 seconds read back as 0, while a 2678400-second
> protocol timeout was rejected. With this change, 2678401 and 4294968
> seconds are rejected, a failed edit leaves the previous service timeout
> unchanged, and 2678400-second service and protocol timeouts read back
> unchanged.
> 
> On an i386 test kernel with HZ=1000, the accepted 2678400-second values
> were clamped to 1073741 seconds by the 32-bit jiffy limit and read back
> as such through both interfaces.
> 
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Suggested-by: Julian Anastasov <ja@ssi.bg>
> Link: https://lore.kernel.org/r/4f420fda8690ac470be44b3da284b65501c77bb5.1793430892.git.x-professor@outlook.com
> Link: https://lore.kernel.org/r/5fa37fba-530c-2c5b-038e-9cb95e34023d@ssi.bg
> Signed-off-by: Yingjie Wang <x-professor@outlook.com>
> ---
> 
> Notes:
>     Changes since v1:
>     - Follow Julian's suggestion to use the 31-day ipvsadm limit, reject
>       larger configured values, and clamp accepted values only for the
>       32-bit jiffy limit.
>     - Move the conversion helper to include/net/ip_vs.h and use it for
>       service, protocol and synchronized connection timeouts.
>     - Store service and protocol timeout ticks in unsigned long values so
>       the full range is representable.
>     - Add runtime coverage for the 31-day boundary, failed service updates
>       and global TCP/UDP timeout readback on x86-64 and i386. The i386 test
>       also verifies the intended MAX_JIFFY_OFFSET clamp.
>     
>     v1: https://lore.kernel.org/r/4f420fda8690ac470be44b3da284b65501c77bb5.1793430892.git.x-professor@outlook.com
> 
>  include/net/ip_vs.h                   | 20 ++++++++++++---
>  net/netfilter/ipvs/ip_vs_app.c        |  3 +--
>  net/netfilter/ipvs/ip_vs_ctl.c        | 35 ++++++++++++++++-----------
>  net/netfilter/ipvs/ip_vs_proto.c      |  4 +--
>  net/netfilter/ipvs/ip_vs_proto_sctp.c |  6 ++---
>  net/netfilter/ipvs/ip_vs_proto_tcp.c  |  6 ++---
>  net/netfilter/ipvs/ip_vs_proto_udp.c  |  6 ++---
>  net/netfilter/ipvs/ip_vs_sync.c       |  6 ++---
>  8 files changed, 52 insertions(+), 34 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 9a83bff32569..4eaa06b5f991 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -18,6 +18,7 @@
>  #include <linux/workqueue.h>
>  
>  #include <linux/compiler.h>
> +#include <linux/jiffies.h>

	The patch looks good to me but you should not include
jiffies.h

> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 157f5c8361ab..175b842cdfec 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -847,7 +847,7 @@ static void ip_vs_proc_conn(struct netns_ipvs *ipvs, struct ip_vs_conn_param *pa
>  			    unsigned int flags, unsigned int state,
>  			    unsigned int protocol, unsigned int type,
>  			    const union nf_inet_addr *daddr, __be16 dport,
> -			    unsigned long timeout, __u32 fwmark,
> +			    unsigned int timeout, __u32 fwmark,
>  			    struct ip_vs_sync_conn_options *opt)
>  {
>  	struct ip_vs_dest *dest;

	The above hunk does not apply cleanly due to a pending
work "ipvs: update flags and seqs in backup server under lock".
I'll let you know when you can post v2 after removing the jiffies.h
above and re-syncing after the above patch.

> @@ -939,9 +939,7 @@ static void ip_vs_proc_conn(struct netns_ipvs *ipvs, struct ip_vs_conn_param *pa
>  	 *  - No problem.
>  	 */
>  	if (timeout) {
> -		if (timeout > MAX_SCHEDULE_TIMEOUT / HZ)
> -			timeout = MAX_SCHEDULE_TIMEOUT / HZ;
> -		cp->timeout = timeout*HZ;
> +		cp->timeout = ip_vs_timeout_ticks(timeout);
>  	} else {
>  		struct ip_vs_proto_data *pd;
>  
> 
> base-commit: 734bef548a96e8774d6eef5dfa2026c6edc4e80b
> -- 
> 2.43.0

Regards

--
Julian Anastasov <ja@ssi.bg>

