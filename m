Received: from mail-qk2-f12.google.com (mail-qk2-f12.google.com [74.125.230.204])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0C71249C4AD
	for <lvs-devel@vger.kernel.org>; Fri, 25 Sep 2026 14:11:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.230.204
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790345496; cv=none; b=fgXuFfJxQXEiWygb0/KTzyb4i7tazcfaApbJ2w3MVUQqrle6oCC6QIPsDm0fnE6ZOdw6xtlYW14Tu6/zlJ+HuwXtYl6CufWoZ/5Bty8VSZbXr1jF1nNwzutckTrOd8wgbIFcRIJKCylmnal3eUsgXNepfFrkssy1Gv+YotvcS44=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790345496; c=relaxed/simple;
	bh=yo5fwu86Mw0YOj9FzmflPUzYzC7n+VFBQsdjcJILCps=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=QyyoQasEqgO132zZOTrybhqos+wHjEdDnI9t4XegBpgJf6XOoJ7Bs3RQjN7wheMLG4G86XpndX5eDEDSLA1PjBJEru4eTtYd0o2MiW9i9L5XuvftEsAJ7zJVOJcHp2gL8aFPTIWtKewBYO4FfBIFvxAqJohox57M7gji3mfI99M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=1password.com; spf=pass smtp.mailfrom=agilebits.com; dkim=pass (1024-bit key) header.d=1password.com header.i=@1password.com header.b=BeuZ3XDm; arc=none smtp.client-ip=74.125.230.204
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=1password.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=agilebits.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=1password.com header.i=@1password.com header.b="BeuZ3XDm"
Received: by mail-qk2-f12.google.com with SMTP id af79cd13be357-93910cadeb0so68495685a.3
        for <lvs-devel@vger.kernel.org>; Fri, 25 Sep 2026 07:11:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1password.com; s=google; t=1790345493; x=1790950293; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=q2mrYp40d3SwEyzC0ifjna6lr6WRZQqdhud4xFgB7sU=;
        b=BeuZ3XDmCWzyj9lW3Te9VH4Pvy2bKx+62S87w6P7p6kW3aw0IMTZB9GNgBfYxfIh5V
         3Qvkqs+3RTlTBGVyoYsdoV6lx/xPosuxztA1RDJ17qfgvkMPBifRRTM58H+gu3VtC4Ob
         CerNsrh+pL2PDb+QXIp5rpPx+em0cr4fpGx3E=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790345493; x=1790950293;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=q2mrYp40d3SwEyzC0ifjna6lr6WRZQqdhud4xFgB7sU=;
        b=VUtXfoChGXDmV+VYPSw7b/HixJWDt1bkaayG4sqaKg71G0oNUoBBBEN1JD4FmsEzBn
         Lt2KGnNx4R5TVpNuZj9I3KbZsp2v8Vrn4WeE9+dsVC6zAx0OBnoYS7tUeCsFk2XXwaOV
         c89kG9ae/wKdkyHTRqRBK8G0QmaRMUrW2yklXglj4sWMggFGT8fG0NLvpGM2+GfWLbjC
         +p7KZnsVZA6PADqMWqN2abVWs1sCKosunMOw+YUPLbaRzbQyl2ePo5efccLjNV2RXIox
         /HELM19saR66kQUL1C3p/HkB/5loQiC2378S0sQqnjbTk3bOIS8kKFZ2wSukS0LjBNh4
         QYnw==
X-Forwarded-Encrypted: i=1; AKwUvBwImQDDFlIEdyytiZHNTkMCQQZgSBzwDI5vhpThqamHivP9e80VuTSXv7rRllaZm2vEr2V+DTuS0DQ=@vger.kernel.org
X-Gm-Message-State: AFuF++kXhTeE4bYEX5O9aYPMPlBMdQa/EuCQLrrS3NRAPQYymp7OGmbt
	kYKcE3vF0su0c7/0JVu/0r2svpWVlyuXurtm0p1x8fnrb8GDoY1dJFJIo+x3KKp+6Mk=
X-Gm-Gg: AYBFou36TaxQc71bHtqTrX6kWsATtMi7XR73fWIbdKOXbXMdtZfj1WhZ+BZjmz1EFt3
	CAQbrc99wvgJsGGPaIGYPMl+YRkywdGBQ4k6VEkrULRBMHatICA20rLsuIhSmkKKe7ukLecg58A
	uSHxNLGpMHts9SoL5l3cV56/cvfV74gmUrDUdUUEYtXvMQKEvKqnagGw8GijDLi7UsCNYG1A65B
	uw1YZF22bAmTMxZYFnS37Bg7VvS9EmhDXQqVPHoMTgwmXeKehdaqsXnMG9rWdlJZ8wCz4MZLw8S
	MkoU8Jxc3GZ6Tq9luzi2yQXKti8m2wXPti2X6ePBdTeKVuw4c5popL1UsVtxhAEHN//VqBUpllK
	f0IJmqnQ+gL5jT252wlQQo4+vtNOdKqyvMeAQrlADtvonH6HMs1/MlZDUnDyEqo+C0LHhMfQDs9
	P11xfc8+6+BNOytyHj9BZ+ZpEx2pPwjmUl7L6keamOQpIG57yO2Q3yuD56r32COuvnx+DcMxrWU
	FDepcVEA2cYTyirGrCW/88mjLYBqg==
X-Received: by 2002:a05:620a:6887:b0:93b:c58c:d3be with SMTP id af79cd13be357-93c43d7be0amr477352185a.37.1790345492707;
        Fri, 25 Sep 2026 07:11:32 -0700 (PDT)
Received: from localhost ([2600:4041:59c3:300:7917:c7f6:28c6:182b])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-93c448b06easm190017485a.16.2026.09.25.07.11.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 25 Sep 2026 07:11:32 -0700 (PDT)
From: Axel Mierczuk <axel.mierczuk@1password.com>
To: Julian Anastasov <ja@ssi.bg>,
	Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	netfilter-devel@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	coreteam@netfilter.org,
	netdev@vger.kernel.org,
	Willy Tarreau <w@1wt.eu>,
	Keith Hoodlet <keith.hoodlet@1password.com>,
	Axel Mierczuk <axel.mierczuk@1password.com>,
	stable@vger.kernel.org
Subject: [PATCH nf 2/2] ipvs: skip cport 0 connections in ip_vs_conn_out_get()
Date: Fri, 25 Sep 2026 10:11:15 -0400
Message-ID: <20260925141115.16126-3-axel.mierczuk@1password.com>
X-Mailer: git-send-email 2.50.1
In-Reply-To: <20260925141115.16126-1-axel.mierczuk@1password.com>
References: <20260925141115.16126-1-axel.mierczuk@1password.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

ip_vs_conn_out_get() does not filter templates. A template with
cport 0 and DR or TUN forwarding bits is matched by a packet sent
to client port 0 that traverses the out hook, and handle_response()
then runs ip_vs_set_state() and the timeout update on a connection
that must never see packets. A backup server receives such
templates over the unauthenticated sync protocol. Connections that
still wait for their cport with IP_VS_CONN_F_NO_CPORT can be
matched the same way.

Require a nonzero cp->cport for a match. Templates keep cport 0
throughout their lifetime. FTP data connections learn their client
port from incoming traffic before replies are processed.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Cc: stable@vger.kernel.org
Suggested-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Axel Mierczuk <axel.mierczuk@1password.com>
---
 net/netfilter/ipvs/ip_vs_conn.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 6fa3e1dc534c..24dbe34a4827 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -579,7 +579,8 @@ struct ip_vs_conn *ip_vs_conn_out_get(const struct ip_vs_conn_param *p)
 				    ip_vs_addr_equal(p->af, p->vaddr,
 						     &cp->caddr) &&
 				    ip_vs_addr_equal(p->af, p->caddr, saddr) &&
-				    p->protocol == cp->protocol) {
+				    p->protocol == cp->protocol &&
+				    cp->cport) {
 					if (__ip_vs_conn_get(cp))
 						goto out;
 				}
-- 
2.43.0

