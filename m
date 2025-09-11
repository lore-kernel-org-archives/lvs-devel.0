Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6A0E4214A8B;
	Thu, 11 Sep 2025 14:41:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.193
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1757601667; cv=none; b=ruWV/mGwK/4yjnhM5N9wtAHzfTD9PLBNIjpceGBVeFJBBpOmfW7tm94uEHLJKNlcfn6VTx+5lZ6tnrP2AyZ0NYLYndiUxUYE500oHE+1vq05kR/fciXo4VOYtH1RMWyFY45A3UUZ3diWkecXJitcBkt4uQjeBswBiRdv7iyn2oE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1757601667; c=relaxed/simple;
	bh=0k9K5Z0+Nwwz0NRSWVtjlErXcniZ4G8o1OcRaDrpy4A=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=Q5NypE6nD0PRlX/hvDQEq/upd2QEpQXL3jxAB80S+W5L6mWmHxhBJWFEhrm143G3hGc+b+yntLPKSo/zOeseKnnUsbgEFd5L/XIdRPbIrL68m+U4cSUVR6MwNaNXxs3ffcLTnN0rZx9Wm2Jcx3c6NTgNfO4GTl6uSX8F63A0iOs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=NVXKW70I; arc=none smtp.client-ip=209.85.210.193
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NVXKW70I"
Received: by mail-pf1-f193.google.com with SMTP id d2e1a72fcca58-772679eb358so712752b3a.1;
        Thu, 11 Sep 2025 07:41:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1757601666; x=1758206466; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=yyBSb1K+ID+ZIw5PFaCdNQifUNTYtrcbftSQOft9yWU=;
        b=NVXKW70IdTSkTDqEXP9xvVLQMPDp4BKMtWVWimT5dmo6vk3gkWFGCGVbKpleGQS8CI
         4REJwFVDzUyUnchhCVtkeE1UQZxckPzQ6ViuHqV9D60s70TscroCyikbTWkto1EMNI/s
         ZsjfZi1NGsjLL/43qfudVwm1UkswHn/UF8aJoaxjFgabflm8LgKx0HT6kXYx94UCvURg
         emkWC6b44korFiO54TkgSRojZSBu5nHyRYUdTvuzEwS5iPlTbjd4ImVC2IYBjDPjOZpK
         JDe/pIoTIq6N7bT8CqyvbHitHLJlnE+g6nw+OQLg/l2XuaJPAOIwT3RXPAVEgfDLLn43
         kDBQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1757601666; x=1758206466;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=yyBSb1K+ID+ZIw5PFaCdNQifUNTYtrcbftSQOft9yWU=;
        b=YN0jTorNOdQoYT13bY5JFdI/qWaL36+J66HqfAxwd6nrWPlO1UuKuo32ILduA0mnqr
         jO+AvKZZbf1XoPhSlkMZcD0KP/NgFQzYxbD2K2N5czOOW1elDxBWXn8u0mVXTrZIVkSX
         EzZ7mPHAl5QkS7me5NPDZi3C1nBZcgwaP3vXy2Q3he4gpAdNkHMHu681VnyJOKwLBwWz
         OjQ/qF8gU+g2koh9VT31M22wySbz74y2fhA1OVA28RAqEPIylkH5WF9u93mJkzZDspYp
         /jbjCTv+whj/Hyn9VdfjLnddZXlCLNV8yhAlQB4OEF7w5u8I1UEOpl0tCGFm0JVEmwJW
         Nr4g==
X-Forwarded-Encrypted: i=1; AJvYcCUhlNZT1f07ahQg9FJ5A3/n8YAPuv7uenaqqS2Ync7wHkQiGKBYNeAeKOzgpx4zYOnFSgzhNSE3s6waIOwroDDD@vger.kernel.org, AJvYcCWdt0fFpZZ76oMHg6o1MiklrvHGDnmbuAr+8JhbZRg75rZ/y3bJF1a5VjETQvQaNpQR653fy0jFYBtM@vger.kernel.org, AJvYcCX1x2Y9j+0vnwHusWy6NBrzR59waMOSgUo5vknweWGOahUEAkuqKdMU+nI3F+XxzzBJrSZC88/q+wwuF0k=@vger.kernel.org, AJvYcCXtHPZMIK1YgOwPSgW2wJiZQK45xWfGGv/RrshCeRiGmLs/w085yBLK2og3iT2Pezf6zbVwuAl6@vger.kernel.org
X-Gm-Message-State: AOJu0YxYxChl2dHbG13jpfZE4LFkb2wDPR94wUnFyCtjKKIC2ns5bTLX
	l+1F+NfTIiqBNRiNrQMHmua4VVi4AiGnal34MK3Qd+U+VoIfxeeJvGMu
X-Gm-Gg: ASbGncs0SF88BNH0dfrYkcHCdm9sXOMzgrw1RzeGQjWx2iJDu1JdzYlUAKRuCkOrbox
	ytPXrLaO/7mZBYSEq3MkixPVaTmhoUy8WcYHhPNT91K5oabAYbdfmQKMnLJdO7Z82I0DLaUmc86
	26EpSPDq8uZi8f2qoQt+koLV/yO5va6NmZU2LCZZ2Min2iNmQ5V1W8yopLzjvq4WyjVgwuOh9uu
	UYbi+W5DXgu7OzrMQQZ5XdEVyYtJecInOcYOVKllCihfNq7AKU168tWXiz/RSfACnAKqxCJk6Vc
	tpqywg1d/qb3sXLmW+PF7Kiso6QspXl0QkFTCnK8xgQ1Kp3SFzF0gNey3Qe0asELrD33TyfEtSM
	CJClArW2FTI9FkHwJZsMG01i7VPVC2hIKBKUq+Gd6m3h2c4m1Bu5xJg==
X-Google-Smtp-Source: AGHT+IF9eyJd8b0T+uwEAz0byGH03qdVJNvPLIp965+c17AGC9jU6i6mh2I8DUh/ICkQsmhTp7I9eA==
X-Received: by 2002:a05:6a00:889:b0:772:45ee:9bb6 with SMTP id d2e1a72fcca58-7742dccdc8bmr23098620b3a.9.1757601665601;
        Thu, 11 Sep 2025 07:41:05 -0700 (PDT)
Received: from LAPTOP-PN4ROLEJ.localdomain ([58.215.202.202])
        by smtp.gmail.com with ESMTPSA id d2e1a72fcca58-77607a47abfsm2370442b3a.32.2025.09.11.07.40.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 11 Sep 2025 07:41:05 -0700 (PDT)
From: Slavin Liu <slavin452@gmail.com>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>
Cc: Slavin Liu <slavin452@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	"David S . Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v3] ipvs: Defer ip_vs_ftp unregister during netns cleanup
Date: Thu, 11 Sep 2025 22:40:20 +0800
Message-Id: <20250911144020.479-1-slavin452@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20250909212113.481-1-slavin452@gmail.com>
References: 
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On the netns cleanup path, __ip_vs_ftp_exit() may unregister ip_vs_ftp
before connections with valid cp->app pointers are flushed, leading to a
use-after-free.

Fix this by introducing a global `module_removing` flag, set to true in
ip_vs_ftp_exit() before unregistering the pernet subsystem. In
__ip_vs_ftp_exit(), skip ip_vs_ftp unregister if called during netns
cleanup (when module_removing is false) and defer it to
__ip_vs_cleanup_batch(), which unregisters all apps after all connections
are flushed. If called during module exit, unregister ip_vs_ftp
immediately.

Fixes: 61b1ab4583e2 ("IPVS: netns, add basic init per netns.")
Suggested-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Slavin Liu <slavin452@gmail.com>
---
 net/netfilter/ipvs/ip_vs_ftp.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index d8a284999544..4db58c42ff9a 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -53,6 +53,7 @@ enum {
 	IP_VS_FTP_EPSV,
 };
 
+static bool module_exiting;
 /*
  * List of ports (up to IP_VS_APP_MAX_PORTS) to be handled by helper
  * First port is set to the default port.
@@ -605,7 +606,7 @@ static void __ip_vs_ftp_exit(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	if (!ipvs)
+	if (!ipvs || !module_exiting)
 		return;
 
 	unregister_ip_vs_app(ipvs, &ip_vs_ftp);
@@ -627,7 +628,9 @@ static int __init ip_vs_ftp_init(void)
  */
 static void __exit ip_vs_ftp_exit(void)
 {
+	module_exiting = true;
 	unregister_pernet_subsys(&ip_vs_ftp_ops);
+	module_exiting = false;
 	/* rcu_barrier() is called by netns */
 }
 
-- 
2.34.1

