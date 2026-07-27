Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 836F46FC5;
	Mon, 27 Jul 2026 18:50:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785178258; cv=none; b=q3LCaO2c26t3cnOgKUkf9fIq2eFInnXJBncIWLSP6W6iltEB4y5MwRo+B5zSbJpKRab+ICfXZtrzGV9BCat4ym0oPktiv7ItU5/H07wEZtJg3BribY9BL3lxssdGXF5VQlYr1JprevWbF7ebk5HdqJ4rRNB7+gXOs8LvyzEWcdQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785178258; c=relaxed/simple;
	bh=4QC76tCdS+csqAO9GvXufeIdzGhX1jIMS7KxN7nkchg=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Irhjp+fmhTbWSnw2EsEabd5CDmPNb7sqsXJL1RoHIKQHlbNXyo1PYjpb34SWnJ74Rb9X0V5esYI7yTz7Te6zaFmVqXJeoEgC4XSnnkxEis0XihVmGw0jejE35rsJm0kNXm63gkv0st0ESlYqlsficou3kacLYCFJUVRC35j3YcQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=zcxuZC0q; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="zcxuZC0q"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 6A6D121B1E;
	Mon, 27 Jul 2026 21:50:51 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=eunBCtB7
	qcHE313uWbo1JCBjrZounbxqpWEL0FczsMc=; b=zcxuZC0qM0Uv40WDrkVcugiE
	ecG7csA86KS4NliqKetTw0c7w5Jw6fqC7REF3Vty0iPz372YYeu+ATOplG/p8qba
	2wi1qNDtnWazouncVQiTdDKyBIQ2tYG/ucK9c3MUENe7EM72vTv602DVgbtl3147
	HywAA9rzGQeoOS4S9rnVpRjG08OEyEqMROKzyxhv4He12vBwOVKfzZuWLr0PvnjQ
	Ke5idkn8TWNj3I2LAsB+X4Yd9P0Zbyi9/2Kk0DB/qDIjfoFjR1+m4vxrqDyPKHwS
	YNZkeEQqPUXUMxBAL8gW2rDXESJKlwH4aEDsLh7uXr2Cw2RkNA4xTmXKe1JiGwJP
	YPt+8OvtTIC13PTWNkcZsiaSic4XXFKRtnCPZvcZGuewPRBtfpYfZzbiAVqC1MQP
	P3cNkEw1VL9tyrEjMtRZkEISDazfXgjEaJi8/lRORLYk8RvtBZUDUNcvUFT3vItb
	vrQg962gEboaXykmpZ3BrERkCZqdUOFLWTGLI3D1bysp/cIjQ9JEW8IPPr1gp6/9
	qjGsTLF7ViHnkEzte5be2E2naDSxkyy7g5i+6KaLAseGOZKSsSY84k7GQbmYj6k9
	P3RQObtP26/QZoogI1l+eOBA/r9DxKPq3kzbiOd+vTdy6qohLKI8xz7x/LsT7yCJ
	XOk0OZyPKobA9lQTmLI=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 27 Jul 2026 21:50:51 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 3253F60A18;
	Mon, 27 Jul 2026 21:50:52 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66RIopmp067553;
	Mon, 27 Jul 2026 21:50:51 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 66RIop8O067552;
	Mon, 27 Jul 2026 21:50:51 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf 0/2] ipvs: csum validations, part 2
Date: Mon, 27 Jul 2026 21:50:22 +0300
Message-ID: <20260727185024.67534-1-ja@ssi.bg>
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

        The second patch returns the per-proto checksum
validations which can be needed for the FORWARD hook and
provides helper for ICMP.

Julian Anastasov (2):
  ipvs: avoid out-of-bounds write in ip_vs_nat_icmp
  ipvs: return the per-proto csum validations

 include/net/ip_vs.h                   |  31 +-------
 net/netfilter/ipvs/ip_vs_core.c       | 102 ++++++++++++++++----------
 net/netfilter/ipvs/ip_vs_proto_sctp.c |   2 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |  40 +++++++++-
 net/netfilter/ipvs/ip_vs_proto_udp.c  |  47 ++++++++++--
 net/netfilter/ipvs/ip_vs_xmit.c       |   2 +-
 6 files changed, 143 insertions(+), 81 deletions(-)

-- 
2.55.0


