Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.219.53
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794922859;
	b=QXZpm6mjYfdHhVZQ0+B697+lK6UBYVJgbW7AC/dGRc8LqwTL+n84gW7humhPc5vtfGAd
	 xh+lvS2r1juoUcwi45+dWa618WX7I+YdDMfPcXydCO4mp+5NJWjkIlcdUGO+YluqttGrk
	 oa2IFb6HX5pihvIsaFFGfuD3Zx8Uh6dqhCtRm1gxYlEOYtoi69Dy3vfMrUDG9AUhgFY16
	 YVALOQMnGJCH8c7SXs25Dl0G6plqp7lLfo4n/1Y2vwIRO8eAvCkFYA6p+6ZvlUuVrNKXu
	 URTd9Y0GKkHQfYV/DcfnW55hhp3x0zbW+TvCgo2qWqU3dYShaSRjklYxfWnubMLzFSQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794922859;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=TwB4RSE1ahOv1eWO7HrIP9Xo526ulRCGPxUhrPC4tB0=;
	b=oKeo6RZJwA3O2IYXwEQHKkB+cMvOkDUvxXgwXhKApY1OoaY/n4F58jZVsXiN58futI0w
	 gWttI/pQnS8RCYcrV86lIGtTE6yOZdhlIX1OHR5msxI4NDxldIstAIWQnxwrI8U7KX7N4
	 PvOM7owAt6p2PocEUwDs/NhYfuNpF9zZXTBRbViLArUrQzfs1P2zluz3O17ssyTqQnuyQ
	 IE1MNy0kx/w5Rcs1m9Xzaway2XicngH+obWo/rnl9kpNT8Cw5MnubAGTK6vVlW803bCW4
	 YXC5b/YTQ/5qAFSYYYfEtOm6QMRGDr7W1rS175k0mUXcKW7rL494CW7+Xk8KpnYleJQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=1password.com;
	spf=pass smtp.mailfrom=agilebits.com;
	dkim=pass header.d=1password.com header.i=@1password.com header.a=rsa-sha256 header.s=google header.b=mbrGrYZU;
	arc=none smtp.remote-ip=209.85.219.53
Received: from mail-qv1-f53.google.com (mail-qv1-f53.google.com [209.85.219.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 700A2606A329
	for <lvs-devel@vger.kernel.org>; Tue, 17 Nov 2026 13:40:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 700A2606A329
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=1password.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=agilebits.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=1password.com header.i=@1password.com header.a=rsa-sha256 header.s=google header.b=mbrGrYZU
Received: by mail-qv1-f53.google.com with SMTP id 6a1803df08f44-91f0274f88cso74467776d6.0
        for <lvs-devel@vger.kernel.org>; Tue, 17 Nov 2026 05:40:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1password.com; s=google; t=1794922858; x=1795527658; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=TwB4RSE1ahOv1eWO7HrIP9Xo526ulRCGPxUhrPC4tB0=;
        b=mbrGrYZU/2TOeFzN23IFhtlXtGQ53gHxnOmST27w/O81rXdXcuR1XDou6E1j48MhA6
         wwq4r2OalvYh9HWBrwgCxsJq6diJWHagel8aNFSlqQNTCIJbHhie31WwSYbXJgaS49Fh
         FCqoYH74WEGJ3ZcXJ1zVY7dOj6La1jKN4T+Go=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794922858; x=1795527658;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=TwB4RSE1ahOv1eWO7HrIP9Xo526ulRCGPxUhrPC4tB0=;
        b=wZtRU1Hw8uu9agZYWPhHLMhOjD1ERmCzGgTJ2qCQr6uyHutpu7oo+X3RRrGEJFaUD9
         lh2YfgXYKZWmc+SqAlsqfdmA0gWZW8u1qzJF7ui1qi9b7EDVGkREbpgniORP+yujayti
         TOp3j+9V9bfmU9CV5EeTPVxMW4WXpxludGNPmakGJOR3gfq6q+Fopbbvn8dMGg92gngS
         AeR3dHprnCCpfRRslCRT8gr0s1PXfSjpAN8/yMsqNvaRlL4T8T+BRPpSCDYec3nKbIJM
         yd9KVfdjtD2v8p083TOT+Y4f7GusqboaSLMoYjZbsOrf8AoGEfWgq+Mv2TEAcL+jV/0s
         EYjg==
X-Forwarded-Encrypted: i=1; AL+hErGDicfPjAT2i7ASkkFt+7LeqgIh0e0QVxHoF9xOte7S2dW8ayEumIpwb9ZnZEamV6QFj9og0x4BleA=@vger.kernel.org
X-Gm-Message-State: APuU4Z+KjraBgou2mGQP8uzNLZnorokDKD2hApnv04GzCqbtGI5FhIoV
	qnkoBho8lPwq1FeNrZqGuuypTbTqQ+9Wq8C80b/emotETq6PcT+XSU8a8jQJbK5bKIo=
X-Gm-Gg: AYBFou3Y8tJmbFbobukpdYOHAUattgOt2EgDiAKf0Avxynzfu7aK2ZWyJH0d8YAJbSg
	aAxwH3jXJnnTHANDDOkPptUgRPNPyII79HOouuezgzfgTcwlyUBEJWh1Ar3TGab5wXephKzGXSU
	j3AmgLdI0bExRTtEreC/aPNK2BWg27ooqiyHBq7tgzjhWrY6cEepckvm9sTSd7GKUVcOjP6bZht
	9MY/GOBKQ0bG01z/4UE8HzqO60z3kWfWofjQbsXp27DoqRMMlzzstcZw9u+sy/VotTHgC1DxCQQ
	SBaRTFwtWo0WtxCKTYSjcoGYBOXSDAUuvCQTI7YjzmTaQAGChZWzopQCr3ozWQ7e12fly4dTwmt
	WySbVl8gU6Euvn3EsBodIMTAVuGGwmVXssNLQLwYO6xa4KyafpcnwS1Qa2bRQjiVGJri6bBzHIs
	yR+2lFiISZWrVgxW/KqY6txUQdPyAtAFIAXwP8RKQjPLHnUA5cLRV1kkL0SDj6v/+a9PGo8aRj9
	5SPxi/rPbmrJWsn4/b1VBH45Em1qHyyHNxZshQvGPflwvjBxsEM1qZJdr5m5ASYYNB9XQf99DJM
	ZGsocZCSyYl8esLUSlxYyDgPTk8CezV8cNuW6/0gLhdaTRoIovSiP2y5hcNa
X-Received: by 2002:a05:6214:62d4:10b0:91e:850b:770b with SMTP id 6a1803df08f44-91f24151026mr170565066d6.17.1794922858319;
        Tue, 17 Nov 2026 05:40:58 -0800 (PST)
Received: from localhost ([2600:4041:59c3:300:b8f8:e592:18c8:ba23])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-91f23db3a81sm110979646d6.42.2026.11.17.05.40.57
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 17 Nov 2026 05:40:57 -0800 (PST)
From: Axel Mierczuk <axel.mierczuk@1password.com>
To: ja@ssi.bg,
	horms@verge.net.au,
	pablo@netfilter.org
Cc: fw@strlen.de,
	phil@nwl.cc,
	dsahern@kernel.org,
	kuba@kernel.org,
	edumazet@kernel.org,
	pabeni@redhat.com,
	davem@davemloft.net,
	netfilter-devel@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	coreteam@netfilter.org,
	netdev@vger.kernel.org,
	w@1wt.eu,
	Axel Mierczuk <axel.mierczuk@1password.com>
Subject: [PATCH nf v2 0/2] ipvs: fix OOB write when NATing ICMPv6 errors quoting non-first fragments
Date: Tue, 17 Nov 2026 08:40:47 -0500
Message-ID: <20261117134049.52386-1-axel.mierczuk@1password.com>
X-Mailer: git-send-email 2.50.1
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

This series fixes a 16-byte OOB write past the verified skb area,
reachable through ICMPv6 errors that quote non-first fragments.
Following Julian's suggestion, it preserves ESP ICMPv6 handling.

Patch 1 includes the embedded IP header in ciph.len at both ICMPv6
call sites when parsing stops at a non-first fragment. It stands on
its own for stable.

Patch 2 makes ipv6_find_hdr() set *offset to the fragment payload
for non-first fragments when target < 0, rejecting a truncated
Fragment header, so every successful return updates *offset. It
drops the workaround from patch 1, which becomes dead code.

Changes since v1:
- Patch 1: rewrote the comment and commit message. Nothing blocks an
  embedded ESP fragment on ciph.len; it continues because of
  pp->dont_defrag and its lookup reads only the addresses. Name the
  skb_ensure_writable() callers, handle_response_icmp() and
  ip_vs_icmp_xmit_v6(), that size the writable area from ciph.len.
  Code unchanged.
- Patch 2: return -EBADMSG when the Fragment header is truncated, so
  *offset never exceeds skb->len (Sashiko, Julian). Add Fixes tag
  (Julian). Drop the ciph.len workaround from patch 1 now that every
  successful return writes *offset (Sashiko). Describe the
  handle_response() effect, the nf_tables trace output change and the
  SYNPROXY callers in the commit message.

v1: https://lore.kernel.org/netfilter-devel/20260925141155.17603-1-axel.mierczuk@1password.com/

Axel Mierczuk (2):
  ipvs: avoid out-of-bounds write in ip_vs_nat_icmp_v6
  ipv6: update *offset for non-first fragments in ipv6_find_hdr()

 net/ipv6/exthdrs_core.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)


base-commit: 734bef548a96e8774d6eef5dfa2026c6edc4e80b
-- 
2.50.1 (Apple Git-155)

