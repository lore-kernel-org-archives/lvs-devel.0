Received: from smtp-relay-internal-1.canonical.com (smtp-relay-internal-1.canonical.com [185.125.188.123])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 75C4A13CFB2
	for <lvs-devel@vger.kernel.org>; Mon,  6 May 2024 14:17:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=185.125.188.123
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1715005063; cv=none; b=AR133PAZdGk8hQ/jserJ4X51GX8bgbDAblEd5tCV8WEldiKaIATSqerHx+rJ0qbVFcB9gsbfIpy5LjWZCrv3roRsjWyJGofjN7opJqU3r1koIrt9Go8QOUbxQ+IYSgn9AsUkqBJkt0uqmSrGPE2UROf6XqofVFwlH0bfZiY6O8I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1715005063; c=relaxed/simple;
	bh=nxK7n6/gLFVbdhAFMU4fQA/TACh6BFrjN5LxPYPmQd8=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=ICOpwiW8qN1vd49u5TJp1CKMrE+TkVETOJwDB3pfZvMkmzQm2u4HTQTUwnDmOQRDp7XgYyAiY1Y/WRG8FilcMegS//pAQTU18LgVGzzvNNTg9tTDKjp7uynCvjAXbmd4aQaPHkidMiq8npWFtMSjFR/c8dbd1PjghAg8TKW//F8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=canonical.com; spf=pass smtp.mailfrom=canonical.com; dkim=pass (2048-bit key) header.d=canonical.com header.i=@canonical.com header.b=U+uv7ZVD; arc=none smtp.client-ip=185.125.188.123
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=canonical.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=canonical.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=canonical.com header.i=@canonical.com header.b="U+uv7ZVD"
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-relay-internal-1.canonical.com (Postfix) with ESMTPS id C097E3FE60
	for <lvs-devel@vger.kernel.org>; Mon,  6 May 2024 14:17:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=canonical.com;
	s=20210705; t=1715005060;
	bh=qt4r3TK8PsAuXlNC2kzf8tL+5tJoUDJM+8uBLU+uv4c=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type;
	b=U+uv7ZVDLkNOvksLLSPk+CKvlYBoRujScqpyaPoutJmVa5V71Sf0n78YDwJCJP7XX
	 a+qDd+0qXmkDAwMOOAUHkSBVfMd2nkc+dXORgQMsIWSzfJsV3Bc9018KnrZJdWTxRC
	 AtNg7B7QbbZjSI0wChn62ydwhiN9w6kd+cpfhie8fzjVpG07qokMzmTeAKwYzfrck2
	 JLpf6JDGuoqA1cNUhTZX+XFivkav9ZMMZotYO5vFenifJ7bIRuBOx02BVgXC0V7oMf
	 ep8O/hDW4H7G2t/btBzUkPzOjFz1yrJbjwl075nYR7VEPW4aC01wPtCnyDTi+8J2tI
	 +P4Rsh/8Yk4CA==
Received: by mail-ot1-f72.google.com with SMTP id 46e09a7af769-6ea2d4eb150so3299082a34.1
        for <lvs-devel@vger.kernel.org>; Mon, 06 May 2024 07:17:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1715005059; x=1715609859;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=qt4r3TK8PsAuXlNC2kzf8tL+5tJoUDJM+8uBLU+uv4c=;
        b=WOQRGWenB1hpZf0kN51F9hEzznvVhk8MGBuQKQsypD8TlMyDKklrloP+gvYQ6oxx9L
         QhD6QYF4cwvGfLrrq0rP297/Jk4Yhmo8Y+5D4Wr9S7H5P3ie2PJstQfY4RfFIob1Tcp4
         Y+Yqw/LD+SkcbrII2Hp+kqSjuqrTxGDjQosODUejNBaMakoH14sWMJjUjsw2lmVCFmhs
         dcXJ7IdqcG9hffv8Fy8UzqFpYiVHQVez3EjHoLHULT2rVTdbWRzSR9upcXehhDnQOniX
         XnYkELIXvel2wWmQVk7oQRhINukXvzxx6GzmN4GQvKeT0dmaORZyQ6B+wJIe+uJelNzJ
         0xpw==
X-Forwarded-Encrypted: i=1; AJvYcCW8124Yzsw0bUyttqNzLSZ0l+RDVv0nuVw6k62LIpwfdOKEnOzpiXuPlm/okCGPoAQxaPfraW/kEGXnrlY5OQdI4WZ/m3VgG0Ts
X-Gm-Message-State: AOJu0YwOsQj9446Lja8IkMcitLib7G9d+emXyCSYS1PoIAhJ1IyA+GnZ
	56OeRdS7oCGiWomzNHdBEUOwkla2n4HDWhu0hE7aqq/U8kJc27zrGpxktMm8t7571KTYGg7tkGh
	BdRpBqDtckXGGgllmcqsCviD+xpB/+X1uVskMqzP44TdNBaaZHFD+L5DwWbsPu1Wd7n/JBdlVHF
	gOtz6AA7FQQjapemf2AfEYzCT3+QaPb0vvPEt7FHaRRx0omC3K
X-Received: by 2002:a9d:6942:0:b0:6ee:ca2:523 with SMTP id p2-20020a9d6942000000b006ee0ca20523mr11510930oto.26.1715005059707;
        Mon, 06 May 2024 07:17:39 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IG4+Q0Cv21uAqcyJ796m3+Z5LSXZzNUgpHYK3KMhn6ZmyOGxu+l9IER9gjG/5nJNA6UEvVOU2NZXkM92K1VP/8=
X-Received: by 2002:a9d:6942:0:b0:6ee:ca2:523 with SMTP id p2-20020a9d6942000000b006ee0ca20523mr11510912oto.26.1715005059317;
 Mon, 06 May 2024 07:17:39 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20240418145743.248109-1-aleksandr.mikhalitsyn@canonical.com>
 <20240418145743.248109-2-aleksandr.mikhalitsyn@canonical.com> <8e70d6d3-6852-7b84-81b3-5d1a798f224f@ssi.bg>
In-Reply-To: <8e70d6d3-6852-7b84-81b3-5d1a798f224f@ssi.bg>
From: Aleksandr Mikhalitsyn <aleksandr.mikhalitsyn@canonical.com>
Date: Mon, 6 May 2024 16:17:28 +0200
Message-ID: <CAEivzxe3Rw26mG-rfEFah7xwLnpf_RjHEp+MZV6bnDm73nLi_A@mail.gmail.com>
Subject: Re: [PATCH net-next v3 2/2] ipvs: allow some sysctls in non-init user namespaces
To: Julian Anastasov <ja@ssi.bg>
Cc: horms@verge.net.au, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, 
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, 
	=?UTF-8?Q?St=C3=A9phane_Graber?= <stgraber@stgraber.org>, 
	Christian Brauner <brauner@kernel.org>, Pablo Neira Ayuso <pablo@netfilter.org>, 
	Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, May 3, 2024 at 3:06=E2=80=AFPM Julian Anastasov <ja@ssi.bg> wrote:>
>
>         Hello,
>
> On Thu, 18 Apr 2024, Alexander Mikhalitsyn wrote:
>
> > Let's make all IPVS sysctls writtable even when
> > network namespace is owned by non-initial user namespace.
> >
> > Let's make a few sysctls to be read-only for non-privileged users:
> > - sync_qlen_max
> > - sync_sock_size
> > - run_estimation
> > - est_cpulist
> > - est_nice
> >
> > I'm trying to be conservative with this to prevent
> > introducing any security issues in there. Maybe,
> > we can allow more sysctls to be writable, but let's
> > do this on-demand and when we see real use-case.
> >
> > This patch is motivated by user request in the LXC
> > project [1]. Having this can help with running some
> > Kubernetes [2] or Docker Swarm [3] workloads inside the system
> > containers.
> >
> > Link: https://github.com/lxc/lxc/issues/4278 [1]
> > Link: https://github.com/kubernetes/kubernetes/blob/b722d017a34b300a228=
4b890448e5a605f21d01e/pkg/proxy/ipvs/proxier.go#L103 [2]
> > Link: https://github.com/moby/libnetwork/blob/3797618f9a38372e8107d8c06=
f6ae199e1133ae8/osl/namespace_linux.go#L682 [3]
> >
> > Cc: St=C3=A9phane Graber <stgraber@stgraber.org>
> > Cc: Christian Brauner <brauner@kernel.org>
> > Cc: Julian Anastasov <ja@ssi.bg>
> > Cc: Simon Horman <horms@verge.net.au>
> > Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> > Cc: Jozsef Kadlecsik <kadlec@netfilter.org>
> > Cc: Florian Westphal <fw@strlen.de>
> > Signed-off-by: Alexander Mikhalitsyn <aleksandr.mikhalitsyn@canonical.c=
om>
> > ---
> >  net/netfilter/ipvs/ip_vs_ctl.c | 21 +++++++++++++++------
> >  1 file changed, 15 insertions(+), 6 deletions(-)
> >
> > diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_=
ctl.c
> > index 32be24f0d4e4..c3ba71aa2654 100644
> > --- a/net/netfilter/ipvs/ip_vs_ctl.c
> > +++ b/net/netfilter/ipvs/ip_vs_ctl.c
>
> ...
>
> > @@ -4284,12 +4285,6 @@ static int __net_init ip_vs_control_net_init_sys=
ctl(struct netns_ipvs *ipvs)
> >               tbl =3D kmemdup(vs_vars, sizeof(vs_vars), GFP_KERNEL);
> >               if (tbl =3D=3D NULL)
> >                       return -ENOMEM;
> > -
> > -             /* Don't export sysctls to unprivileged users */
> > -             if (net->user_ns !=3D &init_user_ns) {
> > -                     tbl[0].procname =3D NULL;
> > -                     ctl_table_size =3D 0;
> > -             }
> >       } else
> >               tbl =3D vs_vars;
> >       /* Initialize sysctl defaults */
>
>         Sorry but you have to send v4 because above if-block was
> changed with net-next commit 635470eb0aa7 from today...

Dear Julian,

sorry about the delay with v4 (just rebased it on top of net-next).

Have just sent it
https://lore.kernel.org/all/20240506141444.145946-1-aleksandr.mikhalitsyn@c=
anonical.com

Kind regards,
Alex

>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
