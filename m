From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [PATCH net-next v1] ipvs: add consistent source hashing scheduling
Date: Mon, 02 Apr 2018 21:12:53 +0200
Message-ID: <m3vad9cthm.fsf@luffy.cx>
References: <20180402172025.7380-1-vincent@bernat.im>
        <alpine.LFD.2.20.1804022145370.1734@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed; d=bernat.im; h=from:to:cc
        :subject:references:date:in-reply-to:message-id:mime-version
        :content-type; s=postfix; bh=2UUsczc18HlCOdxlCjTohxOyBis=; b=Z9o
        k3c/6tCuWu1IK/tuln1oXPfyrYg8P3kw2MbofHmPFRJk0WsT36pL5Mn6eVRQ0+uz
        +rWCAXN0n/61oZorQ0FfSRKPJsJts0/Q0VIiUwt2gHAX3bY/iOiJ7hcFkezGIHLO
        tII0GhRKWxnOHOk2gHXVV0cRwM6tp1rFgSk7LsHo=
In-Reply-To: <alpine.LFD.2.20.1804022145370.1734@ja.home.ssi.bg> (Julian
        Anastasov's message of "Mon, 2 Apr 2018 22:05:00 +0300 (EEST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Julian Anastasov <ja@ssi.bg>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Inju Song <inju.song@navercorp.com>

 =E2=9D=A6  2 avril 2018 22:05 +0300, Julian Anastasov <ja@ssi.bg>=C2=A0:

> 	Sorry to say it but may be you missed the discussion
> on lvs-devel about the new MH scheduler implemented by Inju Song:
>
> https://www.spinics.net/lists/lvs-devel/msg04928.html
> http://archive.linuxvirtualserver.org/html/lvs-devel/2018-03/msg00023.html
>
> 	In the last 6 months we fixed all issues and I acked
> v4 just yesterday:
>
> http://archive.linuxvirtualserver.org/html/lvs-devel/2018-04/msg00003.html

For some reason, "ipvs maglev" in Google doesn't yield those
results. But having code already reviewed is great news for me: I can
use it with confidence. :)
--=20
Make sure your code "does nothing" gracefully.
            - The Elements of Programming Style (Kernighan & Plauger)
