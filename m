Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DBBB1448BAC;
	Tue, 15 Sep 2026 19:40:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789501209; cv=none; b=ZASHVA/7r/tHiomvsavBUSePst2DGyx+FfPWbweUL998Xh4ceeArQQJhftA8lu63/YRdcJAVsr1PCvHipj3+70YbJ5kK6RxLyeEW+rjKAnpuNkwKqVbQBD195OylLba3YmYA/vJyPB3kxyzshIIZ+xYx9g4pY81OIR1Sh0JQjII=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789501209; c=relaxed/simple;
	bh=d6KieFsD/iu17BDGAAdr2x9QVR2UPdRXdPnYmocbMYE=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=P+vMa/Lg39XhsNUEpNoHVbhar1GWBBojsdGaQYtnMC2wu2HknNfiIZdIkYlpxRfG7J+/aAjpSHID4ZxoqMd23qiU22KiToqgHJOO/jPzVSJsj8KMcNQsV8tmQd21f3uqkJ3igU+G0g2pSUzzQeSk0P/BuOOEuRlFOhIpcnWt8jA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=iHx4fqed; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="iHx4fqed"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 8C6B1217BB;
	Tue, 15 Sep 2026 22:39:53 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=2XRwvH3hz2elsKYDGcI/F3nq02hym7ZMDIB5sc84l/4=; b=iHx4fqed77tj
	ygsgXiZaZTRIUOs66MkorSn80HV0NXGgA9TPNCOaYoy5fISBvwLNUe+MFVkyGmLL
	sviXHfSIiYGBTutw2yGvHwLBihZpHcUS+00LiNsJrGHZcS9fTnqrZAb8blljDNS1
	BuK7KX+7xsnRMEubTwq+ggdqiOmoHaK9EbGyK0w+DPtgcilwP4787A/182PCFHLq
	c7hyBOz4pycyYa9+5A+sCkfjb3UqES6b0i8NtgMQPzfBhLQ2Z1X5T0BuTMDQTN+j
	ZooH5VUSm69TxmmBFlfJm9DEEx20QqOWOGEplLGug8sAlUx2QmZtykebHD6SNrJ/
	KQN8S0aGU+52HJ5LwohhBqv8lOklHG5IIT9rAAOycBKo09tRLgNCX3ziqUkyzvnB
	3n+lE7HQETGvpwdlAS5SB40wthld61cFuO7t5l08+4iRLWy+6X5kWEtS9GYV1gok
	1IOJftAiCbTeF7f+JFkQa8Iv9V+DMJ8I8UkUg8dewiXaROwD1vmgpr3DXdbDODI7
	hVdfjovdAos6yTG1UYzCKcVl5ujuhsptMwuh4cwnEKsvYduMsBR3nI71/EJOOXDv
	xM22+o+rpzCSa1JphXAXU1vi8BhuizWpU8Np2ley81Vew892QBccCYTdht2EzABI
	As61PVeD+AHZyo9vRJWi0dKDsReX/k0=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 15 Sep 2026 22:39:53 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 76E49608B2;
	Tue, 15 Sep 2026 22:39:55 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68FJdjEC099682;
	Tue, 15 Sep 2026 22:39:45 +0300
Date: Tue, 15 Sep 2026 22:39:45 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Adriano Cordova <adrianox@gmail.com>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, Shuah Khan <shuah@kernel.org>,
        netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org
Subject: Re: [PATCH 0/4] ipvs: add per-service secure_tcp
In-Reply-To: <20260912013216.588300-1-adrianox@gmail.com>
Message-ID: <7f129041-0578-ec05-9e90-2ad29206df74@ssi.bg>
References: <20260912013216.588300-1-adrianox@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Fri, 11 Sep 2026, Adriano Cordova wrote:

> IPVS currently exposes secure_tcp as a per-netns sysctl. It switches the
> TCP state machine to the hardened tcp_states_dos table.
> 
> These patches make it per-service: a virtual service can set
> IP_VS_SVC_F_SECURE_TCP which is passed into IP_VS_CONN_F_SECURE_TCP at
> connection creation. set_tcp_state() then selects tcp_states_dos for those
> connections with IP_VS_CONN_F_SECURE_TCP set and keeps pd->tcp_state_table
> (the netns default, including the nomem floor) otherwise.
> 
> The flag is part of BACKUP_MASK, so it is preserved on sync to backups.
> 
>   1. uapi: define the per-service secure_tcp flags
>   2. carry the flag on every connection-creation path (scheduler,
>      persistence, RS-initiated, cache-bypass) and on FTP data channels
>   3. honor it in the TCP state machine, resolving the stale FIXME
>   4. kselftest contrasting a secure vs. a plain service.

	Note that there is a review for patch 4 by Sashiko:

https://sashiko.dev/#/patchset/20260912013216.588300-1-adrianox%40gmail.com

	My comments:

	Patch 1:

- lets start IP_VS_SVC_F_SECURE_TCP from 0x0100, i.e. to reserve
some bits for the schedulers

- IP_VS_CONN_F_SECURE_TCP: should we really sync this flag?
It can be configured in every director differently. As
pd->tcp_state_table can be changed at any time, it should be
safe to sync cp->state between different secure_tcp
modes (directors). So, if it is not synced, next free value
should be (1 << 17).

	Patch 2:

- looks like we have many places that read svc->flags.
Better ip_vs_bind_dest() to check for IP_VS_SVC_F_SECURE_TCP
and to set IP_VS_CONN_F_SECURE_TCP. It will allow the synced
connection to inherit the flag from the local director.

	Patch 3:

- there was even tcp_timeouts_dos, see commit f1f71e03b17d.
The idea was to use reduced timeouts under attack which can
be also tuned by user space, something that can be implemented
by using the netlink interface.

	Patch 4:

- if you do not want packets to reach the real server you can
send with TTL=1, the TCP state machine will be updated but at
sending time an ICMP will be sent back.

> Not sure about patch 4... could be dropped or absorbed into ipvs.sh

	I'm not sure too.

Regards

--
Julian Anastasov <ja@ssi.bg>

