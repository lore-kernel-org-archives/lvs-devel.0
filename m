Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 68C8F2571DD;
	Tue,  9 Sep 2025 21:21:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.193
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1757452893; cv=none; b=oSRLUtvFWbjvhFye8O7sq3iXNUF72w7soEr1j8MBpSDwTyW81iFDPgtR6HmkG8ubZCOVsaXdbCVqEgG+/xIZyNICkZQBBPGTPYGmfVEjbBTf8wXU2Enzm4TkBrgxcO1absbpa7W4QmzNLNIHEBPZb4nWbsxWQ7WlkmttsVIAGxI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1757452893; c=relaxed/simple;
	bh=fGpYVORY+qi58YmG/3U9rcvve3DeVxRV1bOvuD50mzI=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=DmO0bilWwn5pwkv+DMgLcnbVMo8LMI1rpcGyMx1fevxiFu8P+StyImegUW5Fyv/oi/HOZsIOA7ldy0cIXrOQtMGJyQiqQj/nHKBq0/IGf7jnUZHIrs1km1wJ5WnQBUYOloQ4nmi/2ovsPugMgbbyhDygGc0ImF8CPgMz6e6gFRc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=L7RAzYS3; arc=none smtp.client-ip=209.85.210.193
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="L7RAzYS3"
Received: by mail-pf1-f193.google.com with SMTP id d2e1a72fcca58-772627dd50aso22483b3a.1;
        Tue, 09 Sep 2025 14:21:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1757452891; x=1758057691; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=fNIzLjHSBMLmqpsA4YNTE+ISQHf5o0XV501JWW+/q58=;
        b=L7RAzYS3X7Ef6aGNFv/W8T936JKodRnrr5cghvHPUNn1VlLTYB1cojRJTEyQwbX5vE
         I0YjuhmMaW5XQGpteoBRyJllMlbz4AyT597OVf93aPdpda11migNJpJGFM4wfGx9LWsG
         Z1zbi2HlKchlLNe6gGXIhsph6I5N11pbut3+n+SKku0sJXiFaybM4l4cg6sK7SyuiCHw
         YjWEtgITcF1e/+FcNnMM3u+EsJU0VKR1Ez13ErjPrbD/9Fxn6Jc5Lu9QqDPKzXRuP+vM
         XJzSCBMlckSE4i++gWwHKDhydP2Sh/H5Ut5RIXQ3FKTRRV6uIDqR8wAoFg/OXAyV8PMT
         PyKw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1757452891; x=1758057691;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=fNIzLjHSBMLmqpsA4YNTE+ISQHf5o0XV501JWW+/q58=;
        b=vK+TZ7HNGcRkrWcIcAY8cg1qfcGXRKj3KZq0gZi+1zVXRxet2vOzWvKyd9KZDpY4Gc
         308tpxakhyyxwBiSRo+vknjx6SDkqp+A2hHiELjNULcExYpX4JyZHVES+hSLRZHsHgCI
         7YfqRL+C/ooWBxhXhgFZ+jX3UTpDJtebMq5SoYC8HgDACgRKiZC/B1Rq6tjJSzIXy6XX
         SsdEnciDFuzeo6vOMkNuCxqU8zEYGL4z1jPJiEB757BSX7A4s4FR7H6HeWyb+7vqIDRH
         prRqIRJKXgE09wJutDnzmjQCtwOMtbrpUDMdLmpXuzOlPVmSnutl92OjhIjolERj5jOR
         HuNg==
X-Forwarded-Encrypted: i=1; AJvYcCVMf1UCyKv2lqbMZQaLQ2DBGvvBj4eU7Hk/WdUeH3TnjqR9J8lIboM7km+h8IoeIbx1VJasWpAqKRBh2ak=@vger.kernel.org, AJvYcCWGuzp97GutlXUryEx1K1V83+PvjE/rpkAIoYF12X406N870qWSMU0mMkW6MaEJOVs655zDmnCQBD5QhbKate6M@vger.kernel.org, AJvYcCXC5fZIAESGM7GvSh7faupJPLmd7GBZRUSC4F1QIhKePJIRGKI6DAy/sjvXIlj4cwPXdtp7PnBPChH6@vger.kernel.org, AJvYcCXvB29g+acoWcDgn2WlABp1AkaRH/TKhWFSN7vATnh1/xuTzss1apQ37lo7+Y0HCpVYW3E7NACi@vger.kernel.org
X-Gm-Message-State: AOJu0YzqgU6R8uxwwm932hRYdqSdU3aw+wawCaC365pbkn/+9l7vEEly
	DAmdvK+1CtNtKd/Yv7RVbx/tnRCEqK9XPX+V/jON7KLyAU+dlTj/CIjM
X-Gm-Gg: ASbGncuzkdViNHcJYOsgS3f2DO9SVKlS+7fOchQDImu8KcxwMmLDl7+XJtlZH2M/lps
	3jtaKU19H0ZjgEhW2dwm8CmHtzf61cUysrKS9VXTJ2J6Oam7pWVUOX40utCrzI8jv+vty+w9B58
	E/TTWjtyQdrukX6ZMkklmFzuShgKm6g4/yF+5Sz4133IEnRvN3pcxzy7YFv1u1qfbmqbZnPmHwX
	9kopfDW2MEqvaCYY6/Ap8+exbaDfQJHw9Rzj/bbX2zk4WzVJJXOVyGFvUlQC1SotiLhNoKs86El
	pGdOMUT3SsEx/mNleXnivYhIMrvoznwMMPJIZd+fIg43DiiR3KcsHjEToHJIKbFB5SiGNd7X235
	BwxsLcaWNE/319UAv0qhIsIKh/dBjZTAzBuyHEncvtQro
X-Google-Smtp-Source: AGHT+IF69GVm9IJToysR6lZUWdZsdWbHVct0EQQeI0UW59zElW5/J7tOX73xksOIgvt4CiPamd/grw==
X-Received: by 2002:a17:902:e551:b0:24c:7bf0:6e68 with SMTP id d9443c01a7336-24cedc7aa79mr250229135ad.7.1757452890597;
        Tue, 09 Sep 2025 14:21:30 -0700 (PDT)
Received: from LAPTOP-PN4ROLEJ.localdomain ([223.112.146.162])
        by smtp.gmail.com with ESMTPSA id 41be03b00d2f7-b548a3f31a5sm658936a12.8.2025.09.09.14.21.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 09 Sep 2025 14:21:30 -0700 (PDT)
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
Subject: [PATCH v2] ipvs: Check ipvs->enable before unregistration in __ip_vs_ftp_exit()
Date: Wed, 10 Sep 2025 05:21:13 +0800
Message-Id: <20250909212113.481-1-slavin452@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20250908065458.536-1-slavin452@gmail.com> 
References: 
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On netns cleanup path, before unregistration in __ip_vs_ftp_exit(),
there could still be existing conns with valid cp->app.

Suggested by Julian, this patch fixes this issue by checking ipvs->enable 
to ensure the right order of cleanup:
1. Set ipvs->enable to 0 in ipvs_core_dev_ops->exit_batch()
2. Skip app unregistration in ip_vs_ftp_ops->exit() by 
	checking ipvs->enable
3. Flush all conns in ipvs_core_ops->exit_batch()
4. Unregister all apps in ipvs_core_ops->exit_batch()

Access ipvs->enable by READ_ONCE to avoid concurrency issue.

Suggested-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Slavin Liu <slavin452@gmail.com>
---
 net/netfilter/ipvs/ip_vs_ftp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index d8a284999544..d3e2f7798bf3 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -605,7 +605,7 @@ static void __ip_vs_ftp_exit(struct net *net)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	if (!ipvs)
+	if (!ipvs || !READ_ONCE(ipvs->enable))
 		return;
 
 	unregister_ip_vs_app(ipvs, &ip_vs_ftp);
-- 
2.34.1

