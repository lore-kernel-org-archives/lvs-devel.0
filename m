Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7F9C33911CF;
	Mon, 20 Jul 2026 20:12:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784578331; cv=none; b=WO23BZ+ahWjDeVOA+Vr+ASQl2SjSb7tVlGpKFhgc5ASuklzier1SYpgmIDYIDUSoyhA+4sR9qOk0U974PQiPmakMOfXEEKb7JLN8R0qWKx0eV8fJQxN0Y2jhpxO4+Ncw684ZdO5VcGuTRbmSVLx9pr0zRP4n9BGBgniiiLDN9eM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784578331; c=relaxed/simple;
	bh=GgESnXzy3sUCf2df+rIkq85Ci4ptJyVjGSbTSaaGMJM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Hgm6Cg3jj3Dyq6/O4eu1sfXhTn2biJYLomghrP5i3nBE69emoYCww3HHQ3TY4dOFyH5wPDiaHGgTE/m4+F3OeGMBVcriNTGKWDHyHySsCabD8aLXLqjYpkkV7a2yoqxXnDHn22yu22KOKC143U3XqBHzUQ9Zf39wSYfsfjkOHqY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=LAoOx2po; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="LAoOx2po"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 3126D22AFB;
	Mon, 20 Jul 2026 23:11:52 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=UB0RotIK
	rnnjaLwFi/wXyl1ZqeEVpszesBOfUWO2vW0=; b=LAoOx2poI4vLPg2okRT7OEmp
	QjjYsiPFNVOxoCuAvEA9N/tSbZC2AQ69dfoYgdBsLbsGYmbyg5DSqmUC1XczrM/W
	h+mgnvjQiZCE75Q7Ee3ncvdtLgtVQQeqC/h8QHTUiAIr8sR5qt/5Uh50204KLH/h
	sQcrBj9OBOo658egox7CwFNuBtZa/nc/sQQUww6SErGc53oiBVSKUY5zAqwvI+Wq
	4UkyduAFf/65Cg7Ja8KisBfqUJ+fTEEz/ProTjGd3PPh3WTZzQewvAA/l7nJ941o
	uue0oIAHNt8Smy8GX9e8URYRNGp/Hg84LZtL7siKs6mo4bEhFHVYTg8KtQNvT9sm
	f9SVsj3Aj16ffBBXqvcV4qWSIwRZ1PXMIMc8VU8aeBsa2aXZUCbKcQ33mtRRTEKC
	sGtrzrw3B4KO5ml9U7iaXDsAyOI0p3ys9UyH4cATvWAYwnzJ09EeVNrmke4bk8b0
	ABo6fKydn9SzTQmpX5LfM7wK9VURREgDmCNkH01S7MBAw4lqPAh2rdumwe+rUUfC
	ZgcEzVuoV3eBbT5eQCQYgNujHI0nYMttJ6kIbXo7lUQYUJDaSK3x1VCIlXgqxwqJ
	1XNloy/yDP0JUKLZNs4kcogk55wISdxsC7jGikokNVlay0aJ3TmNX6iFBVHCFFv/
	o1jr1yS8H3Zw+3YLekc=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 20 Jul 2026 23:11:52 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 55B85601FA;
	Mon, 20 Jul 2026 23:11:53 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66KKBkOn079903;
	Mon, 20 Jul 2026 23:11:46 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 66KKBgbc079901;
	Mon, 20 Jul 2026 23:11:42 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf v2 0/2] ipvs: csum validations and data offsets
Date: Mon, 20 Jul 2026 23:11:20 +0300
Message-ID: <20260720201122.79882-1-ja@ssi.bg>
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

Julian Anastasov (2):
  ipvs: fix the checksum validations
  ipvs: fix places with wrong packet offsets

 include/net/ip_vs.h                   |  49 +++++++--
 net/netfilter/ipvs/ip_vs_app.c        |   4 +-
 net/netfilter/ipvs/ip_vs_core.c       | 149 ++++++++++++++------------
 net/netfilter/ipvs/ip_vs_proto_sctp.c |  19 ++--
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |  48 ++-------
 net/netfilter/ipvs/ip_vs_proto_udp.c  |  54 +++-------
 net/netfilter/ipvs/ip_vs_xmit.c       |  26 ++---
 7 files changed, 172 insertions(+), 177 deletions(-)

-- 
2.55.0


