Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793682317;
	b=z2EyYaFHyg8i9kIvNTL13uPI3ay66vox/y9zVj6k3yVu97hGE+b9vBBsvEtQIoOS59xm
	 i3p3qMGo7LhMf5D6wU3M6rILr9JQeZtH6wQEvm9ci788iNfVI9DLVNaMlx5h0mlWu2RFJ
	 Mr4RuJVLPztory1jK1R0+wCKt5o6Sma1KXern+UA6s7w/FKr20dz7zdzqGm2WP9ygnqaN
	 KTa8ihsc54L4YdUDOncD6SOcRWVywe3wQXlFzi8wkwT6jVa7fx0+kbLjVcW0YpZMvkpTe
	 d0Ejpllqh2fgkDhCiCyIxU0KPiZvHLgSSlfcKWWuyR9RR34vjYW1JHGk0/HCAXtpySQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793682317;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=imQPTaBy9k6YK2vvioFDfraxaLKMbGcfCrTXO6oQIK8=;
	b=QPRlHyX1e/q0P4z2XXuoYhoLPAaI6KUlV/2nUCLa5exOfm8+fAUug7TGidYxs4ENLhWr
	 sen2cMRZsbdfuwf2dvzVM1oAqfmzwNvMTF/aNxGgkv2lKRzUMnAoHy/7r8cQKx2MvZthT
	 oROOUi6OY7sus3bw1IwvsjTrtzM34Mqdan2Tt41nCD36DQ0JxWOdcsegTottQIPhYY34B
	 K+f9j1ExY38s3h/7BkGHZ9+kHuUWAe3B2je9mGDm2ef0+UhcfkPVJ5f3lfvhTyYT2l+sH
	 nMwkKDuGcjp18wnVZAlWvk8ZT74kBs7wstKhtZ9N4/73YpFQa3jcPcF/3XVANolsl6A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=Dc7OAHpB;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 08A49606A324;
	Tue,  3 Nov 2026 05:05:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 08A49606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=Dc7OAHpB
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id C28FF213F4;
	Tue, 03 Nov 2026 07:05:11 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=imQPTaBy9k6YK2vvioFDfraxaLKMbGcfCrTXO6oQIK8=; b=Dc7OAHpBKYVa
	j0+FT65YwJoa/9U3D7X7aNQpbGOpcCETgeG9oXwC9uyDHiPCAuBrSzGnt/83Bd4L
	r1YFTHAzPoTOps6RBSaSba2TFwdypuejT/LrULnkphZLe1YmS7tyISaGoC8Zg5wo
	2E+EnIXoBRg8gdh/AlD8jK0Ma3BQveXRx0LT8JZCTLcIgFO1Pjnj9OLHb2rOWHXf
	WAgLCEXDkOy8cn5xE5ObJAeqoknJqFCAf/4TI+aNeyzqHUqKyDowLfeVTXTva45y
	9lLIZLWpTVhGZE6CoCK3eUkm5fz8JVc2TKq1S2J7bhkPkAA82cM5rIQr2Mois4Dj
	4aOT+Ni3HLbWZygJWoGPMTSUQlCd0WXh8xXbNhpUK/xZ4LigWtAtr6A2q7Ddw9b/
	IMYAezX1FK6dgztRejd3hWYNCc1Ek83ld6BDRo5xLD6hgznp1sptAm1QvVwO9Q6E
	IoGGEh488LOIs59hOMIEZSZp1p/APd2abg+f68mO7IN+gXiIcpUBeLT6Mo8O2tHq
	+tB9zLoTta8hWVbacmMVI8suyWevo/E6eFDYLUn6wRkOo06Fl+MGYs+1oVOiunPU
	KEBUdAsPWS/9aUNUr8DQQTGmpSbo1Z2Zu7unl0ZEgo0pyqWGs1LI7PcAxZAxAVxA
	DB9Oj75z+tBXKF097zm3kga7SSngt3w=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 03 Nov 2026 07:05:11 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 3B4FD61E56;
	Tue,  3 Nov 2026 07:05:11 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6A35542b006195;
	Tue, 3 Nov 2026 07:05:05 +0200
Date: Tue, 3 Nov 2026 07:05:04 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Axel Mierczuk <axel.mierczuk@1password.com>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        Willy Tarreau <w@1wt.eu>, Keith Hoodlet <keith.hoodlet@1password.com>
Subject: Re: [PATCH nf 0/2] ipvs: keep templates and cport 0 conns away from
 packet lookups
In-Reply-To: <f87eab0c-253a-2d5d-d2e6-f4fb691c9813@ssi.bg>
Message-ID: <bc3597b9-9fd9-692c-76ec-90904c787d2f@ssi.bg>
References: <20260925141115.16126-1-axel.mierczuk@1password.com> <002e2c69-ae17-4321-ba3d-74cca0e57123@ssi.bg> <CALb1hrnMJGj5ePZSB89ZW0Uv_oNpepeqgAmGcZxRsLyv64HOYA@mail.gmail.com> <f87eab0c-253a-2d5d-d2e6-f4fb691c9813@ssi.bg>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-1168736756-1793682309=:3469"

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1168736756-1793682309=:3469
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hi Axel,

	Ping after 1 month...

On Sat, 3 Oct 2026, Julian Anastasov wrote:

> On Wed, 30 Sep 2026, Axel Mierczuk wrote:
> 
> > Hi Julian,
> > 
> > Sounds good. I will take a look as well and get back to you.
> > 
> > On Tue, Sep 29, 2026 at 2:29 PM Julian Anastasov <ja@ssi.bg> wrote:
> > 
> >               Hello,
> > 
> >       On Fri, 25 Sep 2026, Axel Mierczuk wrote:
> > 
> >       > A template received over the unauthenticated sync protocol with a
> >       > nonzero cport is matched by data packets in ip_vs_conn_in_get() and
> >       > the protocol state machine runs on it. Patch 1 rejects sync records
> >       > with inconsistent cport and IP_VS_CONN_F_NO_CPORT combinations on
> >       > the backup.
> >       >
> >       > Patch 2 requires a nonzero cp->cport in ip_vs_conn_out_get() so that
> >       > templates and connections still waiting for their cport cannot be
> >       > matched through the out hook.
> >       >
> >       > The companion patch "ipvs: filter some flags received in the backup
> >       > server" rejects template records carrying IP_VS_CONN_F_NO_CPORT.
> >       >
> >       > Axel Mierczuk (2):
> >       >   ipvs: validate cport in received sync records
> >       >   ipvs: skip cport 0 connections in ip_vs_conn_out_get()
> >       >
> >       >  net/netfilter/ipvs/ip_vs_conn.c |  3 ++-
> >       >  net/netfilter/ipvs/ip_vs_sync.c | 19 +++++++++++++++++++
> >       >  2 files changed, 21 insertions(+), 1 deletion(-)
> > 
> >               Axel, this Sashiko review is shattering:
> > 
> >       https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260925141115.16126-1-axel.mierczuk%401password.com
> > 
> >               I'll be back with analyze how should we fix the
> >       problems...
> 
> 	Here is what we have for the Sashiko review:
> 
> https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260925141115.16126-1-axel.mierczuk%401password.com
> 
> Patch 1:
> 
> Q. Should the template branch also reject IP_VS_CONN_F_NO_CPORT?
> A. Fixed by "ipvs: filter some flags received in the backup server"
> which is already in the trees
> 
> Q. Can the master itself briefly send a record with a nonzero cport and
> IP_VS_CONN_F_NO_CPORT still set?
> A. Harmless
> 
> 	So, nothing that needs to change the patch.
> 
> Patch 2:
> 
> Q1. Does this make the "update or create" lookup in ip_vs_ftp_out() in
> net/netfilter/ipvs/ip_vs_ftp.c unreachable?
> A. Looks like we need the same check in ip_vs_conn_out_get:
> 
> We should use:
> 	(!p->vport ^ (!(cp->flags & IP_VS_CONN_F_NO_CPORT)))
> 
> instead of the wrong cp->cport check.
> 
> 	Using p->vport and not re-reading cp->cport above due to
> tricks in ip_vs_conn_fill_cport(), see Q4 below.
> 
> Q2. Can this lead to a new connection being created for every packet of a
> flow started by a real server towards client port 0?
> A. I can provide patch to ignore packets with port 0.
> 
> Q3. The commit message assumes that only templates and NO_CPORT entries have
> cport 0. Does that hold for ordinary MASQ connections scheduled for a
> client that uses source port 0?
> A. I can provide patch to ignore packets with port 0.
> 
> Q4. Can the two separate plain reads of cp->cport in ip_vs_conn_out_get()
> see different values?
> A. We can check p->vport, see Q1
> 
> Q5. TEMPLATE and NO_CPORT
> A. Fixed by "ipvs: filter some flags received in the backup server"
> which is already in the trees
> 
> 	There is the option to create 3th patch "validate vport and dport 
> in received sync records" in your patchset, so that such change can be 
> propagated together:
> 
> 	} else if (!param->vport) {
> 		...
> 	} else if (!dport &&
> 		   (flags & IP_VS_CONN_F_FWD_MASK) == IP_VS_CONN_F_MASQ) {
> 		...
> 	}
> 
> 	Because it depends on your "ipvs: validate cport in received sync 
> records" patch. Such change will prevent sync messages to create
> connections with port 0 that can be later hit by packets with
> port 0. But may be such change is not needed.
> 
> 	I can provide a separate patch that will disallow connections
> with 0 in cp->cport/vport created from packets. It will not conflict
> with your changes.
> 
> 	After correcting the check in ip_vs_conn_out_get() lookup misses
> caused by client port 0 can lead to scheduling for every packet and 
> creating duplicate connections. The main thing is to isolate cport 0
> which for the backup server is already in your patch. The remaining part 
> is to filter it in the scheduler. OTOH, the vport/dport checks are
> just nice to have. The rule here is, if we do not match cport 0 when 
> NO_CPORT is not set, we should also not create connections with cport 0.
> As for the zero vport/dport, I'm not sure, they look harmless.
> What do you think?

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-1168736756-1793682309=:3469--

