Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 55CFA3E9F95;
	Wed, 22 Apr 2026 13:58:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776866319; cv=none; b=GoryBPgRXSd/UUjr4abRBb+Or4Yl2+hR7E46vY+m1xpSbSLPKzwDoqjKxAdWmrvZ+g6xd7vmjdOGjGyp3oQyv+0tYc3P6X8zJJBYxQ/N5FF5uals3NaM2icpnr7J+5Iqy0jv+0oCmnERJM1lCWRbQfVCnwWCmut9yU0kq5fKk1s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776866319; c=relaxed/simple;
	bh=MdAm3Kco0Immanbcm1fXjKBTn9r2xG369pwu5jxC2lU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=LbQwK6mhAQo7g3UC3ajtfrM/dNYt/n0DL59NE8DHjKQ2nd7GvrY2OnYQqj6KeajnjnvSJ73aZEJXJaAJYCC9KFDpcpnmO9qIYNhuuEDMJU8HbjESn50pX5Yl+74iBgpH8p2Vb+qRnSDVohltkO/8CvCIVAaAX5jcGBFb5PytpdM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=awRIhYqm; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="awRIhYqm"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 0EB4B2126F;
	Wed, 22 Apr 2026 16:58:35 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=ZeRo+RPc
	FNRdgxjKi+Lbtd3K4I3+4PwNPkm3getaCT4=; b=awRIhYqm3NSl3u1ccDP4qPve
	7CjLhPNXd8MdblazGqdILCqJ9vf+zGuu8bRhpFHwzEGodschkGmG9HOxhCcodZef
	uqPW1BUt4U6cs1Z3aPwApmwF4EotbnU4us3mPESlxwglULOo9HCzJol6X5c8mUUz
	2pu7wZfhmSHP8M3Kmsx1Xj4f1YsRXb17lU1vqjPY7AvjSI2oB6FEmynVWNlP44GV
	qfliE8DVnUx/66k4b4OzqFpBqlBl7ACsS4sSh9PXN+BJNa8e8AuqU5ZWSdcrevXR
	+GiQtIlTr8IHNdjDAxFvHXt8F672Rp9TNE65uOp743H9CG9VPblBHRioPc2xUrCI
	A8TbKVLmNV/ZIYKQuN/r2JtZ70x2MFqkY9WRCECV2pxSyxDWDvMDA5/3XQ/G8dKs
	OXfmdzHdYPpYbVpsqVXIg3sM3snIFe/7H8er4kQDyT6kJ6w7yTOKPQ6tx83jfvFU
	80qt7VAeKPzqwEbQcTTpb60sHuXSPf3XBCpXMwiKeI/FhP+MSQtGEMRdiv+e/wLD
	5i/u70YsD3jwnIjg+4rb5P4ACJHlQpHNbRIkdMK9KqGLetRXgIQjaiilemRPa9SH
	NYnW2P07dYoX1Dym/c0djbnmia7LKJsJ5hXB8w51DXGXFoYDx63lFDd7Sy9av3be
	WCF7D4ZX5BzRDMzxvQE=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 22 Apr 2026 16:58:34 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 3C4C0609C1;
	Wed, 22 Apr 2026 16:58:34 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63MDwXO7050509;
	Wed, 22 Apr 2026 16:58:33 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63MDwXZB050508;
	Wed, 22 Apr 2026 16:58:33 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCHv3 net 0/3] IPVS: fixes after the new hash tables
Date: Wed, 22 Apr 2026 16:58:20 +0300
Message-ID: <20260422135823.50489-1-ja@ssi.bg>
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
work for resizable hash tables. We target multiple reports from
Sashiko and one from syzkaller. The patches are based on the
net tree where the fixed commits are present...

v3:
  patch 3: use cp->lock in ip_vs_conn_fill_cport() to protect the
  cp->flags modifications

v2:
* patch 3: remove cp->lock from ip_vs_conn_fill_cport() and avoid
  races with resizing and possible multiple attempts to fill cport.

Julian Anastasov (3):
  ipvs: fixes for the new ip_vs_status info
  ipvs: fix races around the conn_lfactor and svc_lfactor sysctl vars
  ipvs: fix the spin_lock usage for RT build

 net/netfilter/ipvs/ip_vs_conn.c | 66 ++++++++++++++++-----------------
 net/netfilter/ipvs/ip_vs_ctl.c  | 63 ++++++++++++++++++++++---------
 2 files changed, 78 insertions(+), 51 deletions(-)

-- 
2.53.0


