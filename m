Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE72E1C695;
	Sat, 14 Feb 2026 15:13:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771081984; cv=none; b=S2USouHOYp6ltoj4KfNb1521HidUaxxiVtUPLUl0FgXpPR7U3NuJJCGDzLRVjMTRTHRgkWX2ml3T8VXNJo8KXPLFldGvqHXLmxLnNd+eqwGcZLo6/eY6jC+cXjXIhBi6MrNRQmx61h2LjbFsruRfKfbkou2NDd3fKg8mNb7gWjE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771081984; c=relaxed/simple;
	bh=pGHGDNAehl0I5AgqITEtnmxcPb2Um1PUdN9h5FNgdGQ=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=aybwn9FcMS0zrop2VipZz5jZPB16fklGM09hYyjKSvNdpim4+qSgQF9LYKI+6KS5N+7OVZ0+6mlokWGBXSsbJ2w4mUnQ1Nd//s41iWAZN9FscO/FkzGye6SwL9Pt8tCrhnzWMbFTqD9S8ltPmhZ+sK6ll5vKBzjanDSMexPNVM4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=lthdKOV2; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="lthdKOV2"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 9CE8C21D5E;
	Sat, 14 Feb 2026 17:13:00 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=1YRFgQbI
	jFSX0TXGd2sRMma1hz6StFpE4bzo8T3dAxc=; b=lthdKOV2HCBq00mCK1pprViW
	iLJ8k1vjKOce4xkT9UxdeVBu5iUcIDXFI8BRATGRqtAKJRCXVDO3Ejc8g1Us2jgV
	OiYApAVRWtK1WIALcCzh5UJW4qox/DP09VWkIhYsRRBt3fkO/lWp6FaQ3EqNph/I
	C4ndaeM6eMOCRrRb1IWrGYWOZVCKqiZECKz9mOtdBzsRWs6h2ujWcbv1/J122a/N
	oxLM6RWvp9gduf2i0LQjMuTISKICRucr8qNskLeKHVuWardbRTU/4KFC4Lp2i5vT
	K+Ggnvhvqe2wMpjy/IBNL5D7Y0Og44ZK6nAJoXdhxm9Qi3MqU7rKmgPyOfdkDjOv
	VsbKKiWCQ1zEnDdHtPG5ReJ3isEOZM0yECFsl4slGkDnx4stF6pEud1C0TjLcO34
	L3Vk34AdNyLRQLvCVKmefzfhuJkNxYRn4ngDlUy+sZovohgBve+4wPSwPcjehF1e
	01swB/5xi8EDEXpZ+xe5Au7rSSwOwWntuCSKMpE5VuVdHzmLJeTLe6LGUInm7mNa
	Oe5xJk8/DiVDFBtckFRhI/J/jc5FZ4F51sQ0+vHeaTJBnO1xXD4u837B+1ZI6OmD
	p73a4FAW+I3tLM/k6+QWAQBq0vJcZVX76qwtJV5xdwESGh2vbIj79UJ6iSSeF8QG
	s/1D7/qDCrbrZGTSD54=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sat, 14 Feb 2026 17:12:59 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 208A9609BE;
	Sat, 14 Feb 2026 17:12:58 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 61EFCvpC019340;
	Sat, 14 Feb 2026 17:12:57 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 61EFCv61019339;
	Sat, 14 Feb 2026 17:12:57 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>
Subject: [PATCH nf-next 0/6] IPVS changes, part 2 of 4 - optimizations
Date: Sat, 14 Feb 2026 17:12:24 +0200
Message-ID: <20260214151230.18970-1-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

        Hello,

        This patchset is part 2 of changes that accumulated in
recent time. It is for nf-next and should be applied when the patches
from part 1 are already applied. It contains optimizations and
per-net changes.

        All patches here come from the work
"ipvs: per-net tables and optimizations" last posted
on 19 Oct 2025 as v6, with the following changes:

Patch 1 comes from v6/patch 2 without changes

Patch 2 comes from v6/patch 3 with cosmetic change:
  - we can not use lockdep_is_held() condition because hlist_bl does
  not support such debugging yet, readers can be only under RCU lock.
  That is the reason for the rcu_read_lock() in the updating code
  in ip_vs_genl_set_cmd().

Patch 3 comes from v6/patch 4 without changes

Patch 4 comes from v6/patch 5 but some of its content was moved
  also to part1/patch 2

Patch 5 comes from v6/patch 6 without changes

Patch 6 comes from v6/patch 11 with small changes because
  it was moved forward before other patches from part 3 and 4

	As result, the following patches will:

* Convert the global __ip_vs_mutex to per-net service_mutex and
  switch the service tables to be per-net, cowork by Jiejian Wu and
  Dust Li

* Convert some code that walks the service lists to use RCU instead of
  the service_mutex

* We used two tables for services (non-fwmark and fwmark), merge them
  into single svc_table

* The list for unavailable destinations (dest_trash) holds dsts and
  thus dev references causing extra work for the ip_vs_dst_event() dev
  notifier handler. Change this by dropping the reference when dest
  is removed and saved into dest_trash. The dest_trash will need more
  changes to make it light for lookups. TODO.

* On new connection we can do multiple lookups for services by trying
  different fallback options. Add more counters for service types, so
  that we can avoid unneeded lookups for services.

* The no_cport and dropentry counters can be per-net and also we can
avoid extra conn lookups


Jiejian Wu (1):
  ipvs: make ip_vs_svc_table and ip_vs_svc_fwm_table per netns

Julian Anastasov (5):
  ipvs: some service readers can use RCU
  ipvs: use single svc table
  ipvs: do not keep dest_dst after dest is removed
  ipvs: use more counters to avoid service lookups
  ipvs: no_cport and dropentry counters can be per-net

 include/net/ip_vs.h             |  39 +++-
 net/netfilter/ipvs/ip_vs_conn.c |  64 +++---
 net/netfilter/ipvs/ip_vs_core.c |   2 +-
 net/netfilter/ipvs/ip_vs_ctl.c  | 368 +++++++++++---------------------
 net/netfilter/ipvs/ip_vs_est.c  |  18 +-
 net/netfilter/ipvs/ip_vs_xmit.c |  12 +-
 6 files changed, 212 insertions(+), 291 deletions(-)

-- 
2.53.0


