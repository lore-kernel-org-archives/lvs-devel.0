From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] IPVS: replace sprintf to snprintf to avoid stack buffer 
	overflow
Date: Tue, 6 Apr 2010 10:58:28 +0800
Message-ID: <k2l412e6f7f1004051958h7c50f439r6b7a84379c35cba5@mail.gmail.com>
References: <20100406025020.GA2741@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:in-reply-to:references
         :from:date:received:message-id:subject:to:cc:content-type
         :content-transfer-encoding;
        bh=AKdGOmtWPVaFrwelPdFZmlRrLx7vAZzLlVYm7OlrTMM=;
        b=aZOH4/AKDPNEwK3tf9BzwOWtn09eMGIDkX5S6bBHhmHYmzUcKwbTkxgc7LUnz4Foql
         NsOZTazXCTVRNyBC71+6APjrdKOGsPQ0Q/KbDuRSlBHJSCBbMDu9EhlJ1xVLNE4bTgKy
         Tq0o0q3OCBMIzxzgHPFnIrU1gB6nRpOGgGhOo=
In-Reply-To: <20100406025020.GA2741@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: wzt.wzt@gmail.com
Cc: linux-kernel@vger.kernel.org, wensong@linux-vs.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

On Tue, Apr 6, 2010 at 10:50 AM,  <wzt.wzt@gmail.com> wrote:
> IPVS not check the length of pp->name, use sprintf will cause stack b=
uffer overflow.
> struct ip_vs_protocol{} declare name as char *, if register a protoco=
l as:
> struct ip_vs_protocol ip_vs_test =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.name =3D =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 "aaaaaaaa....128...aaa",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.debug_packet =3D =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 ip_vs_tcpudp_debug_packet,
> };
>
> when called ip_vs_tcpudp_debug_packet(), sprintf(buf, "%s TRUNCATED",=
 pp->name);
> will cause stack buffer overflow.
>

Long messages will be truncated instead of buffer overflow. We need to
find a way to handle long messages elegantly.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
