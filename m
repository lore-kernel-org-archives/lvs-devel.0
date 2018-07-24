From: Jonathan Cameron <jic23@kernel.org>
Subject: Re: [PATCH 1/4] treewide: convert ISO_8859-1 text comments to utf-8
Date: Tue, 24 Jul 2018 22:04:20 +0100
Message-ID: <20180724220420.7c23daaa@archlinux>
References: <20180724111600.4158975-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1532466267;
        bh=+gQetdksqtCJS/5iDkeVFYHCcl5ewu2mnCt4NvmR+tI=;
        h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
        b=AVFn722KdB9TLRRoWr06d6uUMe2/6pEy6vyreDaX0NUTbBR4nhl1K6pNDbZMdM5JC
         cVgjbjxSnqgKUBsMlHkYuFOhpJzFQKetcH+jW/r8WZY13ubm0oANDL+K/H5ky87Ytr
         GgnUrv6oWxpZyvS2Iq8ZK08pKVYXY/xXkNVun/M0=
In-Reply-To: <20180724111600.4158975-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joe Perches <joe@perches.com>, Samuel Ortiz <sameo@linux.intel.com>, "David S. Miller" <davem@davemloft.net>, Rob Herring <robh+dt@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-wireless@vger.kernel.org, netdev@vger.kernel.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-crypto@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-iio@vger.kernel.org, linux-pm@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

On Tue, 24 Jul 2018 13:13:25 +0200
Arnd Bergmann <arnd@arndb.de> wrote:

> Almost all files in the kernel are either plain text or UTF-8
> encoded. A couple however are ISO_8859-1, usually just a few
> characters in a C comments, for historic reasons.
>=20
> This converts them all to UTF-8 for consistency.
>=20
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
For IIO, Acked-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>

Thanks for tidying this up.

Jonathan

> ---
>  .../devicetree/bindings/net/nfc/pn544.txt     |   2 +-
>  arch/arm/boot/dts/sun4i-a10-inet97fv2.dts     |   2 +-
>  arch/arm/crypto/sha256_glue.c                 |   2 +-
>  arch/arm/crypto/sha256_neon_glue.c            |   4 +-
>  drivers/crypto/vmx/ghashp8-ppc.pl             |  12 +-
>  drivers/iio/dac/ltc2632.c                     |   2 +-
>  drivers/power/reset/ltc2952-poweroff.c        |   4 +-
>  kernel/events/callchain.c                     |   2 +-
>  net/netfilter/ipvs/Kconfig                    |   8 +-
>  net/netfilter/ipvs/ip_vs_mh.c                 |   4 +-
>  tools/power/cpupower/po/de.po                 |  44 +++----
>  tools/power/cpupower/po/fr.po                 | 120 +++++++++---------
>  12 files changed, 103 insertions(+), 103 deletions(-)
>=20
> diff --git a/Documentation/devicetree/bindings/net/nfc/pn544.txt b/Docume=
ntation/devicetree/bindings/net/nfc/pn544.txt
> index 538a86f7b2b0..72593f056b75 100644
> --- a/Documentation/devicetree/bindings/net/nfc/pn544.txt
> +++ b/Documentation/devicetree/bindings/net/nfc/pn544.txt
> @@ -2,7 +2,7 @@
> =20
>  Required properties:
>  - compatible: Should be "nxp,pn544-i2c".
> -- clock-frequency: I_C work frequency.
> +- clock-frequency: I=C2=B2C work frequency.
>  - reg: address on the bus
>  - interrupt-parent: phandle for the interrupt gpio controller
>  - interrupts: GPIO interrupt to which the chip is connected
> diff --git a/arch/arm/boot/dts/sun4i-a10-inet97fv2.dts b/arch/arm/boot/dt=
s/sun4i-a10-inet97fv2.dts
> index 5d096528e75a..71c27ea0b53e 100644
> --- a/arch/arm/boot/dts/sun4i-a10-inet97fv2.dts
> +++ b/arch/arm/boot/dts/sun4i-a10-inet97fv2.dts
> @@ -1,7 +1,7 @@
>  /*
>   * Copyright 2014 Open Source Support GmbH
>   *
> - * David Lanzend_rfer <david.lanzendoerfer@o2s.ch>
> + * David Lanzend=C3=B6rfer <david.lanzendoerfer@o2s.ch>
>   *
>   * This file is dual-licensed: you can use it either under the terms
>   * of the GPL or the X11 license, at your option. Note that this dual
> diff --git a/arch/arm/crypto/sha256_glue.c b/arch/arm/crypto/sha256_glue.c
> index bf8ccff2c9d0..0ae900e778f3 100644
> --- a/arch/arm/crypto/sha256_glue.c
> +++ b/arch/arm/crypto/sha256_glue.c
> @@ -2,7 +2,7 @@
>   * Glue code for the SHA256 Secure Hash Algorithm assembly implementation
>   * using optimized ARM assembler and NEON instructions.
>   *
> - * Copyright _ 2015 Google Inc.
> + * Copyright =C2=A9 2015 Google Inc.
>   *
>   * This file is based on sha256_ssse3_glue.c:
>   *   Copyright (C) 2013 Intel Corporation
> diff --git a/arch/arm/crypto/sha256_neon_glue.c b/arch/arm/crypto/sha256_=
neon_glue.c
> index 9bbee56fbdc8..1d82c6cd31a4 100644
> --- a/arch/arm/crypto/sha256_neon_glue.c
> +++ b/arch/arm/crypto/sha256_neon_glue.c
> @@ -2,10 +2,10 @@
>   * Glue code for the SHA256 Secure Hash Algorithm assembly implementation
>   * using NEON instructions.
>   *
> - * Copyright _ 2015 Google Inc.
> + * Copyright =C2=A9 2015 Google Inc.
>   *
>   * This file is based on sha512_neon_glue.c:
> - *   Copyright _ 2014 Jussi Kivilinna <jussi.kivilinna@iki.fi>
> + *   Copyright =C2=A9 2014 Jussi Kivilinna <jussi.kivilinna@iki.fi>
>   *
>   * This program is free software; you can redistribute it and/or modify =
it
>   * under the terms of the GNU General Public License as published by the=
 Free
> diff --git a/drivers/crypto/vmx/ghashp8-ppc.pl b/drivers/crypto/vmx/ghash=
p8-ppc.pl
> index f746af271460..38b06503ede0 100644
> --- a/drivers/crypto/vmx/ghashp8-ppc.pl
> +++ b/drivers/crypto/vmx/ghashp8-ppc.pl
> @@ -129,9 +129,9 @@ $code=3D<<___;
>  	 le?vperm	$IN,$IN,$IN,$lemask
>  	vxor		$zero,$zero,$zero
> =20
> -	vpmsumd		$Xl,$IN,$Hl		# H.lo_Xi.lo
> -	vpmsumd		$Xm,$IN,$H		# H.hi_Xi.lo+H.lo_Xi.hi
> -	vpmsumd		$Xh,$IN,$Hh		# H.hi_Xi.hi
> +	vpmsumd		$Xl,$IN,$Hl		# H.lo=C2=B7Xi.lo
> +	vpmsumd		$Xm,$IN,$H		# H.hi=C2=B7Xi.lo+H.lo=C2=B7Xi.hi
> +	vpmsumd		$Xh,$IN,$Hh		# H.hi=C2=B7Xi.hi
> =20
>  	vpmsumd		$t2,$Xl,$xC2		# 1st phase
> =20
> @@ -187,11 +187,11 @@ $code=3D<<___;
>  .align	5
>  Loop:
>  	 subic		$len,$len,16
> -	vpmsumd		$Xl,$IN,$Hl		# H.lo_Xi.lo
> +	vpmsumd		$Xl,$IN,$Hl		# H.lo=C2=B7Xi.lo
>  	 subfe.		r0,r0,r0		# borrow?-1:0
> -	vpmsumd		$Xm,$IN,$H		# H.hi_Xi.lo+H.lo_Xi.hi
> +	vpmsumd		$Xm,$IN,$H		# H.hi=C2=B7Xi.lo+H.lo=C2=B7Xi.hi
>  	 and		r0,r0,$len
> -	vpmsumd		$Xh,$IN,$Hh		# H.hi_Xi.hi
> +	vpmsumd		$Xh,$IN,$Hh		# H.hi=C2=B7Xi.hi
>  	 add		$inp,$inp,r0
> =20
>  	vpmsumd		$t2,$Xl,$xC2		# 1st phase
> diff --git a/drivers/iio/dac/ltc2632.c b/drivers/iio/dac/ltc2632.c
> index cca278eaa138..885105135580 100644
> --- a/drivers/iio/dac/ltc2632.c
> +++ b/drivers/iio/dac/ltc2632.c
> @@ -1,7 +1,7 @@
>  /*
>   * LTC2632 Digital to analog convertors spi driver
>   *
> - * Copyright 2017 Maxime Roussin-B_langer
> + * Copyright 2017 Maxime Roussin-B=C3=A9langer
>   * expanded by Silvan Murer <silvan.murer@gmail.com>
>   *
>   * Licensed under the GPL-2.
> diff --git a/drivers/power/reset/ltc2952-poweroff.c b/drivers/power/reset=
/ltc2952-poweroff.c
> index 6b911b6b10a6..c484584745bc 100644
> --- a/drivers/power/reset/ltc2952-poweroff.c
> +++ b/drivers/power/reset/ltc2952-poweroff.c
> @@ -2,7 +2,7 @@
>   * LTC2952 (PowerPath) driver
>   *
>   * Copyright (C) 2014, Xsens Technologies BV <info@xsens.com>
> - * Maintainer: Ren_ Moll <linux@r-moll.nl>
> + * Maintainer: Ren=C3=A9 Moll <linux@r-moll.nl>
>   *
>   * This program is free software; you can redistribute it and/or
>   * modify it under the terms of the GNU General Public License
> @@ -319,6 +319,6 @@ static struct platform_driver ltc2952_poweroff_driver=
 =3D {
> =20
>  module_platform_driver(ltc2952_poweroff_driver);
> =20
> -MODULE_AUTHOR("Ren_ Moll <rene.moll@xsens.com>");
> +MODULE_AUTHOR("Ren=C3=A9 Moll <rene.moll@xsens.com>");
>  MODULE_DESCRIPTION("LTC PowerPath power-off driver");
>  MODULE_LICENSE("GPL v2");
> diff --git a/kernel/events/callchain.c b/kernel/events/callchain.c
> index c187aa3df3c8..24a77c34e9ad 100644
> --- a/kernel/events/callchain.c
> +++ b/kernel/events/callchain.c
> @@ -4,7 +4,7 @@
>   *  Copyright (C) 2008 Thomas Gleixner <tglx@linutronix.de>
>   *  Copyright (C) 2008-2011 Red Hat, Inc., Ingo Molnar
>   *  Copyright (C) 2008-2011 Red Hat, Inc., Peter Zijlstra
> - *  Copyright  _  2009 Paul Mackerras, IBM Corp. <paulus@au1.ibm.com>
> + *  Copyright  =C2=A9  2009 Paul Mackerras, IBM Corp. <paulus@au1.ibm.co=
m>
>   *
>   * For licensing details see kernel-base/COPYING
>   */
> diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
> index 05dc1b77e466..cad48d07c818 100644
> --- a/net/netfilter/ipvs/Kconfig
> +++ b/net/netfilter/ipvs/Kconfig
> @@ -296,10 +296,10 @@ config IP_VS_MH_TAB_INDEX
>  	  stored in a hash table. This table is assigned by a preference
>  	  list of the positions to each destination until all slots in
>  	  the table are filled. The index determines the prime for size of
> -	  the table as_251, 509, 1021, 2039, 4093, 8191, 16381, 32749,
> -	  65521 or 131071._When using weights to allow destinations to
> -	  receive more connections,_the table is assigned an amount
> -	  proportional to the weights specified._The table needs to be large
> +	  the table as=C2=A0251, 509, 1021, 2039, 4093, 8191, 16381, 32749,
> +	  65521 or 131071.=C2=A0When using weights to allow destinations to
> +	  receive more connections,=C2=A0the table is assigned an amount
> +	  proportional to the weights specified.=C2=A0The table needs to be lar=
ge
>  	  enough to effectively fit all the destinations multiplied by their
>  	  respective weights.
> =20
> diff --git a/net/netfilter/ipvs/ip_vs_mh.c b/net/netfilter/ipvs/ip_vs_mh.c
> index 0f795b186eb3..94d9d349ebb0 100644
> --- a/net/netfilter/ipvs/ip_vs_mh.c
> +++ b/net/netfilter/ipvs/ip_vs_mh.c
> @@ -5,10 +5,10 @@
>   *
>   */
> =20
> -/* The mh algorithm is to assign_a preference list of all the lookup
> +/* The mh algorithm is to assign=C2=A0a preference list of all the lookup
>   * table positions to each destination and populate the table with
>   * the most-preferred position of destinations. Then it is to select
> - * destination with the hash key of source IP address_through looking
> + * destination with the hash key of source IP address=C2=A0through looki=
ng
>   * up a the lookup table.
>   *
>   * The algorithm is detailed in:
> diff --git a/tools/power/cpupower/po/de.po b/tools/power/cpupower/po/de.po
> index 78c09e51663a..840c17cc450a 100644
> --- a/tools/power/cpupower/po/de.po
> +++ b/tools/power/cpupower/po/de.po
> @@ -323,12 +323,12 @@ msgstr "  Hardwarebedingte Grenzen der Taktfrequenz=
: "
>  #: utils/cpufreq-info.c:256
>  #, c-format
>  msgid "  available frequency steps: "
> -msgstr "  m_gliche Taktfrequenzen: "
> +msgstr "  m=C3=B6gliche Taktfrequenzen: "
> =20
>  #: utils/cpufreq-info.c:269
>  #, c-format
>  msgid "  available cpufreq governors: "
> -msgstr "  m_gliche Regler: "
> +msgstr "  m=C3=B6gliche Regler: "
> =20
>  #: utils/cpufreq-info.c:280
>  #, c-format
> @@ -381,7 +381,7 @@ msgstr "Optionen:\n"
>  msgid "  -e, --debug          Prints out debug information [default]\n"
>  msgstr ""
>  "  -e, --debug          Erzeugt detaillierte Informationen, hilfreich\n"
> -"                       zum Aufsp_ren von Fehlern\n"
> +"                       zum Aufsp=C3=BCren von Fehlern\n"
> =20
>  #: utils/cpufreq-info.c:475
>  #, c-format
> @@ -424,7 +424,7 @@ msgstr "  -p, --policy         Findet die momentane T=
aktik heraus *\n"
>  #: utils/cpufreq-info.c:482
>  #, c-format
>  msgid "  -g, --governors      Determines available cpufreq governors *\n"
> -msgstr "  -g, --governors      Erzeugt eine Liste mit verf_gbaren Regler=
n *\n"
> +msgstr "  -g, --governors      Erzeugt eine Liste mit verf=C3=BCgbaren R=
eglern *\n"
> =20
>  #: utils/cpufreq-info.c:483
>  #, c-format
> @@ -450,7 +450,7 @@ msgstr ""
>  #, c-format
>  msgid "  -s, --stats          Shows cpufreq statistics if available\n"
>  msgstr ""
> -"  -s, --stats          Zeigt, sofern m_glich, Statistiken _ber cpufreq =
an.\n"
> +"  -s, --stats          Zeigt, sofern m=C3=B6glich, Statistiken =C3=BCbe=
r cpufreq an.\n"
> =20
>  #: utils/cpufreq-info.c:487
>  #, c-format
> @@ -473,9 +473,9 @@ msgid ""
>  "cpufreq\n"
>  "                       interface in 2.4. and early 2.6. kernels\n"
>  msgstr ""
> -"  -o, --proc           Erzeugt Informationen in einem _hnlichem Format =
zu "
> +"  -o, --proc           Erzeugt Informationen in einem =C3=A4hnlichem Fo=
rmat zu "
>  "dem\n"
> -"                       der /proc/cpufreq-Datei in 2.4. und fr_hen 2.6.\=
n"
> +"                       der /proc/cpufreq-Datei in 2.4. und fr=C3=BChen =
2.6.\n"
>  "                       Kernel-Versionen\n"
> =20
>  #: utils/cpufreq-info.c:491
> @@ -491,7 +491,7 @@ msgstr ""
>  #: utils/cpufreq-info.c:492 utils/cpuidle-info.c:152
>  #, c-format
>  msgid "  -h, --help           Prints out this screen\n"
> -msgstr "  -h, --help           Gibt diese Kurz_bersicht aus\n"
> +msgstr "  -h, --help           Gibt diese Kurz=C3=BCbersicht aus\n"
> =20
>  #: utils/cpufreq-info.c:495
>  #, c-format
> @@ -501,7 +501,7 @@ msgid ""
>  msgstr ""
>  "Sofern kein anderer Parameter als '-c, --cpu' angegeben wird, liefert "
>  "dieses\n"
> -"Programm Informationen, die z.B. zum Berichten von Fehlern n_tzlich sin=
d.\n"
> +"Programm Informationen, die z.B. zum Berichten von Fehlern n=C3=BCtzlic=
h sind.\n"
> =20
>  #: utils/cpufreq-info.c:497
>  #, c-format
> @@ -557,7 +557,7 @@ msgid ""
>  "select\n"
>  msgstr ""
>  "  -d FREQ, --min FREQ      neue minimale Taktfrequenz, die der Regler\n"
> -"                           ausw_hlen darf\n"
> +"                           ausw=C3=A4hlen darf\n"
> =20
>  #: utils/cpufreq-set.c:28
>  #, c-format
> @@ -566,7 +566,7 @@ msgid ""
>  "select\n"
>  msgstr ""
>  "  -u FREQ, --max FREQ      neue maximale Taktfrequenz, die der Regler\n"
> -"                           ausw_hlen darf\n"
> +"                           ausw=C3=A4hlen darf\n"
> =20
>  #: utils/cpufreq-set.c:29
>  #, c-format
> @@ -579,20 +579,20 @@ msgid ""
>  "  -f FREQ, --freq FREQ     specific frequency to be set. Requires users=
pace\n"
>  "                           governor to be available and loaded\n"
>  msgstr ""
> -"  -f FREQ, --freq FREQ     setze exakte Taktfrequenz. Ben_tigt den Regl=
er\n"
> +"  -f FREQ, --freq FREQ     setze exakte Taktfrequenz. Ben=C3=B6tigt den=
 Regler\n"
>  "                           'userspace'.\n"
> =20
>  #: utils/cpufreq-set.c:32
>  #, c-format
>  msgid "  -r, --related            Switches all hardware-related CPUs\n"
>  msgstr ""
> -"  -r, --related            Setze Werte f_r alle CPUs, deren Taktfrequen=
z\n"
> +"  -r, --related            Setze Werte f=C3=BCr alle CPUs, deren Taktfr=
equenz\n"
>  "                           hardwarebedingt identisch ist.\n"
> =20
>  #: utils/cpufreq-set.c:33 utils/cpupower-set.c:28 utils/cpupower-info.c:=
27
>  #, c-format
>  msgid "  -h, --help               Prints out this screen\n"
> -msgstr "  -h, --help               Gibt diese Kurz_bersicht aus\n"
> +msgstr "  -h, --help               Gibt diese Kurz=C3=BCbersicht aus\n"
> =20
>  #: utils/cpufreq-set.c:35
>  #, fuzzy, c-format
> @@ -618,8 +618,8 @@ msgstr ""
>  "   angenommen\n"
>  "2. Der Parameter -f bzw. --freq kann mit keinem anderen als dem Paramet=
er\n"
>  "   -c bzw. --cpu kombiniert werden\n"
> -"3. FREQuenzen k_nnen in Hz, kHz (Standard), MHz, GHz oder THz eingegebe=
n\n"
> -"   werden, indem der Wert und unmittelbar anschlie_end (ohne Leerzeiche=
n!)\n"
> +"3. FREQuenzen k=C3=B6nnen in Hz, kHz (Standard), MHz, GHz oder THz eing=
egeben\n"
> +"   werden, indem der Wert und unmittelbar anschlie=C3=9Fend (ohne Leerz=
eichen!)\n"
>  "   die Einheit angegeben werden. (Bsp: 1GHz )\n"
>  "   (FREQuenz in kHz =3D^ MHz * 1000 =3D^ GHz * 1000000).\n"
> =20
> @@ -638,7 +638,7 @@ msgid ""
>  msgstr ""
>  "Beim Einstellen ist ein Fehler aufgetreten. Typische Fehlerquellen sind=
:\n"
>  "- nicht ausreichende Rechte (Administrator)\n"
> -"- der Regler ist nicht verf_gbar bzw. nicht geladen\n"
> +"- der Regler ist nicht verf=C3=BCgbar bzw. nicht geladen\n"
>  "- die angegebene Taktik ist inkorrekt\n"
>  "- eine spezifische Frequenz wurde angegeben, aber der Regler 'userspace=
'\n"
>  "  kann entweder hardwarebedingt nicht genutzt werden oder ist nicht gel=
aden\n"
> @@ -821,7 +821,7 @@ msgstr ""
>  #: utils/cpuidle-info.c:48
>  #, fuzzy, c-format
>  msgid "Available idle states:"
> -msgstr "  m_gliche Taktfrequenzen: "
> +msgstr "  m=C3=B6gliche Taktfrequenzen: "
> =20
>  #: utils/cpuidle-info.c:71
>  #, c-format
> @@ -924,7 +924,7 @@ msgstr "Aufruf: cpufreq-info [Optionen]\n"
>  msgid "  -s, --silent         Only show general C-state information\n"
>  msgstr ""
>  "  -e, --debug          Erzeugt detaillierte Informationen, hilfreich\n"
> -"                       zum Aufsp_ren von Fehlern\n"
> +"                       zum Aufsp=C3=BCren von Fehlern\n"
> =20
>  #: utils/cpuidle-info.c:150
>  #, fuzzy, c-format
> @@ -933,9 +933,9 @@ msgid ""
>  "acpi/processor/*/power\n"
>  "                       interface in older kernels\n"
>  msgstr ""
> -"  -o, --proc           Erzeugt Informationen in einem _hnlichem Format =
zu "
> +"  -o, --proc           Erzeugt Informationen in einem =C3=A4hnlichem Fo=
rmat zu "
>  "dem\n"
> -"                       der /proc/cpufreq-Datei in 2.4. und fr_hen 2.6.\=
n"
> +"                       der /proc/cpufreq-Datei in 2.4. und fr=C3=BChen =
2.6.\n"
>  "                       Kernel-Versionen\n"
> =20
>  #: utils/cpuidle-info.c:209
> @@ -949,7 +949,7 @@ msgstr ""
>  #~ "  -c CPU, --cpu CPU    CPU number which information shall be determi=
ned "
>  #~ "about\n"
>  #~ msgstr ""
> -#~ "  -c CPU, --cpu CPU    Nummer der CPU, _ber die Informationen "
> +#~ "  -c CPU, --cpu CPU    Nummer der CPU, =C3=BCber die Informationen "
>  #~ "herausgefunden werden sollen\n"
> =20
>  #~ msgid ""
> diff --git a/tools/power/cpupower/po/fr.po b/tools/power/cpupower/po/fr.po
> index 245ad20a9bf9..b46ca2548f86 100644
> --- a/tools/power/cpupower/po/fr.po
> +++ b/tools/power/cpupower/po/fr.po
> @@ -212,7 +212,7 @@ msgstr ""
>  #: utils/cpupower.c:91
>  #, c-format
>  msgid "Report errors and bugs to %s, please.\n"
> -msgstr "Veuillez rapportez les erreurs et les bogues _ %s, s'il vous pla=
it.\n"
> +msgstr "Veuillez rapportez les erreurs et les bogues =C3=A0 %s, s'il vou=
s plait.\n"
> =20
>  #: utils/cpupower.c:114
>  #, c-format
> @@ -227,14 +227,14 @@ msgstr ""
>  #: utils/cpufreq-info.c:31
>  #, c-format
>  msgid "Couldn't count the number of CPUs (%s: %s), assuming 1\n"
> -msgstr "D_termination du nombre de CPUs (%s : %s) impossible.  Assume 1\=
n"
> +msgstr "D=C3=A9termination du nombre de CPUs (%s : %s) impossible.  Assu=
me 1\n"
> =20
>  #: utils/cpufreq-info.c:63
>  #, c-format
>  msgid ""
>  "          minimum CPU frequency  -  maximum CPU frequency  -  governor\=
n"
>  msgstr ""
> -"         Fr_quence CPU minimale - Fr_quence CPU maximale  - r_gulateur\=
n"
> +"         Fr=C3=A9quence CPU minimale - Fr=C3=A9quence CPU maximale  - r=
=C3=A9gulateur\n"
> =20
>  #: utils/cpufreq-info.c:151
>  #, c-format
> @@ -302,12 +302,12 @@ msgstr "  pilote : %s\n"
>  #: utils/cpufreq-info.c:219
>  #, fuzzy, c-format
>  msgid "  CPUs which run at the same hardware frequency: "
> -msgstr "  CPUs qui doivent changer de fr_quences en m_me temps : "
> +msgstr "  CPUs qui doivent changer de fr=C3=A9quences en m=C3=AAme temps=
 : "
> =20
>  #: utils/cpufreq-info.c:230
>  #, fuzzy, c-format
>  msgid "  CPUs which need to have their frequency coordinated by software=
: "
> -msgstr "  CPUs qui doivent changer de fr_quences en m_me temps : "
> +msgstr "  CPUs qui doivent changer de fr=C3=A9quences en m=C3=AAme temps=
 : "
> =20
>  #: utils/cpufreq-info.c:241
>  #, c-format
> @@ -317,22 +317,22 @@ msgstr ""
>  #: utils/cpufreq-info.c:247
>  #, c-format
>  msgid "  hardware limits: "
> -msgstr "  limitation mat_rielle : "
> +msgstr "  limitation mat=C3=A9rielle : "
> =20
>  #: utils/cpufreq-info.c:256
>  #, c-format
>  msgid "  available frequency steps: "
> -msgstr "  plage de fr_quence : "
> +msgstr "  plage de fr=C3=A9quence : "
> =20
>  #: utils/cpufreq-info.c:269
>  #, c-format
>  msgid "  available cpufreq governors: "
> -msgstr "  r_gulateurs disponibles : "
> +msgstr "  r=C3=A9gulateurs disponibles : "
> =20
>  #: utils/cpufreq-info.c:280
>  #, c-format
>  msgid "  current policy: frequency should be within "
> -msgstr "  tactique actuelle : la fr_quence doit _tre comprise entre "
> +msgstr "  tactique actuelle : la fr=C3=A9quence doit =C3=AAtre comprise =
entre "
> =20
>  #: utils/cpufreq-info.c:282
>  #, c-format
> @@ -345,18 +345,18 @@ msgid ""
>  "The governor \"%s\" may decide which speed to use\n"
>  "                  within this range.\n"
>  msgstr ""
> -"Le r_gulateur \"%s\" est libre de choisir la vitesse\n"
> -"                  dans cette plage de fr_quences.\n"
> +"Le r=C3=A9gulateur \"%s\" est libre de choisir la vitesse\n"
> +"                  dans cette plage de fr=C3=A9quences.\n"
> =20
>  #: utils/cpufreq-info.c:293
>  #, c-format
>  msgid "  current CPU frequency is "
> -msgstr "  la fr_quence actuelle de ce CPU est "
> +msgstr "  la fr=C3=A9quence actuelle de ce CPU est "
> =20
>  #: utils/cpufreq-info.c:296
>  #, c-format
>  msgid " (asserted by call to hardware)"
> -msgstr " (v_rifi_ par un appel direct du mat_riel)"
> +msgstr " (v=C3=A9rifi=C3=A9 par un appel direct du mat=C3=A9riel)"
> =20
>  #: utils/cpufreq-info.c:304
>  #, c-format
> @@ -377,7 +377,7 @@ msgstr "Options :\n"
>  #: utils/cpufreq-info.c:474
>  #, fuzzy, c-format
>  msgid "  -e, --debug          Prints out debug information [default]\n"
> -msgstr "  -e, --debug          Afficher les informations de d_boguage\n"
> +msgstr "  -e, --debug          Afficher les informations de d=C3=A9bogua=
ge\n"
> =20
>  #: utils/cpufreq-info.c:475
>  #, c-format
> @@ -385,8 +385,8 @@ msgid ""
>  "  -f, --freq           Get frequency the CPU currently runs at, accordi=
ng\n"
>  "                       to the cpufreq core *\n"
>  msgstr ""
> -"  -f, --freq           Obtenir la fr_quence actuelle du CPU selon le po=
int\n"
> -"                       de vue du coeur du syst_me de cpufreq *\n"
> +"  -f, --freq           Obtenir la fr=C3=A9quence actuelle du CPU selon =
le point\n"
> +"                       de vue du coeur du syst=C3=A8me de cpufreq *\n"
> =20
>  #: utils/cpufreq-info.c:477
>  #, c-format
> @@ -394,8 +394,8 @@ msgid ""
>  "  -w, --hwfreq         Get frequency the CPU currently runs at, by read=
ing\n"
>  "                       it from hardware (only available to root) *\n"
>  msgstr ""
> -"  -w, --hwfreq         Obtenir la fr_quence actuelle du CPU directement=
 par\n"
> -"                       le mat_riel (doit _tre root) *\n"
> +"  -w, --hwfreq         Obtenir la fr=C3=A9quence actuelle du CPU direct=
ement par\n"
> +"                       le mat=C3=A9riel (doit =C3=AAtre root) *\n"
> =20
>  #: utils/cpufreq-info.c:479
>  #, c-format
> @@ -403,13 +403,13 @@ msgid ""
>  "  -l, --hwlimits       Determine the minimum and maximum CPU frequency "
>  "allowed *\n"
>  msgstr ""
> -"  -l, --hwlimits       Affiche les fr_quences minimales et maximales du=
 CPU "
> +"  -l, --hwlimits       Affiche les fr=C3=A9quences minimales et maximal=
es du CPU "
>  "*\n"
> =20
>  #: utils/cpufreq-info.c:480
>  #, c-format
>  msgid "  -d, --driver         Determines the used cpufreq kernel driver =
*\n"
> -msgstr "  -d, --driver         Affiche le pilote cpufreq utilis_ *\n"
> +msgstr "  -d, --driver         Affiche le pilote cpufreq utilis=C3=A9 *\=
n"
> =20
>  #: utils/cpufreq-info.c:481
>  #, c-format
> @@ -420,7 +420,7 @@ msgstr "  -p, --policy         Affiche la tactique ac=
tuelle de cpufreq *\n"
>  #, c-format
>  msgid "  -g, --governors      Determines available cpufreq governors *\n"
>  msgstr ""
> -"  -g, --governors      Affiche les r_gulateurs disponibles de cpufreq *=
\n"
> +"  -g, --governors      Affiche les r=C3=A9gulateurs disponibles de cpuf=
req *\n"
> =20
>  #: utils/cpufreq-info.c:483
>  #, fuzzy, c-format
> @@ -429,7 +429,7 @@ msgid ""
>  "frequency *\n"
>  msgstr ""
>  "  -a, --affected-cpus   Affiche quels sont les CPUs qui doivent changer=
 de\n"
> -"                        fr_quences en m_me temps *\n"
> +"                        fr=C3=A9quences en m=C3=AAme temps *\n"
> =20
>  #: utils/cpufreq-info.c:484
>  #, fuzzy, c-format
> @@ -438,7 +438,7 @@ msgid ""
>  "                       coordinated by software *\n"
>  msgstr ""
>  "  -a, --affected-cpus   Affiche quels sont les CPUs qui doivent changer=
 de\n"
> -"                        fr_quences en m_me temps *\n"
> +"                        fr=C3=A9quences en m=C3=AAme temps *\n"
> =20
>  #: utils/cpufreq-info.c:486
>  #, c-format
> @@ -453,7 +453,7 @@ msgid ""
>  "  -y, --latency        Determines the maximum latency on CPU frequency "
>  "changes *\n"
>  msgstr ""
> -"  -l, --hwlimits       Affiche les fr_quences minimales et maximales du=
 CPU "
> +"  -l, --hwlimits       Affiche les fr=C3=A9quences minimales et maximal=
es du CPU "
>  "*\n"
> =20
>  #: utils/cpufreq-info.c:488
> @@ -469,7 +469,7 @@ msgid ""
>  "                       interface in 2.4. and early 2.6. kernels\n"
>  msgstr ""
>  "  -o, --proc           Affiche les informations en utilisant l'interfac=
e\n"
> -"                       fournie par /proc/cpufreq, pr_sente dans les "
> +"                       fournie par /proc/cpufreq, pr=C3=A9sente dans le=
s "
>  "versions\n"
>  "                       2.4 et les anciennes versions 2.6 du noyau\n"
> =20
> @@ -485,7 +485,7 @@ msgstr ""
>  #: utils/cpufreq-info.c:492 utils/cpuidle-info.c:152
>  #, c-format
>  msgid "  -h, --help           Prints out this screen\n"
> -msgstr "  -h, --help           affiche l'aide-m_moire\n"
> +msgstr "  -h, --help           affiche l'aide-m=C3=A9moire\n"
> =20
>  #: utils/cpufreq-info.c:495
>  #, c-format
> @@ -493,8 +493,8 @@ msgid ""
>  "If no argument or only the -c, --cpu parameter is given, debug output a=
bout\n"
>  "cpufreq is printed which is useful e.g. for reporting bugs.\n"
>  msgstr ""
> -"Par d_faut, les informations de d_boguage seront affich_es si aucun\n"
> -"argument, ou bien si seulement l'argument -c (--cpu) est donn_, afin de=
\n"
> +"Par d=C3=A9faut, les informations de d=C3=A9boguage seront affich=C3=A9=
es si aucun\n"
> +"argument, ou bien si seulement l'argument -c (--cpu) est donn=C3=A9, af=
in de\n"
>  "faciliter les rapports de bogues par exemple\n"
> =20
>  #: utils/cpufreq-info.c:497
> @@ -517,8 +517,8 @@ msgid ""
>  "You can't specify more than one --cpu parameter and/or\n"
>  "more than one output-specific argument\n"
>  msgstr ""
> -"On ne peut indiquer plus d'un param_tre --cpu, tout comme l'on ne peut\=
n"
> -"sp_cifier plus d'un argument de formatage\n"
> +"On ne peut indiquer plus d'un param=C3=A8tre --cpu, tout comme l'on ne =
peut\n"
> +"sp=C3=A9cifier plus d'un argument de formatage\n"
> =20
>  #: utils/cpufreq-info.c:600 utils/cpufreq-set.c:82 utils/cpupower-set.c:=
42
>  #: utils/cpupower-info.c:42 utils/cpuidle-info.c:213
> @@ -529,7 +529,7 @@ msgstr "option invalide\n"
>  #: utils/cpufreq-info.c:617
>  #, c-format
>  msgid "couldn't analyze CPU %d as it doesn't seem to be present\n"
> -msgstr "analyse du CPU %d impossible puisqu'il ne semble pas _tre pr_sen=
t\n"
> +msgstr "analyse du CPU %d impossible puisqu'il ne semble pas =C3=AAtre p=
r=C3=A9sent\n"
> =20
>  #: utils/cpufreq-info.c:620 utils/cpupower-info.c:142
>  #, c-format
> @@ -547,8 +547,8 @@ msgid ""
>  "  -d FREQ, --min FREQ      new minimum CPU frequency the governor may "
>  "select\n"
>  msgstr ""
> -"  -d FREQ, --min FREQ       nouvelle fr_quence minimale du CPU _ utilis=
er\n"
> -"                            par le r_gulateur\n"
> +"  -d FREQ, --min FREQ       nouvelle fr=C3=A9quence minimale du CPU =C3=
=A0 utiliser\n"
> +"                            par le r=C3=A9gulateur\n"
> =20
>  #: utils/cpufreq-set.c:28
>  #, c-format
> @@ -556,13 +556,13 @@ msgid ""
>  "  -u FREQ, --max FREQ      new maximum CPU frequency the governor may "
>  "select\n"
>  msgstr ""
> -"  -u FREQ, --max FREQ       nouvelle fr_quence maximale du CPU _ utilis=
er\n"
> -"                            par le r_gulateur\n"
> +"  -u FREQ, --max FREQ       nouvelle fr=C3=A9quence maximale du CPU =C3=
=A0 utiliser\n"
> +"                            par le r=C3=A9gulateur\n"
> =20
>  #: utils/cpufreq-set.c:29
>  #, c-format
>  msgid "  -g GOV, --governor GOV   new cpufreq governor\n"
> -msgstr "  -g GOV, --governor GOV   active le r_gulateur GOV\n"
> +msgstr "  -g GOV, --governor GOV   active le r=C3=A9gulateur GOV\n"
> =20
>  #: utils/cpufreq-set.c:30
>  #, c-format
> @@ -570,9 +570,9 @@ msgid ""
>  "  -f FREQ, --freq FREQ     specific frequency to be set. Requires users=
pace\n"
>  "                           governor to be available and loaded\n"
>  msgstr ""
> -"  -f FREQ, --freq FREQ     fixe la fr_quence du processeur _ FREQ. Il f=
aut\n"
> -"                           que le r_gulateur _ userspace _ soit disponi=
ble \n"
> -"                           et activ_.\n"
> +"  -f FREQ, --freq FREQ     fixe la fr=C3=A9quence du processeur =C3=A0 =
FREQ. Il faut\n"
> +"                           que le r=C3=A9gulateur =C2=AB userspace =C2=
=BB soit disponible \n"
> +"                           et activ=C3=A9.\n"
> =20
>  #: utils/cpufreq-set.c:32
>  #, c-format
> @@ -582,7 +582,7 @@ msgstr ""
>  #: utils/cpufreq-set.c:33 utils/cpupower-set.c:28 utils/cpupower-info.c:=
27
>  #, fuzzy, c-format
>  msgid "  -h, --help               Prints out this screen\n"
> -msgstr "  -h, --help           affiche l'aide-m_moire\n"
> +msgstr "  -h, --help           affiche l'aide-m=C3=A9moire\n"
> =20
>  #: utils/cpufreq-set.c:35
>  #, fuzzy, c-format
> @@ -602,11 +602,11 @@ msgid ""
>  "   (FREQuency in kHz =3D^ Hz * 0.001 =3D^ MHz * 1000 =3D^ GHz * 1000000=
).\n"
>  msgstr ""
>  "Remarque :\n"
> -"1. Le CPU num_ro 0 sera utilis_ par d_faut si -c (ou --cpu) est omis ;\=
n"
> -"2. l'argument -f FREQ (ou --freq FREQ) ne peut _tre utilis_ qu'avec --c=
pu ;\n"
> -"3. on pourra pr_ciser l'unit_ des fr_quences en postfixant sans aucune "
> +"1. Le CPU num=C3=A9ro 0 sera utilis=C3=A9 par d=C3=A9faut si -c (ou --c=
pu) est omis ;\n"
> +"2. l'argument -f FREQ (ou --freq FREQ) ne peut =C3=AAtre utilis=C3=A9 q=
u'avec --cpu ;\n"
> +"3. on pourra pr=C3=A9ciser l'unit=C3=A9 des fr=C3=A9quences en postfixa=
nt sans aucune "
>  "espace\n"
> -"   les valeurs par hz, kHz (par d_faut), MHz, GHz ou THz\n"
> +"   les valeurs par hz, kHz (par d=C3=A9faut), MHz, GHz ou THz\n"
>  "   (kHz =3D^ Hz * 0.001 =3D^ MHz * 1000 =3D^ GHz * 1000000).\n"
> =20
>  #: utils/cpufreq-set.c:57
> @@ -622,21 +622,21 @@ msgid ""
>  "frequency\n"
>  "   or because the userspace governor isn't loaded?\n"
>  msgstr ""
> -"En ajustant les nouveaux param_tres, une erreur est apparue. Les source=
s\n"
> +"En ajustant les nouveaux param=C3=A8tres, une erreur est apparue. Les s=
ources\n"
>  "d'erreur typique sont :\n"
> -"- droit d'administration insuffisant (_tes-vous root ?) ;\n"
> -"- le r_gulateur choisi n'est pas disponible, ou bien n'est pas disponib=
le "
> +"- droit d'administration insuffisant (=C3=AAtes-vous root ?) ;\n"
> +"- le r=C3=A9gulateur choisi n'est pas disponible, ou bien n'est pas dis=
ponible "
>  "en\n"
>  "  tant que module noyau ;\n"
>  "- la tactique n'est pas disponible ;\n"
> -"- vous voulez utiliser l'option -f/--freq, mais le r_gulateur _ userspa=
ce _\n"
> -"  n'est pas disponible, par exemple parce que le mat_riel ne le support=
e\n"
> -"  pas, ou bien n'est tout simplement pas charg_.\n"
> +"- vous voulez utiliser l'option -f/--freq, mais le r=C3=A9gulateur =C2=
=AB userspace =C2=BB\n"
> +"  n'est pas disponible, par exemple parce que le mat=C3=A9riel ne le su=
pporte\n"
> +"  pas, ou bien n'est tout simplement pas charg=C3=A9.\n"
> =20
>  #: utils/cpufreq-set.c:170
>  #, c-format
>  msgid "wrong, unknown or unhandled CPU?\n"
> -msgstr "CPU inconnu ou non support_ ?\n"
> +msgstr "CPU inconnu ou non support=C3=A9 ?\n"
> =20
>  #: utils/cpufreq-set.c:302
>  #, c-format
> @@ -653,7 +653,7 @@ msgid ""
>  "At least one parameter out of -f/--freq, -d/--min, -u/--max, and\n"
>  "-g/--governor must be passed\n"
>  msgstr ""
> -"L'un de ces param_tres est obligatoire : -f/--freq, -d/--min, -u/--max =
et\n"
> +"L'un de ces param=C3=A8tres est obligatoire : -f/--freq, -d/--min, -u/-=
-max et\n"
>  "-g/--governor\n"
> =20
>  #: utils/cpufreq-set.c:347
> @@ -810,7 +810,7 @@ msgstr ""
>  #: utils/cpuidle-info.c:48
>  #, fuzzy, c-format
>  msgid "Available idle states:"
> -msgstr "  plage de fr_quence : "
> +msgstr "  plage de fr=C3=A9quence : "
> =20
>  #: utils/cpuidle-info.c:71
>  #, c-format
> @@ -911,7 +911,7 @@ msgstr "Usage : cpufreq-info [options]\n"
>  #: utils/cpuidle-info.c:149
>  #, fuzzy, c-format
>  msgid "  -s, --silent         Only show general C-state information\n"
> -msgstr "  -e, --debug          Afficher les informations de d_boguage\n"
> +msgstr "  -e, --debug          Afficher les informations de d=C3=A9bogua=
ge\n"
> =20
>  #: utils/cpuidle-info.c:150
>  #, fuzzy, c-format
> @@ -921,7 +921,7 @@ msgid ""
>  "                       interface in older kernels\n"
>  msgstr ""
>  "  -o, --proc           Affiche les informations en utilisant l'interfac=
e\n"
> -"                       fournie par /proc/cpufreq, pr_sente dans les "
> +"                       fournie par /proc/cpufreq, pr=C3=A9sente dans le=
s "
>  "versions\n"
>  "                       2.4 et les anciennes versions 2.6 du noyau\n"
> =20
> @@ -929,19 +929,19 @@ msgstr ""
>  #, fuzzy, c-format
>  msgid "You can't specify more than one output-specific argument\n"
>  msgstr ""
> -"On ne peut indiquer plus d'un param_tre --cpu, tout comme l'on ne peut\=
n"
> -"sp_cifier plus d'un argument de formatage\n"
> +"On ne peut indiquer plus d'un param=C3=A8tre --cpu, tout comme l'on ne =
peut\n"
> +"sp=C3=A9cifier plus d'un argument de formatage\n"
> =20
>  #~ msgid ""
>  #~ "  -c CPU, --cpu CPU    CPU number which information shall be determi=
ned "
>  #~ "about\n"
>  #~ msgstr ""
> -#~ "  -c CPU, --cpu CPU    Num_ro du CPU pour lequel l'information sera "
> -#~ "affich_e\n"
> +#~ "  -c CPU, --cpu CPU    Num=C3=A9ro du CPU pour lequel l'information =
sera "
> +#~ "affich=C3=A9e\n"
> =20
>  #~ msgid ""
>  #~ "  -c CPU, --cpu CPU        number of CPU where cpufreq settings shal=
l be "
>  #~ "modified\n"
>  #~ msgstr ""
> -#~ "  -c CPU, --cpu CPU        num_ro du CPU _ prendre en compte pour le=
s\n"
> +#~ "  -c CPU, --cpu CPU        num=C3=A9ro du CPU =C3=A0 prendre en comp=
te pour les\n"
>  #~ "                           changements\n"

