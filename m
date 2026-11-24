Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795545663;
	b=c+FjaQ5ShhtpRsZn6aQD7HdzOe4NFpUG4q7zMREnAnFsrsH5JOjSv4UbN1VjsY2wXphc
	 67i7qguDTdZhwQ85jdmsVLrVn1Dqjdyz27yWV5UYCf0D45wjHLc2CIFG1UndXHc378foG
	 Y7ybm7qB4CHJygeNLMLXVLXi2n8S6AdCsyDB7wX9UQZczfeFx9KTiz95gkIGZ14CWyCAq
	 Zbz/JwfQ42H9gxDmlxQ+SrlFyz74L8S/L6ehNzvf7qP7zbic+BaLtWHvjFACnjwaGNxKW
	 AS2iqo6rJRSZHK69GfKbqKF8DD0YSPX4qSM/I3qIkMiCkFN5/4X3ZPhIPHshhrEfWBQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795545663;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=n2qIdbUbrmrO5Tamz1dNoJO2mgm+tzAsUk2d3u3jcFk=;
	b=x4o9HF03FWUcWw1700ya1n6CX/Jb3ARvcZ+RNmaKJQrS4Ioa2r2NQfYAQS3QFl+Ut/Bs
	 xilafgO8vASwm5UyUjXr0HMbnpDZrDtWtN+yJSEK/86UDWUNDH71tC9tYdYY6ntnEG9S5
	 LC2a0sP8edPgGoBaDyc2VxIit1mRBxlAC2o4FQgoqllmhsWEDA4pENG8ocNbfR30TYnPy
	 QGpbHWUxovrfvoOl9VfmtAHBh4cktlrTH6JVUrf+s9G9ccHmf8d2bjh+/p795nIz6tEMY
	 UEMxON1E/3NM+cap5pVEw8z1KFdxI9GT4ItjKpPF8E/PLh5w1lri1GqIqX2BUWiX93g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=0ysjRwJP;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EF53C606A32C;
	Tue, 24 Nov 2026 18:41:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org EF53C606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=0ysjRwJP
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id CBF9621FD0;
	Tue, 24 Nov 2026 20:40:58 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=n2qIdbUbrmrO5Tamz1dNoJO2mgm+tzAsUk2d3u3jcFk=; b=0ysjRwJPWggA
	Gdna5o3RHnBE6nq0tuLC9a7pYAj6NeaTXxEvmiTU8+w/SlfUC3pVdORjFJEkTOEO
	OKjjXAz209lCvNbEGCp0+t8ViMYtr2Qw+jJt9yhVDz/CEZ3+fHCyGdL4zvLB2TVY
	EBaSdPTHQpf2tbYM2nhuPfNLDSUsv5BYYwepJU2iT2Gwi91Hv7jPb7imZrigB239
	QH8sKEUJc3Z9S2GFigBB+aXAxXPsyWoAnapBaH9PQETwLRygc0dgIHDM96jJunmc
	J0ylTFIRSFVzSqIb/wnTXpQ/JadfFLK+oy2g1odlkyDe6JyD3FCc4SX1UFJWHqGJ
	N9MDFdPc/xm/HTVAB63cVoTq4Iuf9xoh0bzKJwhCYFIsgEVEssMy+su4ZW1jQ4q6
	nQ3Fcb8hj/ck7VdykAzd/7KU0xU3kEIup3rY9rcepHMDfMwJHAV2/9TBJ2FHIlFo
	HDHhTIPRq+Ss5dfaOHCaeVlY/srqrwO8KGqgzEEj4g1Bq3TsCbLbvqIxnssKf1ht
	MS3EiXiKCilTbtVlkXHs9fxReev4gjkeaIVaMMcVWCOX0CpEgQ3oSpSnrEANkrY7
	y04lXS9JHtlchUUx48P4dsxu3FqCC62Lzci3hu/F7FoMrkm18/V0+uLwbcV4MCdJ
	vEgum1k1Wrx79plE0HwZvI6C0ffNVn4=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 24 Nov 2026 20:40:58 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 69A7660FCC;
	Tue, 24 Nov 2026 20:40:58 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6AOIesNO124806;
	Tue, 24 Nov 2026 20:40:54 +0200
Date: Tue, 24 Nov 2026 20:40:54 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Pablo Neira Ayuso <pablo@netfilter.org>
cc: Florian Westphal <fw@strlen.de>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org,
        "Zhenrong (Daniel) Gu" <zrgu@stu.xjtu.edu.cn>,
        Xing Feng <xingfeng@stu.xjtu.edu.cn>, Peng Zhang <p-zhang@xjtu.edu.cn>
Subject: Re: [PATCH nf] ipvs: fix connection reuse with the resizable hash
 tables
In-Reply-To: <20261124160226.103532-1-ja@ssi.bg>
Message-ID: <4ef66de3-3942-c2ba-ed0e-d81af26139d1@ssi.bg>
References: <20261124160226.103532-1-ja@ssi.bg>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Tue, 24 Nov 2026, Julian Anastasov wrote:

> Zhenrong (Daniel) Gu, Xing Feng and Peng Zhang report for
> a problem with the reused connections while testing a passive
> runtime checker for L4 load balancers.
> 
> When connection is reused, we create new connection and put it
> first in the list. By this way all packets hit the new connection
> leaving the reused one to expire. This order worked before the
> the introduction of resizable connection hash table which
> started to reverse the order of connections each time the
> table is resized. If the table is resized while the reused
> connection is still present, the next packets will not hit the
> new connection.
> 
> To fix that we prefer not to rely on the order of connections,
> now we will just mark the reused connection with a new flag
> IP_VS_CONN_F_REUSED, so that it can be skipped when the list
> is traversed on received packet. As the reused connection is
> still hashed while waiting its timer to expire, it is visible
> to the procedures that delete connections on memory pressure
> or netns cleanup. Also, when the reused connections are now
> marked, we can exclude them from the synchronization process.
> 
> Reported-by: "Zhenrong (Daniel) Gu" <zrgu@stu.xjtu.edu.cn>
> Reported-by: Xing Feng <xingfeng@stu.xjtu.edu.cn>
> Reported-by: Peng Zhang <p-zhang@xjtu.edu.cn>
> Link: https://lore.kernel.org/all/avx0_13w3xGNdZP8@fxxowodeMacBook-Pro.local/
> Fixes: 2fa7cc9c7025 ("ipvs: switch to per-net connection table")
> Tested-by: "Zhenrong (Daniel) Gu" <zrgu@stu.xjtu.edu.cn>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

	Sashiko has some valid concerns that we can address in new 
version:

https://sashiko.dev/#/patchset/20261124160226.103532-1-ja%40ssi.bg

	As for the packet with sport 0 matching NO_CPORT connection,
this can be fixed separately.

pw-bot: changes-requested

Regards

--
Julian Anastasov <ja@ssi.bg>

