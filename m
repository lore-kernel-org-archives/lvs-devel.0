Received: from mail-vs2-f42.google.com (mail-vs2-f42.google.com [74.125.227.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB3053DA5A3
	for <lvs-devel@vger.kernel.org>; Sun, 20 Sep 2026 05:47:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789883245; cv=none; b=UDo/IG+616MJvvV3jbdbJlYvnIL+ZwXR8b3sJp/tWWN9NrSN4IkUl+A7l+JNuWLMSGYYa+2FQqhTQYUHxrlVssVRb+mWHQreEXGCTMl805SpyT4kNp/BvMx/8UhZ0UNkwYgZsVkma3ji6idhmtpVczciLW4KR3pDcBQNV54UsvA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789883245; c=relaxed/simple;
	bh=vGxo+U1sJMCVsq3sDI08zPDza2WpfMA+ZZBuxg0Rgp4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=PM1UvQMj2qE6oWX8ryB5+NSZbX1D6ENWVyBIAqheHt4HOk/gRYBlMR0Wi0d5oAIbiTT9or+Tcrqo24C3Ftx5G4W+3YV4E9BR+C05dazWmaOcMG1c2ml1HSj+H99vlrT7aGq+V9KWJVmy808RoIirf3Q3dkunsoZVzlj7s7N633U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=TEQulDE3; arc=none smtp.client-ip=74.125.227.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TEQulDE3"
Received: by mail-vs2-f42.google.com with SMTP id 71dfb90a1353d-5c67e2ff27eso1581458e0c.0
        for <lvs-devel@vger.kernel.org>; Sat, 19 Sep 2026 22:47:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789883243; x=1790488043; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=+xdh7oWEQ9m8Qy+E3UVjKRIovBOhuQDCeQrchOYtk/I=;
        b=TEQulDE3nl8kiz1wCPMXCgEJbUO+jVTyndy00etcWmK+1D3JdkS8dv3/IvjMzs3lfY
         VtkEiGed3v/fAZ5gLLH5ggs6wtZGQiVPFCf9H9QDczWG4lL/1fIIB5Hpe8SFi/Lq96fs
         JLmz1FKG8Gv88sRHjiWSUiErOmw3ABuS+ExW4v0rC6NojLc/4nK9DJlNDuJJKsjzGePD
         0duUl17ynITUWEZ7jm2jkw6u3pirvUiQ2x+D4Nbimr8rX5FhZ/cCvjjjq5JoCkH/fyfV
         wEvC/uhsHgsxpGVxk5jYYNVRtBo5EFxHd9CTPx29iW/IUkXFC65TrVpkJVh43tsMg1jw
         loUg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789883243; x=1790488043;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=+xdh7oWEQ9m8Qy+E3UVjKRIovBOhuQDCeQrchOYtk/I=;
        b=xTjM7C3WjVSqJ5o/pIcjSOhQKIn5ZU8x7sd985rPWRpfuuPjZrfVpGugvevpypXgoO
         kK6eAhkoefAyh0AO4Dm6OHzFSLTNMATiBi1q9LBAIHsU7RU+qvt0l6wJgbw26FPNxN80
         AKkOh65F78Qq4i3Afq1hL3HgTLMUdaaeO84L8h71rxifPzC8E8SrH0AyeLd7mJbnGVpj
         BL5wbH8xXoLGGcchEB8bXIpKg6olGIMbfWAb0NJhO25QMEFO65hYPIaFOkpN2COWDenu
         bKroGd1h1yqg9UeoyJ2swPCkfhDXTdOdvtnixO3QD45gae8dLoagMCfmhFx+rm0aqSIk
         +jBA==
X-Forwarded-Encrypted: i=1; AKwUvBxAF21p18loEBjJ4zfEEobiNDitfCjqwTZ7xB+cj7S2Jj0ReGT5idRGe5HaRrE18c1RvHF5CpCYzrY=@vger.kernel.org
X-Gm-Message-State: AFuF++lGL0pJqY7t68tFaFvY5aGKz/0CpnP4W+5OQ+j+cNYtj7jOJShu
	TR2W4S+gOleOgxc7BI3v/ol39NS9BzQxJfAiJv7IvFxmwZS26RDBcmlD
X-Gm-Gg: AYBFou0LaGqzkEbKUxGMCFqiOr8x/D/3g3B5QKNGc+RBeoe4+jjZAef5X+CDfGJlY5l
	+3b3MQTo7TvMeq8m5vt/M5Wvx+czImzF/TsUOZhZQ+R4cRik1aqZutbssaqG+BZ5OFPD51+jlBE
	qGFq/huT3HUd81/+H4p4BCAFHnvgr6Fg4MiIumkYPJG1APYWCqsnI6WDo8noofY4V8bE95WuJWH
	Hv0gJEVz0gT5ww1/ZNH4p67xd+vfYAnE62Rve2AM9Tlh0UQtkPgmzpveLoeFQsxKJua70pyaMCE
	cX1qqQeBG6eg6gZyVGfYv6GYkh5ndtZWsReI/nBmnk0aDEL1XDVMir9dGAYwPbBiCmV5rtDJsvQ
	3alnEM9bF3hnVGJdVWWeoPWSuj4v/aYptfxZ8RjSbUqjdAg1gd92WADhWG0dJg0hJUfRwnSuN4Z
	OR7O0ci/3Z9yv3UsZOpg38/QpTryyjjiIx/FCFGveXHTVVF3OLWXixlKdbgIdFflY=
X-Received: by 2002:a05:6102:158c:b0:7a5:2427:ecc1 with SMTP id ada2fe7eead31-7a55ce7d127mr3164716137.19.1789883242711;
        Sat, 19 Sep 2026 22:47:22 -0700 (PDT)
Received: from adriano ([190.215.95.120])
        by smtp.gmail.com with ESMTPSA id ada2fe7eead31-7a6aa41dac0sm4521732137.2.2026.09.19.22.47.19
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 19 Sep 2026 22:47:21 -0700 (PDT)
From: Adriano Cordova <adrianox@gmail.com>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Florian Westphal <fw@strlen.de>,
	netfilter-devel@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v4 nf-next 2/3] ipvs: tcp: enable per-connection secure_tcp in state machine
Date: Sun, 20 Sep 2026 02:47:07 -0300
Message-ID: <20260920054708.988867-3-adrianox@gmail.com>
X-Mailer: git-send-email 2.51.0
In-Reply-To: <20260920054708.988867-1-adrianox@gmail.com>
References: <20260920054708.988867-1-adrianox@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Let set_tcp_state select tcp_states_dos when the connection
carries IP_VS_CONN_F_SECURE_TCP, otherwise keep using the
global pd->tcp_state_table (the netns default / or if nomem).

Signed-off-by: Adriano Cordova <adrianox@gmail.com>
---
(no changes since v1)

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

