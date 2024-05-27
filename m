Received: from todd.t-8ch.de (todd.t-8ch.de [159.69.126.157])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 52BC115EFA8;
	Mon, 27 May 2024 17:04:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=159.69.126.157
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1716829479; cv=none; b=cTA9CJdg9JPsSuMpzVbEYvtLAWf2txRy3QntXzQUpx0a1wrodQk+rJxeDilITtVpP8hnGT+22htOiXZf3Ioq1Bm/hDZMGGlCNlHpIf5ffmTnnxC8DHtp8Hp4tTbCPvFYYHCyHSdVGAKKNUr2kvRwSTcLlFiPcaeBeXOU8t+znFE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1716829479; c=relaxed/simple;
	bh=d+939s1gUjKIZzgNkXzByiTSHTvsRrwL2Na7XW8r8Sc=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=uUhzXFNaLZqaMyVEJvVpcTX0ImBT/X9Q0Iw+U/kymNBK0QRhPQqiSnFsg7eyeAfqtDKg5jQw0fp/CUHOQ4m+sR54LyFvfu6C09i6MGQT3mKBDCB55I8ZnBYVUCQuDYheeOIB/u6JfgQbtG0XkUfLqFCV+523iDTCxl6bKe88QGg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=weissschuh.net; spf=pass smtp.mailfrom=weissschuh.net; dkim=pass (1024-bit key) header.d=weissschuh.net header.i=@weissschuh.net header.b=ioEWqtoE; arc=none smtp.client-ip=159.69.126.157
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=weissschuh.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=weissschuh.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=weissschuh.net header.i=@weissschuh.net header.b="ioEWqtoE"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=weissschuh.net;
	s=mail; t=1716829474;
	bh=d+939s1gUjKIZzgNkXzByiTSHTvsRrwL2Na7XW8r8Sc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:From;
	b=ioEWqtoEhJv/qUIz1kd217IaIRGNkKHPwk+yb35eevzAepek/I3Stgk0fbQblRO8L
	 37Zoq/PWR3btDrjIcHcFi2X91IzcnNAFe1MtJ6YoGN5GRf+yr+bf3dshq/2R3baCqR
	 c/NgTdG3gMhRx8/+OSfQFSDgu7WZoOFSIDO5f22w=
From: =?utf-8?q?Thomas_Wei=C3=9Fschuh?= <linux@weissschuh.net>
Date: Mon, 27 May 2024 19:04:19 +0200
Subject: [PATCH net-next 1/5] net/neighbour: constify ctl_table arguments
 of utility function
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20240527-sysctl-const-handler-net-v1-1-16523767d0b2@weissschuh.net>
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
X-Developer-Signature: v=1; a=ed25519-sha256; t=1716829474; l=1125;
 i=linux@weissschuh.net; s=20221212; h=from:subject:message-id;
 bh=d+939s1gUjKIZzgNkXzByiTSHTvsRrwL2Na7XW8r8Sc=;
 b=I8PHk/EKKuje+OjEhgK0nJZr42eh/mh/MvKC2JH2tNPlQfzlr+QogobANgrxLs80EOlm2y+v7
 QJ43JvYzsvzA+ht8rQF6fFl1rRCIVfzgcwPJQ/bE1Oc0F9lui18zlRW
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
 net/core/neighbour.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 45fd88405b6b..277751375b0a 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -3578,7 +3578,7 @@ static void neigh_copy_dflt_parms(struct net *net, struct neigh_parms *p,
 	rcu_read_unlock();
 }
 
-static void neigh_proc_update(struct ctl_table *ctl, int write)
+static void neigh_proc_update(const struct ctl_table *ctl, int write)
 {
 	struct net_device *dev = ctl->extra1;
 	struct neigh_parms *p = ctl->extra2;

-- 
2.45.1

