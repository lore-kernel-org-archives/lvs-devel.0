Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793720355;
	b=fve/xCVR3ZvA31NC02XNpph56dcW1ouVHg4VwgA9kZp37GHTxrn7idQky5U6A1+9kMSj
	 7GkRJLSlb+MpuJ2oks0SwHjVIVxTg71iPpdFt/Fl2aShgbcBfSO2AQw0B8yVIbciAk02n
	 kFPQt+Et8zROr1XLvKp8Uebwr8G1RAyVaZoNUtpS1SnippuTm/YEe0ooXshAVkV4MSZQR
	 IpH1RFCmVXpzuAdX2Jk0jRDhM4xb6M7lEaLuR0SJpJnUF/cp0fFU/5RvetQEYPfssq45X
	 RvIzLSP98AKFoYyd9g8N1HmT06GlqKR1txy9++T28PlDuMi27Stvut8q/7wnwA3y03w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793720355;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=mhKgjBTtEa3A7AVgCuznDbXkGirC0vT/i1+KnVwVNWc=;
	b=EA9oF8ws6/FG4lE1my4Epu1rH+yE8KXnLN9Cud1Bsv2o94MDheaJXYJEuFFeUjql9fCf
	 YGfnAzykXH5E5A3LdP7rxgY3xXWMydT6I+Hzzoj6dhq17Jxqsa2NuSu60Ty7DU6uBUs4a
	 pbJgw9mERYZFkrgx4hQgM8XpnWol7Ri1V7W7NVHUr51pftTqLdtI0ENmjXqkdqzsomKu5
	 OhTPOkpMo8X6tAgRcPm1XvPHCdvFIbWw3W7LdgrIknoeMyzjLWeprlEtCJvK1+QiiciUo
	 BAl87nwMO/Dncq3rhXbpFGH4Xq6BUcTvfByKikUNL0ESyFX+NclBYg4hEHXj40IQHwA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=rtkSaCSt;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6CC89606A327;
	Tue,  3 Nov 2026 15:39:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 6CC89606A327
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=rtkSaCSt
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id EA07B21F88;
	Tue, 03 Nov 2026 17:39:11 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=mhKgjBTtEa3A7AVgCuznDbXkGirC0vT/i1+KnVwVNWc=; b=rtkSaCStoMyg
	u/mhBbVMgbHC0FxrHFLwoHhZ93IheWjTnmSODYNLeWpBOc+//tSQYe9jrLYiPywV
	3s72EVb/6srY0hp8P7hB3LOGMDMLUvthaLw+CHKX6y5IjSagY+VGb3qe9PoiIj+K
	iCbUeAnQyK4GSwI/9s/+TF/InsHh6A30NnLs1J90QT9DHXFKvhZC8xnvBw0HU/5U
	zrZ/gZ//Qh7d8N3VifRpQmEAYqvmgtMjr1UT8JqTb2vObUAYFFAP2PO0TyLATSeJ
	UeNCb2OG+J0uEDNr+i4r/CBbBe+LkhJvNVDfVCDBFpeG/WraOl+sU20Wy2H2kL2X
	Wsv4DwI7Ts9qZgYPxrXnflv9bt5yJHneTvkKPOxNANlN2RFpmej/d+bh7ZVD7bSO
	Lk2Tzof80L24xsJMPOuWOWU1TiZdZN/kjiJ5Wh3J3jak+TolngQEcS7fndfHnswx
	EBPiwlXw2R9P5bZUST1YewZDmDspmupxYut4h0NIWixRG7/RaDvwVnBMJ9h0PjbC
	vXTdQon0keI+ritjdZ54VpCW5AQl8IQGkfeI4UUKBxRSgMZVXV5alhORbpCQvjeE
	TSzQJfI02vBV5FK6bXnvMwx2VAeh9qTt5MIq6t68CIibtMGJKSR6X3KcZkamQaa8
	7p/tWUjQUNHcm+GB5fgBkjPWOsCHtHk=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 03 Nov 2026 17:39:11 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 440BD61DE8;
	Tue,  3 Nov 2026 17:39:11 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6A3Fd86d061930;
	Tue, 3 Nov 2026 17:39:09 +0200
Date: Tue, 3 Nov 2026 17:39:08 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Axel Mierczuk <axel.mierczuk@1password.com>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        Willy Tarreau <w@1wt.eu>, Keith Hoodlet <keith.hoodlet@1password.com>
Subject: Re: [PATCH nf 0/2] ipvs: keep templates and cport 0 conns away from
 packet lookups
In-Reply-To: <CALb1hrkiDXhnAgbfPZ0sus-uPu+NjKYQuUEbDkmD78KTxy_-VQ@mail.gmail.com>
Message-ID: <160537ab-b47e-dfd5-c887-ba5d01466ca3@ssi.bg>
References: <20260925141115.16126-1-axel.mierczuk@1password.com> <002e2c69-ae17-4321-ba3d-74cca0e57123@ssi.bg> <CALb1hrnMJGj5ePZSB89ZW0Uv_oNpepeqgAmGcZxRsLyv64HOYA@mail.gmail.com> <f87eab0c-253a-2d5d-d2e6-f4fb691c9813@ssi.bg> <bc3597b9-9fd9-692c-76ec-90904c787d2f@ssi.bg>
 <CALb1hrkiDXhnAgbfPZ0sus-uPu+NjKYQuUEbDkmD78KTxy_-VQ@mail.gmail.com>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-2044068999-1793720350=:59492"

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-2044068999-1793720350=:59492
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hi Axel,

On Tue, 3 Nov 2026, Axel Mierczuk wrote:

> Hi Julian,
> 
>       Patch 1:
>       [...]
>               So, nothing that needs to change the patch.
> 
> 
> Agreed, I'll keep it unchanged in v2 with your Acked-by.
> 
>       Patch 2:
>       Q1. Does this make the "update or create" lookup in ip_vs_ftp_out() in
>       net/netfilter/ipvs/ip_vs_ftp.c unreachable?
>       A. Looks like we need the same check in ip_vs_conn_out_get:
> 
> 
>       We should use:
>               (!p->vport ^ (!(cp->flags & IP_VS_CONN_F_NO_CPORT)))
> 
>        
> 
>       instead of the wrong cp->cport check.
> 
> 
> You're right, the cp->cport check breaks the ip_vs_ftp_out() lookup.
> I'll use your check in v2 and fix the commit message.
> 
>       Q2. Can this lead to a new connection being created for every packet of a
>       flow started by a real server towards client port 0?
>       [...]
>       A. I can provide patch to ignore packets with port 0.

	Just to let you know, this patch was already posted:

ipvs: do not create conns from packets with port 0

> 
> 
> Agreed, that belongs in the scheduler. Note the in direction already
> behaves this way: __ip_vs_conn_in_get() does not match a cport 0
> entry without NO_CPORT, so a client with source port 0 is already
> scheduled on every packet. Patch 2 only makes the out direction
> consistent. Happy to test your patch.
> 
>               There is the option to create 3th patch "validate vport and dport
>       in received sync records" in your patchset
>       [...]
>       As for the zero vport/dport, I'm not sure, they look harmless.
>       What do you think?
> 
> 
> I'd leave it out. Those entries can only be hit by port 0 packets,
> which your scheduler patch stops at the source, and keeping the series
> to cport keeps the stable backport small. 
> 
> If you prefer to have it, I'll add it as patch 3.

	Better to skip patch 3 for now, only cport 0 is important.

> I'll send v2 as a fresh thread with a link to v1.

	Very good, thanks!

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-2044068999-1793720350=:59492--

