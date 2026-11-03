Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=162.62.57.137
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793722565;
	b=FEzFX0Yx6Th35N07wka2S10a/gAwyddAgH678ARVHaSD9iO6nirtyfbCU3aMXR7wp8yi
	 Yqr20yyv+XdknEmVckDr4PCdg34SVEdw02oFzmuFK6t0QYmk1nxurgi58TOh0BZFhz4v2
	 oAVQVrfvPykZK88sdDF8NUE1TKZxcCsqo4D9kmak26cdRVlv3i76d9LVwIbqUg6vRlj4A
	 QgG/c+LsBDvWWH1T2Riysam44Rg46L3g1zR2tlD8/G25gF7Fp+7xF6lHt7QgOQAdqW/7v
	 lo2kB2eZdUjLhPtSIWNBQctOao0nFh2osR8QFJdOt6hvh5J3CP97Nyui0P283XEy/RA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793722565;
	h=DMARC-Filter:DKIM-Signature:Received:X-QQ-mid:Message-ID:
	 X-QQ-XMAILINFO:X-QQ-XMRINFO:From:To:Cc:Subject:Date:X-OQ-MSGID:
	 X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=9LM7bW7BvJgw4gfAeBXkU89NfwFVZbgW9lWUN8AzG5Q=;
	b=FwBeHQ20ZeUFXT8IzHxpEYyGqTAp0pw9aQ4s061MZR87oU1WG9arbhUANKT12kHaPWX5
	 u48s7KNiEgTtrSYI0qqcSzKrx0+vETr6s4JQfJZp+o7neWCfR6z/pzvSAmAfGUDWh2qze
	 Iw+IecEzOPocXw2TyCpXh6P57UkXuKOOFelBQZzhKAcZjyXxC0RIyboq3jzHMxAZY3/C8
	 ugKt2ZocVFT0FNCW+hMf1RFAvx/acv+1cneoSDG9GjoFnCtZ/iEPdPZQKt0iqDgtNXrPv
	 hsMP1Q6S/zBcHg4DShtXVc4nZr56GrvwuS+lfWEYN7h7b6lNn6dnBZjGP4ceIYzV1Pg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=qq.com;
	spf=pass smtp.mailfrom=qq.com;
	dkim=pass header.d=qq.com header.i=@qq.com header.a=rsa-sha256 header.s=s201512 header.b=qph3Iegx;
	arc=none smtp.remote-ip=162.62.57.137
Received: from out162-62-57-137.mail.qq.com (out162-62-57-137.mail.qq.com [162.62.57.137])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C7463606A332;
	Tue,  3 Nov 2026 16:16:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C7463606A332
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=qq.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=qq.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=qq.com header.i=@qq.com header.a=rsa-sha256 header.s=s201512 header.b=qph3Iegx
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=qq.com; s=s201512;
	t=1793722553; bh=9LM7bW7BvJgw4gfAeBXkU89NfwFVZbgW9lWUN8AzG5Q=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=qph3IegxGiV35MCw5XBbvK/cAxl2YBMIanem09v3elODGZ/Tw7LYPre8xNLVFv5gO
	 ReTudtNbbiI5WocjfmtG884qE8vzE+Xd946FSFPzPoc4nlQjOqbx5WQ8fghMyimB6I
	 Gxk8VtSr9bzEp5ROOORtDB4T89NaHnhOPOTnCm5k=
Received: from kernel-lab.tail5e91bb.ts.net ([2409:8950:57d:63:4bda:7622:58c1:3569])
	by newxmesmtplogicsvrszc43-0.qq.com (NewEsmtp) with SMTP
	id 3F1850EE; Wed, 04 Nov 2026 00:15:49 +0800
X-QQ-mid: xmsmtpt1793722549tp9bgxq3r
Message-ID: <tencent_9109FFF19F0341A556269E694408976E2708@qq.com>
X-QQ-XMAILINFO: N/WmRbclY25Gc3Kg9n4OQQwOYiQ/YgRH6M/jRKFHKIayuWGMjDc8UcWKTobeoG
	 lCEcSoMmSfLNQk6YsvQzBBiSRTD6/O/ISt+Ox7HlY+3ODnN+iH/wJE96p9P+7UiVfvoiCYxw6+3M
	 PqnkTPB39fGg6gbqBleP3ViOlXJyDwPj6IFptVdENtxZERHliCJ4e7RE0DtXLl5FrxzNPCuGolqY
	 l3id8M94eW/j45OkYgdC21RcyeuuaX++7fIptX7ZJX1dK3eabxcODTwnAQyGKk9CTNYjs0nDbHpG
	 Ly39dRlED0t9fsOkXPhhxTCmvAG9upjbLU0IXcrttMiGqXqAN5RGqU+cipk3kYLMtFcG5Io2pjB6
	 tx9SIjfZwfxFrLd1ncZTjSJmHqtHSs5QGKvSuRconbpeN+WHTeyKx3AtltFCAA/dkIIvlSBnJxic
	 Q9xoGthgG3mkSDoeW/NoHxji3jrG4DxHeoO0q+Dt/byt+I0+Kh/r9ydbZPT5yBexyrH19LS3WfgK
	 tCyY46v1ZuNAQiJgbh91l6KEYUrEWi67O/HdfY6PlSWQVoD5388BtWv1T04tfJ7weU5dRz9cRib9
	 3/NAQUazL5nfQwI7RdhERggVI+V1vYrJ6lJD7uBrZ1A9VOLSiQw31Wq6LRVdn9YnGuinASCr62tU
	 rsjpDd2ltDNURW6dFFvDhv74ECOiDSMtUzTnNgN24BAfP8yCWW3pVFJ4KiqzACpUsAznc+bAtjis
	 lC+xUgFMXig7UdEUmyZURjoVWhDX6NM04wDULg/XflSvrSMEkocfQPTg0rk2efUEwYwXYwlIWkuC
	 AaPNnp9GvB57+SuKbOKPfCcGypDCxCEoOD6vLYuxu8iW4e0LRFeIqT2frbm3egj9ye96y3gnh6Ot
	 nKzSiSvdMUkYrrOMGjMtihOyUhZVKWhjpYSlRVjKfL0NlJw4BswwE5AVM1dExm8niwZBBoTGANG3
	 0O7hSi8hfLqBtmXq7nzuK23H7UwcIRnDeLu6T0Dq4tDEaT83DHNQNb24gLOqW7dAvee2OaLh7+rs
	 Nrg876DE0/5LgNIHirJfFXZ5GxhbtdkwMV7eRX6ITj4D/dgQI+7PzYsStTffagXjDMxU2mXg==
X-QQ-XMRINFO: OD9hHCdaPRBwH5bRRRw8tsiH4UAatJqXfg==
From: Yingjie Wang <1075151112@qq.com>
To: lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org
Cc: horms@verge.net.au,
	ja@ssi.bg,
	dsahern@kernel.org,
	idosch@nvidia.com,
	pablo@netfilter.org,
	fw@strlen.de,
	phil@nwl.cc,
	davem@davemloft.net,
	edumazet@kernel.org,
	kuba@kernel.org,
	pabeni@redhat.com,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH nf v2] ipvs: reject negative sync_refresh_period values
Date: Wed,  4 Nov 2026 00:15:49 +0800
X-OQ-MSGID: <bc742c371e85fbb5fc60bc79868a10b1d03aaf58.1793722537.git.1075151112@qq.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <tencent_C567615098D5B2A71811CFE5CB09C9FFC406@qq.com>
References: <tencent_C567615098D5B2A71811CFE5CB09C9FFC406@qq.com>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

net.ipv4.vs.sync_refresh_period is documented as an unsigned number of
seconds.  proc_dointvec_jiffies() accepts a signed integer and converts
it to jiffies before storing it in an unsigned int field.  Consequently,
writing -1 stores UINT_MAX - HZ + 1 jiffies and bypasses the finite
bound applied to ordinary positive writes.

This changes the behavior of ip_vs_sync_conn_needed().  With
sync_threshold="0 1" (threshold 0, period 1) and
sync_refresh_period=-1, only the first of twelve packets requests a
sync message; the zero-refresh control requests all twelve.

Store the value in seconds, as documented, and convert it at the single
consumer.  Use proc_douintvec_minmax() to reject negative input.  Cap the
value at INT_MAX / HZ to preserve the prior jiffies range and avoid
overflow in secs_to_jiffies().

The issue was reproduced on an affected 7.0 distribution kernel in a
temporary network namespace.  A patched target kernel was built with W=1
and exercised in QEMU; -1 is now rejected with EINVAL, zero and positive
values retain their behavior, and the HZ=1000 boundary accepts 2147483
while rejecting 2147484.

Fixes: 749c42b620a9 ("ipvs: reduce sync rate with time thresholds")
Cc: stable@vger.kernel.org
Signed-off-by: Yingjie Wang <1075151112@qq.com>
---

Notes:
    Changes since v1:
    - Drop the unnecessary <linux/jiffies.h> include.
    - Rebase on current net/main and use the nf target tag.
    
    Link: https://lore.kernel.org/r/tencent_C567615098D5B2A71811CFE5CB09C9FFC406@qq.com/

 include/net/ip_vs.h            | 6 +++---
 net/netfilter/ipvs/ip_vs_ctl.c | 8 ++++++--
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 9a83bff32569..b6834542489a 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1267,7 +1267,7 @@ struct netns_ipvs {
 	int			sysctl_sloppy_sctp;
 	int			sysctl_expire_quiescent_template;
 	int			sysctl_sync_threshold[2];
-	unsigned int		sysctl_sync_refresh_period;
+	unsigned int		sysctl_sync_refresh_period; /* seconds */
 	int			sysctl_sync_retries;
 	int			sysctl_nat_icmp_send;
 	int			sysctl_pmtu_disc;
@@ -1335,7 +1335,7 @@ struct netns_ipvs {
 #define DEFAULT_SYNC_VER	1
 #define DEFAULT_SLOPPY_TCP	0
 #define DEFAULT_SLOPPY_SCTP	0
-#define DEFAULT_SYNC_REFRESH_PERIOD	(0U * HZ)
+#define DEFAULT_SYNC_REFRESH_PERIOD	0U
 #define DEFAULT_SYNC_RETRIES		0
 #define IPVS_SYNC_WAKEUP_RATE	8
 #define IPVS_SYNC_QLEN_MAX	(IPVS_SYNC_WAKEUP_RATE * 4)
@@ -1363,7 +1363,7 @@ static inline int sysctl_sync_period(struct netns_ipvs *ipvs)
 
 static inline unsigned int sysctl_sync_refresh_period(struct netns_ipvs *ipvs)
 {
-	return READ_ONCE(ipvs->sysctl_sync_refresh_period);
+	return secs_to_jiffies(READ_ONCE(ipvs->sysctl_sync_refresh_period));
 }
 
 static inline int sysctl_sync_retries(struct netns_ipvs *ipvs)
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index ce9fe20d6106..82726b6b5e3a 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2369,6 +2369,8 @@ static int ip_vs_zero_all(struct netns_ipvs *ipvs)
 
 #ifdef CONFIG_SYSCTL
 
+static unsigned int sync_refresh_period_max = INT_MAX / HZ;
+
 static int
 proc_do_conn_max(const struct ctl_table *table, int write,
 		 void *buffer, size_t *lenp, loff_t *ppos)
@@ -2824,9 +2826,11 @@ static struct ctl_table vs_vars[] = {
 	},
 	{
 		.procname	= "sync_refresh_period",
-		.maxlen		= sizeof(int),
+		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
+		.proc_handler	= proc_douintvec_minmax,
+		.extra1		= SYSCTL_ZERO,
+		.extra2		= &sync_refresh_period_max,
 	},
 	{
 		.procname	= "sync_retries",

base-commit: 647b81ddefc6364290e67bf33c89d54971f8995e
-- 
2.43.0

