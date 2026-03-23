Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 10F513C0610;
	Mon, 23 Mar 2026 16:36:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774283803; cv=none; b=mTQe7ACSX5su/qAnHfsTv6p/OOCalC9Vhu+n1cLFFh177wg6lxs5ebRJFQgu7sW/SfvWljmyW4r7DLuQZuZhQsuAVEfYFdb9uYAGNxou8Li6iuottg6zXwNIMUdUjFyZfyN/+Np3zWvq9/O4OvUHBHC9xTOVeGRAh30XM5kRrC0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774283803; c=relaxed/simple;
	bh=wmqJAd7pDyIbGcVBkUcGpINHuM3F5E9PQOs2AxbkeDU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=RxOIlA0dozWZgBqbzBDtgUBgV2krQ/USvEU9PKn9HL1jJ7Wj+0sJR5jyksnfWg/ub3JVUeKl3ef+sdO64LfNOVHJDcgXJuzNdJKcmnCkvzwn10COHIJLoPM4yzTT5wHJCPPlGXMpaDsODMhWrNSoaXErg/uLvcoS3XFwjSM0kyg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=2kK8fOPV; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="2kK8fOPV"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id C965121830;
	Mon, 23 Mar 2026 18:26:35 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=p1MV6Hpb
	8RR03QgFcfBlMCPr6Bvpm4eWKCv+NQqe/X0=; b=2kK8fOPVCUPfHIfHb5PKraY9
	KXhY6VeQe1EbVqgSPYvqZ/+UuerjUGb/UkKw6//YitGpncLkBUBYiG/RPBLTiA0I
	WLmegS/bg3KU7Tb130DlRWuF9Li0zFP9RCkc9hCnI/MOESCACZY01J/O/Zdmui+w
	9JvlVGezq/hz2sycoBohU/tZw6TlcCYfn2tDaZdpjnMxzS/a6lN4dRFZoBmGaNqN
	XJpSAnyUUI5Dpf9uIUJF+O5jvE9YNbvGGV3mdXfhlm1D0R7bnQKdWdt/msdNFdbP
	NBAhd+IPQ8h5RJexTcHqBJ+F2jo+2T3u1PafiVfG5o8Jgvc1sgzxecJhfRnaaE3a
	QkJsLtG5bZYzg9JeLZtS/ukWCjcDvQDfSPbYF1L5wE6M+zmcesOMqUVgWmPKX8AY
	02ed6gW4/WuEHzXnRYk3zJGiBH0rDsr95JHUf9Js+Nd1eLWBK5bhgG7AYxsMOoJb
	ycj5dw31LJAAkbWpD2cPgeZamzj5UNZusA+WSniuULNMYqrC/NohSgyq3wUy95zf
	klIIH6u1m5g645o8Rvey5PLU4LSB0bCt1Rimnd+4hON3a6rs3/qbrGd9lRjASaML
	n5yQs/lNKb5M6yMS6lEHSqpmduUYLWP++ZKGJyG6KjFKmhZq6rxqNon00kB0GnOs
	8vhil+KZgD/kngOhJEI=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 23 Mar 2026 18:26:34 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 7FDD460AD5;
	Mon, 23 Mar 2026 18:26:34 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 62NGQWQ6045001;
	Mon, 23 Mar 2026 18:26:32 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 62NGQRdh044999;
	Mon, 23 Mar 2026 18:26:27 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>
Subject: [PATCH nf-next 0/3] IPVS changes, part 4 of 4 - extras
Date: Mon, 23 Mar 2026 18:25:20 +0200
Message-ID: <20260323162523.44964-1-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

        Hello,

        This patchset is part 4 of changes that accumulated in
recent time. It is for nf-next and should be applied when the
patches from part 1-3 are already applied. It contains extras
for the per-net tables.

        All patches here come from the work
"ipvs: per-net tables and optimizations" last posted
on 19 Oct 2025 as v6, with the following changes:

Patch 1 comes from v6/patch 10 with added get_conn_tab_size() helper

Patch 2 comes from v6/patch 13 with added text for the commit

Patch 3 comes from v6/patch 14 with updated docs

	As result, the following patches will:

* As the connection table is not with fixed size, show its current
  size to user space

* Add /proc/net/ip_vs_status to show current state of IPVS, per-net

cat /proc/net/ip_vs_status
Conns:	9401
Conn buckets:	524288 (19 bits, lfactor -5)
Conn buckets empty:	505633 (96%)
Conn buckets len-1:	18322 (98%)
Conn buckets len-2:	329 (1%)
Conn buckets len-3:	3 (0%)
Conn buckets len-4:	1 (0%)
Services:	12
Service buckets:	128 (7 bits, lfactor -3)
Service buckets empty:	116 (90%)
Service buckets len-1:	12 (100%)
Stats thread slots:	1 (max 16)
Stats chain max len:	16
Stats thread ests:	38400

It shows the table size, the load factor (2^n), how many are the empty
buckets, with percents from the all buckets, the number of buckets
with length 1..7 where len-7 catches all len>=7 (zero values are
not shown). The len-N percents ignore the empty buckets, so they
are relative among all len-N buckets. It shows that smaller lfactor
is needed to achieve len-1 buckets to be ~98%. Only real tests can
show if relying on len-1 buckets is a better option because the
hash table becomes too large with multiple connections. And as
every table uses random key, the services may not avoid collision
in all cases.

* add conn_lfactor and svc_lfactor sysctl vars, so that one can tune
  the connection/service hash table sizing


Julian Anastasov (3):
  ipvs: show the current conn_tab size to users
  ipvs: add ip_vs_status info
  ipvs: add conn_lfactor and svc_lfactor sysctl vars

 Documentation/networking/ipvs-sysctl.rst |  35 ++++
 net/netfilter/ipvs/ip_vs_ctl.c           | 247 ++++++++++++++++++++++-
 2 files changed, 278 insertions(+), 4 deletions(-)

-- 
2.53.0


