Received: from mail-pl1-f194.google.com (mail-pl1-f194.google.com [209.85.214.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F318E22333B;
	Mon,  8 Sep 2025 06:55:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.194
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1757314539; cv=none; b=E/kyejSR/6FPHY2rz93ewt7sC/XyWhNHB6+nF4Es+L3MjnyGZAE+hAXyRYawlOiSqQkt+arYnVgHyr3x2CCpAEG0SpxqEqy1AY7adzB9Eaf6zhaOvMOV1gjDcV1ipckiei6YOOZuposdj7flmH48oSTBCX8P8xZH2gdvpuYmMxE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1757314539; c=relaxed/simple;
	bh=7bTeksVHgoD9R6xdLvzwlbYp8OJAiXj4vQhWz3mJ+D8=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=AoNHnmhDgOBPCgryQNNxCI5lnXaCmD9VyVz3eng/9GM/XVdqCSQI3JfP/RLlllhnJa6Cw4rm1nsXCERegwj84lSEIcobChpZnXqOXNoAc1ehJpgW8U31mH6QyOgKu1RDMyPwJD9XaA2c3HtfP8BASHZrzrwxYyK531Zyt8Zcnlg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=LRwrAnOE; arc=none smtp.client-ip=209.85.214.194
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LRwrAnOE"
Received: by mail-pl1-f194.google.com with SMTP id d9443c01a7336-24cbd9d9f09so54436085ad.2;
        Sun, 07 Sep 2025 23:55:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1757314537; x=1757919337; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=m+4an8/Jt/b4JIGzziEWzfZAC//LsinPWKCYsKZxOsU=;
        b=LRwrAnOEvZ/oo3c0wpBTqevb3ifpqUBYAY4w38Bdeg2Sv1XpKCjnO/BrLFRSqJdGjG
         L5IBwpwiV0gHfT6OIzglAGq9uDBZT5nywzbS92G8EOehFwlKmD/by/fbELDScnlRakZg
         TCfYvrOVZgQPOZnj0N1kH4PWCnb7TdkYMraJhIgerAY9nPt4Q0ZW9U/d2QN2oG/35rSE
         jwy5kguS+bR4qW4bIdrqhd041dFNnY3Wls+G/ewyRHQ97zmAUQCgWCWsEWYrwNLOJIy/
         USA8wJ6OmJ9/a+pEzBss/9nETto6qUgKUZkvhJxK8Wg1Z25Sm5LL3A7h3mz/j8k1v48n
         Wayg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1757314537; x=1757919337;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=m+4an8/Jt/b4JIGzziEWzfZAC//LsinPWKCYsKZxOsU=;
        b=vmM9ufqe40ovPMPcE+coh8QMqJS3K7vrYh/zUYU3gUtKQa4pDyDqqUgj7jJbycGYmo
         w5VksW3R3/eh1u+7Et1rvOm4m9qIqE/9pHTwrO9dVTXOZPFeRPhd4DVSb/LtZbPFxaje
         bTxs7RoXbVEIg/vrBYRNfk8FJlkz7ls1Ms9Si84KjEBZuqI1S2UN5oKI56Ia0xGap23s
         jJ2Tvj9jsahVrj7ZP9gFA/bD0OSdqIgTMLkSgYIIhoblzNPNSCUmIakdjtB3bP1ujaPB
         nvrs17kNdwlGqozfaLrkM6TPsIxmmAf34oviV7sSMG4ircbECeRc1O5Da/bU+dz4Ztrd
         tG0g==
X-Forwarded-Encrypted: i=1; AJvYcCUDbdrIGuu6w6YuhGAdQ5JUBVG/7RHBrZrzNEZ7KcB+BXxIDAqtuzwHK/K7PS11nG53AV6oaWvvZC9OxNER/PQz@vger.kernel.org, AJvYcCUG0Kq5nNB86umSZHp3cBHNMh4aY6AhgExUiICpW40aHdnAagpLSnAsap3mzVHfyss9UucDAtyQ@vger.kernel.org, AJvYcCUZI0Uintcsw/GF/usTPZ9PNsClLpFIcgjdZYLnSprYWRHe+XorgHnUEOHKIifaNKJWnbjgyD997UXLmnQ=@vger.kernel.org, AJvYcCXtvTlynpZeWIC8WaY0wgZmwkmuL4G1NRU7ypKK+Ujw9VE7H8XZsrHiQE2mgJ0EeJ0RBBkMcVQXVifK@vger.kernel.org
X-Gm-Message-State: AOJu0YxB/5iNfXqS5kSboAxjMMzWpGMMWwKrZq/Ffpja+rnnV/d/YpMw
	H51rdqXYuAhRJ2rBDr9vEbC01a/iddLjg0XR2QpOJXo5kPpyoY0N8OuL
X-Gm-Gg: ASbGncvp2NQdyNZ8cjUu09fWOAK7s9dZER8Ux4kmOjX2vbHBsQRD/auOqZ/13EK42ha
	+20SIjRUoGLUVBf9Dh6nCEyftNfoRBZ/vi+MTT0AgJD4rOsqoXLjRNILw0coLEF2E/LIVMSIQHL
	3VGAq307c+trFeDXd9jzIe8DwSGg5FcgnKwfzh5N44zngfoDBspwqcU9tygI/xWUQzk7XbGZm/t
	+t2b7B9NO1VMRGRxBC1RWNitmdjMyLWlWPm+5aQ5QNHmtjhVo3AGjlk0JuC87eZ/I5XX0R1PR9V
	yflE6KCN6GAIe2GXKm3BoeXfh2hJWYc5HGxvzp2Ccmn0acZw3cyrMs1vs1uNjottIZhKgnE84A4
	U/mc4Vv9iAxZMUQ3LO8xx1ZekJV+OWtkJNX7guzerv/zK8SYvgRKDMg==
X-Google-Smtp-Source: AGHT+IERpqLRWZZggZfXidF0BIQUzIIQrruf3eLug6WWMnit4W8FJL2qnWiuLeQslKVuS6tNgq261A==
X-Received: by 2002:a17:902:e2c4:b0:24a:f7dc:cad4 with SMTP id d9443c01a7336-2516ef54e11mr65328835ad.11.1757314537095;
        Sun, 07 Sep 2025 23:55:37 -0700 (PDT)
Received: from LAPTOP-PN4ROLEJ.localdomain ([221.228.238.82])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-32b94a2feacsm4566083a91.8.2025.09.07.23.55.31
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 07 Sep 2025 23:55:36 -0700 (PDT)
From: Slavin Liu <slavin452@gmail.com>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>
Cc: Slavin Liu <slavin452@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 1/1] IPVS: Fix use-after-free issue in ip_vs_unbind_app()
Date: Mon,  8 Sep 2025 14:54:58 +0800
Message-Id: <20250908065458.536-1-slavin452@gmail.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When exiting a network namespace, in cleanup_net()->ops_undo_list(),
ip_vs_ftp_ops->exit() is called before ip_vs_core_ops->exit_batch().
The ip_vs_app ip_vs_ftp and its incarnations will be freed by unregister_ip_vs_app().
However, there could still be connections bound to ip_vs_ftp's incarnation.
cp->app points to the free'd incarnation, which will be accessed later by
__ip_vs_cleanup_batch()->ip_vs_conn_net_cleanup()->ip_vs_conn_flush()->ip_vs_conn_del()->
ip_vs_conn_expire()->ip_vs_unbind_app(), causing a uaf. This vulnarability can
lead to a local privilege escalation.

Reproduction steps:
1. create a ipvs service on (127.0.0.1:21)
2. create a ipvs destination on the service, to (127.0.0.1:<any>)
3. send a tcp packet to (127.0.0.1:21)
4. exit the network namespace

I think the fix should flush all connection to ftp before unregistration.
The simpler fix is to delete ip_vs_ftp_ops->exit, and defer the unregistration
of ip_vs_ftp to ip_vs_app_net_cleanup(), which will unregister all ip_vs_app.
It's after ip_vs_conn_net_cleanup() so there is no uaf issue. This patch
seems to solve the issue but has't been fully tested yet, and is also not graceful.

Signed-off-by: Slavin Liu <slavin452@gmail.com>
---
 net/netfilter/ipvs/ip_vs_ftp.c | 13 -------------
 1 file changed, 13 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index d8a284999544..68def1106681 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -598,22 +598,9 @@ static int __net_init __ip_vs_ftp_init(struct net *net)
 	unregister_ip_vs_app(ipvs, &ip_vs_ftp);
 	return ret;
 }
-/*
- *	netns exit
- */
-static void __ip_vs_ftp_exit(struct net *net)
-{
-	struct netns_ipvs *ipvs = net_ipvs(net);
-
-	if (!ipvs)
-		return;
-
-	unregister_ip_vs_app(ipvs, &ip_vs_ftp);
-}
 
 static struct pernet_operations ip_vs_ftp_ops = {
 	.init = __ip_vs_ftp_init,
-	.exit = __ip_vs_ftp_exit,
 };
 
 static int __init ip_vs_ftp_init(void)
-- 
2.34.1

