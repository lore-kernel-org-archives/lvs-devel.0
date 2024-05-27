Received: from todd.t-8ch.de (todd.t-8ch.de [159.69.126.157])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EF177160787;
	Mon, 27 May 2024 17:04:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=159.69.126.157
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1716829482; cv=none; b=Yn5Tfn/wKubTtFkyyGWyp8+iAgMkBfv6ZncYNuXxkDRVDT2tyjFjWCUxMNHN6t8MZKxh5K4lgperCML6SgNj+vzx8O5hf8OaU/6Vz+7XwcT2pUV92DygMVlwfkcd/CuZIjBnsHb+VsuajoUOI8CIcjSBtvQvHPcheto0ckcjAsw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1716829482; c=relaxed/simple;
	bh=ailtByMMrVQJn27XJsDw/nbP0vGnYMWIFcr3PmJgg44=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=UrV8bZcbWKtrPB4B7A5NBO7sFlbkZzuCc56Ioq3Egt6h4O7abZde1z/a3u9S2JNVGwc3EphtOA5OZMsK7o1vRI3RW4iIBpv7c3G9qp0SMsQ6BlSZyslayPdK/9TfWBNX8sjEpv/zvMjJ1cqYIQBAcsisVf8meHGuVD0GhZMpuX0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=weissschuh.net; spf=pass smtp.mailfrom=weissschuh.net; dkim=pass (1024-bit key) header.d=weissschuh.net header.i=@weissschuh.net header.b=IqE+RzwB; arc=none smtp.client-ip=159.69.126.157
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=weissschuh.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=weissschuh.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=weissschuh.net header.i=@weissschuh.net header.b="IqE+RzwB"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=weissschuh.net;
	s=mail; t=1716829475;
	bh=ailtByMMrVQJn27XJsDw/nbP0vGnYMWIFcr3PmJgg44=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:From;
	b=IqE+RzwBivIpCk4R98n5wU8NbdtFNA+FjTy44Dg0QoHNpAZkUfkT06AVDH6iZpljW
	 OqnVmISUXO7mrkDbigqPFtiBZ4xFpfvQUu54F6B4C413eo8GTozbD0/fHz9Zs9es3Q
	 oPyeOuQ6tKb+jjN5c+wgRUvpbiTwi/LGmQ+dzq4E=
From: =?utf-8?q?Thomas_Wei=C3=9Fschuh?= <linux@weissschuh.net>
Date: Mon, 27 May 2024 19:04:23 +0200
Subject: [PATCH net-next 5/5] ipvs: constify ctl_table arguments of utility
 functions
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20240527-sysctl-const-handler-net-v1-5-16523767d0b2@weissschuh.net>
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
X-Developer-Signature: v=1; a=ed25519-sha256; t=1716829474; l=1608;
 i=linux@weissschuh.net; s=20221212; h=from:subject:message-id;
 bh=ailtByMMrVQJn27XJsDw/nbP0vGnYMWIFcr3PmJgg44=;
 b=Ru62T8Y5h2w0VlL5uxRe86TKAf0NyNrErX+coxsEOXiZxsk2X1m5Z125qR4GW1qsgvz6opeXk
 Ute+fsbkP1mCkvqzSYzyYHVbtm+V4CfChBn24ke9FiCqBONYI60ePzj
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
 net/netfilter/ipvs/ip_vs_ctl.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index b6d0dcf3a5c3..78a1cc72dc38 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1924,7 +1924,8 @@ proc_do_sync_ports(struct ctl_table *table, int write,
 	return rc;
 }
 
-static int ipvs_proc_est_cpumask_set(struct ctl_table *table, void *buffer)
+static int ipvs_proc_est_cpumask_set(const struct ctl_table *table,
+				     void *buffer)
 {
 	struct netns_ipvs *ipvs = table->extra2;
 	cpumask_var_t *valp = table->data;
@@ -1962,8 +1963,8 @@ static int ipvs_proc_est_cpumask_set(struct ctl_table *table, void *buffer)
 	return ret;
 }
 
-static int ipvs_proc_est_cpumask_get(struct ctl_table *table, void *buffer,
-				     size_t size)
+static int ipvs_proc_est_cpumask_get(const struct ctl_table *table,
+				     void *buffer, size_t size)
 {
 	struct netns_ipvs *ipvs = table->extra2;
 	cpumask_var_t *valp = table->data;

-- 
2.45.1

