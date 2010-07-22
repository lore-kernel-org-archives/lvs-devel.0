From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: LVS on local node
Date: Thu, 22 Jul 2010 11:46:04 +0200
Message-ID: <1279791964.2467.12.camel@edumazet-laptop>
References: <27901279770680@web67.yandex.ru>
	 <1279781811.2405.15.camel@edumazet-laptop>
	 <AANLkTimneLE2xKg6fie5u3Cvjzcrq4VnK6wMT3pno0JK@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:subject:from:to:cc
         :in-reply-to:references:content-type:date:message-id:mime-version
         :x-mailer:content-transfer-encoding;
        bh=MeeeAL3/RLSC/U8EIVpN552k7smVs2J9EVFyLC2Rd2E=;
        b=mQ7HrXZtHqx6bw8NiLspPGa6j9a3M4IywRKrR66pSDPaCOS8UIdcMKqh9PXXrzJlNz
         uvQSrNcIPcmnp+OXE34tJxk+H5bJqDtQMX+2FH2/hNJsMbtNFrWe+zbPSb9XIGFRBsdj
         BeOSWDfu6i+hqppPofPpBoW4qqaOiSFgNdOZU=
In-Reply-To: <AANLkTimneLE2xKg6fie5u3Cvjzcrq4VnK6wMT3pno0JK@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Changli Gao <xiaosuo@gmail.com>, Patrick McHardy <kaber@trash.net>, Jan Engelhardt <jengelh@medozas.de>
Cc: Franchoze Eric <franchoze@yandex.ru>, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

Le jeudi 22 juillet 2010 =C3=A0 17:10 +0800, Changli Gao a =C3=A9crit :

>=20
> I think maybe REDIRECT is enough. If the public port is one of the
> real ports, you need to append "random" option to iptables target
> REDIRECT. If not, "REDIRECT --to-ports 1000-1007" is good enough, and
> the destination port will be selected in the round-robin manner.
>=20

Yes, on 2.6.32, no RPS, so undocumented --random option is probably the
best we can offer. (random option was added in 2.6.22)

iptables -t nat -A PREROUTING -p tcp --dport 1234 -j REDIRECT --random =
--to-port 1000-1007

Here is a patch to add "random" help to REDIRECT iptables target

Thanks

[PATCH] extensions: REDIRECT: add random help

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/extensions/libipt_REDIRECT.c b/extensions/libipt_REDIRECT.=
c
index 3dfcadf..324d0eb 100644
--- a/extensions/libipt_REDIRECT.c
+++ b/extensions/libipt_REDIRECT.c
@@ -17,7 +17,8 @@ static void REDIRECT_help(void)
 	printf(
 "REDIRECT target options:\n"
 " --to-ports <port>[-<port>]\n"
-"				Port (range) to map to.\n");
+"				Port (range) to map to.\n"
+" [--random]\n");
 }
=20
 static const struct option REDIRECT_opts[] =3D {


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
