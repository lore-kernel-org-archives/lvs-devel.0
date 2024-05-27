Received: from todd.t-8ch.de (todd.t-8ch.de [159.69.126.157])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7AC0E15EFC0;
	Mon, 27 May 2024 17:04:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=159.69.126.157
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1716829479; cv=none; b=VrhHZbctsrOiLhxTY8/Abzn1R/t5zZ+pcUTDkjTrsaewdvoCF/J4PrXTJA7BbhE2CD0nbODaVmR+qVhrmLR4CEVg+j015eI3On3CS/PJ2ENwYbYREgMbWOR9KhiqbKOKoMi/ssjmaDxhA8wyGq/DNecMH8Vvm6pwDOuv+mFjfcM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1716829479; c=relaxed/simple;
	bh=FFGTVRbTurxQo0JWz0lQLj1C10dd9/WiAX6I+AdPlYo=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=f/NjKTD8h6Li6sCZsv0Y7fPOLMc5FyeuTYU645HUfMVhs8P1YcafQhj3DMM9+4Pg1xH/7q+lDMTVZpGBje8XFz9aYbp9LSNPkhm0gPS/EBcz6X1iWTfUZ6AfKvHWNvIMcGqd2eenqWPDXkn8nY0B0Ow9fqSJoR1NMx6FV1BTWQM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=weissschuh.net; spf=pass smtp.mailfrom=weissschuh.net; dkim=pass (1024-bit key) header.d=weissschuh.net header.i=@weissschuh.net header.b=FV+sRWEO; arc=none smtp.client-ip=159.69.126.157
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=weissschuh.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=weissschuh.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=weissschuh.net header.i=@weissschuh.net header.b="FV+sRWEO"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=weissschuh.net;
	s=mail; t=1716829474;
	bh=FFGTVRbTurxQo0JWz0lQLj1C10dd9/WiAX6I+AdPlYo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:From;
	b=FV+sRWEOTy5EN7cytDdzZN3Cdk1S0GqDhR6xNXGxiUROtd0VqVHFfx50AplxEUIOM
	 88YFvMB2C94c7SdDyf2lWZW4E8aIPYqBIySfHmiryXBIN+L+cYsPDFw73c/mpYeU1o
	 YJSqhjjr/dHrJky2PZd/rmIg3VHdpjNrLbfCmS5s=
From: =?utf-8?q?Thomas_Wei=C3=9Fschuh?= <linux@weissschuh.net>
Date: Mon, 27 May 2024 19:04:21 +0200
Subject: [PATCH net-next 3/5] net/ipv6/addrconf: constify ctl_table
 arguments of utility functions
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20240527-sysctl-const-handler-net-v1-3-16523767d0b2@weissschuh.net>
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
X-Developer-Signature: v=1; a=ed25519-sha256; t=1716829474; l=2049;
 i=linux@weissschuh.net; s=20221212; h=from:subject:message-id;
 bh=FFGTVRbTurxQo0JWz0lQLj1C10dd9/WiAX6I+AdPlYo=;
 b=sttcjn5SIR5SkxssfxV9+g8iPbz84T1kDPeBe+IPUdpZAZ2FupxWcbTvb8V+QnDtrL0kkBGnf
 VPQTQD2ee+ODDB0jiKhyfgITYKangBPiGvIZentC4dP3yoxkPOqMF/D
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
 net/ipv6/addrconf.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 5c424a0e7232..1e69756d53d9 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -863,7 +863,7 @@ static void addrconf_forward_change(struct net *net, __s32 newf)
 	}
 }
 
-static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, int newf)
+static int addrconf_fixup_forwarding(const struct ctl_table *table, int *p, int newf)
 {
 	struct net *net;
 	int old;
@@ -931,7 +931,7 @@ static void addrconf_linkdown_change(struct net *net, __s32 newf)
 	}
 }
 
-static int addrconf_fixup_linkdown(struct ctl_table *table, int *p, int newf)
+static int addrconf_fixup_linkdown(const struct ctl_table *table, int *p, int newf)
 {
 	struct net *net;
 	int old;
@@ -6378,7 +6378,7 @@ static void addrconf_disable_change(struct net *net, __s32 newf)
 	}
 }
 
-static int addrconf_disable_ipv6(struct ctl_table *table, int *p, int newf)
+static int addrconf_disable_ipv6(const struct ctl_table *table, int *p, int newf)
 {
 	struct net *net = (struct net *)table->extra2;
 	int old;
@@ -6669,7 +6669,7 @@ void addrconf_disable_policy_idev(struct inet6_dev *idev, int val)
 }
 
 static
-int addrconf_disable_policy(struct ctl_table *ctl, int *valp, int val)
+int addrconf_disable_policy(const struct ctl_table *ctl, int *valp, int val)
 {
 	struct net *net = (struct net *)ctl->extra2;
 	struct inet6_dev *idev;

-- 
2.45.1

