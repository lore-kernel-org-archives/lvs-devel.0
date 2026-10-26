Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=117.135.210.8
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793003921;
	b=zulY26lsOaPU4/yscFtJF24LRzqIPmMh7sQ/zTIb2yjH/o8DH34x4uDBYOr0rJZGkW/c
	 nV7+Fk6dvZLY2epAI8S8sQhdbNdb4dd/WE+/kWpTrq/xRBGM5yDjhmZwEIZAdnVL+8LkD
	 OPFy4KYHo2Smxnu9f8Ab24jirWTlwLqreMYmDuKiETjhkbATFYLPmK8w4Q5xFniKlVNCX
	 JDU6J6xKTrmiEZSiJ/LQveR4RDYL9DvDVHs5m3AfjsnLxEZDg281MTPknlWovz/9fL7+1
	 8HdPeFF/bDDFn+n/TbF0a5AC/BmZbWZikh61fwm4PeotZRNFL8OHhjWOhjfuZjV0XvA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793003921;
	h=DMARC-Filter:DKIM-Signature:Received:From:To:Cc:Subject:Date:
	 Message-Id:X-Mailer:MIME-Version:Content-Transfer-Encoding:
	 X-CM-TRANSID:X-Coremail-Antispam:X-CM-SenderInfo;
	bh=coeVfKNB1bEP2tEL7RGoajkOYYpgAEhPrKIKA7ffVew=;
	b=oLZcPTBSKgmn14+fKpF//YLkEdtVfuGVVthCvVQAobXQnJmrhLNpvBwQ+GgLUTG8kT3O
	 Ox9vBNUsgPXOhZrn7h0HZpSlZomKQgVHhpCvZjKhZAvTmjUwrbqx8eMgloQ3yhGR+M18y
	 9OIuMLtRm27hKO2CqP2C8Ub9WqKEKvFq/UFHNf29BEoDCPszXFVoqcxSyNgCf1Xvn9OFt
	 O+wU89ZVhKyKA+bC5a1+XdiBTPlUxWvS1Gajo+hdSyFl2+HmL4NgRiuerrE8WabCLsUPd
	 PyJCKAQzNgTIHn74MNAKKJjfLemI3YbKHXAhhIW3dSrgnQ5EQgvdkfu+fLEtyKWcKjA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=126.com;
	spf=pass smtp.mailfrom=126.com;
	dkim=pass header.d=126.com header.i=@126.com header.a=rsa-sha256 header.s=s110527 header.b=HjYoLhxe;
	arc=none smtp.remote-ip=117.135.210.8
Received: from m16.mail.126.com (m16.mail.126.com [117.135.210.8])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CA3D2606A31A;
	Mon, 26 Oct 2026 08:38:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org CA3D2606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=126.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=126.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=126.com header.i=@126.com header.a=rsa-sha256 header.s=s110527 header.b=HjYoLhxe
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=126.com;
	s=s110527; h=From:To:Subject:Date:Message-Id:MIME-Version; bh=co
	eVfKNB1bEP2tEL7RGoajkOYYpgAEhPrKIKA7ffVew=; b=HjYoLhxecT72kvAGe2
	3UKM8NdPrKHWEUYKWFDOs+c9R5ulO1pd+ZyybInYPo4dTCHiB54/7YBDJVPl02Lj
	o0OCAMwIHf//S7UE2f/2iouj/aIUn2/W8vQmAk0Q7avlEty9yUHKcJOhD+TtYzqw
	/h2R6RdhFPO+vsHFD25D0t/jU=
Received: from localhost.localdomain (unknown [])
	by gzsmtp3 (Coremail) with SMTP id PikvCgD3v_01Ed9qmtQJCQ--.65058S2;
	Mon, 26 Oct 2026 16:37:11 +0800 (CST)
From: Linkui Xiao <xiaolinkui@126.com>
To: horms@verge.net.au,
	ja@ssi.bg,
	dsahern@kernel.org,
	idosch@nvidia.com,
	davem@davemloft.net,
	edumazet@kernel.org,
	kuba@kernel.org,
	pabeni@redhat.com
Cc: netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Linkui Xiao <xiaolinkui@kylinos.cn>
Subject: [PATCH net-next] ipvs: annotate the lockless read of sysctl_sync_threshold[0]
Date: Mon, 26 Oct 2026 16:37:08 +0800
Message-Id: <20261026083708.617278-1-xiaolinkui@126.com>
X-Mailer: git-send-email 2.25.1
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
X-CM-TRANSID:PikvCgD3v_01Ed9qmtQJCQ--.65058S2
X-Coremail-Antispam: 1Uf129KBjvJXoW7ZF15Cw43Zw47uw4DJF17GFg_yoW8tr4xpr
	W5Jr9xAr4Du3y7Xr4DJFy29rWSvw4kG3y7KF98Kr4rA3WDJr98trySyFy0kFW29rn7AFWS
	vFZ8ta4Fka98AFJanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDUYxBIdaVFxhVjvjDU0xZFpf9x07UlhFsUUUUU=
X-CM-SenderInfo: p0ld0z5lqn3xa6rslhhfrp/xtbBqBfjumrfETfT4wAA3F

From: Linkui Xiao <xiaolinkui@kylinos.cn>

sysctl_sync_threshold() reads ipvs->sysctl_sync_threshold[0] from the
packet path without any synchronization: ip_vs_sync_conn_needed(),
ip_vs_sync_conn_v0() and ip_vs_sync_conn() run in softirq context on
behalf of ip_vs_in_hook(), ip_vs_conn_expire() is a timer callback and
ip_vs_proc_conn() runs in the backup sync kthread. The only writer,
proc_do_sync_threshold(), updates the array with a plain memcpy() while
holding ipvs->sync_mutex, a mutex none of the readers ever take.

Commit 749c42b620a9 ("ipvs: reduce sync rate with time thresholds")
already recognized this race, but only for the second element of the
array: "As the sysctl_sync_period now can be 0 use ACCESS_ONCE to avoid
division by zero". sysctl_sync_threshold() was left with a plain access
even though both elements live in the same array and are written by the
same memcpy().

A stale value is not dangerous here: the element is only compared
against a packet counter and stored into cp->in_pkts, and an aligned int
cannot tear on any supported architecture. What the missing annotation
does allow is for the compiler to reload the element, so the two
comparisons in ip_vs_sync_conn_needed() can observe different values
for one and the same packet, and KCSAN reports the unsynchronized
access.

Read the element once with READ_ONCE(), exactly like the adjacent
sysctl_sync_period() has done since 749c42b620a9.

Fixes: 749c42b620a9 ("ipvs: reduce sync rate with time thresholds")
Signed-off-by: Linkui Xiao <xiaolinkui@kylinos.cn>
---
 include/net/ip_vs.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 9a83bff32569..5aa6a94ed104 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1353,7 +1353,7 @@ static inline int sysctl_conn_max(struct netns_ipvs *ipvs)
 
 static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
 {
-	return ipvs->sysctl_sync_threshold[0];
+	return READ_ONCE(ipvs->sysctl_sync_threshold[0]);
 }
 
 static inline int sysctl_sync_period(struct netns_ipvs *ipvs)
-- 
2.25.1

