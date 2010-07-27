From: Wensong Zhang <wensong@linux-vs.org>
Subject: Re: [patch 2/5] ipvsadm: Dont include getopt.h
Date: Tue, 27 Jul 2010 13:26:11 +0800
Message-ID: <AANLkTinZNpHMPT7OCcQ7=nGFpjac-eTwGJH5YFGOobWn@mail.gmail.com>
References: <20100726080448.476781076@vergenet.net>
	<20100726080645.721715688@vergenet.net>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:sender:received
         :in-reply-to:references:date:x-google-sender-auth:message-id:subject
         :from:to:cc:content-type:content-transfer-encoding;
        bh=HOaUEI2a2yeO5t5v+wTJOSXToHDn1t7ZqFaAGC2IMxU=;
        b=gK3FfTmEhzfxeUdbIHl21w5VL4HqXD+ysO9JFp8Kkt4FW95G6e7mf0hYUJUf+81Lu3
         H9GrId/sc8y9zMpAoTzRangntecsYv2cXd8lskT7RA3neJVw+FjMC7rsVm6Ah42UHqV7
         hGHXQ2Ox6AXfYO9ucA8WYdb+kQqludAVVcQd8=
In-Reply-To: <20100726080645.721715688@vergenet.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Nick Chalk <nick@loadbalancer.org>

Applied, thanks!

On Mon, Jul 26, 2010 at 4:04 PM, Simon Horman <horms@verge.net.au> wrot=
e:
> getopt isn't used any more.
>
> Signed-off-by: Simon Horman <horms@verge.net.au>
>
> Index: trunk/ipvsadm.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- trunk.orig/ipvsadm.c =A0 =A0 =A0 =A02010-07-25 15:41:19.000000000=
 +0900
> +++ trunk/ipvsadm.c =A0 =A0 2010-07-25 15:41:28.000000000 +0900
> @@ -93,7 +93,6 @@
> =A0#undef __KERNEL__ =A0 =A0 =A0/* Makefile lazyness ;) */
> =A0#include <stdio.h>
> =A0#include <stdlib.h>
> -#include <getopt.h>
> =A0#include <netdb.h>
> =A0#include <string.h>
> =A0#include <unistd.h>
>
>
