Received: from cstnet.cn (smtp81.cstnet.cn [159.226.251.81])
	(using TLSv1.2 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C3A6E2F691F;
	Thu, 28 May 2026 07:22:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=159.226.251.81
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779952939; cv=none; b=uRCqLakLuAMkW8XlpL31QI4nRGtmor3tacLjxCL7MVWqAIteiUKX/McnOtqE1wMxMmFEajL1gBlBV71lgtbbjoQn+aV7XAq6eD8V3SClBKOprj+h8KAqiDdVawnJnJN5UHing0xdYPJogDu7M2dcepRNkffLMCl9o8iUDsTEHlU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779952939; c=relaxed/simple;
	bh=HQccW3NY6NB8F97899rtJRwOSafIKecHykuhjXPa8is=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=Rlo479j2do0+8eIFBFMnRzxgSyLDCU3jkJwGVUpYmES+3whRur+HTJCZOX3B072bLvWKbzYMju/Q/qTInF1+Sp7akqMQ9BfBbOQBNk+X4M6Jd0N3gak62IRnSFkljPW8rhoQsGCnahMYrEviuuYX+BLNrrqwqXeHAStEMv1oHQc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=iscas.ac.cn; spf=pass smtp.mailfrom=iscas.ac.cn; arc=none smtp.client-ip=159.226.251.81
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=iscas.ac.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=iscas.ac.cn
Received: from dfae2b116770.home.arpa (unknown [36.110.52.2])
	by APP-03 (Coremail) with SMTP id rQCowAAX_OL+7BdqDZ6tEg--.412S2;
	Thu, 28 May 2026 15:21:34 +0800 (CST)
From: Wentao Liang <vulab@iscas.ac.cn>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	"David S . Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>
Cc: Phil Sutter <phil@nwl.cc>,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	linux-kernel@vger.kernel.org,
	Wentao Liang <vulab@iscas.ac.cn>,
	stable@vger.kernel.org
Subject: [PATCH] netfilter: ipvs: fix ct refcount leak when template is invalid
Date: Thu, 28 May 2026 07:21:00 +0000
Message-Id: <20260528072100.1163109-1-vulab@iscas.ac.cn>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-CM-TRANSID:rQCowAAX_OL+7BdqDZ6tEg--.412S2
X-Coremail-Antispam: 1UD129KBjvJXoW7KryfKFyrZrWUGr43Gw4DArb_yoW8XFy7p3
	42kry3XrWUGryDGr4kAFyxJryakr4xAF17ur90k3s3Xwn0qF4Uta1a9rya9F48Ar4Yg3y3
	XF4Fq39xCF95CFJanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUU9014x267AKxVW8JVW5JwAFc2x0x2IEx4CE42xK8VAvwI8IcIk0
	rVWrJVCq3wAFIxvE14AKwVWUJVWUGwA2ocxC64kIII0Yj41l84x0c7CEw4AK67xGY2AK02
	1l84ACjcxK6xIIjxv20xvE14v26ryj6F1UM28EF7xvwVC0I7IYx2IY6xkF7I0E14v26F4j
	6r4UJwA2z4x0Y4vEx4A2jsIE14v26rxl6s0DM28EF7xvwVC2z280aVCY1x0267AKxVW0oV
	Cq3wAS0I0E0xvYzxvE52x082IY62kv0487Mc02F40EFcxC0VAKzVAqx4xG6I80ewAv7VC0
	I7IYx2IY67AKxVWUJVWUGwAv7VC2z280aVAFwI0_Gr0_Cr1lOx8S6xCaFVCjc4AY6r1j6r
	4UM4x0Y48IcxkI7VAKI48JM4x0x7Aq67IIx4CEVc8vx2IErcIFxwACI402YVCY1x02628v
	n2kIc2xKxwCY1x0262kKe7AKxVWUtVW8ZwCF04k20xvY0x0EwIxGrwCFx2IqxVCFs4IE7x
	kEbVWUJVW8JwC20s026c02F40E14v26r1j6r18MI8I3I0E7480Y4vE14v26r106r1rMI8E
	67AF67kF1VAFwI0_GFv_WrylIxkGc2Ij64vIr41lIxAIcVC0I7IYx2IY67AKxVWUJVWUCw
	CI42IY6xIIjxv20xvEc7CjxVAFwI0_Gr0_Cr1lIxAIcVCF04k26cxKx2IYs7xG6r1j6r1x
	MIIF0xvEx4A2jsIE14v26r1j6r4UMIIF0xvEx4A2jsIEc7CjxVAFwI0_Gr0_Gr1UYxBIda
	VFxhVjvjDU0xZFpf9x0JUqeHgUUUUU=
X-CM-SenderInfo: pyxotu46lvutnvoduhdfq/1tbiBwkBA2oXz2JAoAABs9

ip_vs_sched_persist() calls ip_vs_ct_in_get() to look up an existing
connection template, which returns ct with a reference held. If the
template exists but fails the ip_vs_check_template() validation, the
function can leak the reference in two ways:

1. If no destination is found (scheduler returns NULL), the function
   returns NULL at the !dest check without calling ip_vs_conn_put(ct).

2. If a destination is found and a new template is created via
   ip_vs_conn_new(), the old ct pointer is overwritten without its
   reference being released.

Fix this by adding ip_vs_conn_put(ct) before the early return when no
destination is found, and before overwriting ct with the new template.

Cc: stable@vger.kernel.org
Fixes: 5b57a98c1f0d ("IPVS: compact ip_vs_sched_persist()")
Signed-off-by: Wentao Liang <vulab@iscas.ac.cn>
---
 net/netfilter/ipvs/ip_vs_core.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index d40b404c1bf6..bdc3f296876a 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -536,6 +536,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 			IP_VS_DBG(1, "p-schedule: no dest found.\n");
 			kfree(param.pe_data);
 			*ignored = 0;
+			ip_vs_conn_put(ct);
 			return NULL;
 		}
 
@@ -551,6 +552,7 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
 		if (ct == NULL) {
 			kfree(param.pe_data);
 			*ignored = -1;
+			ip_vs_conn_put(ct);
 			return NULL;
 		}
 
-- 
2.34.1

