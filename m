Received: from todd.t-8ch.de (todd.t-8ch.de [159.69.126.157])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 817CC15EFC2;
	Mon, 27 May 2024 17:04:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=159.69.126.157
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1716829479; cv=none; b=puPx8ylwREKFVNCQsC8G7d0Z6SN87p6LUh3kYjYKHbKgZt+Y9R997Hu9kHvydIRcnkELIk5SaGzK5LefumioHCM3FRl4ybqGJUiRSsfur+Ge9FXdQzkSbK3kHzKMi8HSI2uzjcP4NoWMkF8hogP2X5UaGpAmj/0J2kmtLAI7LCA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1716829479; c=relaxed/simple;
	bh=IZAxBClgjR2JRRgfT5u1GNIr+agkxq1+agyYcocn9Rs=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=s7BCaF916vJiCg+dBkEgPXIT/qeRxzpVK+Gyd+MdTRmDv9hL6TuV9bnTeeBRlRao1yz412EFhgWhHZplSkOVMwhhmwzd4lv9Rcp+ak504Es2gY+t3N7j4WYHpeAqvFmnAeiRtGYWFjuqQA5BGXBP5YDmHv1aOlGVdc0RUun3Z7Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=weissschuh.net; spf=pass smtp.mailfrom=weissschuh.net; dkim=pass (1024-bit key) header.d=weissschuh.net header.i=@weissschuh.net header.b=da/fhpWv; arc=none smtp.client-ip=159.69.126.157
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=weissschuh.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=weissschuh.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=weissschuh.net header.i=@weissschuh.net header.b="da/fhpWv"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=weissschuh.net;
	s=mail; t=1716829474;
	bh=IZAxBClgjR2JRRgfT5u1GNIr+agkxq1+agyYcocn9Rs=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:From;
	b=da/fhpWvJelKxMWpgjF8T7sg0ljON57xbSnx/pR9isNqHBqFm5Lr/c8WMZs0ZP4bq
	 b71Vzcrn3R9Q2+LG6r6EHTJFx4RoZJJRLRZ4C5VWv1j4LSuXhG2el/8I0+S5yK9Hsv
	 iJUcNRq1H55iPWiGLsQeTSaojsBi0YAZXy00+vx8=
From: =?utf-8?q?Thomas_Wei=C3=9Fschuh?= <linux@weissschuh.net>
Date: Mon, 27 May 2024 19:04:22 +0200
Subject: [PATCH net-next 4/5] net/ipv6/ndisc: constify ctl_table arguments
 of utility function
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20240527-sysctl-const-handler-net-v1-4-16523767d0b2@weissschuh.net>
References: <20240527-sysctl-const-handler-net-v1-0-16523767d0b2@weissschuh.net>
In-Reply-To: <20240527-sysctl-const-handler-net-v1-0-16523767d0b2@weissschuh.net>
To: "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, David Ahern <dsahern@kernel.org>, 
 Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, 
 Pablo Neira Ayuso <pablo@netfilter.org>, 
 Jozsef Kadlecsik <kadlec@netfilter.org>
Cc: Joel Granados <j.granados@samsung.com>, 
 Luis Chamberlain <mcgrof@kernel.org>, netdev@vger.kernel.org, 
 linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, 
 netfilter-devel@vger.kernel.org, coreteam@netfilter.org, 
 =?utf-8?q?Thomas_Wei=C3=9Fschuh?= <linux@weissschuh.net>
X-Mailer: b4 0.13.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1716829474; l=1095;
 i=linux@weissschuh.net; s=20221212; h=from:subject:message-id;
 bh=IZAxBClgjR2JRRgfT5u1GNIr+agkxq1+agyYcocn9Rs=;
 b=hw+Pgu/VKaC68kmI3/6DupMdnaPEiQWJV4ODKOTgA1hLEJwxHTRAfUo5GeMcva1eO0s8yKF9v
 1wznNFvMJTOC66Nx627QVe8fLrKNrFbhksSFY1a6itTykcQ7gRtObEE
X-Developer-Key: i=linux@weissschuh.net; a=ed25519;
 pk=KcycQgFPX2wGR5azS7RhpBqedglOZVgRPfdFSPB1LNw=

The sysctl core is preparing to only expose instances of
struct ctl_table as "const".
This will also affect the ctl_table argument of sysctl handlers.

As the function prototype of all sysctl handlers throughout the tree
needs to stay consistent that change will be done in one commit.

To reduce the size of that final commit, switch utility functions which
are not bound by "typedef proc_handler" to "const struct ctl_table".

No functional change.

Signed-off-by: Thomas Weißschuh <linux@weissschuh.net>
---
 net/ipv6/ndisc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index d914b23256ce..254b192c5705 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1936,7 +1936,7 @@ static struct notifier_block ndisc_netdev_notifier = {
 };
 
 #ifdef CONFIG_SYSCTL
-static void ndisc_warn_deprecated_sysctl(struct ctl_table *ctl,
+static void ndisc_warn_deprecated_sysctl(const struct ctl_table *ctl,
 					 const char *func, const char *dev_name)
 {
 	static char warncomm[TASK_COMM_LEN];

-- 
2.45.1

