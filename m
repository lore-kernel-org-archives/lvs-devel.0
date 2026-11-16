Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794843687;
	b=OS6RhQm4RGQp43V58sZhel3Uib4jGbTu9NdWruBHn0lHQCvep7zM5rms2THzD/0ycyz8
	 Xdkxz4hnHl8iN0tBdHQbLPzJAvH/oY/FpcZ70LJhCD+gBGgRIISgciJWxTvSlZF4PpQDB
	 em2+me89DH3yIIM5NG118QLnzok9iGmbP5DG+pzG40jc9qPgKIiVPwOQD4E/XYLWXEy93
	 C+MfGmAuqBLutP3ioHe5RQ46tS1thpnxYSDhjzPUcpcIX6J0nef/NjuJs5AXwXB5GBLzN
	 mUICMDZzMujBBntTQ0WKE7QU/F35CNKyQqmcQ2ruHJNsdoLDAlsrWUxb7S2WmSnQCpw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794843687;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=W/Ym3u4usM4ArSt2EhaBMBkXZ0AvTiTm9s1YVFwTSto=;
	b=HZV50LSDSLAJC5hXZHws+xjUSCTsGlazDzOQky7dMsAorROCBy8bb+8UHMT2kMIVNGeO
	 Ein6vurYnkHDRw5YTwwd6FmrTBoZ//qgx0Nxn1vDWlMoRIRV7jpnNzoHMgiAdywoNMrSU
	 /mLDV36UKCaP/SwGxJLVORb3ZDJbaCO/52DIOxjAEvIige2fbiS69N014R9vbYA5r3y8k
	 KdrtrobsM1Mc47rXnShmIA4GBRy/+0SZ3F3liBlHPsDg3A5pzZX3GfJRmMerYmQAuER+D
	 n/HRK/pLoo5JLqGZcQFt57TVimJ2p/1IxDYZ1JoX0nLl15Hk0SQZbmB+Yu7e5x0YXhA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=YYrhCjGJ;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 26EEE606A31C;
	Mon, 16 Nov 2026 15:41:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 26EEE606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=YYrhCjGJ
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id C3DAB21B52;
	Mon, 16 Nov 2026 17:41:17 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=W/Ym3u4usM4ArSt2EhaBMBkXZ0AvTiTm9s1YVFwTSto=; b=YYrhCjGJ1ikC
	4u5g9qFaxvjjIgwvHb2kLdkFC4YIJJtt+K09RY9FM/9eW2qpRDguxL79bc99DhmA
	/gCMhIvoRVD1Sh8fEDFsFRBNqQaDdBRbXC1OxGVOR4NQYSnzhsvpshz9d/ARpcOD
	8s+LXScD9eUcDgvY7fbdQensJjCdpcHTUc9lQjilVqT98EafBi6oEUOUVkaVqQhd
	XKkKKCQzSvZ91OqdC/Pafx1cy4Gg23MGFbJIGcsSBtDSHvoVuYgE1Wbm5DKPPees
	RIzLEwiHQRdvmheqBZB8wqGyZGOmTKnVI4ywy0gooyDJv+zpM/ahamAMZYkyG6e+
	MFCjh2CJL+FFpwZO3y0qJVSjdIIIOuqDWM59Rs2fEuzUpP9490iKb89MOVD3kQlD
	V/GKs5uQ+5qk8aJNSKiLiKqzgSW8Zd0tdYlQ3MG4vmLOGYySLIIFcUyMUCcjGPXi
	p9dYgVgkjPx7f+eoTP3lVcyd1hIbQlWyy9dhHiAsCahuDEcPVy1XJW5NB6+702+3
	bkYfDlWMIzgZl4JhP/hO1O0TBJt+JpDaZebtiNDHezfUW1eE827uj9QxWUoNOCNT
	zHppA0ycefDfoREwgOA2pwQ+6oIscrlGc4PZi5c9TSW8br8O84EILVqM8Eh6yHNs
	2116gZmx75r7ZYYeHizAq8DQLNyw1pM=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 16 Nov 2026 17:41:17 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 5F05B60B48;
	Mon, 16 Nov 2026 17:41:17 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6AGFf59c081465;
	Mon, 16 Nov 2026 17:41:06 +0200
Date: Mon, 16 Nov 2026 17:41:05 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Theodor Arsenij Larionov-Trichkine <theodorlarionov@gmail.com>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Simon Horman <horms@verge.net.au>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        netdev@vger.kernel.org, coreteam@netfilter.org
Subject: Re: [PATCH nf v3] ipvs: ftp: do not link expectations to unconfirmed
 conntracks
In-Reply-To: <CAEZyMPB+oNBrnxV09Ji-Ao7Bcs93Qg=qx0B_b=3ULFx3nEFo+Q@mail.gmail.com>
Message-ID: <2bd179df-abde-19d7-0bd4-996b7adcc5d7@ssi.bg>
References: <20261116101506.98853-1-theodorlarionov@gmail.com> <avrgKSO8nfTnv4iL@chamomile> <CAEZyMPB+oNBrnxV09Ji-Ao7Bcs93Qg=qx0B_b=3ULFx3nEFo+Q@mail.gmail.com>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-845209124-1794843669=:8917"

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-845209124-1794843669=:8917
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hi Theodor,

On Mon, 16 Nov 2026, Theodor Arsenij Larionov-Trichkine wrote:

> On Mon, Nov 16, 2026 at 1:51 PM Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > I think this is coming a bit late?
> >
> > Maybe it is possible to check this earlier in this path?
> 
> You mean returning at the top of ip_vs_ftp_out() if the ct is not
> confirmed, and letting the packet through untouched? Or even before
> ip_vs_ftp_out() gets called?

	Early in ip_vs_ftp_out but you have to base this patch on
top of the template fix:

ipvs: ftp: skip conntrack templates in ip_vs_ftp_out

	Or to wait it to be included in the nf tree.

	Then after the:

	if (cp->state != IP_VS_TCP_S_ESTABLISHED)
		return 1;

+	ct = nf_ct_get(skb, &ctinfo);
+	if (!ct || !nf_ct_is_confirmed(ct) || nf_ct_is_template(ct))
+		return 0;
+	/* seqadj extension not created by original packet? We usually
+	 * add the extension for the first packet in ip_vs_update_conntrack().
+	 */
+	if (!nfct_seqadj(ct))
+		return 0;

	I.e. we want:

- ct to be present
- this should not be the first packet (nf_ct_is_confirmed)
- should not be template
- the first packet should create seqadj ext before confirmation,
in ip_vs_update_conntrack()

	By moving it early we drop the PASV response without
creating IPVS expectation (NO_CPORT connection).

	I hope the above is correct :)

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-845209124-1794843669=:8917--

