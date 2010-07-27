From: Wensong Zhang <wensong@linux-vs.org>
Subject: Re: [patch 1/5] ipvsadm: Add --ipv6 to ipvsadm.8
Date: Tue, 27 Jul 2010 13:21:00 +0800
Message-ID: <AANLkTino1ucor393Z5nsHUaWamZyGRuCmz6k3xU64x0U@mail.gmail.com>
References: <20100726080448.476781076@vergenet.net>
	<20100726080645.453757910@vergenet.net>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:sender:received
         :in-reply-to:references:date:x-google-sender-auth:message-id:subject
         :from:to:cc:content-type:content-transfer-encoding;
        bh=0mdAGFoaMUF4Uj9xc7dpO3C9LDxSkEwyhC62KFJzuNc=;
        b=wDhgcMHq0oAid2HZ1nOR1OQ5/yD57z/FLLsQqpz6ZXxUam2xntpZSvkPskRKeTcT58
         bySE//h0wA3FfvtyUwzemPEAZWhv4cm2rQoFatELTACb+XHz5ji9nmSkl51pUHdSCrWY
         10NhUvB4Sgd1fO/tPQB22WbgVzjaT/P9ML32w=
In-Reply-To: <20100726080645.453757910@vergenet.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Nick Chalk <nick@loadbalancer.org>

Applied, thanks!

On Mon, Jul 26, 2010 at 4:04 PM, Simon Horman <horms@verge.net.au> wrot=
e:
> Signed-off-by: Simon Horman <horms@verge.net.au>
>
> Index: trunk/ipvsadm.8
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- trunk.orig/ipvsadm.8 =A0 =A0 =A0 =A02010-07-25 21:00:51.000000000=
 +0900
> +++ trunk/ipvsadm.8 =A0 =A0 2010-07-25 21:00:54.000000000 +0900
> @@ -412,7 +412,7 @@ counters, =A0instead =A0of only the rounded
> =A01000) M's (multiples of 1000K) or G's (multiples =A0of 1000M). =A0=
This
> =A0option is only relevant for the -L command.
> =A0.TP
> -.B -6
> +.B -6, --ipv6
> =A0Use with -f to signify fwmark rule uses IPv6 addresses.
> =A0.SH EXAMPLE 1 - Simple Virtual Service
> =A0The following commands configure a Linux Director to distribute
>
>
