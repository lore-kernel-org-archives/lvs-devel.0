Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=162.62.57.49
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793612360;
	b=tpBLg87X7EbozDHMXEakqgrq14O0BsXPQKfGgDXuV9GEDkfLE8lqUju5RL46uB7b3Z1z
	 qJQP/mWdxzkiEM4cCOdg0fPqI6I7U/II1N9F5FPiDeOsjMpjUgj3r5J/x25ha4zKM4XbT
	 Mu/stizO5xnK7rHIyGfLPzs2PLeH6AYwReAhTM1Kkye+vBSAOeKgbOa+0bWEnVCXMPCmt
	 lBjnNxh3txVSczlPaFQSjU0vETuN4DTFTCug6i5jXzIUaGg+UfIV6UoT3AG+4FgEkBFUU
	 0D/JrbMiGQwffGJ5cz+N//Ku2ms2bal/HB60Im0dHVBqtRgVxsF4O7sW+vsDOwcGlBQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793612360;
	h=DMARC-Filter:DKIM-Signature:Received:X-QQ-mid:Message-ID:
	 X-QQ-XMAILINFO:X-QQ-XMRINFO:From:To:Cc:Subject:Date:X-OQ-MSGID:
	 X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=idDGnToHTI8V01eTL1ZKlhBmpecIfWRGMl5+8+8jY9k=;
	b=xqybCVidy1HCmBMxiuf+QLXLcqdHZrHinJvT5KZ0+vivEgvvIHwqerei3r4ZPO8c4ATy
	 3RDL8LTgfPWF01TgWMIBx+4SOoE8Cp7r2DWqr1DUbUneL4EGTb73gTqm3Re87XIIybrxC
	 oO/T6fUXpWBeMD7lAXdo/9TF+0mlt3926kIGqtpVMw8efM29lDIGE32zRP9KFVx+IdX4F
	 rCWHG3fwqFfpcQng04/Rci240Bhl8iPOL+QORIRnA2TFFz86DSYXK0OfBRjiIB88kQJc/
	 1fuJohlMu8mHbyLRNaClOakXoGBi7nEsMSDGOhcYY58yPi+xuZrQ3giIye7el/ukfaA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=qq.com;
	spf=pass smtp.mailfrom=qq.com;
	dkim=pass header.d=qq.com header.i=@qq.com header.a=rsa-sha256 header.s=s201512 header.b=VeHNBXJT;
	arc=none smtp.remote-ip=162.62.57.49
Received: from out162-62-57-49.mail.qq.com (out162-62-57-49.mail.qq.com [162.62.57.49])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B62AB606A327;
	Mon,  2 Nov 2026 09:39:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B62AB606A327
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=qq.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=qq.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=qq.com header.i=@qq.com header.a=rsa-sha256 header.s=s201512 header.b=VeHNBXJT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=qq.com; s=s201512;
	t=1793612353; bh=idDGnToHTI8V01eTL1ZKlhBmpecIfWRGMl5+8+8jY9k=;
	h=From:To:Cc:Subject:Date;
	b=VeHNBXJT/CFXEafMjdxMDvY5icqoR19231o1XUT0p5HjBno+QzDtmsqYJg+DqRZoc
	 mIi9cAq6xEGNNY5U3KH7TkpZHZeMutRw3udbtiECRnDcAAcw/edaiP7VBvUny1cTMD
	 pAxmr2tBzO+8J2X52Gg6kM/iXtqQFhEzaXksoMlE=
Received: from kernel-lab.tail5e91bb.ts.net ([2409:8950:57d:63:3bd5:e9be:8454:44da])
	by newxmesmtplogicsvrszb51-0.qq.com (NewEsmtp) with SMTP
	id 9CA0D2E2; Mon, 02 Nov 2026 17:39:10 +0800
X-QQ-mid: xmsmtpt1793612350twko5wxud
Message-ID: <tencent_C567615098D5B2A71811CFE5CB09C9FFC406@qq.com>
X-QQ-XMAILINFO: MpvrJ5NyRx5i+FftzjWdGeZJywDh85miewFWjFJ9YsCv0nyi2QKfczPHfkMWUY
	 uuVPPwe96DLLr+l2mB4VYGUSzxmf0idoH8lEVKoIoo4qUB+g4YyhqGDMwkcyjBaxiRe8JGVhX7Ee
	 Z1QRllWMGxPX8ox5lleEE0XVY+SbsiCrkSaLji1Xz+QrgxrnC/BGEcF6ls88u+u4MAm9vp64aNuu
	 lB7eLJXg9wrG/grdxSYMZ4g1CrFZl21Y18ePF/P79JRKUP27oZWjLp+krpHrEXvIUQmdzm4UvQ2/
	 KVhjIb4nNskUXglYhFwaCNWNtiGpfMjDh9L/tVqxYmnya3tZFox0yHf+TcPpGlNOAqP/07Ubq45t
	 jgpF7L7bcY7/mURr4sa07hDm6n/iZebQP2hLgD7Od6pywXccF6Rfk5qXlYWh8S3LPduFdYv+hFJr
	 ehwBdXL0hRK51YXfALtQSeLBZJ2w6MFeiJiKia/RhveP/Ogzpq9pvnfozaiL4C3n/JjXIxxvWy7H
	 8P+5DwEEzRZo44hYUismQ3Hk9nW6kyFH2NWFLpRJXlvIA0npB+jYSz/prL7ZxI/W31u8WCgnuJPH
	 AOlbzpcjPtTA6lHRrJ7/gged1Lp5JwywKEKw1Sa5lA4bMwHGzrzDdiWvNKmhgWDlOm3Apim15VR7
	 bMb30njK4eJ3L6uwpBkwfUFlpvxnoPN67Z2MV9AOPoTw3wCt2/ha/JUQOMo+TdpeXFIF3cXELoC5
	 UzLBPxFJycS7OqrRTWY1gXZwE3MBlCe1uxqM+mhYTWnTWd4NyhIhAEmGMcSeuwW8uCMPVAoTVgyv
	 QhX52O8dkkBL0+rc6rqpgHJfdqmC53X/+tIpj/JR8VN4luAESdCRXQe759CDPIOWiDh8wD5IBGW/
	 HMZDZ7EJn65KilunvqSV/EtYg4jBzpdJ8f+/PF6lK36kufqie7iCKSxXl3+uZCPPiSLP10GJkBlu
	 UZW+UdRKBWh1pO2vGfZ01k2IjznXTkXnR91d0u0aGlZdQra2wF92XrqHFoT23Jpp3cSsPycToxdZ
	 Lb0Bvk1TDaOKz6oNGx1glA08YrbppzEVIB5HLuCCeIEytBAfsf
X-QQ-XMRINFO: MPJ6Tf5t3I/ylTmHUqvI8+Wpn+Gzalws3A==
From: Yingjie Wang <1075151112@qq.com>
To: lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org
Cc: horms@verge.net.au,
	ja@ssi.bg,
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
Subject: [PATCH net] ipvs: reject negative sync_refresh_period values
Date: Mon,  2 Nov 2026 17:39:09 +0800
X-OQ-MSGID: <939bfbcb4fd7692b2fd50515a21b2b9995a5bf1c.1793612333.git.1075151112@qq.com>
X-Mailer: git-send-email 2.43.0
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
 include/net/ip_vs.h            | 7 ++++---
 net/netfilter/ipvs/ip_vs_ctl.c | 8 ++++++--
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 9a83bff32569..66f26c3d1f75 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -19,6 +19,7 @@
 
 #include <linux/compiler.h>
 #include <linux/timer.h>
+#include <linux/jiffies.h>
 #include <linux/bug.h>
 
 #include <net/checksum.h>
@@ -1267,7 +1268,7 @@ struct netns_ipvs {
 	int			sysctl_sloppy_sctp;
 	int			sysctl_expire_quiescent_template;
 	int			sysctl_sync_threshold[2];
-	unsigned int		sysctl_sync_refresh_period;
+	unsigned int		sysctl_sync_refresh_period; /* seconds */
 	int			sysctl_sync_retries;
 	int			sysctl_nat_icmp_send;
 	int			sysctl_pmtu_disc;
@@ -1335,7 +1336,7 @@ struct netns_ipvs {
 #define DEFAULT_SYNC_VER	1
 #define DEFAULT_SLOPPY_TCP	0
 #define DEFAULT_SLOPPY_SCTP	0
-#define DEFAULT_SYNC_REFRESH_PERIOD	(0U * HZ)
+#define DEFAULT_SYNC_REFRESH_PERIOD	0U
 #define DEFAULT_SYNC_RETRIES		0
 #define IPVS_SYNC_WAKEUP_RATE	8
 #define IPVS_SYNC_QLEN_MAX	(IPVS_SYNC_WAKEUP_RATE * 4)
@@ -1363,7 +1364,7 @@ static inline int sysctl_sync_period(struct netns_ipvs *ipvs)
 
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

base-commit: cb284914e749388eef402938bdb3115fe1f6d337
-- 
2.43.0

