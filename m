Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 29B12211A28;
	Fri, 24 Apr 2026 04:07:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777003678; cv=none; b=fWkDiM/LpBRDAFbC2SRkZ6qYufltsAxVkq4fzdlhqFoEgrn9U4Wek5Z+F3N2LYfFXJH9TOfLUf8SP5dO5Ukkazs6CmVA8I5nPdh7q2ISD+x84dP99WQI3VczcA/OmTSDMju12VHXUIVZmmhY+0yhA/JDn7Qx/vQpUe+1INJDyJg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777003678; c=relaxed/simple;
	bh=0DV8j0AWbwd01YUWwODvf3S96mEaLIBEUKSwnR534E4=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=q1Oe6ov/9QTbfBxfblvl8OwQVfOho7z9KYnSmz667ssFZI85tYL0p7vkvo0dCwttBL7npOdWHfM7AMve6HHdsbDX4/iTHj8J6jriP6+e6LIhl/ODG4u4D+wREP55cHw7YdcCdZhYCSJbb0TK+Vyljq1I4O34aT+dhv9OrpX5i/A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=6yeXKlvw; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="6yeXKlvw"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 32E9921269;
	Fri, 24 Apr 2026 07:07:46 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=5tLSa8rS
	PmTjWE90FCxnV/aucT9T+tmRCc7GBQfwwbI=; b=6yeXKlvwoGtW42jznBgis+DF
	2E/XC1UYva69z3z4cEze2409tdhy3mEoQTaDqPm1cX2841nQyS/uKFfMcbh0LTfK
	uT1HWuZTiX4+1gaWci3ibVzEVI6hIRZKS3wMITXzaqYCR8htQk3Y9FsJ+VfXN+OV
	U95FvAD7MWo/T6nhz5CcCwpNK9oMiECYiBgG2j3jAD/nWVmK98RhjAVX736oKuCO
	xmoluCuwLGvMBQ1TQQBKd8pPqytQwJv0MXwafD67qMs4wGVq1+wGSVq/oM8Bzv9Q
	vBPfCXM5FPhx61TVAK00IUA/p7L9D6oT+PutjDIlSf7LwhxNrPVoWPlKeJewSbJD
	CyRRvXhgy08aapjdMDj9QGu4GpVDaGevelkhIhS0EMzmhT8+44oAyT24398GdvhV
	UCEZQOvEqNfZ7ABahULjkam10c+VxgdQzOzC/45vyRe7d0uo0rKHJzUOG9bSPrxm
	kU0H4FAp8I70ECK+SghJtpmne7DZcVtZMBSLGq6v0qc9zWYpUcLwUBLG+99f8PLq
	eU1AqDJJJhyMayjJOZkYNPfbLS8durUufNAbQ46jMYwQ7vbIpHfLwoh8yPmT+LIC
	4k088hgE+L98OWB8E+1BehSG7rdPYbSQC3nAI3AnFgNOT6syrfRhA+l8l5F+8HTs
	qpjiaZ+IJYyS8bapnFk=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Fri, 24 Apr 2026 07:07:45 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 849A960B2A;
	Fri, 24 Apr 2026 07:07:44 +0300 (EEST)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 63O47gAJ006122;
	Fri, 24 Apr 2026 07:07:42 +0300
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.1/8.18.1/Submit) id 63O47aJj006120;
	Fri, 24 Apr 2026 07:07:36 +0300
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCHv4 net 0/3] IPVS: fixes after the new hash tables
Date: Fri, 24 Apr 2026 07:07:20 +0300
Message-ID: <20260424040723.6104-1-ja@ssi.bg>
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

v4:
  patch 3: add error message for too many hash table changes in
  ip_vs_conn_fill_cport()

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

 net/netfilter/ipvs/ip_vs_conn.c | 71 +++++++++++++++++----------------
 net/netfilter/ipvs/ip_vs_ctl.c  | 63 ++++++++++++++++++++---------
 2 files changed, 82 insertions(+), 52 deletions(-)

-- 
2.53.0


