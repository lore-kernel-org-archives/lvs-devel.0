Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 40DF538B7AA;
	Thu, 30 Jul 2026 18:39:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785436759; cv=none; b=rzKXXdryvLh9eU6ALqXpRfj9H8Uf1XRGu85lYcI47jRC1vx6ZTzG2+xEOwa2856SD0IAkacLsrJMD2mOg8X6Pih16JrPhqZpR1By5nidoEJmkrEXImAGZxYFv6XI1SLjVgn0HxL7VoLfztW3qZGVFCvFq85YhA6HdjIUi01kYCg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785436759; c=relaxed/simple;
	bh=avTTomHfQunYRQRSDm2xT2lnRd3IyNO/RwR9BVc4UT8=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=oCid4ecmyHd59FD9Ywwqw4d0woRPn5mPk/ZhOtgvURR62s8kA0Xjpjg6l8sc+hkZ0Z6jNlOJKHwGJfFBLdYcS5SC35LLlqK2usquljb0/q2JZOE08qmjrumMVIDPHpxxgdaGKpc4LfxKWgaBs1yNNXOIsVGMxSpRqC365wjCKJA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=wVOA6bdy; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="wVOA6bdy"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 3EAA4216C4;
	Thu, 30 Jul 2026 21:39:00 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=M0cw6ACg
	Nw3TC/WU8odm16aBUjO9swiWHbOtK6KHZZg=; b=wVOA6bdyDJa9X1jc1QRfsTjB
	mGSQEUU7Ke0RFMhvbALhR5kbRgPh2HztWoBoF4mEpa3YIUuXdJst//npR+SQZA1T
	xCRdDneY0KieX1HheFQO1J/2A9DRWZknRUcOIzqe7n9sakRBjEUbAc9+S6I1i3Rh
	GTJHsy0ykJD/q+/LkOrcW0kpHeJc3ZMNDkiV84CWbLg1Hvq/XQos+Op/ow4anOhC
	VCQ8NkQXG7GX7XeDGmOEL9CA5O/SD729wiyBL0+WF6elNMSgw8S8nCxiTMQTI6MS
	w1FczuBjDj9q8UqU4LHyDcZO61tIQdkLj5eWVEl/YbgCbtRh2zJ7X587E2dhkB3M
	uMmf3W4D1yIRH/FEpykU0KFk2ER8qnWotC/A4WzIPqfxHqfgz0rYRAvhjIXEMZY7
	1vG5VFBLqRiB0hv6RURTsO961mXRAta6yG4st3aV/GYI3IK1OOeym0fJQ407wJ2X
	G4Wo072mEEJLAhUDDh9ueYaDDAmZO9q3AdKcaxSaAFa8Y23oxaQFdRE7qE7VCBSB
	KBFQmYF7VfvbdCl0giyisHYYSoHY8R8od3DlFlOmq8u+ZK36vmobxPDg4Bj6NYha
	+MfDjBLoMfFKfg+SaxX/95umqn466fo7sE+Pc23kPAok/zJ6vH8TuiNzTsYy8ikF
	nerreGw/nMcq1PS1Ci0=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Thu, 30 Jul 2026 21:39:00 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 1CF7A61BEF;
	Thu, 30 Jul 2026 21:39:01 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 66UIaDUM087543;
	Thu, 30 Jul 2026 21:36:13 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 66UIaAVF087540;
	Thu, 30 Jul 2026 21:36:10 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf v3 0/2] ipvs: csum validations, part 2
Date: Thu, 30 Jul 2026 21:35:04 +0300
Message-ID: <20260730183506.87473-1-ja@ssi.bg>
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

Changes:
v2->v3:
* patch 2: rely on nf_checksum for marking the csum as
  validated

v1->v2:
* patch 2: prefer our common helper for csum validation because
  the old TCP/UDP checksum validation for IPv6 on CHECKSUM_COMPLETE
  was wrong

v1:
* patch 2: use per-proto checksum validations

Julian Anastasov (2):
  ipvs: avoid out-of-bounds write in ip_vs_nat_icmp
  ipvs: return the csum validation for forward hook

 include/net/ip_vs.h                   | 21 +++------
 net/netfilter/ipvs/ip_vs_core.c       | 67 ++++++++++++++-------------
 net/netfilter/ipvs/ip_vs_proto_sctp.c |  2 +-
 net/netfilter/ipvs/ip_vs_xmit.c       |  2 +-
 4 files changed, 42 insertions(+), 50 deletions(-)

-- 
2.55.0


