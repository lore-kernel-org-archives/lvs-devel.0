Received: from smtpbguseast2.qq.com (smtpbguseast2.qq.com [54.204.34.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 99BD82857FA;
	Fri,  4 Jul 2025 08:36:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=54.204.34.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1751618199; cv=none; b=BXY70Ky8UAlt/D0P16ikQ4fHqmp5bKc6+X3nB+MqMNsHaH+HzppTbwHW8gXZ8MbLJj6It6pgNh41OHFhG0VeNig4nGM/o2r/b2HT3I2xIjUnyUnmLbI/On6BZIokS/QwHvlhcvzD+02xjvtbXTOmV8ND6nbJNpykig3BhRstSPI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1751618199; c=relaxed/simple;
	bh=w2oE4pOh1akyKzIgJzSCOJHT+T23QNxc7gNrBnaFFh0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=hyOLvKNqEzpUhFxq0eY5aHSb7GqgW037Ioek3Yfja1ylqN4U1KYpaPOw+hMtfqGGEj1VwDRYiLAkSE/Zq21uttAQ6drH6R5AtcGEQEtopisEtxToakylThw0p+Inqd9HydU5vRXqPhNjiyYYdUb40bZTX3XlF2EjtDOrejFdj1s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=uniontech.com; spf=pass smtp.mailfrom=uniontech.com; dkim=pass (1024-bit key) header.d=uniontech.com header.i=@uniontech.com header.b=JPJ/sWpp; arc=none smtp.client-ip=54.204.34.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=uniontech.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=uniontech.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=uniontech.com header.i=@uniontech.com header.b="JPJ/sWpp"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=uniontech.com;
	s=onoh2408; t=1751618185;
	bh=d95nx73kVtyU4RyV75KvYPcyXTaQmjFaV1z38NhfO0A=;
	h=From:To:Subject:Date:Message-ID:MIME-Version;
	b=JPJ/sWppdQuAt42JSvwi5mAkDItJ0kzLh+ZmRDstLITBOIkEK/OrXLj0cxTLJOrdo
	 a2X2Il2+kGvHWvU2kC3QUezQMskuXcDiSpYtNX5yKEb2fXgBd9wWvOcd49fmUD967C
	 iZX0xCjrQAlmWiqH2JcR5CniELT1UfBdw0xzyFRU=
X-QQ-mid: zesmtpip3t1751618170ta0779b56
X-QQ-Originating-IP: GVTrYKP7FbgWTpX/QoheMwYVtVk1rEfX3Iwi04kHrNQ=
Received: from avenger-e500 ( [localhost])
	by bizesmtp.qq.com (ESMTP) with 
	id ; Fri, 04 Jul 2025 16:36:07 +0800 (CST)
X-QQ-SSF: 0002000000000000000000000000000
X-QQ-GoodBg: 1
X-BIZMAIL-ID: 16565113001037801047
EX-QQ-RecipientCnt: 18
From: WangYuli <wangyuli@uniontech.com>
To: horms@verge.net.au,
	ja@ssi.bg,
	pablo@netfilter.org,
	kadlec@netfilter.org,
	davem@davemloft.net,
	edumazet@google.com,
	kuba@kernel.org,
	pabeni@redhat.com
Cc: netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	linux-kernel@vger.kernel.org,
	zhanjun@uniontech.com,
	niecheng1@uniontech.com,
	guanwentao@uniontech.com,
	wangyuli@deepin.org,
	WangYuli <wangyuli@uniontech.com>
Subject: [PATCH RESEND] ipvs: ip_vs_conn_expire_now: Rename del_timer in comment
Date: Fri,  4 Jul 2025 16:35:53 +0800
Message-ID: <E5403EE80920424D+20250704083553.313144-1-wangyuli@uniontech.com>
X-Mailer: git-send-email 2.50.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-QQ-SENDSIZE: 520
Feedback-ID: zesmtpip:uniontech.com:qybglogicsvrgz:qybglogicsvrgz8a-1
X-QQ-XMAILINFO: NFToOSOzJvJPUdRWuFYvA3xtNnngWCK/MdKYtqeU2XliL+CABkjlBu/r
	NHDglCmfW02t2Pqw/zDzAoIOC0bZq2+793TnV4M5V26BfcRBbiIzBEVtvsmO5a/k74QM2ia
	MfvOhQZZverk3WrGyS83rGmJ5rLsBd91QWB8NduumkJLxlmix6S7xwrhSjRPEfoaSnyPgus
	1gdMQDY+jBSpAfFl6+tSW9gfX0Hjwxb5MjgkEFUFh8LPPOAhlg9p7+rSxTgeVSwYdUw58S3
	fRbX3+5eQd5TAnf+X/PnYehg5BHwinNpenVg8WFvyQltZvNcfebTLCy/mD6udzh2fQM3/34
	ZW9ONEaf+weLoHnmwR+E4uL0Bt9NRMlulZ4MiHoyUe9xQ22nSJZT5m34FBmeyRGP1uDqscw
	vUO/Aa86dWyqAB/3m96X5HfRs8bgxbBXDO0E2ABViO3UvvPqFvkPjCJc4Rec7JJa4lyb8rQ
	lGkkK5AUSWC6wcHh5oqQKvjjPaWkn8UO6R0rjFb+5ylQTFeZ/HA0jDr4gXqV6tjqk3WazpY
	dYVEBrtpCToclT0TQdrw05bB0C947MsZOk6BeiGSX/Q9+GWQIbcYjWqe7/XXj/piLnn9Tvs
	i0t86ikm1wjvh375bxgsvMCC/mtQJnsDxsAC9M2SwrKjbwE0C49AyhAT2T7dCMiL7s1RgPn
	6TsfmOQ5JEPZc1gVQbkuYiovf5iLhhwQtBq4MkD4wNwocq62xozYh9M6yw+2/7AvNfVpWA5
	BQzd8aPjPfq04hAlCxuEaQYcgBzZk16/w0O0br6qMDzJPLVya2451RGRwfHdFrY3R9gzoXL
	cdU6pK3buqhHNfQIK67eHO68fbq9NUuepbTjMMXqsgk9HDsmVty654mW0cT6gg/FnMfNWBE
	Dn9xZo0+2Ph1M+YhieHB40qm+3cPhtLvEM/9TAefmZapefea05W6Tjv2pZ/hehXjibfWv5T
	SdH1QfSXm3uz8byrizR/7W9tA+s33Tg2wQpNL6i+mAC/nzLnBfBm9CbxEg4nAQwp7sc97nj
	hyn2b8a1YuOVJvHC2fo+6hawEpZXrdiI6qzUA0KmI6OvaA7hNtto4xRNAPomOKRfOovJD2e
	PquAjAN4QY7
X-QQ-XMRINFO: Nq+8W0+stu50PRdwbJxPCL0=
X-QQ-RECHKSPAM: 0

Commit 8fa7292fee5c ("treewide: Switch/rename to timer_delete[_sync]()")
switched del_timer to timer_delete, but did not modify the comment for
ip_vs_conn_expire_now(). Now fix it.

Signed-off-by: WangYuli <wangyuli@uniontech.com>
---
 net/netfilter/ipvs/ip_vs_conn.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 44b2ad695c15..965f3c8e5089 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -926,7 +926,7 @@ static void ip_vs_conn_expire(struct timer_list *t)
 void ip_vs_conn_expire_now(struct ip_vs_conn *cp)
 {
 	/* Using mod_timer_pending will ensure the timer is not
-	 * modified after the final del_timer in ip_vs_conn_expire.
+	 * modified after the final timer_delete in ip_vs_conn_expire.
 	 */
 	if (timer_pending(&cp->timer) &&
 	    time_after(cp->timer.expires, jiffies))
-- 
2.50.0

