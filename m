Received: from mail-vs2-f27.google.com (mail-vs2-f27.google.com [74.125.227.27])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DE31E4BEE3C
	for <lvs-devel@vger.kernel.org>; Sat, 12 Sep 2026 01:32:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.27
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789176776; cv=none; b=luLVEttWtjl6rMZ9xLuDzXeOCGTIS4OSBKwJIReXvEG4VE/CfkFhgWAhx+WIPJPylF8IZKkh9xI2VtD3K2p2FqBGtD9WenUkUR22Tz62+PzrnDyNkXgWCPuMCt12GNoxatuV6GM5Z5rLVGsSZr44CV2HhN6L0aFQRFuYQHzzXMQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789176776; c=relaxed/simple;
	bh=W3fiDar/lm5WkpMHbhW77gh+6N9tJ47fTMLt8bhssWw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=oH5K+sKIFP/ND+U4pch60wkoCs9gCAg5/9aWVFy6WgePjGMPeO4zTeyu7V+D/2fNcXIUeFmHPcKeh6mGlWvc1sXp5x9rcneOzOHB09tC6mX9b8798LH1uEl9c1QMmBlzoQQuGafZduOCqjgD80s1sofaA2WEuul0155ck1G6bes=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Y9PWRs0a; arc=none smtp.client-ip=74.125.227.27
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Y9PWRs0a"
Received: by mail-vs2-f27.google.com with SMTP id 71dfb90a1353d-5c963d7503fso145115e0c.0
        for <lvs-devel@vger.kernel.org>; Fri, 11 Sep 2026 18:32:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789176774; x=1789781574; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=kO+7YN2IAaySDWCD3o40tVhY4GBw4G0JdF/ryYyBPSg=;
        b=Y9PWRs0aHvyFCCd2i+4/2OIjX5tHOU4ymyVT0f+EjmB6in0BHaezTtBx9xzQ/0EtbY
         WkhI8O+xs0MWgua/vNHmDX9ZneMunf7vZmX1gV5XPQHpCJpVVun4CSTx62LTSrDoDSNa
         W4ZhqqHjdQEqllDIcrv7bkQGbcV5Pzs0l9EOsvuSew9uCy+rBHuK1cGud+QZ79Tqs7Wy
         OnxfZQfW6udDu7+hqpDKF4DCzK3xEW1BWlRq+tItb7lxMY88Hq6UTkIs587tSN3H3Vrh
         bVApyf6U8j/xkZfFnt9kz10opGomzlr3YjHTZ4qYKguWCHImLROG44zHRMmKAjDpwWHQ
         ZB5w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1789176774; x=1789781574;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=kO+7YN2IAaySDWCD3o40tVhY4GBw4G0JdF/ryYyBPSg=;
        b=XdM+drQqx72IlOwoIGRh/kSRZU7G8wMuk2ZigY6HJ2I5Si6XH3jiCd7DT5LFfpg8Po
         P+aL79I8s8CRI8cmVmgQ9PyMQ6XV5+uFDyL9PnEX8BbOsx5FI5r6rm40xZ6odngoA97c
         mp7jFIbal9+w1yGUlkHXyoWbpuBX45+SieWnQdUyx9cKPo3Smn+UzL8/fVib4BrxUum+
         y1Or2LF4lA3APl8ndZPeUCzLgFsjBhHd9IsF9c64dHbDp66Ktnsez75VhkY3t7hbJPuN
         CoghA/BJGyVKMxEXH5DzyOqDpXH76BBRUOJjCBedIUGEt77n48ibWF7OxsHv4AxaiEUf
         3iJA==
X-Forwarded-Encrypted: i=1; AKwUvBzmX682FmcumcgaB5OQrf+CoJihgw++TxhqDE/4ONg8DiwOQlJ7KIGLF4shxBQBSqcWaL37i8vdfxw=@vger.kernel.org
X-Gm-Message-State: AFuF++m34/7LSDwGJ9wylk8iR+KYCzfbRTYcSmc5QnvR2aHi5sD8gKoS
	LilBNyniR6XUslN/sjqfiMkcG5rZWKUnf6Cc7+ErVOPNHxYEHlVIfw7S
X-Gm-Gg: AYBFou0vaMqUxXaUZyEbC6C5C+UfwCLR0VWnhzBVh2AINrdQD0cJBLf3nLJSdq8JT/j
	H+obe5yNfcFELyWW4gTApzbD9oip484kJcYAibGSqud0KfuJv29FfgtRMJKfpl5IweTSSt15kLD
	+MjOuTaiE3ISigxa+XjsfNX8Qd+sDHOERwKGoRXPLJd8AmGLQbSAyyr9w6FD20YFMo9hW3rwsmF
	rFMld52i76uq9aZohKi7RuXYRukKpstCuHX25VIgSaviORuFt3qdm1HMiXhjMR41atLJ0riXk2Q
	S3HYzmHhkUT5LvSAW7qM9XVmafz01F1dyuHML2Y3FolWqSOEkX7/BC3AudphywLvtbNZp3MSiKb
	P6fPn06eUXba0tJfm8oDqI6otChu/Yd5J1czPikMWUlT0DaiU+Xzl6k+zvlTfYLjALkCPvi9O8v
	fkLO+6C00ugwQ9yBN0OTiz031qANMV0qtKNgCCU5VkTCKDvJXpquY4GvRmb+wKphY=
X-Received: by 2002:a05:6122:420e:b0:5c5:731b:11d2 with SMTP id 71dfb90a1353d-5c8463028afmr4284498e0c.8.1789176771974;
        Fri, 11 Sep 2026 18:32:51 -0700 (PDT)
Received: from adriano ([190.215.95.120])
        by smtp.gmail.com with ESMTPSA id 71dfb90a1353d-5c84714c380sm4738262e0c.15.2026.09.11.18.32.47
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 11 Sep 2026 18:32:51 -0700 (PDT)
From: Adriano Cordova <adrianox@gmail.com>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	"David S . Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Shuah Khan <shuah@kernel.org>,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Adriano Cordova <adrianox@gmail.com>
Subject: [PATCH 3/4] ipvs: tcp: enable per-connection secure_tcp in state machine
Date: Fri, 11 Sep 2026 22:32:15 -0300
Message-ID: <20260912013216.588300-4-adrianox@gmail.com>
X-Mailer: git-send-email 2.51.0
In-Reply-To: <20260912013216.588300-1-adrianox@gmail.com>
References: <20260912013216.588300-1-adrianox@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Let set_tcp_state select tcp_states_dos when the connection
carries IP_VS_CONN_F_SECURE_TCP, otherwise it keep using the
global pd->tcp_state_table (the netns default / or if nomem).

Signed-off-by: Adriano Cordova <adrianox@gmail.com>
---
 net/netfilter/ipvs/ip_vs_proto_tcp.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index fec0e8b47b71..3b9a2c8e9a52 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -451,11 +451,10 @@ static void tcp_timeout_change(struct ip_vs_proto_data *pd, int flags)
 	int on = (flags & 1);		/* secure_tcp */
 
 	/*
-	** FIXME: change secure_tcp to independent sysctl var
-	** or make it per-service or per-app because it is valid
-	** for most if not for all of the applications. Something
-	** like "capabilities" (flags) for each object.
-	*/
+	 * This remains the netns-wide default / global floor (e.g. when
+	 * memory pressure kicks in). Per-service hardening is now carried
+	 * by IP_VS_CONN_F_SECURE_TCP on each connection (set_tcp_state).
+	 */
 	pd->tcp_state_table = (on ? tcp_states_dos : tcp_states);
 }
 
@@ -479,6 +478,7 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 	int state_idx;
 	int new_state = IP_VS_TCP_S_CLOSE;
 	int state_off = tcp_state_off[direction];
+	const struct tcp_states_t *table;
 
 	/*
 	 *    Update state offset to INPUT_ONLY if necessary
@@ -496,8 +496,10 @@ set_tcp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 		goto tcp_state_out;
 	}
 
-	new_state =
-		pd->tcp_state_table[state_off+state_idx].next_state[cp->state];
+	table = pd->tcp_state_table;
+	if (cp->flags & IP_VS_CONN_F_SECURE_TCP)
+		table = tcp_states_dos;
+	new_state = table[state_off + state_idx].next_state[cp->state];
 
   tcp_state_out:
 	if (new_state != cp->state) {
-- 
2.51.0

