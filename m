Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795409959;
	b=HZm3GhemcBMaBE7DQo3woUVBo5zFq3QF24m7NcyN6p+3IiHXgX8mr9NLZf2HP+aDguN2
	 0rop4oGzLsLjzYgvpdrIenhxzMcjlcoNfdCNmfzIjkz7FUYQAnRvOI3hWn3dh8uSX12P8
	 HH44xWkJnl1z9YpbeeUh78rBaLxSDVVE2dCIcZ/u85z72CTWsnIlFCBbclVN260LhhJZz
	 sJ11uVML5dupNqv9xI3Da58ARbNrBHwiZy4nJHGIlfDcdh0YpIHF4vumdg3DQy0p101k7
	 QBggwcMjfjY8dGGoH2UZl+no+1HYlAJr6BJusvN5t1E7ls8in4uqrPL3qUrWTKLs5sA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795409959;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=zZPMnOoD3D5OwWOxaet/uf4K5uCHN0KkpJ2jHZ+77oE=;
	b=SwNfqW64kJIASZrZQx6xA8IcxEKe2o1m33aolj4rpaYY3uLbu0XLCvq16keWduw6yffa
	 +PGpMfsKinUbYftouungiPUUeyLmkQEOWZGEcozn9gAKwuwpjglfT5LONZSmHXgXEOv5V
	 qjpmcwKBB99lOlQn7Qw1JkQZGD+kgknza4iFEwLtmovR2jRvCR5Gju8YsegEJ3R9pGIqe
	 fIxovP1VL/Cd/cy6aWqNwRjshrYapOVjpnL/MpA/LnaW4ld5BWoqmL6HtlXQ3KUyii0Qa
	 arlVdNrJf/5EuVdk6d3QJ+ZnpMuK35SvUBIg/1EchEjDnKNzfGURXWPbVtJqH5/9RLA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=U+cLN2Fy;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B5CE0606A31A;
	Mon, 23 Nov 2026 04:59:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B5CE0606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=U+cLN2Fy
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 67A7321B1A;
	Mon, 23 Nov 2026 06:59:08 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:message-id
	:mime-version:reply-to:subject:subject:to:to; s=ssi; bh=zZPMnOoD
	3D5OwWOxaet/uf4K5uCHN0KkpJ2jHZ+77oE=; b=U+cLN2FyLLLgKmNNeiHI88aF
	Me+Rh9pwMbi8IZtadKcVYO0Nbr5bWheydeu7iJwNF8dR8TxKGvIGHJ2VlYmNyeY4
	XqxXjgTWjYQ9ClcbDQ62EzU2VkFsjFkMEvWEKZlAG1c8rGgdTmffclWCNf2TA80X
	K7ABwrl9j2JjdMMKjUnGaTjDRWgSmzCVFJ/+xfDcp1o7VewcKn3rAgQm7WB8TQ9n
	PFreStrrh9F7KIywOJ7a5THWVpEqG87irxrxws6ZEtFhP0YUmW80ba0Fj0ISi64S
	S/W9SF2FcY3nCkHA0eA/TdAWG5VAu6iBoRIeibm9eUNrpozPr8WhsxgJGB6iWhOl
	gSU59uj7RyhBlCUgYK5L0HOuSMBp+XSH5QLIGXboOn2W568LyUT0ALi32DA9lkOJ
	vqswSo0eL0lwQTIr+ni5BjbRxgJfGd7oqRodU9bSc8BYMPeIZLdbob64Jqm2Rybu
	/K2CArpU3gCjN/lsyDQ4uC2a/njSWj/UBplxgqYxbW8ZDqD9+N8hca9q+JePFkqo
	U3GG0Xt8w9N7Xotc1att5RU2K/WupBDpkHvUvAMfzPs6LLPIu9StZ/g8iCj16U8i
	Ozp0S/UyvObYT7WHlK4UyGXbM1yRff3JSCLWCAX+xvHl2Q2MDQR9RIejS4exWL8O
	nN86/OUPz2v5rqfQWkI=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 23 Nov 2026 06:59:08 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 88DF960707;
	Mon, 23 Nov 2026 06:59:07 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6AN4x05h005462;
	Mon, 23 Nov 2026 06:59:00 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 6AN4x0cI005461;
	Mon, 23 Nov 2026 06:59:00 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Florian Westphal <fw@strlen.de>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org
Subject: [PATCH nf] ipvs: fix use-after-free after failed app module init
Date: Mon, 23 Nov 2026 06:58:44 +0200
Message-ID: <20261123045844.5444-1-ja@ssi.bg>
X-Mailer: git-send-email 2.56.1
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

Sashiko warns that we have two problems during app module init
which can lead to possible use-after-free.

1. We may successfully register app for particular port and netns
allowing the connections to take module reference but later
if init fails we still hold these references after the init phase,
long after the module is freed.

2. We may successfully register the ftp app for some netns but later
if init fails we still leak the registered apps and incarnations
after the init phase, long after the module is freed.

To fix the first problem we will disallow try_module_get() to be
called in MODULE_STATE_COMING state, i.e. while module init is
still running.

For the second problem, we recently added exiting_module variable to
catch the case when the ftp module was exiting but this does not
cover the init phase. Fix it by using defer_unreg variable which is
set while not in module init/exit phase to defer the app pernet
unregistration during cleanup_net to ip_vs_app_net_cleanup() after
all module references are dropped.

Link: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20261103140308.591690-3-pablo%40netfilter.org
Fixes: 134121bfd99a ("ipvs: Defer ip_vs_ftp unregister during netns cleanup")
Fixes: be97fdb5fbcc ("ipvs: generalize app registration in netns")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_app.c |  9 ++++++++-
 net/netfilter/ipvs/ip_vs_ftp.c | 24 +++++++++++++++++-------
 2 files changed, 25 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index 2c1b47702da2..fdec626124be 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -43,7 +43,14 @@ static DEFINE_MUTEX(__ip_vs_app_mutex);
  */
 static inline int ip_vs_app_get(struct ip_vs_app *app)
 {
-	return try_module_get(app->module);
+	struct module *mod = app->module;
+
+	/* Failed module init should return without any module references,
+	 * so allow access to the module only after the init phase.
+	 */
+	if (mod && module_is_coming(mod))
+		return false;
+	return try_module_get(mod);
 }
 
 
diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 44de99f4d187..0a6440c2132c 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -52,7 +52,8 @@ enum {
 	IP_VS_FTP_EPSV,
 };
 
-static bool exiting_module;
+static bool defer_unreg; /* Defer unreg on cleanup_net */
+
 /*
  * List of ports (up to IP_VS_APP_MAX_PORTS) to be handled by helper
  * First port is set to the default port.
@@ -629,10 +630,12 @@ static void __ip_vs_ftp_exit(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	if (!ipvs || !exiting_module)
-		return;
-
-	unregister_ip_vs_app(ipvs, &ip_vs_ftp);
+	/* Unregister app only on module init/exit, on netns cleanup
+	 * it is done later in ip_vs_app_net_cleanup().
+	 * It is equally correct to check for !net->is_dying.
+	 */
+	if (ipvs && !defer_unreg)
+		unregister_ip_vs_app(ipvs, &ip_vs_ftp);
 }
 
 static struct pernet_operations ip_vs_ftp_ops = {
@@ -643,7 +646,14 @@ static struct pernet_operations ip_vs_ftp_ops = {
 static int __init ip_vs_ftp_init(void)
 {
 	/* rcu_barrier() is called by netns on error */
-	return register_pernet_subsys(&ip_vs_ftp_ops);
+	int ret = register_pernet_subsys(&ip_vs_ftp_ops);
+
+	if (ret >= 0) {
+		defer_unreg = true;
+		/* commit before switching to MODULE_STATE_LIVE */
+		smp_wmb();
+	}
+	return ret;
 }
 
 /*
@@ -651,7 +661,7 @@ static int __init ip_vs_ftp_init(void)
  */
 static void __exit ip_vs_ftp_exit(void)
 {
-	exiting_module = true;
+	defer_unreg = false;
 	unregister_pernet_subsys(&ip_vs_ftp_ops);
 	/* rcu_barrier() is called by netns */
 }
-- 
2.56.1


