Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A4FBA43B483;
	Wed, 22 Jul 2026 10:16:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784715366; cv=none; b=OKaBC3eJU5QM2EPuXVeTIEdsdGJFc7Nh5dIHEvc79xIZlxz95Rayfp/hfZQeSkuglAO2C6o6FFBati356KVuIV/xdbIP887DQ5Z9W7Pvx9d4/4zlcCGaYW4JexiaGhp2apood81QTsFx2bx7EHXP8ydwenC73oHM0H5bjK8IWlw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784715366; c=relaxed/simple;
	bh=Q/Oe0o4KmP10JLv8kKVhqE2HHkn4m95mzX25clp+VIQ=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=LTsT89SMvnVAD++1VvqFPtpa5vc8OV3cEYOZdTeI0FBhdBrWEIbl6dTWbQ1ClEPgCuF3jj0AIMNW0virUyWBUeBedByYspbqsMCac64h443FoCv7fdiiGDnpQq95xY3L4AFH7hUtL3CfsCVZLqAkXxdPvl9u2NMevfxmjrnUrHI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=koiqB+XM; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="koiqB+XM"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id EF9DB2188A;
	Wed, 22 Jul 2026 13:15:51 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=akwny7u0
	c3+Ul2Lak+HvMje9GRIRemBVsn3kFdyTYGQ=; b=koiqB+XMqzGexDO5s8M4I7bY
	GVfI6g07bQEVylTt3veXttIGr1DwuiZucn0dobMGvggSLTt28jokOp+J22ZgHl3q
	Lmq6vjMUn5LEAm8jr7E1UeU4pTAGoKVHrCFa5rI9g+9EWdMM3dm21BAgN8ffh63y
	vMJSznMv8BkAhW/wYoonRPfLxpbhJG46Jp8iC8asRokVw8jVKJMibfftD3at2rGJ
	pBh/unluw60IvQUryKKfilEERRadZQYd1EPfDOX16EbiRmHIJkbu3iiXt2wTIAOU
	CCnSrsPB4EwkZUVEh0u02CTXTL+GZcavM2naKaQAT3DfcIsMFjvGrxnSzRHoP+IY
	cpiu+mEwIS6iTjljUX51qTNCjp+c0YqrI9kJ7FEiyEY+9DQlJMz9rhQEA+sWpdlD
	xj7JATnyczVeNRP3Dk2Yh6tsd+Vm+ookG+ANMeN8E3g+Hml/OIkirsaPaM2IEuTV
	MvGSbmUbSY3W1I15Zkk0/NTthQG9Yc4kXWrgOvuvsNjjcwZcSQN9TvgaN/+pvhok
	HRchvxfOXvwAnPPNXAbqtrx8ME1Gkcrp8c18pbdCXcFXlUgp/obprAWeeD2OzTVy
	wCDiIup259heoWzYeDTkRvbt6kEs/6CHNy3TMmo1B8vBiHgt5tW1PM5eOEZgwCrr
	FoR+oN1wuU0tJ0QGVNg=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 22 Jul 2026 13:15:51 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 3419560400;
	Wed, 22 Jul 2026 13:15:52 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66MAFiUq036335;
	Wed, 22 Jul 2026 13:15:44 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 66MAFfgt036334;
	Wed, 22 Jul 2026 13:15:41 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf v3 0/3] ipvs: csum validations and data offsets
Date: Wed, 22 Jul 2026 13:15:14 +0300
Message-ID: <20260722101517.36313-1-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

	Hello,

	This patchset contains fixes for the checksum
validations for ICMPv6 and switches TCP, UDP and ICMP to
use nf_checksum for LOCAL_IN.

	It also corrects offsets to be based on skb->data and to
respect the network offset.

        Finally, it prevents to read/write ICMP payload for
non-first embedded fragments wrongly assuming the TCP/UDP/SCTP
ports are present there.

Changes:

v2->v3:
* patch 2: add __maybe_unused to coff and outer_proto to silence
  the compiler warnings when IPVS debugging is not enabled, reported
  by the kernel test robot <lkp@intel.com>:
  https://lore.kernel.org/oe-kbuild-all/202607210623.du5PqolJ-lkp@intel.com/
* add patch 3

v1->v2:
* patch 1: switch to using nf_checksum, validate only at LOCAL_IN and
  for MASQ
* add patch 2

Julian Anastasov (3):
  ipvs: fix the checksum validations
  ipvs: fix places with wrong packet offsets
  ipvs: do not mangle ICMP replies for non-first fragments

 include/net/ip_vs.h                   |  48 +++++--
 net/netfilter/ipvs/ip_vs_app.c        |   4 +-
 net/netfilter/ipvs/ip_vs_core.c       | 180 +++++++++++++-------------
 net/netfilter/ipvs/ip_vs_proto_sctp.c |  19 +--
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |  48 ++-----
 net/netfilter/ipvs/ip_vs_proto_udp.c  |  54 ++------
 net/netfilter/ipvs/ip_vs_xmit.c       |  42 ++++--
 7 files changed, 193 insertions(+), 202 deletions(-)

-- 
2.55.0


