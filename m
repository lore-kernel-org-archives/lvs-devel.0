Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793606886;
	b=Q/LZ3xFLaOjaSoLa+R57ILYY7dmM8aGmh228YzOdCZ2uQcHImMZ4nLdOv6nJfEQKZcYX
	 ozbvlIQW/3gaLNgsFAUAn6hWEmoHHpm2KFxDtOiU8uhjsCM+K6ZlSBZX/ssUe8ra14zgI
	 lFDzjCKbxOCnP1bbBAfLzNVJKG22izDfOg8NiXxaFqzyTqp1KH+WEqqW/1tflhSBkGysu
	 1Aq2OqIIO5OJzDVPAkZqjrx6S5m4vqxUq2Z+W8koIwaOuamdzgNfeVCI7vVe7764MFYCH
	 7tSqgeHdilKswAxPA7/EMMPRnj5VF/j9Cu4wu9vW1QWOQRlDgEFNIXoa8Lq3CD/XjVA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793606886;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:MIME-Version:Content-Transfer-Encoding;
	bh=UXpNPwwg/3VHXxujGKE9fvTZ6+Kbn3xYS2JPLzMac08=;
	b=U6bkv0OaxsIwIDCRJGxg4PPAI2PJhUnMDAjPoePCnj/5GwbGjgij75qd2AKFQnxOPh97
	 fTWp2cdT/S5C06q5P+roN5ecvkMaTFudn4o+x7lO392xa5Ayi1gFxoyXzOVDHrrIWJeXQ
	 lRq+p1cHs5NIH6zOcDBX+heHYQmKZcacWhV488XLYBLYq56E1p3XBvKxa+AlNjOHLo4p+
	 KOxc1f5sSYbEKBKpBJ50IfhYK5xe/+wZEeZzsyDA5ZoLjLVbDoARCgxGRPFPjVQMMtDwr
	 xMgpkGvSmp68xzh06FYydb24hlfhBaP5iEnb1DTTakJceW9RlmygfInfjQlOAHwPYew==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=J+qGcIWo;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5D41B606A32E;
	Mon,  2 Nov 2026 08:08:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 5D41B606A32E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=J+qGcIWo
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id D4AE821F8B;
	Mon, 02 Nov 2026 10:07:56 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-transfer-encoding:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=UXpNPwwg/3VHXxujGKE9fvTZ6+Kbn3xYS2JPLzMac08=; b=J+qGcIWoRMd/
	VA5w5tyD3KOjmlQk7kmgaQkKGBtqn1IscVY3f1z+QuG74cXTKKQcrTMMsCa/att3
	GDlpcAdkAyVnV2IZbHH+eeHEcKyR1yJ85AmOLVYoIkCrj9V85OobRZYfpQLQTBuy
	Tu3/Xmxsj4s6UXioj7tIcE6qf/iUn+vnDzbwvkqMuFiCdYJlCYMJyYryhGHpXp71
	Qp6+e/hGotZUP4UKfnfQscU40rAoWt5bF76qBtwgO+lOITM0InUiwNuSTAAjPXnH
	aIJOBmOsnusDpSKYg05ER4X4yIj5/rA2u6Z97VqVfMFlvb8H14ybvKoPXnn5A/VR
	C2qoQKwnv8txc8ki/MclFlM5ywG1T4K9+QjngiwtFusmMHjSGtOl10lX1K3khkRn
	dOFlBw62YQTJxwnFxdtyXgZgF054Xg08cNdUlzkXDKW+p4yL1vr4sevO27r/BVsS
	2YKMWQXJbAitX0rjM5/uAXL5bzq4BBDn0P2+Koif7MJxJW3ntrXJOYwOW5V7S0Kh
	v9WlPWE5EfGlm1sDWyGfnzB39ZwQ16pz0W3hoZJLAo/iD7odCtD9VhWXfxFJs/a4
	om+aUhGVZWw7soqa97ACPJHpinxP2Ocw66gr+g1ktSBwCXzJZzX5zdNMjnhi/+TK
	JzHkgip3bpWDm5ZGYZ04WMLWzo58dag=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Mon, 02 Nov 2026 10:07:56 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 2D18560BAF;
	Mon,  2 Nov 2026 10:07:56 +0200 (EET)
Received: from ja.home.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6A287fc0022199;
	Mon, 2 Nov 2026 10:07:41 +0200
Received: (from root@localhost)
	by ja.home.ssi.bg (8.18.2/8.18.2/Submit) id 6A287faF022198;
	Mon, 2 Nov 2026 10:07:41 +0200
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: [PATCH nf v3 1/2] ipvs: update flags and seqs in backup server under lock
Date: Mon,  2 Nov 2026 10:07:27 +0200
Message-ID: <20261102080728.22178-2-ja@ssi.bg>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261102080728.22178-1-ja@ssi.bg>
References: <20261102080728.22178-1-ja@ssi.bg>
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

Sashiko reports that we modify the conn flags and seq values in
the backup server without holding cp->lock. The same is true for
other fields such as state, old_state and timeout which are
modified by protocols under lock.

Extend the locked region in ip_vs_proc_conn() to update the
fields atomically.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Link: https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260927220816.268206-1-pablo%40netfilter.org
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_sync.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 157f5c8361ab..39b9bd83bc5c 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -850,6 +850,7 @@ static void ip_vs_proc_conn(struct netns_ipvs *ipvs, struct ip_vs_conn_param *pa
 			    unsigned long timeout, __u32 fwmark,
 			    struct ip_vs_sync_conn_options *opt)
 {
+	struct ip_vs_conn *cp_new = NULL;
 	struct ip_vs_dest *dest;
 	struct ip_vs_conn *cp;
 
@@ -891,9 +892,6 @@ static void ip_vs_proc_conn(struct netns_ipvs *ipvs, struct ip_vs_conn_param *pa
 		flags &= IP_VS_CONN_F_BACKUP_UPD_MASK;
 		flags |= cp->flags & ~IP_VS_CONN_F_BACKUP_UPD_MASK;
 		cp->flags = flags;
-		spin_unlock_bh(&cp->lock);
-		if (!dest)
-			ip_vs_try_bind_dest(cp);
 	} else {
 		/*
 		 * Find the appropriate destination for the connection.
@@ -920,6 +918,8 @@ static void ip_vs_proc_conn(struct netns_ipvs *ipvs, struct ip_vs_conn_param *pa
 		}
 		if (!(flags & IP_VS_CONN_F_TEMPLATE))
 			kfree(param->pe_data);
+		cp_new = cp;
+		spin_lock_bh(&cp->lock);
 	}
 
 	if (opt) {
@@ -951,6 +951,9 @@ static void ip_vs_proc_conn(struct netns_ipvs *ipvs, struct ip_vs_conn_param *pa
 		else
 			cp->timeout = (3*60*HZ);
 	}
+	spin_unlock_bh(&cp->lock);
+	if (!dest && !cp_new)
+		ip_vs_try_bind_dest(cp);
 	ip_vs_conn_put(cp);
 }
 
-- 
2.56.0


