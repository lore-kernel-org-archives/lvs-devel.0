Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.179
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794686064;
	b=uyfeGI3Qkh3G1Ek8kH76cyIQZuz34+2C6UkzKzFTJCr7N6npyWVtShBkdDuu8DYTsY6B
	 IoeY26E9JZNZ+AQDCkqekYCsITHBuIo3+NruO3qkdWypCR0SIIfl0O/HoJ7Y0aSPF/udL
	 5Pw0GhIR7GEA3rXOLVk0RUqfy0PL52L+SzPsdG4oyAd1nCqsdrZpzSjzFj/yNObE2U4AC
	 zCY66A+SVS3rWe435RR1gPd3x8jFPNwJiSgUTwT7wEnjTYva7YRmlL8718jbxfr4pxRW3
	 5s7T/8aW//48MW6Rxyhz9+Up4i6DxPQJyjC7yUmPWsOkMmISaDVokz2aJUFs/Oks6EA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794686064;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=3qJyGE4a5UB8YhjOY/fzHOLCz805/i0NwCGq/ktQh8s=;
	b=nHNMmZyRwQGox4uQPpZ06uwoEPR83HeYfmli1NAIiQAfLtRxv72Nn+a9/b4TF0E0QzxM
	 +dpxqVR2yfZR4uTNbesMTVq+S8+neob8bjWRevkmPUofBb7J8uwHKAaEiO1Widbx2YTlV
	 y2BmNIPbzOoNGAjsidyukaJzei97itt/wnRjrOCWPBIWYo8zKJdEh36NnDaqHLNJsAg+B
	 UmTOATYZVzy91eL9KiaHzKjl67sdZYGHh+bpfmCKSzkKu/xSI5aMRtQME5YjAS3GU0+2b
	 Yh29RfzB1/jQ4OvVKGKPw4c8ldogtAoF7gmkKJs0iUHx09XP6Fc5o5cRY1PWYVTN/1A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=wIUueDOB;
	arc=none smtp.remote-ip=74.125.82.179
Received: from mail-dy1-f179.google.com (mail-dy1-f179.google.com [74.125.82.179])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 35E68606A327
	for <lvs-devel@vger.kernel.org>; Sat, 14 Nov 2026 19:54:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 35E68606A327
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=wIUueDOB
Received: by mail-dy1-f179.google.com with SMTP id 5a478bee46e88-37628596783so3712187eec.1
        for <lvs-devel@vger.kernel.org>; Sat, 14 Nov 2026 11:54:24 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794686063; x=1795290863; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=3qJyGE4a5UB8YhjOY/fzHOLCz805/i0NwCGq/ktQh8s=;
        b=wIUueDOBpnVCEvuV8Dp2/5jiAS+lYJl4cP2IVvXaTwL/NtbOF8E8OqpR1ki0rwgV4d
         Qec5TkPv0LlEh2Y8V/u9Q43jXt1yQmzhpMWLB2CUDZgGmaA3QxIAqDH0yKtxJgtwhT2O
         5bgWymkei0ImgUBzoSsanK+1ZWFBMKcSp9Xnmjz+usNmf59VffX6IvJ+uAMZ6x4MIva6
         Y56K6nOVKvFIOxhdmCokMLbIt0LEN0RrmXyhCSk9sOIgG4HLbEWsInMOfIhU95K1ikJ5
         o6jpnA3CHQTHjXPVjkosZKfqXN/2gs6gqXC1Ymz5ux3Fy07zhmVMY2BhXS4dnBIGDWLi
         xL1Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794686063; x=1795290863;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=3qJyGE4a5UB8YhjOY/fzHOLCz805/i0NwCGq/ktQh8s=;
        b=SkS3BFrRwNav2twDZHxQmX0pk2flgThwEkGYLy7izPwDZHPV8yk7tlhJwTdcTPN9Jn
         Wab8KL8dzCnTrRlo29sEyLqkffSM78ZMMwd2lxw3xcnfAMeR2bpzHUI+sO6JLQ1vCp6P
         pbWOX3poWUXapuZk3L+0t3r/zd40x9rgsH5rlbkVGVHfov5nS4salUtxCCLaLuvh6JIF
         Mi1oom2OzdhUb3GdubkbLIPLTdNtB+JOmfemK6+QOSw/wF8QQcGnZB/eZsrswK4A1mQf
         +EYcStlDFFHMR4IRxnqYx+zDFDvWXP6WOATp7hYcGAaLjYLCG/m0RFlDh5d8fJAukUuD
         dG1w==
X-Forwarded-Encrypted: i=1; AL+hErGovEp0p2aooWHc2rMJm+OwHFSmSJMBgg2lJ0istr9/iAgt/DYUiDjFxLb7BWHKcwYMMuAYKcSsZGw=@vger.kernel.org
X-Gm-Message-State: APuU4Z++glA26uIfAE++fB+sU1z4VJ4EQYjuKO3x11hCG5AKkD3ErtUw
	edFur6AtcxhOPzFU9MIYRtrSlu9TrhDSqR8ZZ4SlaqVeSq28Gbwahm03
X-Gm-Gg: AYBFou2U9rRgMpYKRnd8Q3K15rF0UkAWWtkMSHKT7O8YJmt9KITTQGLelSDuVrjCMe1
	197kzakjtnAN7omARV6p9njn0QMEteGeXU4tF13KIErZWRc6XW9rv582rPLWJdK4nt8e02x2fzN
	Ew0RMwgJWX0etopn1cWU7h5yoMVxggeo76h0evZ88WOLnousLnm1FAvKzjLEgldtqwWsdUCkVWn
	zYz2zp2Jl6c0PVy6dQ9Pi/2TI3z1k6GV8Ch1pvYpVbXxlpWPCn8rU7qtO+9eBCV3WNyudBMr+eb
	5V1auwv2vjN4sstAxqngBGFW77P9UTmZsSqrOKInWJyw+Z3UsfMDbxotd3Fa6985oNm1+IkHEwA
	ASO/JO2AdigSbTXlOCXz9jWwe3XlHHG3SnQVU1QY3AvNJU2QyzYHbGn2YMr/WCttg203SyVUSDt
	Kis2uFdJxh5b1QWRm8PzQdHX2FZGc1tBTjvvvOnPf5hnE5mspWqxdfW3rCdv097Q0zc+7UNHHR6
	xEioW6mBunHyZqRXLJfBGbjdFm8mmQhZMHSmBkHWyPS/d1mGC3US7Qi62cf8chAfMNXLN8ILy0N
	J3tE6bVK/W1ODHs6FvldV6ILIOYeB5U6V8re
X-Received: by 2002:a05:7301:fc09:b0:36e:b3e6:ebe7 with SMTP id 5a478bee46e88-37966a58499mr5631650eec.26.1794686063266;
        Sat, 14 Nov 2026 11:54:23 -0800 (PST)
Received: from user.. ([2405:201:c052:b00b:f7bc:3425:951e:ab09])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-37956bad134sm23226931eec.27.2026.11.14.11.54.15
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 14 Nov 2026 11:54:22 -0800 (PST)
From: pavankumaryalagada@gmail.com
To: horms@verge.net.au,
	ja@ssi.bg
Cc: pablo@netfilter.org,
	fw@strlen.de,
	phil@nwl.cc,
	davem@davemloft.net,
	edumazet@kernel.org,
	kuba@kernel.org,
	pabeni@redhat.com,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	linux-kernel@vger.kernel.org,
	skhan@linuxfoundation.org,
	Yalagada Pavan Kumar <pavankumaryalagada@gmail.com>,
	syzbot+84e27adb95fd2a1fe9bb@syzkaller.appspotmail.com,
	stable@vger.kernel.org
Subject: [PATCH net] ipvs: wait for RCU callbacks before dst_ops teardown
Date: Sun, 15 Nov 2026 01:24:09 +0530
Message-ID: <20261114195410.96503-1-pavankumaryalagada@gmail.com>
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

From: Yalagada Pavan Kumar <pavankumaryalagada@gmail.com>

During network namespace cleanup, IPVS releases cached destinations
using RCU callbacks. However, ip6_route_net_exit() destroys the
per-CPU destination counters before these callbacks complete.
The RCU callbacks call dst_release(), which updates the destroyed
counters and causes a NULL pointer dereference in
percpu_counter_add_batch().

Call rcu_barrier() at the end of __ip_vs_cleanup_batch() to make
sure all pending IPVS RCU callbacks finish before the destination
counters are destroyed.

Reported-by: syzbot+84e27adb95fd2a1fe9bb@syzkaller.appspotmail.com
Link: https://lore.kernel.org/all/6af795e2.98e60839.1e023a.00d4.GAE@google.com/T/
Closes: https://syzkaller.appspot.com/bug?extid=84e27adb95fd2a1fe9bb
Fixes: 026ace060dfe ("ipvs: optimize dst usage for real server")
Cc: stable@vger.kernel.org
Signed-off-by: Yalagada Pavan Kumar <pavankumaryalagada@gmail.com>
---
 net/netfilter/ipvs/ip_vs_core.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 8a3c880fdb26..9c456efe13c7 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2553,6 +2553,11 @@ static void __net_exit __ip_vs_cleanup_batch(struct list_head *net_list)
 		IP_VS_DBG(2, "ipvs netns %d released\n", ipvs->gen);
 		net->ipvs = NULL;
 	}
+
+	/*
+	 * Wait for ip_vs_dest_dst_rcu_free() callbacks before dst_ops teardown
+	 */
+	rcu_barrier();
 }
 
 static void __net_exit __ip_vs_dev_cleanup_batch(struct list_head *net_list)
-- 
2.43.0

