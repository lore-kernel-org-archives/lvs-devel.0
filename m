From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: LVS on local node
Date: Thu, 22 Jul 2010 11:59:52 +0200
Message-ID: <1279792792.2467.15.camel@edumazet-laptop>
References: <27901279770680@web67.yandex.ru>
	 <1279781811.2405.15.camel@edumazet-laptop>
	 <AANLkTimneLE2xKg6fie5u3Cvjzcrq4VnK6wMT3pno0JK@mail.gmail.com>
	 <1279791964.2467.12.camel@edumazet-laptop>
	 <AANLkTimLZG_-4wbKy8nrajHVKQvvGtRKEd8qHNoU3swJ@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:subject:from:to:cc
         :in-reply-to:references:content-type:date:message-id:mime-version
         :x-mailer:content-transfer-encoding;
        bh=7vEzzR6xfmVwzq2GqXjuNFyI8hf9bmv7pLXH23saHAo=;
        b=Iwsvy/ohuCY5GuwT8aZW7pOq6PRBc3GZlHagBEEiDAt3EZ/+5PIuk2KdFdqeTNOKlO
         Tou4qZcS5MePDqmOy3Tx3FPZoZW5knt38D1xtoWelP4BjQfyXovJEiuToiL8i3KmZwZp
         hS8IX/6S32Gckmcc9jcGBZixa0zL+xA0ht8aw=
In-Reply-To: <AANLkTimLZG_-4wbKy8nrajHVKQvvGtRKEd8qHNoU3swJ@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Changli Gao <xiaosuo@gmail.com>
Cc: Patrick McHardy <kaber@trash.net>, Jan Engelhardt <jengelh@medozas.de>, Franchoze Eric <franchoze@yandex.ru>, wensong@linux-vs.org, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

Le jeudi 22 juillet 2010 =C3=A0 17:52 +0800, Changli Gao a =C3=A9crit :

>=20
> FYI: the random option is documented in the manual page of iptables.
>=20
>    REDIRECT
>        This  target is only valid in the nat table, in the PREROUTING=
 and OUT-
>        PUT chains, and user-defined chains which are only  called  fr=
om  those
>        chains.   It redirects the packet to the machine itself by cha=
nging the
>        destination IP  to  the  primary  address  of  the  incoming  =
interface
>        (locally-generated packets are mapped to the 127.0.0.1 address=
).
>=20
>        --to-ports port[-port]
>               This  specifies  a  destination  port  or range of port=
s to use:
>               without this, the destination port is never  altered.  =
 This  is
>               only valid if the rule also specifies -p tcp or -p udp.
>=20
>        --random
>               If  option --random is used then port mapping will be r=
andomized
>               (kernel >=3D 2.6.22).
>=20
>=20

Note my patch has nothing to do with the man page, its already up2date.

I usually dont read the Fine manuals, do you ?

Try :

iptables -t nat -A PREROUTING -p tcp --dport 1234 -j REDIRECT --help

REDIRECT target options:
 --to-ports <port>[-<port>]
				Port (range) to map to.


You see [--random] is missing.



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
