From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 03/20] ipvs: properly zero stats and rates
Date: Mon, 14 Mar 2011 05:09:09 +0100
Message-ID: <1300075749.2761.56.camel@edumazet-laptop>
References: <1300074346-13799-1-git-send-email-horms@verge.net.au>
	 <1300074346-13799-4-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:subject:from:to:cc:in-reply-to:references
         :content-type:date:message-id:mime-version:x-mailer
         :content-transfer-encoding;
        bh=PV6J7qqTecX13IOs0SHpqHCY2zwS4qgxKnrrJolCnkU=;
        b=sZ/Iaja2EhIFvvpJH77uzg8mSVBzNQSE3hm256LoHhHbqE2rUjvHzK6rjErX/HYLmB
         szbJvKVvx72B7HW5fF3uor3QZ4pgp9gyEwTigBlzdeRaJeB/JbXVk+KFjmSwuz5cTPW4
         i49Og4Duyn8EKv0F8flsH2SQauGPJPKxOR6uo=
In-Reply-To: <1300074346-13799-4-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>

Le lundi 14 mars 2011 =C3=A0 12:45 +0900, Simon Horman a =C3=A9crit :
> From: Julian Anastasov <ja@ssi.bg>
>=20
>  	Currently, the new percpu counters are not zeroed and
> the zero commands do not work as expected, we still show the old
> sum of percpu values. OTOH, we can not reset the percpu counters
> from user context without causing the incrementing to use old
> and bogus values.
>=20
>  	So, as Eric Dumazet suggested fix that by moving all overhead
> to stats reading in user context. Do not introduce overhead in
> timer context (estimator) and incrementing (packet handling in
> softirqs).
>=20
>  	The new ustats0 field holds the zero point for all
> counter values, the rates always use 0 as base value as before.
> When showing the values to user space just give the difference
> between counters and the base values. The only drawback is that
> percpu stats are not zeroed, they are accessible only from /proc
> and are new interface, so it should not be a compatibility problem
> as long as the sum stats are correct after zeroing.
>=20
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>



