Received: from mail-qt1-f176.google.com (mail-qt1-f176.google.com [209.85.160.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 237083F0750
	for <lvs-devel@vger.kernel.org>; Fri, 31 Jul 2026 14:08:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.176
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785506907; cv=none; b=EH7kjQ7h8JmabmebecWUESC6Wym3njPB5U96lzf62FH2l6tfvoUtaDe1zDXxJ8zl1HRh18kOkqbRbYC9RySz3X2OfIEUl7Gzh4mlC4ttAirt3f2e9VXmtRQD3uxvrDLICvnBw8JWFTAu2gc3/CeMw0YieKq1rrNq2aaLxlNIIKA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785506907; c=relaxed/simple;
	bh=S8ZYhVxFV3d81I8luPNn70FLZtYvMhbuabZAfFkqwIg=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=dJO23TWAFKOziuAPisGVHtDN2b7qsmEIx4k3EE8VqCgf6pIm9weOr8cpUbK7t8gg9+MfY8wDf/6INYwS9ilQqYGk7pKbp869es5uIF+cS+V7zcwgy94o75PaNH1aXp5nlJQ63zuH8Ywbc5+56aUxBHfzamz9FeiLebQGpSx3K+k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=trailofbits.com; spf=pass smtp.mailfrom=trailofbits.com; dkim=pass (2048-bit key) header.d=trailofbits.com header.i=@trailofbits.com header.b=D6lFA0k2; arc=none smtp.client-ip=209.85.160.176
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=trailofbits.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=trailofbits.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=trailofbits.com header.i=@trailofbits.com header.b="D6lFA0k2"
Received: by mail-qt1-f176.google.com with SMTP id d75a77b69052e-51c0ecfaee7so5892051cf.0
        for <lvs-devel@vger.kernel.org>; Fri, 31 Jul 2026 07:08:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=trailofbits.com; s=google; t=1785506904; x=1786111704; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=4CYqaoDHFTXverpQiHzNbFE4tLgoDQ4zGj2U6cQ1kUE=;
        b=D6lFA0k2d+qI7i6En2Q2Y3mDRPFJAr7PRpHhc8NoYXZWmwn7BT3qoc/xV+iQZcdmEO
         N6kHiy+mV94Ie89UxbGSNX8WC4ztQN8LODekF49M0r7dBJysGlCQdyo+oW30hujfefLE
         q+c6eu2mIbi4+GBp0xKPWKbaoOFdambS61TBDcvZmAGfXuMW+SQ0J9WBolO0AD1lbtlW
         ewPHR1JD3egBiYl7XnfFPT0IDIvMnDSOq9X8XgAxqY3MYoOADzVA3FzMPEGdCMS7m2fJ
         aE/vPM8R6SPYS4II1doR+tXAaM02bZvK5wRETTIZwG8soIZM9L7a6Sc2XeQGKXl8ACYw
         RdwQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785506904; x=1786111704;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=4CYqaoDHFTXverpQiHzNbFE4tLgoDQ4zGj2U6cQ1kUE=;
        b=MIPeJezOxgfBlgMgtGjzEUrCE3/05VS5jM5b0IzbOSMcAtpNmVrmcemetm0QzvI2GT
         Gfx7Mkn2nKw0WPcF1XZhWdI8L3qZO0X6Qtn704IQ6es07l2lAmGO7hjbeeMPlv1m0y3x
         WF88GNzo0V/xIOSRwvMi8X9/AT8R9fyS2XIlvu6TiL5EP8hVDWYbhG16212NyGpemt+V
         k/py/vLdQLBbznkJ9mL252swJ+xgfDXkaKpQ7NvFILmP6ciqiUcu6mNxe99DgC7mq9Xr
         61YRumS8zJkdEhlflyzcVdaJn++NElUDq84w/6LpVm9i3QLAbXhbwbjX4ilvpU287aRn
         euOQ==
X-Forwarded-Encrypted: i=1; AHgh+Rp6W3h5SdkM67MW3zFx6RAe3FJVUCIIwq53BRSxg6Roc3oB2aPM/hX15/6TfJ9eu1NiNvoWj7bYzIQ=@vger.kernel.org
X-Gm-Message-State: AOJu0Yy6JyEyfoeB2VpEnJlHklsHMV8n+WE7EFscwPR7zHB7bdeUhi4J
	32c5pMr9smzbhWopYjcL23gEQhV+hiN/gFhx08tUF589p4pIIFOKbPGYTBhhZ+D4rnE=
X-Gm-Gg: AR+sD120i2p+jyBDOOHZP8jtciMIwXbqaI6jQy7z0d1AamSQgdPx5KWfLwsulOhrCNu
	5UbXTSfbx2BMIShifcDxLFNgWWodClxAuy6FjWTYdtinMxAPOPNv4L/T1vbdzlQ/ioheY/R3JXj
	SAOUFlBCg8O78upZNz6tuOHpIU1FiWS6f+hr/Wio0iyk9zR11SWdnhfXnCueZAZnORQWf1iBKqJ
	3CHHtL+ospVxytEgCkkurO/by+Z1rvfYug7FU5Gm4PZ0ZL+vHxsw9ptQ5qIAHHAbEPI/yryvDZ0
	G2DQD4c1C1yxzZzSDgnupkOqdXm865VBLX+qDyAW/m+TB3hyCe+B2jqpjoa/XG6cFpITeDEBlKU
	vyHrfQETvOaPUypWvtXEOtcE9/N3uBFEmg67+JYcxlWE0ggtfqbooryUl3W8ixO95men1x85EfD
	YJ/GNAHFU4jzSR89u6OQpE0qMn6013mOzTi4xArOBpaQ+r6Fdgx5b0z1FpWNdKRGNTIQ==
X-Received: by 2002:a05:622a:8f:b0:51b:f563:f613 with SMTP id d75a77b69052e-52b567c6399mr3664281cf.35.1785506903762;
        Fri, 31 Jul 2026 07:08:23 -0700 (PDT)
Received: from localhost ([146.190.222.192])
        by smtp.gmail.com with UTF8SMTPSA id d75a77b69052e-52b4ebeb909sm8257931cf.29.2026.07.31.07.08.23
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 31 Jul 2026 07:08:23 -0700 (PDT)
From: David Lee <david.lee@trailofbits.com>
To: horms@verge.net.au,
	ja@ssi.bg,
	pablo@netfilter.org,
	fw@strlen.de,
	davem@davemloft.net,
	edumazet@google.com,
	kuba@kernel.org,
	pabeni@redhat.com
Cc: David Lee <david.lee@trailofbits.com>,
	Kyle Zeng <kylebot@openai.com>,
	Dominik 'Disconnect3d' Czarnota <dominik.czarnota@trailofbits.com>,
	phil@nwl.cc,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Subject: [PATCH] ipvs: clear IPv4 options after rebasing tunnel ICMP errors
Date: Fri, 31 Jul 2026 14:08:22 +0000
Message-ID: <20260731140822.567128-1-david.lee@trailofbits.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

ip_vs_in_icmp() rebases an skb from the outer ICMP packet to the
quoted original request before passing it to icmp_send(). However,
IPCB(skb)->opt still describes the outer IPv4 header.

A timestamp option in the outer header can therefore leave an offset
that points into the quoted transport header after the rebase.
__ip_options_echo() treats a byte at that stale location as the option
length and copies it into the fixed-size option storage on the
__icmp_send() stack, causing a stack out-of-bounds write.

Clear the stale option metadata after resetting the network header.
Keep the remaining control block fields, including the ingress
interface used by the ICMP response path.

Fixes: f2edb9f7706d ("ipvs: implement passive PMTUD for IPIP packets")
Cc: stable@vger.kernel.org
Bug found and triaged by OpenAI Security Research and 
validated by Trail of Bits.

Assisted-by: Codex:gpt-5.6-sol gpt-5.5-cyber
Signed-off-by: Kyle Zeng <kylebot@openai.com>
---
Trail of Bits has a reproducer for this bug that triggers a
KASAN stack-out-of-bounds write in __ip_options_echo() and can share if needed.

 net/netfilter/ipvs/ip_vs_core.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index bafab9345..fe06c380c 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1951,6 +1951,7 @@ ip_vs_in_icmp(struct netns_ipvs *ipvs, struct sk_buff *skb, int *related,
 		if (pskb_pull(skb, offset2) == NULL)
 			goto ignore_tunnel;
 		skb_reset_network_header(skb);
+		memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 		/* Ensure the IP header is present in headroom */
 		if (!pskb_may_pull(skb, hlen_orig))
 			goto ignore_tunnel;
-- 
2.53.0
