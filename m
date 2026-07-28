Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3230044C506;
	Tue, 28 Jul 2026 20:25:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785270353; cv=none; b=T+GV/hwrS4FCIpsxIwqUxdcqZADmJDU1Y39OLY2H3vHJmDPQmOFiRafv5hbMooevwQtj7iuFM8aecKFg8tRA3LXRMqjqtt/pt0RXT8hG79F0uutmk2wjnG94wAfSPXlh3nqMJIemCL+4C+xo5rDVGJ1mJ2Gh/XI6OtzfJV3gVi4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785270353; c=relaxed/simple;
	bh=RRwWgbgEsfdFJNx3rgxFWuB0wCj6B0bOhLSjtF4BEfY=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Hr1UxHOkWpvXRksDrQlerOimKYQXwXjs9/MzW/4psaQAc6a5kjNm0HxylqhRAfbG+DdLGquhXl20I8RCzgAr0hp+RLSv99uC1RdkvA52B5zX+GKTN3984EzhpImiz5odtBwun71hXOrA7ol1e9808VvqTJM8adaBkETaZQ2zWMU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=4+d1Q8XF; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="4+d1Q8XF"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id E22CF21311;
	Tue, 28 Jul 2026 23:25:38 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=FSzBtaPt
	VDIID4WDGY3+mioG2hKTlFxf9Pa4vK5l9BI=; b=4+d1Q8XFq2YkS19MSZKSR8jK
	n7rWkus66OTt1/+QLj6XSJLzDL4nL8uaIpPiajvKTtz/7Dzmd65kh2eBTObnW58z
	FkBrJpwEQNf6K/K3Hautl+YgvCdtuqCHsui8W2xwTBY/nzKbPvPkEhl0poPc3fxZ
	CIaFc0mlvrXnSWuP9i78pEe2cqQ0gkaipyBepnDaCxrFF6iH2In6jlddTvDOG/+n
	GtPZNIc5Zwphlcew5SkGhGC+tmLf+wUPUvH/v9w0Lm7DbOY7Jq1yORKU0REFnb7X
	cMkhk4bxWhWpDWbk6NU3EoyXQsFx+IsJhQfL+G7TgSS/SCQDjSX0bx2Gn4Zy+K1U
	PC5aAjYpWOH13i2X52Y/19T/GSPkRlB4tH3xaCXJB7nrPMwyeuKEfAUl0cLDZyWt
	hyKFZEuRs5mPOWT5hq7i88VDlp2bMA/IR1vnJ6TukEXkDZpruy7SpcQiy5eOlE/+
	P/CbSaNJaANDvou3CSuLL75RLzBZnHl+xohe4jYickyzykKZ9/xo6RldSRIdaen8
	BDcR0SEiWZMtC9t7tUHDbTCNvzemNMAKqqAQuTwS6XCj8djbGCdSXSYsXFK/Ixx6
	+e5VOgCeRP+YzGIYXOTcI3wqlHqez5VLgL/t3H6kby7BohV2UlwJcsL8IxDLnFCW
	vTNH0vnsq1oACF8MfXg=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 28 Jul 2026 23:25:38 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id AA95760B6E;
	Tue, 28 Jul 2026 23:25:39 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66SKPW3L059201;
	Tue, 28 Jul 2026 23:25:32 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 66SKPUwJ059194;
	Tue, 28 Jul 2026 23:25:30 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf v2 0/2] ipvs: csum validations, part 2
Date: Tue, 28 Jul 2026 23:25:18 +0300
Message-ID: <20260728202520.59179-1-ja@ssi.bg>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

	Hello,

        This patchset contains more fixes after the
previous batch of fixes for checksum validations.

        The first patch avoids reading the IPv4 ihl field
multiple times to prevent local attacker to cause
out-of-bounds write in ip_vs_nat_icmp.

        The second patch returns the checksum validations
which can be needed for the FORWARD hook.

Julian Anastasov (2):
  ipvs: avoid out-of-bounds write in ip_vs_nat_icmp
  ipvs: return the csum validation for forward hook

 include/net/ip_vs.h                   | 32 +--------
 net/netfilter/ipvs/ip_vs_core.c       | 94 +++++++++++++++++----------
 net/netfilter/ipvs/ip_vs_proto_sctp.c |  2 +-
 net/netfilter/ipvs/ip_vs_xmit.c       |  2 +-
 4 files changed, 66 insertions(+), 64 deletions(-)

-- 
2.55.0


