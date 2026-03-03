Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3783F372695;
	Tue,  3 Mar 2026 21:05:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772571927; cv=none; b=BFUl/XISHz+tMGvABF1ZX9cEGn/DLvj2+M33qDXF6ouFt4RQdwzZG/iqyZRA9AMj6j3cPJVAo7DT/r60CNvEKgoS1B4e/lDC1tU9dU3i/1HVWO/BBZhoHBAYNCrI+HbEJID4ZhaZxQw4A7FYHTM/Tm56PtBAnXGJUeKhDj70jP4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772571927; c=relaxed/simple;
	bh=BHByZ8TtEWWAgTcopnqzmrJNDaK/z0ZMbjpYyPt/744=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=ueaJ6PBvGOU2beV09SnQ/T4WHAQQYdxuee3wencb2xeCDUHI1eND8GYtMX7+w7/0Wv2hEZZKASVg1+MlZzpIWfy7ePc7WAt64rwtpEGDLpsBckHjJ2oSlhy8o4mEguAMA8kNbvOU6KsXnHTlvbD7ibqNzNAYNDX/S/ztRzNpw+w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=X2bWJzRF; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="X2bWJzRF"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 46DFC212E5;
	Tue, 03 Mar 2026 23:05:16 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=ynGO4LLl
	5fragEpjb+aTEi5427c9krBPDRCH5Z43/28=; b=X2bWJzRFVoZXPwcCOM/A1V07
	Se3TA/C6GMMbyOq1yDccHgTWc/sfyumUsH6xlCeqkgxQOfDGYhpovFmGSMdtImaE
	eYfTV6kXeJHUfN1PW2KR5M6brj/+Pu/R4r/M2/ThnV3ymEJGAP2lBXFrHEG/w+C6
	oSVpwh3+U4l1cl3S0w5XfqXkwvCRGVaUC7Ec0lpJOHMOd7T3trs5WY78Flx+8D5Y
	msCkghONcU65llQqXqDuXuBEdTBDTIFwdvEWHnMVYIoqrkj7jVI+8vDv6XDwsBpM
	0FWEqPdc2Braq/idGI1umRX/e4W6S+8jGmKV+aX7kHM6vpiRpjP30H82l5LdAwQp
	eyuCGeSGW4vS1dhTm2osepUytWaInlKwA0FBZHD1zdSAVcOIE/jMMNuTVVL1xcrK
	ytgRiSH2Ui5z9mLGVdqfkDbGrhAfjv0zt+WiKCqPWCFsS1dT7dGFytJx32tQIwQt
	B8fvI2HlBCLpOMe4fwo97v5hXRrPuLWVWyGdJNNG4hFeT9NYjB95/lhktt2EE7As
	nuaxPARpeSzI+xxMw6g8aO/hGBBRIX1pianysmnz9H63zK1Haee6BVLBo1ZU8GNK
	/CGo2+8Gn/rCIANMSvqPQumeFB4qGSxyC2VVFXh5BLIYGXX4PyXED2bDU8+OrpWr
	495FRQ0QJ3RSOUU7QOs=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 03 Mar 2026 23:05:15 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 2BAEB600C6;
	Tue,  3 Mar 2026 23:05:13 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 623L56r3087500;
	Tue, 3 Mar 2026 23:05:06 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 623L54Vd087499;
	Tue, 3 Mar 2026 23:05:04 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Dust Li <dust.li@linux.alibaba.com>,
        Jiejian Wu <jiejian@linux.alibaba.com>, rcu@vger.kernel.org
Subject: [PATCHv2 nf-next 0/5] IPVS changes, part 3 of 4 - per-net tables
Date: Tue,  3 Mar 2026 23:04:03 +0200
Message-ID: <20260303210408.87468-1-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

        Hello,

        This patchset is part 3 of changes that accumulated in
recent time. It is for nf-next and should be applied when the patches
from part 1 and 2 are already applied. It contains changes that convert
the connection and service tables to be per-net and targets more netns
isolation when IPVS is used in large setups.

	First patch adds useful wrappers to rculist_bl.h, the
hlist_bl methods IPVS will use in the following patches. The other
patches are IPVS-specific.

        All patches here come from the work
"ipvs: per-net tables and optimizations" last posted
on 19 Oct 2025 as v6, with the following changes:

Patch 1 comes from v6/patch 1 without changes

Patch 2 comes from v6/patch 7 with added comments

Patch 3 comes from v6/patch 8 without changes

Patch 4 comes from v6/patch 9 with some changes due to the
  v6/patch 11 position change

Patch 5 comes from v6/patch 12 without changes

	As result, the following patches will:

* Add new wrappers into rculist_bl.h

* Add infrastructure for resizable hash tables based on hlist_bl
  which we will use for services and connections: hlists with
  per-bucket bit lock in the heads. The resizing delays RCU lookups
  on a bucket level with seqcounts which are protected with spin locks.
  The entries keep the table ID and the hash value which allows to
  filter the entries without touching many cache lines and to
  unlink the entries without lookup by keys.

* Change the 256-bucket service hash table to be resizable in the
  range of 4..20 bits depending on the added services and use jhash
  hashing to reduce the collisions.

* Change the global connection table to be per-net and resizable
  in the range of 256..ip_vs_conn_tab_size. As the connections are
  hashed by using remote addresses and ports, use siphash instead
  of jhash for better security.

* Make the connection hashing more secure for setups with multiple
  services. Hashing only by remote address and port (client info)
  is not enough. To reduce the possible hash collisions add the
  used virtual address/port (local info) into the hash and as a side
  effect the MASQ connections will be double hashed into the
  hash table to match the traffic from real servers:
    OLD:
    - all methods: c_list node: proto, caddr:cport
    NEW:
    - all methods: hn0 node (dir 0): proto, caddr:cport -> vaddr:vport
    - MASQ method: hn1 node (dir 1): proto, daddr:dport -> caddr:cport


Julian Anastasov (5):
  rculist_bl: add hlist_bl_for_each_entry_continue_rcu
  ipvs: add resizable hash tables
  ipvs: use resizable hash table for services
  ipvs: switch to per-net connection table
  ipvs: use more keys for connection hashing

 include/linux/rculist_bl.h        |  49 +-
 include/net/ip_vs.h               | 377 ++++++++++--
 net/netfilter/ipvs/ip_vs_conn.c   | 992 ++++++++++++++++++++++--------
 net/netfilter/ipvs/ip_vs_core.c   | 179 ++++++
 net/netfilter/ipvs/ip_vs_ctl.c    | 691 +++++++++++++++++----
 net/netfilter/ipvs/ip_vs_pe_sip.c |   4 +-
 net/netfilter/ipvs/ip_vs_sync.c   |  23 +
 7 files changed, 1881 insertions(+), 434 deletions(-)

-- 
2.53.0


