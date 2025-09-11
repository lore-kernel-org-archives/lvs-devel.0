Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5B435362999
	for <lvs-devel@vger.kernel.org>; Thu, 11 Sep 2025 17:58:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.196
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1757613489; cv=none; b=g6z1tpOGwP5wx5UhlANkyuQeKqIC9sYFV/5SUQzgK+Q27AFmF4nRsK0wUDNWURkCzIPMbxY5x5mwTxnmh+QjLMiC2PIaBY4kcUqDY29NvukZi/srxxK2TourEEJwZDq048mAuhpB5Dm1Rn/F4cuMt8/o9MYoobxQ+BxdmiiKkyY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1757613489; c=relaxed/simple;
	bh=Pm9Apo4QHpXic38DAH5OGxtr6ou8VcwBJFVP53wjRfE=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=KhSBR4hTxRskpWxeAGxGtnp9bikCcEcQwM6tpzscEBm7RET8D1GywglCMTH+9/UawTai0VdLNotuJh/+/WNVgvXrYzFL+iWjhtkHkS7GDXCZC/XQ+p1JZ0WsnPd1oQROjvM53snL9P8aVlKWpKRS27Ewb5gYbwgF7B6jGQ0A4JI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Sj6ChNil; arc=none smtp.client-ip=209.85.210.196
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Sj6ChNil"
Received: by mail-pf1-f196.google.com with SMTP id d2e1a72fcca58-772627dd50aso2329856b3a.1
        for <lvs-devel@vger.kernel.org>; Thu, 11 Sep 2025 10:58:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1757613487; x=1758218287; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=Iw7YUMOBfQ9U5b9jGNBg6dyHxPq4WQMdK/IHZCbdPrk=;
        b=Sj6ChNil8uV1gQtJZ2ETvPGy1/VD3BKPBiojbm18ihfQvKgS1H5LcakMRcVpL4+XH5
         5uCVGRZsb78ENUdItmK1X4zj9L33Kq6hcKFq3Oz2QUZoYcpRjDBGP2hBBNqZpB26OqQn
         Nb+7iBnZeegBpFpzxITyiasNYDKwUjyfeL1aIFTCVW1YMg7HEu0tNGcPpcTFXyECOINO
         Ia/3LZU7Q6Jj8qAXCm6jDNu0Zlk+SayC5FUNsJBOh8RmC6JMappuY6em2ydJ+B4QDbqf
         AaqPhi0leb5LKyCw+KCrDzQGwnJ/vaeqa54Ae4+LFVCroYtBo4YFvEKLBUzUYUOs/CyM
         7fVg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1757613487; x=1758218287;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=Iw7YUMOBfQ9U5b9jGNBg6dyHxPq4WQMdK/IHZCbdPrk=;
        b=mPVHK+eYVTXXQ4qUBzhx3CrFpHtX/bhomXV2tqSpJ0+Wd053/DJN/n/ROkDPPQWq3P
         l/YR62oXXlmrzUFwPCEAHoxcHZGHFndCGPtLiwkQq3/qZxj58Tu/kV2/FB4XTplg4wq4
         M92axprQ+FxLktJde3F5Pv0NFh8Imo+SRv9oyyoJsOwevorG98sKzvUNGw0w+1wyw0Yb
         lIicBR1x94cqEVyONn3gJYQJ4tHIOfAfXNIKgYUD/UZx045MAfQ3FT+MvrtLEoDatL+N
         fq1yy6HdF7wNT7zznOKuiznweVs23w5Vpy/i/Gbntks4Pfa9qRHhYezu2bGytK3et+Gs
         Ij0A==
X-Forwarded-Encrypted: i=1; AJvYcCUkJVeMs181RDbAUrePlgqScUKMfASZHDNJXHPexzyGza6DryaCPJNcXXcSX7+Kn/RM7gnZzcFxy0Y=@vger.kernel.org
X-Gm-Message-State: AOJu0YxJcW3GTRX+290InS+bw/q2RfnrzAFj91QdK9Sa2sMAveVpdnzc
	zEKH517u+hJrveAyX7TN+xCQtZzx2UoCeuQXOwVgLwzhGL0bhR2/dL8x
X-Gm-Gg: ASbGncvWeCRDLkKKOVLmFNnKWKqKCuGDWcoXun2eO7J/yuh4V/BeS/H5tDpFrpivp8m
	9VGCmNDZv135KVXFCzyBYOHYm3T+KU9qDvK17a0WJdwfUio9JgpY/Z0H5QINs1pqI7SoMnhn6u9
	ShdYESDD3b1lwO0IYJcIA+XwpD4nEv5qrCXyzSR3t29qNW9W9u0e1d35z6HvwgbenB9qYEiYCDs
	pVNE0AmLO83+rOrRge7kYJdQ2Z3SBLe18Kj7rtU10tLWtffUkC6T6oVGMu4mkjM+hzyJcPOPdcl
	7EgVqhjTQXVDc0XXDoUWHrQaSQdU76+0h9FJrAXqXVhOqeef5YdAYijV7AmcW/9gPzZc1Z3qEQ7
	tly+mmO3wcTO0pJWnMlPbCCoMfhDTUYD6xL8lsHumO9BfcQjgDLpucXQ=
X-Google-Smtp-Source: AGHT+IG77yXU5YlLI1tFffiCTEQpvWi9veG5l2RgvVH0S57Unqa0HNc8Ibh+Grt38fgXKTYeu86E+Q==
X-Received: by 2002:a05:6a21:3394:b0:243:d1bd:fbac with SMTP id adf61e73a8af0-2602820cf69mr266598637.7.1757613486523;
        Thu, 11 Sep 2025 10:58:06 -0700 (PDT)
Received: from LAPTOP-PN4ROLEJ.localdomain ([223.112.146.162])
        by smtp.gmail.com with ESMTPSA id d2e1a72fcca58-77607b34254sm2731524b3a.75.2025.09.11.10.58.02
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 11 Sep 2025 10:58:06 -0700 (PDT)
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
Subject: [PATCH v4] ipvs: Defer ip_vs_ftp unregister during netns cleanup
Date: Fri, 12 Sep 2025 01:57:59 +0800
Message-Id: <20250911175759.474-1-slavin452@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20250911144020.479-1-slavin452@gmail.com>
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

Fix this by introducing a global `exiting_module` flag, set to true in
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
 net/netfilter/ipvs/ip_vs_ftp.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index d8a284999544..206c6700e200 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -53,6 +53,7 @@ enum {
 	IP_VS_FTP_EPSV,
 };
 
+static bool exiting_module;
 /*
  * List of ports (up to IP_VS_APP_MAX_PORTS) to be handled by helper
  * First port is set to the default port.
@@ -605,7 +606,7 @@ static void __ip_vs_ftp_exit(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	if (!ipvs)
+	if (!ipvs || !exiting_module)
 		return;
 
 	unregister_ip_vs_app(ipvs, &ip_vs_ftp);
@@ -627,6 +628,7 @@ static int __init ip_vs_ftp_init(void)
  */
 static void __exit ip_vs_ftp_exit(void)
 {
+	exiting_module = true;
 	unregister_pernet_subsys(&ip_vs_ftp_ops);
 	/* rcu_barrier() is called by netns */
 }
-- 
2.34.1

