Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793682474;
	b=3yN4c8Dq4es9nIqbaBBM8d6ucOIHZHNtgtqJffBte8C0IZkgv01TXrF6Jyuq9H11rxZm
	 Qx91HgeBOAqGoR3ObNSunVNAVLZnnPiOT/uZGHA1qEruiOYKod8KKUKiQGTSxSlenw/RL
	 8SZ/rUkyT56qazH3BIbq4AtxKpJHE0B5tWC1VRZZ7B7rhDZDbWSQLkSYGXaKLQiTbShil
	 MbCB6rifQncq2dEqecXVE0WeoygY8fMWqg8VrI4WZ0xNx6ermubTHNF3pwSNPLsMYnyiN
	 yIDKNLArNsPmh/oQ/SH2QTOWFdvEedS2DJgeq1Ac0PpK3vFkGgRAJGWUzCdwocjjfHg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793682474;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=SFlEIXtfeBdCi4j7U4HZAVeWwarSZTrBIgJfQrtcCCE=;
	b=VDXJGD1LXrctLuEKUT9bHsFMc9M6C9JbpqgJJJlTBcBB2pkuHjkbWAC9kpR6L9EQAQGG
	 RrO7gM1LUo4Mw0oWAz5i7sMajWq8z/Y+qQBrvYdaRaED29s6masP6x7SJJyFElSCj3yng
	 yUZnbBSut/11RpnWhmG6dpUUu0nOls+nmouV1nkI/gRlY7I2F2Y/h9RQnip/CKOije+O6
	 vnPSRspnF3eXjVYX+keRq0/SbjBsDRck9N6+agsOmqYwdgbseh8RFP15AUf9eViwCtKV6
	 zEMe+2ygBxq2d1xgeQ7Q00dxdC/Bo0hl+JJsxSBp9ovxmaQxQ/NH4QTiT8XMYJPj1Hg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=pT0cdI18;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EE63E606A324;
	Tue,  3 Nov 2026 05:07:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org EE63E606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=pT0cdI18
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 86B6A213E3;
	Tue, 03 Nov 2026 07:07:50 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=SFlEIXtfeBdCi4j7U4HZAVeWwarSZTrBIgJfQrtcCCE=; b=pT0cdI18E7g4
	e/tMOQO9eOeTfUFzTQDLnlFJWfVjEWQ07znvVAWpgpPUXKB7XwiAq/rtXZin1Vf2
	nZ+STny8kgtlW/YmrKFmv2Lefb4OIeMZj2a2TINH8r3pL4EZtkWS7kBI9tlnJJdU
	gq0RKwGCq2uzq66X/PrrZb1glghhi8aLbmTYG9HlxLABeJ8YdMN/NqcaHEegLDbB
	NRY/UwaWpBSLwvSfnEYuEYPV0o5FBnO+dMvSKOrS400QLVJC8NoTaPIy/MrE8Eh7
	GR1OL+ySjFQGiLGaODkk0eQQaxquAMd6hS7JzzMh6Ab+9xC+h59PwrIQQq22VdrB
	LlP44HNeRtg0Z7Q1Hczbxh229sklv3N3RhRF2VxdH3zb1QGnQKQNcl3Jlpi4YriF
	vR14BFCTV2pJWFOQ64DmQ20phGqV2Al3Agg5i936t1qCLoa2By4EaeeveBTPrt6Z
	7ozdRH/HmLziNOTfR8hbrJ65qoIZtAPC+ny5FoDvpQKGg4wre+VaJhgx5Hr8m+Q6
	PD1XeFUCJ3SnPV9v8rpSoweti/DNgvc+ixVPpCI895r57BxYv7yzm61NqKWyPvTu
	V3hmV+koSH+rBlzcojDTXG/5cwYWhO0sONptgS6qHEM0DE9KF8pRoI7RHL981fD9
	sWFLMTrW/s6ig3mg/7tfrv2vyyFbPIs=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 03 Nov 2026 07:07:50 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id DEB7261E56;
	Tue,  3 Nov 2026 07:07:49 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6A357lWt006288;
	Tue, 3 Nov 2026 07:07:48 +0200
Date: Tue, 3 Nov 2026 07:07:47 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: =?UTF-8?B?7ISx67OR7LCs?= <tjdqudcks0424@naver.com>
cc: horms@verge.net.au, pablo@netfilter.org, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        stable@vger.kernel.org
Subject: Re: [PATCH net] ipvs: prevent LBLCR destination leak after entry
 expiry
In-Reply-To: <3ed677db-8c85-a603-6c9e-3cf21535a488@ssi.bg>
Message-ID: <633084dc-adb3-27f8-a702-509adff2258d@ssi.bg>
References: <20260929170747.503223-1-tjdqudcks0424@naver.com> <3ed677db-8c85-a603-6c9e-3cf21535a488@ssi.bg>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-1102736379-1793682468=:3469"

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1102736379-1793682468=:3469
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

	Ping after 1 month...

On Wed, 30 Sep 2026, Julian Anastasov wrote:

> On Wed, 30 Sep 2026, tjdqudcks0424@naver.com wrote:
> 
> > From: 성병찬 <tjdqudcks0424@naver.com>
> > 
> > ip_vs_lblcr_schedule() looks up a cache entry under RCU before taking
> > svc->sched_lock.  The expiry timer can remove that entry from the hash
> > table and erase its destination set before the scheduler takes the lock.
> > 
> > RCU keeps the stale entry itself alive, so the scheduler can continue and
> > insert a new destination-set element into it.  Since the entry is already
> > unhashed and its set was already erased, no later path finds the new
> > element.  Both the element and its destination reference are leaked when
> > the parent entry is freed.
> > 
> > Recheck the address mapping while holding svc->sched_lock and update the
> > set only when the hash table still maps the address to the entry obtained
> > by the scheduler.
> > 
> > This was found during an AI-assisted source audit.  Diagnostic-only timing
> > instrumentation forced expiry after lookup on a two-vCPU x86-64 QEMU
> > guest.  The unmodified code inserted into the stale entry and left one
> > element outstanding in each of three runs; kmemleak reported the related
> > allocation in one run.  With this change, the same stale-entry condition
> > was reached in three runs, but no stale insertion or outstanding element
> > remained.
> > 
> > An unforced 679-second run processed 65,536 marked packets without hitting
> > the race.  The result therefore confirms the lifetime leak and the effect
> > of the fix under forced timing, but does not establish practical remote
> > resource exhaustion.
> > 
> > Fixes: c5549571f975 ("ipvs: convert lblcr scheduler to rcu")
> > Cc: stable@vger.kernel.org
> > Signed-off-by: 성병찬 <tjdqudcks0424@naver.com>
> > ---
> >  net/netfilter/ipvs/ip_vs_lblcr.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
> > index f53f05ceea36..ef18f3c9d5da 100644
> > --- a/net/netfilter/ipvs/ip_vs_lblcr.c
> > +++ b/net/netfilter/ipvs/ip_vs_lblcr.c
> > @@ -686,7 +686,8 @@ ip_vs_lblcr_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
> >  
> >  		/* Update our cache entry */
> >  		spin_lock_bh(&svc->sched_lock);
> > -		if (!tbl->dead)
> > +		if (!tbl->dead &&
> > +		    ip_vs_lblcr_get(svc->af, tbl, &iph->daddr) == en)
> 
> 	ip_vs_dest_set_eraseall() does not update set->size, what if
> we use atomic_set(&set->size, -1) there and to check it here to
> avoid inserting dest into dying en? This should reduce the time
> while we hold sched_lock.
> 
> 		if (!tbl->dead && atomic_read(&en->set.size) >= 0)
> 
> >  			ip_vs_dest_set_insert(&en->set, dest, true);
> >  		spin_unlock_bh(&svc->sched_lock);
> >  		goto out;
> > -- 
> > 2.43.0

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-1102736379-1793682468=:3469--

