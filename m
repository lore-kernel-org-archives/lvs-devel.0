Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9F54619CD1B;
	Mon, 20 Apr 2026 16:56:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776704187; cv=none; b=U7q3YpkyOzKn14yoKsaweBQQUZefFV6f1Y87LM6dfPvRAPgvmkMihRYg2A5x/3dDicge4i/XLuXzmai0KGLCW3qwhpjMGTTVFHUWE3VBL8dRmnE0o88hgxOfbDbuYB2xPe07km/42RjSpHnGtaoWm1NGlBULkUp56kzFiybWY88=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776704187; c=relaxed/simple;
	bh=93V6hpTgnjumJAGFzE3PjQqJ2JHpN7gM3pJjadsIycg=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Az4fPYQHjalWA9aL1w7Ipr7GQIZFJpAiMJwOyCHiKUm/g1skA6SBInuehg3NrAKEqaslg2xLc6zXp7rhOWxbyQtDO7tDh5kPbK4YsuVBgSleNcWFgbr+BsaVaQ5uYuWkLBVyDaKlLgr/sVHR3AnVFxYWjZsaD9712X77AC5CO4E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=Fu7Ws23g; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="Fu7Ws23g"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id E2406210CF;
	Mon, 20 Apr 2026 19:56:13 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=EZE1k82P
	vjDiHHrAOcX5sT+O+gEAAUVS6oFRq0SlIGg=; b=Fu7Ws23ge43dpAtUFtCYEo2N
	yAWyZX80rRX1cdvuxX5kZZOyVEPKWSDRpWAzeKPlszIHYMSyoCKCBgGfkDA7AKQH
	7ciB5JsWW6kN4/VBeiC5XDpiRFK6kfcQi9kW5cLXbUaOJeIAeTY1gjBZaXv3FC13
	g692XAvb4gCszyrJEEnt0xddmcrewxyJ/Hm083mI6czZTsJPDN76i8hdqfPPK+ve
	yxCdndq765a4GPMHnfvvXgfED072YACNLWTr1KXrSJLwUYc/wDzy1ulIyEejRbah
	y8sdCN2y+TARwpo4TFs1PSZFwZGl+bkMkvOq+FlODcz9fN+chOD8ZWLdC85KnIoB
	jP9xj9zFn5qV4bw4WWtm4a1Ijv8wYrzTgLzJJiwf3bmHz2xAijrhvKbWFQZIpLda
	t3k/L2+kIvadjCvQoyZDW0/W8peiKdemxMhBT3l/nCG7xDwMnFrexf9xoh8gEGHo
	1/9091tqW/qbZgQYAM8ttHDdSDldtopx2B38QyU/RXM5H/bQ44e7lnzbHvFp+vW1
	Id12qZ8WvNAoKtvrf8yjURwtvH+A0MQy7Vpvfe9uQDURJlsohtWZxeSvELYhPuov
	3MZI8SBmUZTIeO908aZeK7snSnhfwsi9GqHB8zqcKEmmA49tVlf/owW5a/6tDTta
	r8xPE13BiHskz3Vnx/s=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 20 Apr 2026 19:56:13 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 90A6F60548;
	Mon, 20 Apr 2026 19:56:12 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63KGu4wm085552;
	Mon, 20 Apr 2026 19:56:04 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63KGu0bx085550;
	Mon, 20 Apr 2026 19:56:00 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCHv2 net 0/3] IPVS: fixes after the new hash tables
Date: Mon, 20 Apr 2026 19:55:36 +0300
Message-ID: <20260420165539.85174-1-ja@ssi.bg>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

        Hello,

        This patchset contains fixes after the recent net-next
work for resizable hash tables. We target 2 reports from
Sashiko and one from syzkaller. The patches are based on the
net tree where the fixed commits are present...

v2:
* patch 3: remove cp->lock from ip_vs_conn_fill_cport() and avoid
  races with resizing and possible multiple attempts to fill cport.

Julian Anastasov (3):
  ipvs: fixes for the new ip_vs_status info
  ipvs: fix races around the conn_lfactor and svc_lfactor sysctl vars
  ipvs: fix the spin_lock usage for RT build

 net/netfilter/ipvs/ip_vs_conn.c | 52 ++++++++++++---------------
 net/netfilter/ipvs/ip_vs_ctl.c  | 63 +++++++++++++++++++++++----------
 2 files changed, 68 insertions(+), 47 deletions(-)

-- 
2.53.0


