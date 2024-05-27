Received: from todd.t-8ch.de (todd.t-8ch.de [159.69.126.157])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7AC5815EFC1;
	Mon, 27 May 2024 17:04:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=159.69.126.157
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1716829479; cv=none; b=kPY02Wx8DHHD+w6X08Bln9IBxxWfqFl6S2XOmUTI8zx2FgTlAMCf/OLaaul1BWRNan6znRm+dyIdKq4jGN2eGbJBb5UzsqNt/WGp9poDv3asmusY2CsCQt6m+9vGRFIAxb6hRfw35M8v6P0OaAJkWBRkGqcK276+rXdht2dbnLs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1716829479; c=relaxed/simple;
	bh=6bL6o2hxyBnXcYtE4OX3yQlXt4wHX1IZ6z1HXg4YTBk=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=C/GZQawcANFXochF+QIAA+jH908UTDM2iiETOyPfZL8KZNVvJ64e9FegD1x22YH6/z00I+ggGnkttfobOhALEQ9PC4zfPFCWw0YE8S0SCcT+QQ1hKLuFmjyQAcs/FTnYUWMbCSzWx5Cu8StrEW+ZvVNZjYskjpNBDWLm9z7GVL4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=weissschuh.net; spf=pass smtp.mailfrom=weissschuh.net; dkim=pass (1024-bit key) header.d=weissschuh.net header.i=@weissschuh.net header.b=lqxWsCfl; arc=none smtp.client-ip=159.69.126.157
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=weissschuh.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=weissschuh.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=weissschuh.net header.i=@weissschuh.net header.b="lqxWsCfl"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=weissschuh.net;
	s=mail; t=1716829474;
	bh=6bL6o2hxyBnXcYtE4OX3yQlXt4wHX1IZ6z1HXg4YTBk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:From;
	b=lqxWsCflEGwW19FrFUiFp4De6UxyScYLTSkduJW/fU5Qg7l5ex7td7Gy94VfWY+Zi
	 jfPtQ+hLjKssploNEcrzQS4oizGn0MyazL355TZwPXJpDD22aFKye7Isg3+D8hTyKF
	 exRKnWIEygkHl5GBvAhhsrmqhHBl2sTh+iE9rp8I=
From: =?utf-8?q?Thomas_Wei=C3=9Fschuh?= <linux@weissschuh.net>
Date: Mon, 27 May 2024 19:04:20 +0200
Subject: [PATCH net-next 2/5] net/ipv4/sysctl: constify ctl_table arguments
 of utility functions
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20240527-sysctl-const-handler-net-v1-2-16523767d0b2@weissschuh.net>
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
X-Developer-Signature: v=1; a=ed25519-sha256; t=1716829474; l=1585;
 i=linux@weissschuh.net; s=20221212; h=from:subject:message-id;
 bh=6bL6o2hxyBnXcYtE4OX3yQlXt4wHX1IZ6z1HXg4YTBk=;
 b=dLFQIDCQf5HQcl5crzjSnoc/K6V0T8suTQVBLbLK4maEZiLFn9DDVa6zHKrQ+E8V5TpmVXdYa
 9X2NvZxdxjOB2GfaD1j2GxruOHgL0gqSvV3ykbTTaIgy6tI7OkODKNE
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
 net/ipv4/sysctl_net_ipv4.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 162a0a3b6ba5..d7892f34a15b 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -130,7 +130,8 @@ static int ipv4_privileged_ports(struct ctl_table *table, int write,
 	return ret;
 }
 
-static void inet_get_ping_group_range_table(struct ctl_table *table, kgid_t *low, kgid_t *high)
+static void inet_get_ping_group_range_table(const struct ctl_table *table,
+					    kgid_t *low, kgid_t *high)
 {
 	kgid_t *data = table->data;
 	struct net *net =
@@ -145,7 +146,8 @@ static void inet_get_ping_group_range_table(struct ctl_table *table, kgid_t *low
 }
 
 /* Update system visible IP port range */
-static void set_ping_group_range(struct ctl_table *table, kgid_t low, kgid_t high)
+static void set_ping_group_range(const struct ctl_table *table,
+				 kgid_t low, kgid_t high)
 {
 	kgid_t *data = table->data;
 	struct net *net =

-- 
2.45.1

