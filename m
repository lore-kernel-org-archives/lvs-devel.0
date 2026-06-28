Received: from mail-ej1-f67.google.com (mail-ej1-f67.google.com [209.85.218.67])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C2D2E3438B9
	for <lvs-devel@vger.kernel.org>; Sun, 28 Jun 2026 05:45:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.218.67
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782625515; cv=pass; b=c/2r5nOmergdzMUjpFh9AebgdljZKB8qgBPk0H7ouETtD7el4LNnyl3BNefDq8+eVpOhhkv9PtTqzRTXicVOZLJzpGjTEo7DW8vx4mgBIxFGXdsdEKQmK/3RfacYyDz4bpnrE+OoF/IjEivgYR//cCIlKlgYuOSCN6ZoOIHzCoE=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782625515; c=relaxed/simple;
	bh=Hc1AF5CYasLbTlGV9oYOuBcM5iYw5fAGn0qVWD48s/c=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=u7Id+NtFBBZ0ai2vghsxubIXimXDBeH19Qo2NkY1uPgK2n3FVJoTM1rlxWqcCgJ7M16mq1czAItIo54T95OAsuRjXttW4BBh+RP5jvGGIUUwPUvQf/b3vbwfJAm6BZzCRYYxAZFGG0ZeFTTIeD0n7IILOdWu7poOuHpL7xrJcj8=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=qDb0WtUB; arc=pass smtp.client-ip=209.85.218.67
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qDb0WtUB"
Received: by mail-ej1-f67.google.com with SMTP id a640c23a62f3a-c08acccf4a4so301977166b.3
        for <lvs-devel@vger.kernel.org>; Sat, 27 Jun 2026 22:45:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1782625512; cv=none;
        d=google.com; s=arc-20260327;
        b=bXdQVPZPh7Klx2qurEX50VyYJ/QVp7lZsXtqqQkflUrpTrPwjrZGW7VCbHu+KbqNO+
         92GQpVkvjXcH5KyR3K4cA40cVnW9dQgJy3gcQsfVBCcYFDZShixKfGgfqgt5omKfu5Bd
         F33OmEcKOpZla/agXbEqryFNKw8L1KesvJTiQW5epnzMaiGF+y+okPiT1p9iDNMYEJqD
         XB+cfhisXE6YLBzfC9aaUOa+WZSMcHB4HdS7QZhItMtr464FqnwkNM8sGM+sYG7yCbHT
         70rTqmXamoCxU6xaJY+e7W/n/gJXTd20bfs5ObWevPpdunc/t+/YMEd9mb1YFS7KQV35
         u8tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=ryg9VsI2q7eTLjDcyzpNo1Dk3naB663ocaoFsbpektQ=;
        fh=osKf7dWH/pJYZR36ANpiYfcVrrRjV9ByUhEsTpSKsww=;
        b=ZRH1OvkfJA/XhbX5IfR3DIbMbGAObUWdCekbjhyoFiWitc9xs9C/2Ti32ddRTj/Qbt
         CAp5LptVe78O9jF3JmRdXfgm5+gf6b6+cdDCbMr8QM/ZcjZUq/VzEl0oz7QQKJoZGObM
         QjsLGquCzD3UkRuZUIXdcHVACKIkTXUHluF2qlcFrcGZ0lQj/Uv2Y4AsQLtKsGQwdPkI
         AjU5DV9hA/rAgCZ9d0qiFjUaTH10a4o7VQHpXc5Ou95nj1dJ1QdjwUzpSsm7L/mB/005
         EvgSrKXga4mu8dqJ3L7TYYmAvw+pIifhsj4bTYLVcjdjiPKBBdVPW3k6S08EPrQptJMg
         XWdA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1782625512; x=1783230312; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=ryg9VsI2q7eTLjDcyzpNo1Dk3naB663ocaoFsbpektQ=;
        b=qDb0WtUBM4TNXbdDLx3grZkIoo9ks5xMoFBWzMgZN2X1llCp5Y0zCL5Icw4GMgUEpd
         JOQz1Qnvf9T5mqw66oEQ6Fq8OexuTVNYyC+trQ+Aw9MXSuZNgieJmtiDhlQlV9v9CczS
         DodNVaIoniFecE1tPn1CiQiCqlBx8FSaeulgXh8rASjwFBwBVuRXbUQ+W7ORLkQ83vvS
         JwDhZ5fterh1lkuDXuM5F6Ije1eFB2WIlpIdLMiYBnaZR0fjWyru+G4Utoch+LIPafYL
         Qm3dahv0GZzm3G/tGmaX3D2SNsgnO2GVIdSHB7mlt1Yx34nfl6xn8hcQjd0qosh3Gdo6
         GNJA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1782625512; x=1783230312;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=ryg9VsI2q7eTLjDcyzpNo1Dk3naB663ocaoFsbpektQ=;
        b=XikuvMnQVTz0cRkpCLrhdf9jbzBJQWpMxDopY1oH2FDVif931LFjjRCBznsfj2AlRB
         ozrJ/bNHjI9+T2dCOM+T6uQj6u4dtZbPLf1QXl2J8ReR8ONchvol6b5uTM1NyquDMIC3
         bO1bV/14w9eKs8dK7k7W1e6mKZPN5jdZFpTF0nfU9F5l0PjUg01yTtRWCIAzJTEZU6Me
         aaGGpuyInv3peDAVF6NfnKdgeJIBs4Eab9QXlcDFTgjhQjJ0xpeQBI9BTL3K8P/c2RMz
         kOusIR3ttv2dolJj+lUe5bWc4kcI2jvjqiAl7jlCrhUOw9aduPXbEl29iZcdzH1TdU3A
         ARsw==
X-Forwarded-Encrypted: i=1; AHgh+RoxVsKdy6gkC5kQgpB9zk1mL7IK31WqSVlbQyZQcoSP1CBDzgvYfydZe1G5jpZBDYgHZmzez0hMLPk=@vger.kernel.org
X-Gm-Message-State: AOJu0YwfawBTVaHq+BFGkiXCkkzTbNQvgEgnMpjdTRnADFnXYM6Pay8i
	b8BYkoEynEHOxGpUW2cF9C0m5PQg6jmrzmlzPkTBtkkZPs7/h0wkFu9SCVv7SyFnmpo5QXulPvD
	lqtWLcTcFnILmcNw5l8KxYSs0rjRuDYA=
X-Gm-Gg: AfdE7clibIOkGbnJCHB7pBpw2QrRvtxBfULQK0NXyM7X2fgUKqupWx0egnqWtR1LeU+
	bQo7jRqidNKPvnCAN/aaj60OBf6xOvaX8hya4fL345w8Dvu3fb9uT0kl/F2WmgKqDXP2UzklfPc
	tKE7ayWJE0EI09XFDptER/Guf6Mjgg2w/ZGDZpqBngTEnlFpLc777T+S152wB8IkngVgnybCEsm
	XDSvyCBGgHm/KuaFXQ+tPU+qva9rilSidumxfXbxZA6ImGTP4mzJfQSwUnSyFdH5/j24E/W
X-Received: by 2002:a17:907:3c86:b0:c12:fb7:2b33 with SMTP id
 a640c23a62f3a-c120fb7321emr647148166b.22.1782625511876; Sat, 27 Jun 2026
 22:45:11 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <cover.1782540466.git.roxy520tt@gmail.com> <1b914f41d725bc064c9ba9830dc8169329737270.1782540466.git.roxy520tt@gmail.com>
 <a37698c7-46de-1f04-5306-b6a6af7ee6c7@ssi.bg>
In-Reply-To: <a37698c7-46de-1f04-5306-b6a6af7ee6c7@ssi.bg>
From: tt roxy <roxy520tt@gmail.com>
Date: Sun, 28 Jun 2026 13:44:59 +0800
X-Gm-Features: AVVi8CfHVbnPZ1rZlBSrW9Z6b4N9_UcNROEh7oVZYpN_tGY6tdLcfHYQLaKgELM
Message-ID: <CALMqdkR704S2BG_QD_bgHTFp2+1QCi7n0T4zoZyTo8mDZevYSA@mail.gmail.com>
Subject: Re: [PATCH 1/1] ipvs: preserve conn hash flags when late-binding dest
To: Julian Anastasov <ja@ssi.bg>
Cc: Ren Wei <n05ec@lzu.edu.cn>, lvs-devel@vger.kernel.org, 
	netfilter-devel@vger.kernel.org, horms@verge.net.au, pablo@netfilter.org, 
	fw@strlen.de, phil@nwl.cc, kaber@trash.net, nick@loadbalancer.org, 
	yuantan098@gmail.com, yifanwucs@gmail.com, tomapufckgml@gmail.com, 
	bird@lzu.edu.cn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, Jun 28, 2026 at 4:47=E2=80=AFAM Julian Anastasov <ja@ssi.bg> wrote:
>
>
>         Hello,
>
> On Sun, 28 Jun 2026, Ren Wei wrote:
>
> > From: Zhiling Zou <roxy520tt@gmail.com>
> >
> > Synced connections can be created before their destination exists. When
> > the destination is later added, ip_vs_try_bind_dest() binds it to the
> > existing connection through ip_vs_bind_dest().
> >
> > ip_vs_bind_dest() copies destination connection flags into cp->flags.
> > For an already hashed connection, changing flags that define conn_tab
> > membership breaks the hash table invariants. In particular, adding
> > IP_VS_CONN_F_ONE_PACKET after the connection has been hashed can make
> > expiry skip unlinking it from conn_tab. Changing the forwarding method
> > can also make unlink use a different single or double hash-node layout
> > than the one used at insertion time.
> >
> > Preserve the flags that define conn_tab hashing when binding a
> > destination to an already hashed connection.
> >
> > Fixes: 26ec037f9841 ("IPVS: one-packet scheduling")
>
>         The problem with the fix is that we should do it
> in the hard way: the backup server should be able to define
> its own forwarding methods. Otherwise, we can break existing
> setups. For example, master can have localnode for some
> dests, this can not be preserved in the backup for the
> synced conns.
>
> > Cc: stable@vger.kernel.org
> > Reported-by: Yuan Tan <yuantan098@gmail.com>
> > Reported-by: Yifan Wu <yifanwucs@gmail.com>
> > Reported-by: Juefei Pu <tomapufckgml@gmail.com>
> > Reported-by: Xin Liu <bird@lzu.edu.cn>
> > Assisted-by: Codex:gpt-5.4
> > Signed-off-by: Zhiling Zou <roxy520tt@gmail.com>
> > Signed-off-by: Ren Wei <n05ec@lzu.edu.cn>
> > ---
> >  net/netfilter/ipvs/ip_vs_conn.c | 14 +++++++++++++-
> >  1 file changed, 13 insertions(+), 1 deletion(-)
> >
> > diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs=
_conn.c
> > index cb36641f8d1c..016273906aac 100644
> > --- a/net/netfilter/ipvs/ip_vs_conn.c
> > +++ b/net/netfilter/ipvs/ip_vs_conn.c
> > @@ -998,7 +998,11 @@ static inline int ip_vs_dest_totalconns(struct ip_=
vs_dest *dest)
> >  static inline void
> >  ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
> >  {
> > +     const unsigned int hash_flags =3D IP_VS_CONN_F_FWD_MASK |
> > +                                     IP_VS_CONN_F_NOOUTPUT |
> > +                                     IP_VS_CONN_F_ONE_PACKET;
> >       unsigned int conn_flags;
> > +     __u32 old_flags;
> >       __u32 flags;
> >
> >       /* if dest is NULL, then return directly */
> > @@ -1011,7 +1015,8 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_=
vs_dest *dest)
> >       conn_flags =3D atomic_read(&dest->conn_flags);
> >       if (cp->protocol !=3D IPPROTO_UDP)
> >               conn_flags &=3D ~IP_VS_CONN_F_ONE_PACKET;
> > -     flags =3D cp->flags;
> > +     old_flags =3D cp->flags;
> > +     flags =3D old_flags;
> >       /* Bind with the destination and its corresponding transmitter */
> >       if (flags & IP_VS_CONN_F_SYNC) {
>
>         We can here unconditionally drop the IP_VS_CONN_F_ONE_PACKET flag=
:
>
>                 conn_flags &=3D ~IP_VS_CONN_F_ONE_PACKET;
>
>         Because IP_VS_CONN_F_ONE_PACKET conns are not synced.
>
>         And here when (flags & IP_VS_CONN_F_HASHED) and the fwd
>         method changes between MASQ and non-MASQ for
>         !IP_VS_CONN_F_TEMPLATE we should call some new func
>         that properly hashes/unhashes just the hn1 node.
>         I can provide such function with proper locking.
>

Thank you for the review.

I agree. Preserving the forwarding method is too conservative and can
break backup setups where the backup server intentionally uses its own
forwarding method.

For v2 I will drop IP_VS_CONN_F_ONE_PACKET from conn_flags
unconditionally, since one-packet connections are not synced.

For the MASQ/non-MASQ transition on already hashed non-template
connections, I agree that the right fix is to update only the hn1 hash
node instead of preserving the old forwarding method. Since this needs
to follow the conn_tab locking rules carefully, I would appreciate the
helper you mentioned and will use it for v2.

Thanks,
Zhiling

> >               /* if the connection is not template and is created
> > @@ -1023,6 +1028,13 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip=
_vs_dest *dest)
> >               flags &=3D ~(IP_VS_CONN_F_FWD_MASK | IP_VS_CONN_F_NOOUTPU=
T);
> >       }
> >       flags |=3D conn_flags;
> > +
> > +     /* Preserve conn_tab hashing invariants after late binding. */
> > +     if (old_flags & IP_VS_CONN_F_HASHED) {
> > +             flags &=3D ~hash_flags;
> > +             flags |=3D old_flags & hash_flags;
> > +     }
> > +
> >       cp->flags =3D flags;
> >       cp->dest =3D dest;
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>
