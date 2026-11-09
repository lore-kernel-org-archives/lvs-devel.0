Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.167.46
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794193927;
	b=UWyCmCHEFW0Orsdf90oABKk2Ho/tPRMRGPDVR+my9wNldMZ96uXKvQLLGX4bV4KGJBst
	 wqfgXKoJfH7zXNX//aFnAwSWcgpgJ+GrEqAj83q0/MHkya9poaE4vYY7Bix/rGECRuD3x
	 UgFlTWsdcT3GLmQgMOt0NpuFdUM1FBHkuvROTbvvgsfb6XU0EUfyeQ5yZob7KRc8g2fp8
	 Z4eERo27t8pdcoMX6cDQxsHSfRNSpXskbz6j+BKgrb4ChMCrIenu+hu2bAZTv2EmEcJi6
	 4WeGomSYdrnt8i/7CZznhNJAKqtDKITbc/yKDLuE6U3dJAXNBIlX3DHww22Zf0/Amxg==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794193927;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=SS4X10tnH1zMkf70V4OKi2rc8i/EWRIUyaIhQlrMvdc=;
	b=oAn9+s2TlpijOKcsUDx20AQvgQWahK7sbDhCPUcrjj5zCULlVhsmtAzc879KQgQmuQ6C
	 U2S4YKuVSDuaIJWiFt+keNwyGsy/LLVRCL+ah4rcGIhwxHt6c2XF8ex38MC+LiY9EI73+
	 4OYD9QubWq3iRFZKxt8KCzop6vdQuEbRgV3CBSKj82sMFq5Kr/AFNgmw0iT+JWvh9y0Ho
	 vzHFa1lZVIqGunr9pjZD9ASAbYc03EnPyT4k67FmeqWhhusmRlMZYKq6/12DjEqbm5APG
	 /uR0jwORUF3dqzMDyAxwuDbEgqxgdiwJZR4yTdN7acNUwEwCKYeVLDC8r12tqpndi4w==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=K3I4VwLW;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.167.46
Received: from mail-lf1-f46.google.com (mail-lf1-f46.google.com [209.85.167.46])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5CFD6606D802
	for <lvs-devel@vger.kernel.org>; Mon,  9 Nov 2026 03:12:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 5CFD6606D802
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=K3I4VwLW
Received: by mail-lf1-f46.google.com with SMTP id 2adb3069b0e04-5be4b61fd3dso351289e87.3
        for <lvs-devel@vger.kernel.org>; Sun, 08 Nov 2026 19:12:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794193926; cv=none;
        d=google.com; s=arc-20260327;
        b=nPmi5M11DLZEvHnwGFwILC5hQLaV8Oj47+b9/COp/sxjngjVeezYmWHpq0DBTA6yTD
         CF6yGRI6MyP/OYGbSHaOEqzVCy1DdLxE5FCR2s54mUlL1CNkD+o8Pv60fNUry2Dt71sH
         IXgBDr6XnQpfPzLFaH9BSoBuVczSub+mrNn1yeMJhxxSNn+4kva7V9Hfsg6pagVapCBc
         Gl2sZSSkCnVo2nEZTHq3/7LqCAFwi6y8NfTrrqi1CnJ3LM9WQwSmQh5PMYxBD2gyv+wO
         6jzpm+a9yYtjbuTGa/QcSKysfV6VNcTKAzv0ZvxseZw+lLO9ljeBTJBojN8XXGe/dhsI
         DxRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=SS4X10tnH1zMkf70V4OKi2rc8i/EWRIUyaIhQlrMvdc=;
        fh=477+7hlB/kGJ5vm9PTjC34ok/MxgTjw9vpyDQmpOGK4=;
        b=E+BkY1V3mBNqu7WDynu+ZQFDC1B+OwSM/rmrWLGyccYCXe+OagM/EUDoLM0+UaLTua
         bd6mJOk8L+OufYUrwQToW953usmVFRYYtm0jUHMoRfjQ0g0FsyEEXDOVdGBSdjw5LNkS
         XbHITAY5CD8cSwgEAq2Rf1oRpyS/InUTBj/Rro7VG7usYg7miGvtbOW56mNgFIn+M0UY
         lE3YoYbH2zQvy/6i3C4AnhHOCOGPyWZQcZdjSODZAg+ogxo09YCQcZCxkbWS+8bCFs9Q
         2IPgtCU/Xy1/usFtOt5cwGx8hLk+TVXrTtNlJbxY+a/gLAnKdK7ADl67sIWNwfvb44UE
         NngA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794193926; x=1794798726; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=SS4X10tnH1zMkf70V4OKi2rc8i/EWRIUyaIhQlrMvdc=;
        b=K3I4VwLWEjz/fpLEPrFW7CwWrv4fEPGezH8KCxj8e1ufefKHddQU0HQPNqhelpULLs
         qD5oo3ycK0fELO4DjDpfzOWDbVm8cfFRQ5A1jA2yO0+I0NsEaTuBIJg5i67pN5ub/jmI
         qsNxOptt7VmpG23mOKOjDSsGBrXn4VFgztxIDuY1Nt7nYdVfFgOO0iYj0Gm3KSMPn+Op
         hWysY9gDo+QuzUe3gBv0Syd/Ff9TzB8oM28pszgFfUIN0f93NBtOAKIYcO9WntOzU16r
         qA5qfw4Xx6k1Zm1SS/s6l9zMEGwSLIjQcgNgakX8x9MRJlbJH/83PfhVRT2bYdomWWIq
         a++g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794193926; x=1794798726;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=SS4X10tnH1zMkf70V4OKi2rc8i/EWRIUyaIhQlrMvdc=;
        b=2Ejudyz+S1M5dVYGboL+K7qbb9jIz/zbq9rk8MpPNwR49LBJc8nlyNqqqqbcL8oP7a
         MOhs590jBtlbKN+CIQgpC2xj/2x6iLZdOmcI9xB4WwucdAIVugqxsxrYXQq4fSibxJc/
         OR1Y35sAY4nRGNoZeoz65wj96LZnaQQCO3K9i0vC5LGHJsmDbJ8GNp7OeXz+wg5iHeGC
         5Uc2GC+4IeDFeStMdL0e+zx1YfFxNc21pqAihsR16bENChYVsCWxUg3LU0QJpF84j54K
         fpKQBfCkDmUZXQvLtBEfDOHA96/Z3a7UJCxMx0VRyrGFtYqPx3gyQRA9xiY1QdVM1BTN
         nvrQ==
X-Forwarded-Encrypted: i=1; AL+hErH5tExy2MpnZuypEQVfqURm3umCrY6l7osZuuhlBJvqj5RRZYlJ68H5RpZEWWkOqTX8hTbdNY/7NN4=@vger.kernel.org
X-Gm-Message-State: APuU4Z/mH3caqY4yco5rmcKlO99rdIvzdfRxyg2fkbRkBGqzW1oaC/4s
	Thh4ZYaXPfB4t61PIV8ZjcfRVOAusbU+s3o4huod0K4Vt8OMP5zFn2onZWvRVFWO7DoxKWISWNj
	dH0y+QBU3aZu4Z3l0yO5d8HRa9EnLEJA=
X-Gm-Gg: AYBFou1OGiTQuFAREwMawiASttyxE2RX7nXsPxUmBXHf90P0Y2zt+OlPKga1BpOFMXd
	P3PuaxBhpvwbEFuq1icnYYc340cNODVmhivgmkIuTdILcqeALHEzObhpSVveNhZAFxAzadFzyVT
	HKZRf9ckd2mydlYz5zYC7icZfIOOGF5slcqveiw7Uk9MBDvo4IQOFNXwAh/VysTH9Y5Kg3VStfE
	CfwTIrN7vo0g6udWT4EZsQFhR9p+YjphpS8Q3/wv6zqXwoJHXKEzjenbgMKYizvnQg/O/wk1LpD
	5EAOeAekYbxaNs2X0LUeWeNiAcB1kPRfY/rx3Fc0AcGn+4285sVg7wBwiASIVrf1VGEUTc5Poeg
	MH5+j1rd/q8/y1/HzrYYkEGNPIBb1cKi63jPwjM2AaVxOYLDRsNoBvMynJUpfWEedNwobc9jRfL
	eHNcYj6eE6ePO/op/q2D/fqCSz1pLNMdIBVSnhyS4ntJNztfreZJK3
X-Received: by 2002:a05:6512:3088:b0:5c0:471:f028 with SMTP id
 2adb3069b0e04-5c14bfedffcmr703341e87.22.1794193925282; Sun, 08 Nov 2026
 19:12:05 -0800 (PST)
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261109025425.328445-1-jiayuan.chen@linux.dev>
In-Reply-To: <20261109025425.328445-1-jiayuan.chen@linux.dev>
From: Jason Xing <kerneljasonxing@gmail.com>
Date: Mon, 9 Nov 2026 11:11:26 +0800
X-Gm-Features: AclHuK-8zzYe5mJdMRhvHJ2iaIG2lKRoeKrY7lhKeXbLBk5rPZ5G9f2uOL9YkTM
Message-ID: <CAL+tcoDvFNAZubOjw9+Z1eyaVeiBzt_Xg3KMNucY879bg-ZLow@mail.gmail.com>
Subject: Re: [PATCH net-next 00/14] net: annotate data-races around sysctl knobs
To: Jiayuan Chen <jiayuan.chen@linux.dev>
Cc: netdev@vger.kernel.org, David Ahern <dsahern@kernel.org>, 
	Ido Schimmel <idosch@nvidia.com>, "David S. Miller" <davem@davemloft.net>, 
	Eric Dumazet <edumazet@kernel.org>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
	Simon Horman <horms@kernel.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>, 
	Phil Sutter <phil@nwl.cc>, Nikolay Aleksandrov <razor@blackwall.org>, Paul Moore <paul@paul-moore.com>, 
	Matthieu Baerts <matttbe@kernel.org>, Mat Martineau <martineau@kernel.org>, 
	Geliang Tang <geliang@kernel.org>, Julian Anastasov <ja@ssi.bg>, Allison Henderson <achender@kernel.org>, 
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Xin Long <lucien.xin@gmail.com>, 
	"D. Wythe" <alibuda@linux.alibaba.com>, Dust Li <dust.li@linux.alibaba.com>, 
	Sidraya Jayagond <sidraya@linux.ibm.com>, Mahanta Jambigi <mjambigi@linux.ibm.com>, 
	Tony Lu <tonylu@linux.alibaba.com>, Wen Gu <guwen@linux.alibaba.com>, 
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, 
	coreteam@netfilter.org, bridge@lists.linux.dev, 
	linux-security-module@vger.kernel.org, mptcp@lists.linux.dev, 
	lvs-devel@vger.kernel.org, linux-rdma@vger.kernel.org, 
	rds-devel@oss.oracle.com, linux-sctp@vger.kernel.org, 
	linux-s390@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 9, 2026 at 10:55=E2=80=AFAM Jiayuan Chen <jiayuan.chen@linux.de=
v> wrote:
>
> While testing the recent sysctl range fixes I noticed that a lot of our
> sysctl knobs are read with plain loads while the handlers update them
> with WRITE_ONCE() and no lock, so KCSAN reports them as data races. I
> then used an LLM to go through every ctl_table under net/ and list the
> readers that were left behind. This series annotates them with
> READ_ONCE(), and adds WRITE_ONCE() to a few custom handlers and netlink
> paths that store to the same fields with plain writes. Most of it is a
> plain READ_ONCE() at each read; where a function reads the same knob
> twice to make one decision, it now reads it once into a local, so the
> comparison and the value it acts on cannot come from two different
> writes.
>
> There are no Fixes tags. Done one knob per patch this would be well over
> a hundred commits, so I grouped them by subsystem and feature instead to
> keep the review manageable. If maintainers prefer, I can split it up
> further with a Fixes tag on each one, as several smaller series.

Over the last year, I've been thinking about the annotation stuff
especially around sysctls, which, I suppose, shouldn't actually affect
the real workload but does affect the outcome of the syzbot.

Out of sheer curiosity, my question would be what is the point of
trying to change all of them? Or what kind of benefits can we get from
the big series?

Thanks,
Jason

>
> No functional change. KCSAN does hit these, e.g. toggling
> net.ipv6.icmp.echo_ignore_all while receiving ICMPv6 echo requests:
>
>   BUG: KCSAN: data-race in icmpv6_rcv / proc_dou8vec_minmax
>
>   write (marked) to 0xffffffff8ee2940d of 1 bytes by task 504 on cpu 0:
>    proc_dou8vec_minmax+0x1ab/0x1f0
>    proc_sys_call_handler+0x282/0x3a0
>    proc_sys_write+0x13/0x20
>    ...
>
>   read to 0xffffffff8ee2940d of 1 bytes by interrupt on cpu 3:
>    icmpv6_rcv+0x99d/0xd40
>    ip6_protocol_deliver_rcu+0x787/0x9a0
>    ip6_input_finish+0xb0/0x1b0
>    ip6_input+0xa8/0x250
>    ipv6_rcv+0x14b/0x1c0
>    ...
>
>   value changed: 0x01 -> 0x00
>
> Jiayuan Chen (14):
>   ipv4: annotate data-races around ip_rt_* sysctls
>   inet: frags: annotate data-races around fqdir->timeout and
>     fqdir->max_dist
>   ipv6: annotate data-races around addrconf sysctls
>   ipv6: annotate data-races around icmpv6 reply sysctls
>   calipso: annotate data-races around cache sysctls
>   sctp: annotate data-races around sctp sysctls
>   mptcp: annotate data-races around pernet sysctls
>   rds: annotate data-races around core rds sysctls
>   netfilter: conntrack: annotate data-races around conntrack sysctls
>   netfilter: bridge: annotate data-races around br_netfilter and nf_log
>     sysctls
>   ipvs: annotate data-races around lblc_expiration and lblcr_expiration
>   net/smc: annotate data-races around smc sysctls
>   netfilter: conntrack: annotate data-races around timeout and tcp
>     sysctls
>   netfilter: cttimeout: annotate data-races around the default timeouts
>
>  include/net/ipv6.h                            |   2 +-
>  include/net/netfilter/nf_conntrack_acct.h     |   6 +-
>  .../net/netfilter/nf_conntrack_timestamp.h    |   2 +-
>  net/bridge/br_netfilter_hooks.c               |  20 ++--
>  net/bridge/netfilter/ebt_log.c                |   2 +-
>  net/ipv4/inet_fragment.c                      |   2 +-
>  net/ipv4/ip_fragment.c                        |   6 +-
>  net/ipv4/route.c                              |  34 +++---
>  net/ipv6/addrconf.c                           |  22 ++--
>  net/ipv6/calipso.c                            |   6 +-
>  net/ipv6/icmp.c                               |  10 +-
>  net/ipv6/ndisc.c                              |   2 +-
>  net/ipv6/route.c                              |   8 +-
>  net/mptcp/ctrl.c                              |  18 +--
>  net/netfilter/ipvs/ip_vs_lblc.c               |   2 +-
>  net/netfilter/ipvs/ip_vs_lblcr.c              |   2 +-
>  net/netfilter/nf_conntrack_core.c             |   8 +-
>  net/netfilter/nf_conntrack_ecache.c           |   2 +-
>  net/netfilter/nf_conntrack_expect.c           |   2 +-
>  net/netfilter/nf_conntrack_netlink.c          |   2 +-
>  net/netfilter/nf_conntrack_proto.c            |   6 +-
>  net/netfilter/nf_conntrack_proto_generic.c    |   8 +-
>  net/netfilter/nf_conntrack_proto_gre.c        |  20 ++--
>  net/netfilter/nf_conntrack_proto_icmp.c       |  12 +-
>  net/netfilter/nf_conntrack_proto_icmpv6.c     |  12 +-
>  net/netfilter/nf_conntrack_proto_sctp.c       |  13 ++-
>  net/netfilter/nf_conntrack_proto_tcp.c        | 110 +++++++++---------
>  net/netfilter/nf_conntrack_proto_udp.c        |  24 ++--
>  net/netfilter/nf_flow_table_core.c            |   4 +-
>  net/netfilter/nf_log_syslog.c                 |   2 +-
>  net/rds/recv.c                                |   2 +-
>  net/rds/send.c                                |   8 +-
>  net/rds/threads.c                             |   4 +-
>  net/sctp/associola.c                          |   2 +-
>  net/sctp/bind_addr.c                          |   2 +-
>  net/sctp/endpointola.c                        |  14 +--
>  net/sctp/input.c                              |   2 +-
>  net/sctp/sm_make_chunk.c                      |   6 +-
>  net/sctp/sm_sideeffect.c                      |   2 +-
>  net/sctp/sm_statefuns.c                       |   6 +-
>  net/sctp/socket.c                             |  46 ++++----
>  net/sctp/sysctl.c                             |  16 +--
>  net/sctp/transport.c                          |   6 +-
>  net/smc/af_smc.c                              |   8 +-
>  net/smc/smc_clc.c                             |   8 +-
>  net/smc/smc_core.c                            |   2 +-
>  net/smc/smc_tx.c                              |   2 +-
>  47 files changed, 259 insertions(+), 246 deletions(-)
>
> --
> 2.43.0
>
>
