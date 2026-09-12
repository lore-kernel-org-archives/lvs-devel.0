Received: from mail-vs2-f12.google.com (mail-vs2-f12.google.com [74.125.227.12])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C66612E7380
	for <lvs-devel@vger.kernel.org>; Sat, 12 Sep 2026 01:32:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.12
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789176765; cv=none; b=k9LvqHu4OsqC8mnf567o4kxqkto4yNTACSKwuOJrDiYIRVwJ0J2bBNYT9Mn9c6PRmudow9ZGfdJctQuaZz+DTQc4DTkxzkuYAMmKSCIk/osy6aBkfkyxGogPyYbqnCiJnUeg2Q9fsUtKxhkT2w7G58m2DnWiw0BP0XKSlNVrTyU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789176765; c=relaxed/simple;
	bh=2YWlYRxSsd59Cxr38HsvuYWsNmqjwpeBupscQi1Ng5s=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=tySYMOU4Z5AYGT4iHaWpC8qZ9WIkSSlQkvH2+rUdPRqLYFvbXNtDFkglOSPGybtRGi117sQS0bUYGCoH07IXYINgPbv+EdSm2wIRvL7EgC2VqQgFXZlexskuSg1QUEQ2h2kXSXmCh7rGt7OjfhYgUs2s6EoADz/vrAVeydaxsBo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=CSRYfJZD; arc=none smtp.client-ip=74.125.227.12
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CSRYfJZD"
Received: by mail-vs2-f12.google.com with SMTP id ada2fe7eead31-7935ecb5d8fso60303137.2
        for <lvs-devel@vger.kernel.org>; Fri, 11 Sep 2026 18:32:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789176763; x=1789781563; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=C6zxdqyVH4a+n8GPVigkqqRm1GgEw+7DCMINwgLF4EI=;
        b=CSRYfJZDk7Kb80tYu/EhSCPAHljfBspw6sZsMC+jdlVD4j1673ZFNk4I4Nm/njpkS+
         Mt82nrKd2LSQsGT+ChL5B2n3ZZ1Bdastk11bPeOIhSyVTYSve4B2m3oqbdWwU6DTh8sx
         E06LAJgk4B/fEkRazeLAsg97/GYdBGMyXAxwbI+7X5TiHQtdNVYngSGIld8MHI8la6CG
         3Gbfr/RgV322NFYxddU5tHm1uMQngsiTbpIIVm5C+onNsWjpKVJ/vTzQcmTDaEZ6EEjh
         mus1mOu1NTRL4MDYc3E8ibsEeSChVJEbMdwcXGqxzqEKmmZaihcohc/+NKV5Gxbr9Guw
         CtJw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1789176763; x=1789781563;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=C6zxdqyVH4a+n8GPVigkqqRm1GgEw+7DCMINwgLF4EI=;
        b=dItk20RxEtZs7EZgGvrJEPflou+Rp0nH+G96NsNIbfs5cvrXfEshpSEh98Y1EB0lxA
         5G+6CcWt2fLOywZF12ajIBsPYI6N7Nc/Ogq/PppM2OHCpqfyyndbceTkuu+dXZwBTOxs
         aBTZI/+gYDnFxd6DyWMMqQCf5FBPh3Oqbtp0oBQSujnuRAp1ONuCCWQzUJe+n9GSVF02
         GHTAHJwBBVXxHPg3FIZ8j0fn2IQXYVzisJKAlLYAeOxxY/PREMiTfz2iP5mDY+lq8f56
         VPLhGTUtflWCP0uRxpBjjcm3jEC6WM67HOZy7BXBrX/p8sgC4ODtHJdVPzt++iq+8ahs
         bXyQ==
X-Forwarded-Encrypted: i=1; AKwUvBwv8hTq+IVD8mZP29eckz6ee55kg6ZnnC+ImjcT9C13gfXtnkRc9mgnTglhHfFvSKQamemsCcK5rYU=@vger.kernel.org
X-Gm-Message-State: AFuF++msycZKHC4h8p6jCKrOFWdU4FodTbv5LT4ofrLb30vWC8B/BRCp
	7jLQYWyxXMw+BnG9Urg/V4t2XWhDyLo9/Mb7aM0fUrzJYkPG+xmE4jzl
X-Gm-Gg: AYBFou2taHBwd3nQhA15DOEllWBjkWfCs11Gs+HyiDrm+jqtDlATOT5afb4csrAv5fK
	Xoj+i8EVAGkim0Ck+1F1neAJmioTfmZJyVmZE6LgLuL+LfghML/IsX07oSN0Lz9qhMfpdJ/iLQ+
	/uTB0k9cA5BtbTlpQ7/LuEnSOpuLMj2NJeub8r5elvDB0B7HcuVpnQOB783qPwZXiBDl6IYvSEd
	KL0OTvgsqpqeeG0qcjFoK5TaItSh91+Uw+v9UpZ6mCH3Sqm3rT0cPiHutCrH0+mL2CMggWSAebJ
	UcuoWuAs8IqrpAm62OIBYywAeXCn/23kw/0yFRiyyLnlSFP8tZJA50+FZO+KdNR0m4JIg+6O/Io
	DmGu1kanNLs5C0hQEiN7mzoTmzPiFX076pD+BaEfxxA/CF5Zsz1wxZmmzJe7H3BwWl+TSW65l9Q
	TKw5bhB4zRRoEtW9tZR5bf8LVw/mSR97zBGQIRKegJEzD/JjnetBhJcmNwWisV7ik=
X-Received: by 2002:a05:6102:c8f:b0:78f:7135:b4ff with SMTP id ada2fe7eead31-795a65b013dmr913468137.2.1789176762542;
        Fri, 11 Sep 2026 18:32:42 -0700 (PDT)
Received: from adriano ([190.215.95.120])
        by smtp.gmail.com with ESMTPSA id 71dfb90a1353d-5c84714c380sm4738262e0c.15.2026.09.11.18.32.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 11 Sep 2026 18:32:42 -0700 (PDT)
From: Adriano Cordova <adrianox@gmail.com>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	"David S . Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Shuah Khan <shuah@kernel.org>,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Adriano Cordova <adrianox@gmail.com>
Subject: [PATCH 1/4] ipvs: add flags for per-service secure TCP state table
Date: Fri, 11 Sep 2026 22:32:13 -0300
Message-ID: <20260912013216.588300-2-adrianox@gmail.com>
X-Mailer: git-send-email 2.51.0
In-Reply-To: <20260912013216.588300-1-adrianox@gmail.com>
References: <20260912013216.588300-1-adrianox@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Add the flag IP_VS_SVC_F_SECURE_TCP to mark a virtual service
for the DoS hardened TCP connection state table, and the
flag IP_VS_CONN_F_SECURE_TCP to mark a connection and then
pass to the TCP state machine.

The connection flag is included in IP_VS_CONN_F_BACKUP_MASK,
so it is preserved on the backup node.

Signed-off-by: Adriano Cordova <adrianox@gmail.com>
---
 include/uapi/linux/ip_vs.h | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
index 2c37c6ac7525..34fcfaf13cd3 100644
--- a/include/uapi/linux/ip_vs.h
+++ b/include/uapi/linux/ip_vs.h
@@ -27,6 +27,7 @@
 
 #define IP_VS_SVC_F_SCHED_SH_FALLBACK	IP_VS_SVC_F_SCHED1 /* SH fallback */
 #define IP_VS_SVC_F_SCHED_SH_PORT	IP_VS_SVC_F_SCHED2 /* SH use port */
+#define IP_VS_SVC_F_SECURE_TCP	0x0040		/* use the hardened TCP table */
 
 /*
  *      IPVS sync daemon states
@@ -89,6 +90,7 @@
 #define IP_VS_CONN_F_NO_CPORT	0x0800		/* no client port set yet */
 #define IP_VS_CONN_F_TEMPLATE	0x1000		/* template, not connection */
 #define IP_VS_CONN_F_ONE_PACKET	0x2000		/* forward only one packet */
+#define IP_VS_CONN_F_SECURE_TCP	0x0008		/* use the hardened TCP table */
 
 /* Initial bits allowed in backup server */
 #define IP_VS_CONN_F_BACKUP_MASK (IP_VS_CONN_F_FWD_MASK | \
@@ -96,7 +98,8 @@
 				  IP_VS_CONN_F_INACTIVE | \
 				  IP_VS_CONN_F_SEQ_MASK | \
 				  IP_VS_CONN_F_NO_CPORT | \
-				  IP_VS_CONN_F_TEMPLATE \
+				  IP_VS_CONN_F_TEMPLATE | \
+				  IP_VS_CONN_F_SECURE_TCP \
 				 )
 
 /* Bits allowed to update in backup server */
-- 
2.51.0

