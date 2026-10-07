Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 86E9131716D;
	Wed,  7 Oct 2026 03:52:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791345164; cv=none; b=abqZYuRIBUtfMt5MFSb2zxacos8oTs9+DnWfPrCp7Ufhs/T9SL7z5GYla+zMxW6d6UymdbLkhNrPIvanF4RXHoqEpMSqMSU2WYvFqfA8eGDKhivwBJtyHhwmklkiHG10v9FveDrnnBI9LjrmLXPZhsHnFGqbdupXSOw28iq1znw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791345164; c=relaxed/simple;
	bh=haFObLgzphEho3QAO6yHGt4K3LpwpfAQZ/J/4dk+nao=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=t/04ODL6kONZYw4po5yJQxREwi2QBm90mnFdW5KuVeUSAsqgmSuIMTnc6QuM7YtwilOpxpRMF8KRihLK9VCWV5xTCEJ51iLdNq64EEwcLnemF0ifzQuxAT4r9i7ArPKXYIV6RE0leDUXlJUAc1J+ReLdF4iGNqomRnvoce2inx0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=MYqgeJzj; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="MYqgeJzj"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 11CF622660;
	Wed, 07 Oct 2026 06:52:29 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=1/GihXzcXaa9gVMN8nBm2j88+am7/AdxtgfXZW7hqhg=; b=MYqgeJzj4+N2
	l+JIZN06Xyx4l6aDzg3FJzxPfyVodTF8cbM5CT86ZQY1pPbONqA78zmHbtXkHGgd
	b1XCeKn5X8tVSPENWGnETKGHpytI8iDtK8u26foKIEoJ9yC8V91jj7345otAcpMF
	v5gnzlWVG0GtaYPZ7IClTO4T6NoHBRil2sibb37ER7UG+e+3eypW/vt3EanAsjHo
	96mvxEJzFnsPfkRdYDgrRVlYlU+5u7/i+yObf7D6DyEPFwy47bKZ8iOeNMZsBm87
	7fKJWpvdDhXVhBeoy7Z2AmqSHMJvSvE6rpEfVTXLGCcp9XF0pQ5whu4DMVk/npua
	XPRWTMvzC9SeF1JueXQ8CeouAbk6EdbMpIl81/OJehwgHOAtNH92un8VxFYb9sDa
	taE/fKjMUMkRlsIUXYO8D+2+eXCm1JFs4ZjRSyG6HGyaE91DRGDv7JloGrUCcqPh
	oFFlViDjkEm+qI9fw2fwSJBtA+ayeLrbd/Qg0vjZuGNN6DwQLAl8ImgnmLj8hOuH
	6wtk8yiNx+ZDVc69tjYqEagQtmcpnvPrzVDXAPD9tyHyAzFvATlXjFCJwiExOVBA
	q2vUjauXCzhPfTINHupBs8tLH6870c235+amV+zsQ+MBw2w0IQR8nEIhfGErwpg0
	GMV7CGdvkG1cIIQaHxMAxHyAsOZobjw=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 07 Oct 2026 06:52:28 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id CFBE960CB6;
	Wed,  7 Oct 2026 06:52:29 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6973qJ5c006764;
	Wed, 7 Oct 2026 06:52:19 +0300
Date: Wed, 7 Oct 2026 06:52:19 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Adriano Cordova <adrianox@gmail.com>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
        lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v6 nf-next 0/3] ipvs: add per-service secure_tcp
In-Reply-To: <20261005230808.148478-1-adrianox@gmail.com>
Message-ID: <6dc97857-6878-7572-65ba-c70ef3800554@ssi.bg>
References: <20261005230808.148478-1-adrianox@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 5 Oct 2026, Adriano Cordova wrote:

> IPVS currently exposes secure_tcp as a per-netns sysctl. It switches the
> TCP state machine to the hardened tcp_states_dos table.
> 
> These patches make it per-service: a virtual service can set
> IP_VS_SVC_F_SECURE_TCP which is passed into IP_VS_CONN_F_SECURE_TCP at
> connection creation. set_tcp_state() then selects tcp_states_dos for those
> connections with IP_VS_CONN_F_SECURE_TCP set and keeps pd->tcp_state_table
> (the netns default, including the nomem floor) otherwise.
> 
>   1. uapi: define the per-service secure_tcp flags and stamp the flag in
>      ip_vs_bind_dest() (cache-bypass has no dest)
>   2. honor it in the TCP state machine, resolving the stale FIXME, and
>      document the new default/opt-in split
>   3. kselftest contrasting a secure vs. a plain service
> 
> Changes in v2:
> - Let IP_VS_SVC_F_SECURE_TCP be 0x0100, leaving 0x0040/0x0080 for the
>   scheduler flags. Let IP_VS_CONN_F_SECURE_TCP be (1 << 17) and no longer
>   in IP_VS_CONN_F_BACKUP_MASK.
> - Set flag in ip_vs_bind_dest() instead of at every ip_vs_conn_new()
>   call site.
> - selftest: send probes with TTL=1 instead of an nft drop, and fix
>   Sashiko comments.
> 
> Changes in v3:
> - Merge patch 1/4 and 2/4
> - Re-send patches (v2 dropped patches 3/4 and 4/4)
> 
> Changes in v4:
> - selftest: check the return values of setsockopt(IP_HDRINCL), sendto()
>   and mnl_socket_bind(), and fail do_add() when IPVS does not reply.
> - selftest: fix the remaining Sashiko comments: check inet_pton(),
>   initialize fam and the parsed addresses, and verify the flags attribute
>   length before copying it.
> 
> Changes in v5:
> - Document secure_tcp as the netns-wide default and the new per-service
>   IP_VS_SVC_F_SECURE_TCP opt-in.
> - selftest: reword the changelog to "a bare SYN followed by a bare ACK".
> - selftest: skip when the ip_vs or ip_vs_rr module is unavailable.
> - selftest: check the probe exit status so that a probe which dies after
>   the SYN cannot leave the secure-side SYN_RECV assertion passing.
> 
> Changes in v6:
> - Rebase onto nf-next.
> 
> Adriano Cordova (3):
>   ipvs: add flags for per-service secure TCP state table
>   ipvs: tcp: enable per-connection secure_tcp in state machine
>   selftests: netfilter: ipvs: add per-service secure_tcp test

	Patches 1-2 look good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

	Patch 3 for selftests looks ok but should be considered
by the netfilter maintainers.
  
	Please consider providing ipvsadm patch:

https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git/

	As for the Sashiko review:

https://sashiko.dev/#/patchset/20261005230808.148478-1-adrianox%40gmail.com

	We decided not to restore the IP_VS_CONN_F_SECURE_TCP
flag in the backup server, the flag will depend on the local
configuration in the backup server.

> 
>  Documentation/networking/ipvs-sysctl.rst      |   4 +
>  include/uapi/linux/ip_vs.h                    |   2 +
>  net/netfilter/ipvs/ip_vs_conn.c               |   4 +
>  net/netfilter/ipvs/ip_vs_core.c               |   3 +
>  net/netfilter/ipvs/ip_vs_proto_tcp.c          |  16 +-
>  .../testing/selftests/net/netfilter/Makefile  |   6 +
>  .../selftests/net/netfilter/gen_tcp_probe.c   | 158 ++++++++
>  .../net/netfilter/ipvs_secure_tcp.sh          | 169 +++++++++
>  .../net/netfilter/ipvs_secure_tcp_mln.c       | 337 ++++++++++++++++++
>  9 files changed, 692 insertions(+), 7 deletions(-)
>  create mode 100644 tools/testing/selftests/net/netfilter/gen_tcp_probe.c
>  create mode 100755 tools/testing/selftests/net/netfilter/ipvs_secure_tcp.sh
>  create mode 100644 tools/testing/selftests/net/netfilter/ipvs_secure_tcp_mln.c
> 
> 
> base-commit: 8b4e7209c842d8cb9516f1f5ef0a88aa2d8831a6
> -- 
> 2.51.0

Regards

--
Julian Anastasov <ja@ssi.bg>

