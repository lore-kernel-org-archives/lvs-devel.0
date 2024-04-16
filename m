Received: from smtp-relay-internal-0.canonical.com (smtp-relay-internal-0.canonical.com [185.125.188.122])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9CFB412F393
	for <lvs-devel@vger.kernel.org>; Tue, 16 Apr 2024 14:59:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=185.125.188.122
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1713279559; cv=none; b=Lujl+msfDob7zfNqbH4HbP2jQ3ArAg9m4jZRj6rW7zL6BzcKl7Gdfyyps/OEWY4IInrHIZow4mkNg6udIf50TcNmjoQWWw1so0mzSeJTnKM7c0pJ6jsN/woVeokPPKkXwHx9Y7JTvAdnqJ+BL3F/e2m20PfH89iZNhm2HKU+NLI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1713279559; c=relaxed/simple;
	bh=7lyToubjndBkFS/xjTwm6ZMyDvw4t6Soiztt3CZy43I=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version:Content-Type; b=cbE5T9dSC2eHGEKrGQ+RNm+jrIIAft5ful4PTCf/MJIAsG9YVygG1Bw0BNZo/EHV3qCCKIOOeCkwI8sSzov+pkIx6gcM8+bVv3wcnkSDFQc9wkPwtVY1+9ES0bfNrHnMyeM1egHbGWTQIb6mklEjiqeEVr0SDytaUtZ5DlLX8hg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=canonical.com; spf=pass smtp.mailfrom=canonical.com; dkim=pass (2048-bit key) header.d=canonical.com header.i=@canonical.com header.b=bTNnjpIa; arc=none smtp.client-ip=185.125.188.122
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=canonical.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=canonical.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=canonical.com header.i=@canonical.com header.b="bTNnjpIa"
Received: from mail-ej1-f71.google.com (mail-ej1-f71.google.com [209.85.218.71])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-relay-internal-0.canonical.com (Postfix) with ESMTPS id 55560411E9
	for <lvs-devel@vger.kernel.org>; Tue, 16 Apr 2024 14:49:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=canonical.com;
	s=20210705; t=1713278952;
	bh=SQh3gD+ToMzBSqvlRyRoPbaP+xTFtE8pqccMPR/X80o=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version:Content-Type;
	b=bTNnjpIaXCd5s6ImaVwHNR7OSVdldJr9ZXp9rizlLvN0oab5b/ipYE1rYNTdWZcki
	 sZiYr2Lria1r4Y3P94FTAa6fggkFwnfmoN2+KShG2m4/2STcSOG9IHkidpZ2O4Iug3
	 kZArQ6TkTQkayjwKRqUoNi3Be6Aip/zaV/5es6pil2Y+fW2rJVAJOEXUWZFbGIjFFD
	 ss2W4hgwqToocZT+FvWrvBkcKhYaAiN9S4dDRjGBw3n5gH65e4/4Gx67ThzOrQQTzA
	 Ew+p07TB13snTlofinejF86g628ukNRtOZL4zmzXpAuPav7cFQ31/HxJ2tgLFg/9pV
	 5oT28nwGfqUmg==
Received: by mail-ej1-f71.google.com with SMTP id a640c23a62f3a-a46cc88be5fso293790266b.2
        for <lvs-devel@vger.kernel.org>; Tue, 16 Apr 2024 07:49:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1713278952; x=1713883752;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=SQh3gD+ToMzBSqvlRyRoPbaP+xTFtE8pqccMPR/X80o=;
        b=fXnTT1jnh0o8ozBNFXrcxU33jaoH1GObxyAamMxAPpyqO5AKsJYr2paSVIUqkYraf9
         dCgAKz+Tp+ft+1JsmvuTAjTOUpiyRqecrLeTlLgMVYybHZeBFDaEVKIS9OaOOqsr2ira
         +xViaRRdA8FzDdugmYMsFW8fowwLMujqAHlaVG28oXZnHMRR/uYAUueK2TGHZa/YL7HB
         VWSOdDRx7CBUXPmZUgXKXpAVB+Z6b4vY+JemLYrn/yIMHTJ7RGTVDUD6uJnZQiFMfkVq
         uLbYguBz/8uMpFXHv5bDEVRPdYfWyJc8tj8FRPMKPXKBTS7Fi0L3oOHE+7QWZZ7JNB+J
         2kbw==
X-Forwarded-Encrypted: i=1; AJvYcCU0GS5YdUWT1/DVfOhaKnvo9JN0Uui4vbeL/vSfBuPmDyEfh7SFwekSmQb/hxpF1F4Xq8NOcqOQaA+8/LXYHcBjTkyEDuXrsy/Y
X-Gm-Message-State: AOJu0YxVeUsPo+jqpW912SzoEph63tBaUTha1nXz3AlCKd62cNq6vnpD
	LOg96eJBZFn1rVZ9yJzWLTHe42wWQ0DwZG3+PhW7cNflEpbcUL3Q/Nl+wMKOtd0Zam+Bf1vBAWK
	+nipr9lriWzJZeCZ/kkoTULOt4OPE6a5YqYso5S7tYNOBx7eqcHBEd57sAhcpLSsCukWy/iUUCw
	==
X-Received: by 2002:a17:906:4956:b0:a52:6a4b:c810 with SMTP id f22-20020a170906495600b00a526a4bc810mr3400656ejt.35.1713278951886;
        Tue, 16 Apr 2024 07:49:11 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IEyz7nSFg/BkyuaXVLZ2ohQQZlKhJDri29PE7VWvk9uGXGz9gTCezlFmTExiTaW78zWQV6OQA==
X-Received: by 2002:a17:906:4956:b0:a52:6a4b:c810 with SMTP id f22-20020a170906495600b00a526a4bc810mr3400639ejt.35.1713278951519;
        Tue, 16 Apr 2024 07:49:11 -0700 (PDT)
Received: from amikhalitsyn.lan ([2001:470:6d:781:ef8b:47ab:e73a:9349])
        by smtp.gmail.com with ESMTPSA id gv15-20020a170906f10f00b00a517995c070sm6916856ejb.33.2024.04.16.07.49.10
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 16 Apr 2024 07:49:11 -0700 (PDT)
From: Alexander Mikhalitsyn <aleksandr.mikhalitsyn@canonical.com>
To: horms@verge.net.au
Cc: netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexander Mikhalitsyn <aleksandr.mikhalitsyn@canonical.com>,
	=?UTF-8?q?St=C3=A9phane=20Graber?= <stgraber@stgraber.org>,
	Christian Brauner <brauner@kernel.org>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@netfilter.org>,
	Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next] ipvs: allow some sysctls in non-init user namespaces
Date: Tue, 16 Apr 2024 16:48:14 +0200
Message-Id: <20240416144814.173185-1-aleksandr.mikhalitsyn@canonical.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Let's make all IPVS sysctls visible and RO even when
network namespace is owned by non-initial user namespace.

Let's make a few sysctls to be writable:
- conntrack
- conn_reuse_mode
- expire_nodest_conn
- expire_quiescent_template

I'm trying to be conservative with this to prevent
introducing any security issues in there. Maybe,
we can allow more sysctls to be writable, but let's
do this on-demand and when we see real use-case.

This list of sysctls was chosen because I can't
see any security risks allowing them and also
Kubernetes uses [2] these specific sysctls.

This patch is motivated by user request in the LXC
project [1].

[1] https://github.com/lxc/lxc/issues/4278
[2] https://github.com/kubernetes/kubernetes/blob/b722d017a34b300a2284b890448e5a605f21d01e/pkg/proxy/ipvs/proxier.go#L103

Cc: Stéphane Graber <stgraber@stgraber.org>
Cc: Christian Brauner <brauner@kernel.org>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Jozsef Kadlecsik <kadlec@netfilter.org>
Cc: Florian Westphal <fw@strlen.de>
Signed-off-by: Alexander Mikhalitsyn <aleksandr.mikhalitsyn@canonical.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 143a341bbc0a..92a818c2f783 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -4285,10 +4285,22 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
 		if (tbl == NULL)
 			return -ENOMEM;
 
-		/* Don't export sysctls to unprivileged users */
+		/* Let's show all sysctls in non-init user namespace-owned
+		 * net namespaces, but make them read-only.
+		 *
+		 * Allow only a few specific sysctls to be writable.
+		 */
 		if (net->user_ns != &init_user_ns) {
-			tbl[0].procname = NULL;
-			ctl_table_size = 0;
+			for (idx = 0; idx < ARRAY_SIZE(vs_vars); idx++) {
+				if (!tbl[idx].procname)
+					continue;
+
+				if (!((strcmp(tbl[idx].procname, "conntrack") == 0) ||
+				      (strcmp(tbl[idx].procname, "conn_reuse_mode") == 0) ||
+				      (strcmp(tbl[idx].procname, "expire_nodest_conn") == 0) ||
+				      (strcmp(tbl[idx].procname, "expire_quiescent_template") == 0)))
+					tbl[idx].mode = 0444;
+			}
 		}
 	} else
 		tbl = vs_vars;
-- 
2.34.1

