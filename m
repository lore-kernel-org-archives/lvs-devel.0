Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.160.179
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793725161;
	b=WWloWps487KLK8qToWigV5clb4XgL437Yb245eOADGIHBZeFvcUAkZggvj/RkgCa5Rzj
	 c5k5mBJOnYvwPJam05wdMElpY01LBwO6HeuDrRS4aNs23NSJ47Qj39OTWeQyNatxBuH1V
	 yaUUqCxap6xD8EozrXD9bSj+x/ub8bG9IBuG5HDvspFvNTvudlH3aJ5kT64W4NDxwf3T7
	 XakbhRYCUb7jnV82xTbqWWGZQZlO0zmwuwHO5tvY/16hP8g+qCQAjqgpNf7+KBHR21Rvm
	 RmkUhKs8OPs4mbBbMgPjNd2DOToYM60cHmYHj7wRtElktJilWuht+eR2ZxenhcFWoLA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793725161;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=x1NI3skowoAtNdcXptzYo27srndyE5ZnDqWHrHmy4U4=;
	b=lyCh4BDN7cqOz/1ZzbfCJxUZNCPYmVPO51aPAHimcIJ+gxOXmGiDQLFxHCNXpO8u5pYA
	 T254XHLtr5HksqkwfxGlo2qePVwsqMAqtgonx5AoizwBJfHu7LyfXgo/HREiXkQGPQO2+
	 2WaG//LUmVRJV3Jyy5BNH/Vf7HidXeVowlHLptR7OYDl7OycRJgHBurcHdsXH7CGlUHZb
	 UpE0fskHMMzuT9Yl+PxkZGv0Y2KulVtLetGzHLIyvb4NN6RrxR827CKXAYbKTgbQWE3mK
	 JgrNiW7sYMZgsV82V2REWuHQc8rNyeuYK0LQ8VPKYPWZO5nlx9Ntfw3Wojl2AP+JXBw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=1password.com;
	spf=pass smtp.mailfrom=agilebits.com;
	dkim=pass header.d=1password.com header.i=@1password.com header.a=rsa-sha256 header.s=google header.b=HvE6CnDk;
	arc=none smtp.remote-ip=209.85.160.179
Received: from mail-qt1-f179.google.com (mail-qt1-f179.google.com [209.85.160.179])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BEC19606A33A
	for <lvs-devel@vger.kernel.org>; Tue,  3 Nov 2026 16:59:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BEC19606A33A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=1password.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=agilebits.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=1password.com header.i=@1password.com header.a=rsa-sha256 header.s=google header.b=HvE6CnDk
Received: by mail-qt1-f179.google.com with SMTP id d75a77b69052e-5364d86f7f0so60495111cf.1
        for <lvs-devel@vger.kernel.org>; Tue, 03 Nov 2026 08:59:20 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1password.com; s=google; t=1793725160; x=1794329960; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=x1NI3skowoAtNdcXptzYo27srndyE5ZnDqWHrHmy4U4=;
        b=HvE6CnDkjqXySwNnSQZMyeD4DSmhSNJZ5RuJy5b40IJ8vc3t7iydK31t81eeeIpz0e
         ZBLyyMJH+Z3iDY+sb0OebSLGqPrZy9R9RhUXkFrBvJT0VjU+YQ6c1S/inFLyGnz3EY9t
         Bdaj8s+/76t7301785EuSYGoocmPSroSPJJNI=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793725160; x=1794329960;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=x1NI3skowoAtNdcXptzYo27srndyE5ZnDqWHrHmy4U4=;
        b=lpU/dreJCvbfY462nqtLtFSy4KfQwRO7okh09SwXLhvNOK7J5GIEKpmTJQuNxc4veL
         LHEIpjpKF0l6px3tnUDKHtRxHSh4+GEQsoQ2LpFFjf1N1rPFHHePmRqu7Ywgeb/BaUyQ
         zK1Ejpp8BDUEtLY7AEJ1BFiTOeEONtZnnlR8D0Rn0SAIjPnECTLMnprI8V8GjFYHNNUa
         DU7o19CDg7VyrD//cKtlYDg9pPmO/X2GJPEihtPJhAAu8UDP3ke9D/VVqUhbIWUyWs5H
         Q5dKkSqOZ74qcSAdznmgUd+/JN20ULlM5zi0dR5bj/kBjxNPCyWTpYFJClkaYP7H4TVp
         xsRg==
X-Forwarded-Encrypted: i=1; AKwUvBym/jyQXynrtTdzU/HvzAeWz3YDD4c3JVmt1A4hjHkcpn7sxNF/TYvrKtoPCu3bopnB7pDxpDNSE/Y=@vger.kernel.org
X-Gm-Message-State: APuU4Z93DZy60UdurVUKF0n0NzAacPEO/1YdNe4SxlRGxyp1gxK4ZWmy
	3ECxjRUnYFjImQVE/5jITrk65kNGx3y58O8tJessIwe7difMobUWd1+pkMe2LSenGR0=
X-Gm-Gg: AYBFou32HP2eKIuOv+mqSxe+kSDOffO1AabSDT7nPmNam3Sy+JDKmTDHsbZFLBC8hLb
	AxRXvq9zr5vC2UZjMqoZpdWHmVRpALrHpuC9uf2LmvjixUcR+Bi4/d3dBGIrvsJ+ijhW8PeEwHF
	N/4Sjiis07OHUleY52+A18wA3f0iIT7rA52qNK2FFMfn4ALOQPgGAdbppMCqmQMhkNhgjTFj1NR
	Y+NektyP2UI10pJukk/mcRU15QQLXhm6kTEoIwlxmSc/12rqjCmz0zE7eyXpj4IZVVV2w1RNgQ7
	mkZ1zbnMLLYYsimI7s75tpxHENcXpRbEn/ZFFyaXiCKvMll22oO8CUhiK7h3iG8ZbY6F6qoyKx5
	DwYVT9Tu1JqdHOrjZ0IQeDZC3XKn0WABPl5/9zmN2mGcFX2wX7MBlR1PSMC0gCu/Lz2x3v+wfMW
	sB86vhD4cKIM/Q1Km97Jk78oYKAqo84+l1k8XiuVbuYXEt4u/6vzAzUoZBwc05VDlQg6oAPihX9
	kNpPPLTe1iPdn8MKSFilCboLYGNDQYgnl/Tv0qB3E0DdUyhKjyS0sPk2Wc+7EtuNUGXuj7PF8Rq
	oqZGdnjv+II2Its6hkTB2xILQG9z0AAytQFUbNfSZU+rsZGb3NMenOxlAFMq
X-Received: by 2002:a05:620a:4385:b0:93e:5eaf:dd87 with SMTP id af79cd13be357-944217c1057mr2138536485a.62.1793725159609;
        Tue, 03 Nov 2026 08:59:19 -0800 (PST)
Received: from localhost ([2600:4041:59c3:300:a850:2af1:eb93:4121])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-91ca8066ba4sm120593986d6.33.2026.11.03.08.59.19
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 Nov 2026 08:59:19 -0800 (PST)
From: Axel Mierczuk <axel.mierczuk@1password.com>
To: ja@ssi.bg,
	horms@verge.net.au,
	pablo@netfilter.org
Cc: fw@strlen.de,
	phil@nwl.cc,
	netfilter-devel@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	coreteam@netfilter.org,
	netdev@vger.kernel.org,
	w@1wt.eu,
	Axel Mierczuk <axel.mierczuk@1password.com>,
	stable@vger.kernel.org
Subject: [PATCH nf v2 2/2] ipvs: skip cport 0 connections in ip_vs_conn_out_get()
Date: Tue,  3 Nov 2026 11:57:46 -0500
Message-ID: <20261103165746.39516-3-axel.mierczuk@1password.com>
X-Mailer: git-send-email 2.50.1
In-Reply-To: <20261103165746.39516-1-axel.mierczuk@1password.com>
References: <20261103165746.39516-1-axel.mierczuk@1password.com>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

ip_vs_conn_out_get() does not filter templates. A template with
cport 0 is matched by a packet sent to client port 0 that traverses
the out hook, and handle_response() then runs ip_vs_set_state() and
the timeout update on a connection that must never see packets. A
backup server receives such templates over the unauthenticated sync
protocol. An ordinary connection scheduled for a client that uses
source port 0 has cport 0 as well and is matched the same way.

Apply the rule used by __ip_vs_conn_in_get(): a lookup for client
port 0 matches only connections flagged IP_VS_CONN_F_NO_CPORT, which
still wait for their cport, and a lookup for a nonzero client port
matches only connections without this flag. Test p->vport, which was
already compared with cp->cport, instead of reading cp->cport again.

ip_vs_ftp_out() relies on the first case: it looks up the data
connection with client port 0 to find the IP_VS_CONN_F_NO_CPORT entry
created for an earlier PASV or EPSV reply. That lookup keeps working.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Cc: stable@vger.kernel.org
Suggested-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Axel Mierczuk <axel.mierczuk@1password.com>
---
 net/netfilter/ipvs/ip_vs_conn.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 94f25fb7d87e..29cbe797bb86 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -579,6 +579,8 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
 				    ip_vs_addr_equal(p->af, p->vaddr,
 						     &cp->caddr) &&
 				    ip_vs_addr_equal(p->af, p->caddr, saddr) &&
+				    (!p->vport ^
+				     (!(cp->flags & IP_VS_CONN_F_NO_CPORT))) &&
 				    p->protocol == cp->protocol) {
 					if (__ip_vs_conn_get(cp))
 						goto out;
-- 
2.50.1 (Apple Git-155)

