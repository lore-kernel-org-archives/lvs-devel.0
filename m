From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 02/20] ipvs: reorganize tot_stats
Date: Mon, 14 Mar 2011 05:28:23 +0100
Message-ID: <1300076903.2761.64.camel@edumazet-laptop>
References: <1300074346-13799-1-git-send-email-horms@verge.net.au>
	 <1300074346-13799-3-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:subject:from:to:cc:in-reply-to:references
         :content-type:date:message-id:mime-version:x-mailer
         :content-transfer-encoding;
        bh=oqLinNCkU20ZhSqSUxq6otnWNZbcVUEket/hFCUvBgo=;
        b=ClTsuvh7EU95XZOYfs1Xze7HsHFPSdClItlqupk+CiUCFRtD07SswYZCuzZ7SwoxCc
         mQxOVFh11bF9XZtHQA/WvlM3ZwqohB+w3CYeNxChKgegZ35EVTeRtsn6093xR7MAMHi3
         MwJhM0SJYUdQZuRxpeIliM4QxuhfkyvHR/nwE=
In-Reply-To: <1300074346-13799-3-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>

Le lundi 14 mars 2011 =C3=A0 12:45 +0900, Simon Horman a =C3=A9crit :
> From: Julian Anastasov <ja@ssi.bg>
>=20
>  	The global tot_stats contains cpustats field just like the
> stats for dest and svc, so better use it to simplify the usage
> in estimation_timer. As tot_stats is registered as estimator
> we can remove the special ip_vs_read_cpu_stats call for
> tot_stats. Fix ip_vs_read_cpu_stats to be called under
> stats lock because it is still used as synchronization between
> estimation timer and user context (the stats readers).
>=20
>  	Also, make sure ip_vs_stats_percpu_show reads properly
> the u64 stats from user context.
>=20
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>

One comment : per cpu stats are really good to avoid cache misses, but =
I
see tot_stats is included in struct netns_ipvs right after "conn_count"=
,
possibly sharing a hot cache line ?

Thanks


