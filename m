From: Julius Volz <julius.volz@gmail.com>
Subject: Re: IPVS_IPV6 Kconfig fix
Date: Sat, 10 Oct 2009 16:38:51 +0200
Message-ID: <43ca39800910100738pa3a55f0g7db877303846db2f@mail.gmail.com>
References: <BF3B9AC4-D881-4EC7-812B-58BDFA793D68@isohunt.com>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:in-reply-to:references
         :date:message-id:subject:from:to:cc:content-type
         :content-transfer-encoding;
        bh=YACaeM9e+KuzuTHspGAWfhxa481xfkVBVFPE3rZ1S4E=;
        b=i2En5DFoH+8jhvhDB7EIPXCFmo6pAfnYxoy/VkxiDKqKzH6cGo5z5g5gaf719InOT4
         br5mXanH6osDsSrgb5R0BVx1GYy92zcMGWvtu/iTP3G+mnMYUnyhOfhclKTkTU5+lqyd
         OcHPcL8B877wizGiyYLMIxinhTk13RZT+we8c=
In-Reply-To: <BF3B9AC4-D881-4EC7-812B-58BDFA793D68@isohunt.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Allen Parker <parker@isohunt.com>
Cc: davem@davemloft.net, lvs-devel@vger.kernel.org

Hi Allen,

On Sat, Oct 10, 2009 at 4:03 PM, Allen Parker <parker@isohunt.com> wrot=
e:
> Unless there's a very good reason to exclude CONFIG_IPV6=3Dm from
> CONFIG_IPVS_IPV6, you probably shouldn't do it. This patch fixes the
> "hidden" IPVS_IPV6 when IPV6=3Dm.
>
> diff -Nur linux-2.6.30.4/net/netfilter/ipvs/Kconfig
> linux-2.6.30.4-fixed/net/netfilter/ipvs/Kconfig
> --- linux-2.6.30.4/net/netfilter/ipvs/Kconfig =A0 2009-10-10
> 13:59:50.000000000 +0000
> +++ linux-2.6.30.4-fixed/net/netfilter/ipvs/Kconfig =A0 =A0 2009-10-1=
0
> 13:59:24.000000000 +0000
> @@ -26,7 +26,7 @@
>
> =A0config IP_VS_IPV6
> =A0 =A0 =A0 =A0bool "IPv6 support for IPVS"
> - =A0 =A0 =A0 depends on EXPERIMENTAL && (IPV6 =3D y|| IP_VS =3D IPV6=
)
> + =A0 =A0 =A0 depends on EXPERIMENTAL && (IPV6 || IP_VS =3D IPV6)
> =A0 =A0 =A0 =A0---help---
> =A0 =A0 =A0 =A0 =A0Add IPv6 support to IPVS. This is incomplete and m=
ight be
> dangerous.

The problem is that IP_VS_IPV6 doesn't support modularity, so it has
to depend on IPV6 being statically compiled in as well.

An alternative to the current configuration is to automatically select
IPV6=3Dy in the background when selecting IP_VS_IPV6 (and always showin=
g
IP_VS_IPV6). I remember a thread on lkml about that a long while ago,
but don't know the current Kconfig policies regarding this.

Julius
