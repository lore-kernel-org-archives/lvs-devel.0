Received: from mail-pz2-f12.google.com (mail-pz2-f12.google.com [74.125.228.12])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 83DC747DF8E
	for <lvs-devel@vger.kernel.org>; Wed, 23 Sep 2026 09:54:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.228.12
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790157283; cv=none; b=snbGctMZStK+CGUcWhReBgs7Quqf65Hk09ofXDTLpIxRI8O045ObraBoEPi+0ZizCPgpWOAEzipwms6mYi1AjRnBpNTYdUaqN65fYXangBwakCRVixpF8g5dZYYz02wx90cUiw8BN+Qo+lvDse9DsKV65EGdeh7hXBPxrnq+3to=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790157283; c=relaxed/simple;
	bh=+HYS3dvKzoXKXK40VmtMXbgr0IQRMY8SAmPFPgXydIc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=k3ai08m4tPV2vDMw377kzFpwpRQWi1R4zt/VA5lVy+MGUGOVRhexjsHxiQBuJAJrKMwRoeNfJv5n3OWefgi99LV0DZt3pDrtiDWjHePipEOpQa5Ajt0/c7k/VjJRn/kiNUHrAbd3CsNoSe5z6IEJuC6XuvgXDJJqf53bTz5POUQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai; spf=pass smtp.mailfrom=nebusec.ai; dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b=WUBJPao1; arc=none smtp.client-ip=74.125.228.12
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nebusec.ai
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nebusec.ai header.i=@nebusec.ai header.b="WUBJPao1"
Received: by mail-pz2-f12.google.com with SMTP id 41be03b00d2f7-cc4d2fe2056so359042a12.2
        for <lvs-devel@vger.kernel.org>; Wed, 23 Sep 2026 02:54:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=nebusec.ai; s=google; t=1790157280; x=1790762080; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=NcjbznsDNqQjucWemj8GXAQz8O/NVaZRIfNms8EzTJY=;
        b=WUBJPao1nKCo6+v6kyemAzTI9rLczPqkO1XFflfuRQBEx37DSl7CId9ytkFjc5pMei
         sdUvomRgPXuj/sIQT4AkMD/O+4N6GrkqvMVQ2EDlj57PVMGE4CD8Jn4pk0FA7DGFTb9j
         fTCnlsdJiXzTkSlB6vpdAjbCypz/5RuHvoEJH/zVZJUtgmsP3/t4Y6MbZdHSZmLRvSFF
         W0Gylz09fUihZkUk6EP5OlAz6HEc8LJ8meMHrLocHSTdIPWUtDXQGKrtkK1WFHVyxBfW
         ZwJA1ekPG8q1kdzcyzxbKK/nR//MxJFPw28isSuKObJAFVR0ofL1fsZXhoDkUc29FI7n
         7I2Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790157280; x=1790762080;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=NcjbznsDNqQjucWemj8GXAQz8O/NVaZRIfNms8EzTJY=;
        b=n9BD4P9GZhmXr9NK3EQqzBopaCYMqcjHOOA8ch/suYhg/0CYVgYU+lvTdQ/cHubZ0F
         1J03iS3YmbAVjLvlYiJneFRslgBQVjuETkrLPiwLSpssI8FY7VN/eE1V5ty8ajWi+Dic
         wfgAH62qQZT5v+fxOL84+7eakB33dzjLDFK3aCVPCn0ibYYYyltxNHqXMKKjf3gpmw2B
         O6YEGkswdJ+bgT3GfCMDWMHs3r6pXoxeei4JeX3EKw3udYhtpwlqWUYyks0FsiuT1i0K
         10MRgyoKDYuCAKeXRgpB5cOpt6R/q8RZaWMYi0sgmwMU8AgaHCnR0V2ljvnADhuEpYci
         E8LQ==
X-Forwarded-Encrypted: i=1; AKwUvByEIbcoBBzkbfpjvlUtJFd1NEVyYKvhuj5vf18nJsswAEgMixEVgBdTDrgUAN5APt93HQFF02RuGGA=@vger.kernel.org
X-Gm-Message-State: AFuF++kT8y91+69nZ0btXoYSVUvZT+D6w+lkgYrFLpedMWgJ9douePee
	zKEQ4tGH4wr5mBAO2gkIKlYfXP5HBfpbrC5ryLpvpjZieKO7DS2K45xdO6ZfBW98AZE9
X-Gm-Gg: AYBFou0EiHR6i7kK1MvQpEy1RcfYEVG4QR9mTEFQpvCk77y1I6q3nVHmfZ4SKPEruSN
	9JKz/xH1Me21A1a+REE0ha+/N5oShHlV7/l1m8Ls6QoI2C2EoUp1U02W9PDkFIYYyfLK9PCr3r3
	/p4bYoXXthXUKAc80mputDC5rsaV3JWmg5FVUQU3DhetmaErizqrphw4NJOrMbc7h5Sx7lcinpH
	CRS203TxYyTdHPwzYj0GGbm4eC4jXnuNQNu7fzoTkdUuHjA75GFJbqV0ndcKztq1y6ofrxpebSI
	JDh3jy8k8MtynXcNppnA2UYEcrEU7erKcJ5XhDIsxranVQjse8njN5CMX8n7daHxQLKy3YTRpkY
	gRzfgavoGaHKhmuNxZy5YqpnUpMoVNRrhnHThBg4i2V+OBUEwlItNg3SwP+ttZf08vc11aC3nx2
	4nLLhAvkThcGXk17owIhcMccxm/v5rVqPNFHr+yvVGpdo2GZjZ9vF7DUWIt8x29DJYC5/vmyVsC
	i7bZsihFpzsTkET5Mxw/QQOOeODHQ==
X-Received: by 2002:a17:90b:164a:b0:39e:35a0:9c0f with SMTP id 98e67ed59e1d1-3a07e568a6fmr1766161a91.14.1790157279865;
        Wed, 23 Sep 2026 02:54:39 -0700 (PDT)
Received: from 954df21a5119.. ([122.51.212.64])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3a07dc5f3d7sm4793862a91.16.2026.09.23.02.54.34
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 23 Sep 2026 02:54:39 -0700 (PDT)
From: Zihan Xi <zihanx@nebusec.ai>
To: netfilter-devel@vger.kernel.org
Cc: netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	coreteam@netfilter.org,
	linux-kernel@vger.kernel.org,
	horms@verge.net.au,
	ja@ssi.bg,
	zihanx@nebusec.ai,
	pablo@netfilter.org,
	fw@strlen.de,
	phil@nwl.cc,
	davem@davemloft.net,
	edumazet@google.com,
	kuba@kernel.org,
	pabeni@redhat.com,
	stable@vger.kernel.org,
	Vega <vega@nebusec.ai>,
	Luxing Yin <root@tr0jan.top>
Subject: [PATCH nf v4 2/3] ipvs: avoid stack overflow from recursive connection expiration
Date: Wed, 23 Sep 2026 09:54:14 +0000
Message-ID: <8d33e2a83fa6f2fb6419b3f34cd3ff8677684a31.1790146910.git.zihanx@nebusec.ai>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <cover.1790146910.git.zihanx@nebusec.ai>
References: <cover.1790146910.git.zihanx@nebusec.ai>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When a controlled IPVS connection expires, its controller may be expired
synchronously if it has no remaining controlled connections. A chain of
controlled connections can then recurse through ip_vs_conn_expire() and
exhaust the kernel stack during namespace cleanup.

Continue expiration with the controller after the current connection has
been fully cleaned up instead of calling ip_vs_conn_del() recursively. Keep
the expiration walk under RCU, preserve the immediate-drop timeout for a
controller with its own controller, and switch to deletion mode before the
next iteration.

This keeps controlled-connection cleanup synchronous while using one stack
frame for the whole chain. The timer callback race during connection
deletion is handled by the preceding refcount fix.

Fixes: f9200a52eedf ("ipvs: avoid expiring many connections from timer")
Cc: stable@vger.kernel.org
Reported-by: Vega <vega@nebusec.ai>
Assisted-by: LLM
Co-developed-by: Luxing Yin <root@tr0jan.top>
Signed-off-by: Luxing Yin <root@tr0jan.top>
Signed-off-by: Zihan Xi <zihanx@nebusec.ai>
---
changes in v4:
  - Rebase the iterative controller cleanup on the timer-callback fix.
  - Keep the controller walk synchronous and switch to deletion mode for
    the next iteration.
  - v3 Link:
    https://lore.kernel.org/all/cover.1789877273.git.zihanx@nebusec.ai/
changes in v3:
  - Handle the timer-callback race while keeping controller cleanup
    iterative and synchronous.
  - v2 Link:
    https://lore.kernel.org/all/cover.1789435989.git.zihanx@nebusec.ai/
changes in v2:
  - Replace recursive controller expiration with an iterative repeat path.
  - v1 Link:
    https://lore.kernel.org/all/cover.1789110326.git.zihanx@nebusec.ai/

 net/netfilter/ipvs/ip_vs_conn.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 32cfc02aa2912..f85752e79ed92 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1357,6 +1357,9 @@ static void ip_vs_conn_expire(struct timer_list *t)
 	struct ip_vs_conn *cp = timer_container_of(cp, t2, timer);
 	struct netns_ipvs *ipvs = cp->ipvs;
 
+	rcu_read_lock();
+
+repeat:
 	/*
 	 *	do I control anybody?
 	 */
@@ -1366,19 +1369,20 @@ static void ip_vs_conn_expire(struct timer_list *t)
 	/* Unlink conn if not referenced anymore */
 	if (likely(ip_vs_conn_unlink(cp, my_cb))) {
 		struct ip_vs_conn *ct = cp->control;
+		bool next = false;
 
 		/* does anybody control me? */
 		if (ct) {
-			rcu_read_lock();
 			ip_vs_control_del(cp);
 			/* Drop CTL or non-assured TPL if not used anymore */
 			if (!cp->timeout && !atomic_read(&ct->n_control) &&
 			    (!(ct->flags & IP_VS_CONN_F_TEMPLATE) ||
 			     !(ct->state & IP_VS_CTPL_S_ASSURED))) {
 				IP_VS_DBG(4, "drop controlling connection\n");
-				ip_vs_conn_del(ct);
+				if (ct->control)
+					ct->timeout = 0;
+				next = true;
 			}
-			rcu_read_unlock();
 		}
 
 		if ((cp->flags & IP_VS_CONN_F_NFCT) &&
@@ -1405,7 +1409,12 @@ static void ip_vs_conn_expire(struct timer_list *t)
 		else
 			call_rcu(&cp->rcu_head, ip_vs_conn_rcu_free);
 		atomic_dec(&ipvs->conn_count);
-		return;
+		if (next) {
+			cp = ct;
+			my_cb = false;
+			goto repeat;
+		}
+		goto out;
 	}
 
   expire_later:
@@ -1422,6 +1431,9 @@ static void ip_vs_conn_expire(struct timer_list *t)
 
 		__ip_vs_conn_put_timer(cp);
 	}
+
+out:
+	rcu_read_unlock();
 }
 
 /* Modify timer, so that it expires as soon as possible.
-- 
2.43.0

