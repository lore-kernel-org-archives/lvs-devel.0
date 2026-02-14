Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6412B1E376C;
	Sat, 14 Feb 2026 15:09:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771081776; cv=none; b=izPnev+bQ//zmG+47x4/g8dx+Qqa6pS9ZFCk/e8CVGV/nwWiXD9eKzVQmc1nrPFtkRM5+Dz5BbKzenXlTZIUUErn/VNarWhSV335qE4qOcdYv1SkUQ3Wr/pixniaxc7zWrL1i0K4j7YEcSOGReJFxBAcGSsIhjMqHWZlxgZsU2A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771081776; c=relaxed/simple;
	bh=0eX+p3+geX4OS8tVhnoo2fzcDybCRkV9Yef+GnOum+c=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=m1EzRhtnDSviBM8NVNJRPlFzb4DvLiIMFEKGIKsYpwdHMvSfP2IH82tptfQUsxjf4AcFCgDUWBzoud7L5VCCGs3WXdCmg82N18EJ58xXVXWELh8AWQtXWopHBmCpA6aROHDmBw3baVqgcypXBEwmIK+LBhjNILiKMHAjt3pvlnM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=TiL1LOfI; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="TiL1LOfI"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 2A0E021D61;
	Sat, 14 Feb 2026 16:59:30 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=BWgNBQUg
	CuiBoKaIWiaLkSQ41+DWeR5GDSn+Qm/jS3Y=; b=TiL1LOfI5nVhVVHYQUkjfbW5
	aMhQ7xkSLDS4ugWqdhc/bRb9RZys6UdIU9wOQUZHhS+jJFB4WN7godcW8iwTW2j5
	A0JYpt8LEIbgcOvMmBsSqHcyfSpz9cVOhAm50tGz/TvTqwePZ/ZrlnD6VxAIIsds
	Vb9NLQWjLLYnBf9HrsyJDsEKuYs+nm8T95nmt3NFOU+zoPJwqnsCg02dfUnw+OWb
	LczfoUJXhy/4VghZOqUAgk5weWh0udDcGZ9YgzlykUtswimAgNcU1tfmO2/MPDEC
	McU+lXEhxrIOl7iymKQLK1v7ExYfsxiNRxuvFrXc2G+OTF0FWZvqZ9rKW0qps+xN
	3U8xSTsCS7IONUuzC+77kIRl/cVfwiXgzOJfRrojehqTVFI71w+PVrrNGPmcsk6y
	W/8u6j6JWp4iWcaI6XXov5eS6f2UGAObAv1kE43gJqHb45o/9nuKUdpC7dtH7mFj
	08YF0nVPQExSSJXXp4NHzWRqJkm7n2GDvoA4fyj0bO/bFLL9h+RgKiE8dNL4EOcI
	mXT9tknLXS0ShLdWKbdROSSrXW1QUZLYrntAvyXyxJEZjgiy16fys89CTWhdS8Ec
	VOjlxMw8oPTnTfPu2ERFV1SkA7HDIp4rrDmQPlTOkAR3S+tjN7tY/wXJDZHoElSe
	2ur1ti0NoYjEzNnkHSw=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 14 Feb 2026 16:59:29 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id DD93B609BE;
	Sat, 14 Feb 2026 16:59:26 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 61EExP2J018151;
	Sat, 14 Feb 2026 16:59:26 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 61EExJRs018149;
	Sat, 14 Feb 2026 16:59:19 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>
Subject: [PATCH nf 0/2] IPVS changes, part 1 of 4 - fixes
Date: Sat, 14 Feb 2026 16:58:48 +0200
Message-ID: <20260214145850.18130-1-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

        Hello,

        Here are 4 patchsets of changes which are result
of the split of the work "ipvs: per-net tables and optimizations" last
posted on 19 Oct 2025 as v6.

        This patchset is part 1 of changes that accumulated in
recent time. Both patches are independent bug fixes for the nf tree
but only the second patch is a prerequisite for the other 3 parts.
And this second patch includes part of the code that was present in
v6/patch 5.

Links to all 4 parts which are on https://ja.ssi.bg/:
https://ja.ssi.bg/tmp/rht_split1_p1.tgz
https://ja.ssi.bg/tmp/rht_split1_p2.tgz
https://ja.ssi.bg/tmp/rht_split1_p3.tgz
https://ja.ssi.bg/tmp/rht_split1_p4.tgz

Link to v6 of the work these parts are based on:
https://ja.ssi.bg/tmp/rht_v6.tgz


Julian Anastasov (2):
  ipvs: skip ipv6 extension headers for csum checks
  ipvs: do not keep dest_dst if dev is going down

 net/netfilter/ipvs/ip_vs_proto_sctp.c | 18 ++++-------
 net/netfilter/ipvs/ip_vs_proto_tcp.c  | 21 ++++--------
 net/netfilter/ipvs/ip_vs_proto_udp.c  | 20 ++++--------
 net/netfilter/ipvs/ip_vs_xmit.c       | 46 +++++++++++++++++++++------
 4 files changed, 56 insertions(+), 49 deletions(-)

-- 
2.53.0

NOTE: I'm currently posting part 1 for review and applying
and part 2 for review. Even if part 2 can be applied
separately from parts 3 and 4, I prefer parts 2-4 to be
applied to same -next cycle. Just let me know when
should I post the other parts 3-4 for review.


