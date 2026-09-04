Received: from mail-pg1-f177.google.com (mail-pg1-f177.google.com [209.85.215.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9E8A336D500
	for <lvs-devel@vger.kernel.org>; Fri,  4 Sep 2026 11:45:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.215.177
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788522348; cv=none; b=gydPuJPWfzxrFFe693dx/AwpUzBm4cyagw+Ry6vFYlcfzkD3IQVROgDD2Bvw5+FL7nWXuB+95L3Qg0++AskAsyZs4cN9bXWrccC6/pAgElHOycTqR1reLgHk0TyIj+7umlPe7TViy1dXAApk/U0fpgnxIDWv/c3JoqkBUZn2O4s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788522348; c=relaxed/simple;
	bh=4DYiEOsZKjx/4f4PSXfRJejITB67NJXF4cNdrqZROfk=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=aD3gBLc1+kw3n6r91CAJQKaxLOMYUuqZ5WXJwQqvdoXOaTQoGORjeDZiVFnw6XOOiH0lBaPL1IDGJA1DVoNKyG4mRFSaZRNVRkd0GZu7Ga45Ugu9qL6X4XfsfChSIaDi2rCbzIq8tbhD+ojBHqY7HGrG1uQXxY7adDLx/Wua6+A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=glMIBwnc; arc=none smtp.client-ip=209.85.215.177
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="glMIBwnc"
Received: by mail-pg1-f177.google.com with SMTP id 41be03b00d2f7-cc1cc1b42b5so1025472a12.2
        for <lvs-devel@vger.kernel.org>; Fri, 04 Sep 2026 04:45:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1788522345; x=1789127145; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=Ypdm6ycnQEZOWN8WJPUUE2HwMGTgKp4dCj8wtNt7vJI=;
        b=glMIBwncTttwvAe5mGxgfuLlNw2tGMxm8GK/vE00V2EV+D5nQR4OM6pDKnTCDJrarr
         VRIIWrSu6Be0a4wwUH4gjT8BU5fH1e37niqC+ldAEXYVqls70gcwILPRRkzbx7xiHlwo
         J1qS6IFF5XtXKY5Rf9gUlzA2eHQRg9qSOWhVh/M2Q/KayChmZdJnhnjGVCfLMD2Gx3qh
         qg6L6OBBKVIizJqTTuMEq6xrsiI95TFv0ww/I0nj3vRANAIJEwlWuWQ0w+elFtwMZxRN
         EGjA5Q8W5qjTrdOW4B0X1q3TpCr/6qsCZ1PLme9zvwwwKlzwtNqiVV3+IRDknIlfRDYA
         KJAQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788522345; x=1789127145;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Ypdm6ycnQEZOWN8WJPUUE2HwMGTgKp4dCj8wtNt7vJI=;
        b=tXyNVwSwNdRIbyhhI7HJ2ngtfT/jb+jSqwYTZagKhOeqVCnKNc9No0UDipXTvS5/Pe
         A5dBLTrQ3k90VQ+OclMlj5b9MCxC4CZod+hVWpvDfRHGAGsDn7d575vEjPVgAeC37k14
         wV21o3Xf1uWmbHj4nIR4gkOVhnhhB+kIHNwAAbfJ0AF1FGrEKS4UMCMOjootfrqdnnfC
         iPoUK36BheDcmnW+gEywXYj1eMz+MY2YANrNHObWJPWk0fsGgQkWFtalmT6RjGpGUoJb
         rJwF0bIdRcomnSM4Etb12S6vA+ktQyTdQ+INfox3snZnadQ2j9MguFjMF+ba1Kx81QMg
         LCNw==
X-Forwarded-Encrypted: i=1; AKwUvBxuruF3plMMJrctOIQftOtJnUbmdN7jbDC8AO51LGuXz8qCsv4fp7bL3VPIV4WdrZc3u9Gl85ygyxI=@vger.kernel.org
X-Gm-Message-State: AFuF++l7YbWISpxZwjKNIVUX0Wlh/4IoO4/7WaMRQKnBcEOcLMTNez30
	9cl9nl0dGfjL6h5RhWazXZUJG4H0eEujpvALkXXA0PbEO+gmv+RROTjj
X-Gm-Gg: AYBFou0a3k0z1ZAZ1nZDbFgGlchzZkIRW97H/kxqNYNX6vZWRM8WzqYtbdy9TbCAZB1
	pRivEw06OdBQA+dSf4U4S6QRWGLslExZYLsrZ3HQlWf29BwhTBpTu+jpeUyqJUTYBzcMyVbSz7J
	oKkSV6xn5wxeavSQK9pjA8D9q0iBH2mxxbJVIy/MbTdKu9dGl1fkO1vT5S6j1c106Pp47eJfBgP
	1h6a+nfOODQvmM9pmyHDfXmR8nZ34w+a0Qatrjjnt1DX9+7MaX7yiDEiNk3Pfor5rKtYtcJKOcm
	fCU3XepMnIKv7MmWNrwXf7CF3qQRntLojWGTW1RpwcTtrEVx7dWy715FfFwmoCez3eqQV/0LCCq
	d8DEoFUpGP2xL7qFfr92IAL2ZDP9BI83ecPfLnumfjwKNhW6f63o6dlNQxT/98qI+5yVBj5VcKM
	m5izv/AWaZtQoopdEHS1TFkaXmEVl+GCwatn+11Siw1ahNEYqcVZCKngT3+3FYtb4A+H8i7qE0I
	sXlrRrTvDjTfktcRS0qrWn4nw==
X-Received: by 2002:a17:90a:e7c2:b0:398:9be8:ea66 with SMTP id 98e67ed59e1d1-39b261da126mr7004862a91.19.1788522344797;
        Fri, 04 Sep 2026 04:45:44 -0700 (PDT)
Received: from volcano9f6e-hostos.amd.com ([165.204.217.251])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-3339885ca07sm7148372eec.1.2026.09.04.04.45.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 04:45:44 -0700 (PDT)
From: Hemanth Selam <hemanth.selam@gmail.com>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org
Subject: [PATCH] net: netfilter: fix typo "specifiy" in comment
Date: Fri,  4 Sep 2026 17:15:36 +0530
Message-ID: <20260904114537.29953-1-hemanth.selam@gmail.com>
X-Mailer: git-send-email 2.48.1
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Correct "specifiy" to "Specify", reported by scripts/checkpatch.pl using
the misspelling list in scripts/spelling.txt.  Only touches comments, no
code changes.

Assisted-by: Cursor:claude-opus-5
Signed-off-by: Hemanth Selam <hemanth.selam@gmail.com>
---
 net/netfilter/ipvs/ip_vs_sync.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index ea5fdd4f4ce7..5ddde3ab2e59 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1344,7 +1344,7 @@ static void set_mcast_pmtudisc(struct sock *sk, int val)
 }
 
 /*
- *      Specifiy default interface for outgoing multicasts
+ *      Specify default interface for outgoing multicasts
  */
 static int set_mcast_if(struct sock *sk, struct net_device *dev)
 {
-- 
2.48.1

