Received: from mail-m49197.qiye.163.com (mail-m49197.qiye.163.com [45.254.49.197])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 15395388391;
	Fri,  4 Sep 2026 07:19:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=45.254.49.197
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788506362; cv=none; b=ZHk0FO2QRBdGVteMdC4onm8g+ZI/6fp6fQuUky7gQJ4YMsJOfkRR6JzQUOFtcn1O3ouhVF0feKwsL+umv/C1yHU+3xogPh6qOwdS/BOd+9VA05EXnemepw1vJF8R0lBTY77u7W2F0zrbbBm7Vt3XBYmm4FW3zTPKLYboc/GaGMo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788506362; c=relaxed/simple;
	bh=WjPgyhsJhdzJK/5eZTmlpOqsb5WAQS2B2xKFpuZ3xdU=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=Yfuep6casJTsUqmma/uYP+MAFKIYgNO81xtCaLgSWcNpDvhm1tycdkSDPLx0w4X5t6+YGWxLNEFIWN7ilaL78eXTvFJGkc/QuaoNveMzy0Hs3qnDxgvsn3oAstxUwAK4B4sWFanfcClviidaPnonhc4lKDXDXnLVUAoiusNkZns=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=seu.edu.cn; spf=pass smtp.mailfrom=seu.edu.cn; dkim=pass (1024-bit key) header.d=seu.edu.cn header.i=@seu.edu.cn header.b=njBUSfnt; arc=none smtp.client-ip=45.254.49.197
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=seu.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=seu.edu.cn
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=seu.edu.cn header.i=@seu.edu.cn header.b="njBUSfnt"
Received: from PC-202605011814.localdomain (unknown [222.191.246.242])
	by smtp.qiye.163.com (Hmail) with ESMTP id 4c87b05b0;
	Fri, 4 Sep 2026 15:19:13 +0800 (GMT+08:00)
From: Runyu Xiao <runyu.xiao@seu.edu.cn>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Cc: netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org,
	Runyu Xiao <runyu.xiao@seu.edu.cn>,
	Jianhao Xu <jianhao.xu@seu.edu.cn>
Subject: [PATCH net] ipvs: shut down destination trash timer on netns cleanup
Date: Fri,  4 Sep 2026 15:19:08 +0800
Message-Id: <20260904071908.4052966-1-runyu.xiao@seu.edu.cn>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-HM-Tid: 0aa06b492fca03a1kunmc2bb1dbc2dfe3
X-HM-MType: 10
X-HM-Spam-Status: e1kfGhgUHx5ZQUpXWQgPGg8OCBgUHx5ZQUlOS1dZFg8aDwILHllBWSg2Ly
	tZV1koWUFITzdXWRgWCB1ZQUpXWS1ZQUlXWQ8JGhUIEh9ZQVkaT0xPVk5CGR5JSEoeGEhJT1YeHw
	5VEwETFhoSFyQUDg9ZV1kYEgtZQVlJSUlVSkJKVUlPTVVJT0lZV1kWGg8SFR0UWUFZT0tIVUpLSE
	pPSExVSktLVUpCS0tZBg++
DKIM-Signature: a=rsa-sha256;
	b=njBUSfntNTF6zelMXWxmvGK0pgBkoH3JDqSwLQtV8agBObwlw5WzhsDaAnXp9OI7r73OclR8pJha0sgxrxz0xLIa7yREr3k6LERxkPu8i/4H+1GQTWk2HhCmTUSJYl+T25jIJluDOXvY9T/3aZhzeoliaA3KRgkzR7olsI/6Pew=; c=relaxed/relaxed; s=default; d=seu.edu.cn; v=1;
	bh=tnj/RY/ptp6lpQUCEDvXfPt6ryVtxdbMi4SqTFsPpmQ=;
	h=date:mime-version:subject:message-id:from;

ip_vs_dest_trash_expire() accesses the per-network-namespace IPVS state
and rearms the destination trash timer while entries remain.  The
cleanup path uses timer_delete_sync(), which waits for a running callback
but still allows a racing callback to rearm the timer.

Use timer_shutdown_sync() when the per-network-namespace destination
trash is finally cleaned up.  This prevents the callback from being
queued again before the IPVS state is released.

Fixes: f2431e6e9255 ("IPVS: netns, trash handling")
Cc: stable@vger.kernel.org
Assisted-by: Codex:GPT-5
Signed-off-by: Runyu Xiao <runyu.xiao@seu.edu.cn>

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 4c1c73944..0eb6cdb5f 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1192,7 +1192,7 @@ static void ip_vs_trash_cleanup(struct netns_ipvs *ipvs)
 {
 	struct ip_vs_dest *dest, *nxt;
 
-	timer_delete_sync(&ipvs->dest_trash_timer);
+	timer_shutdown_sync(&ipvs->dest_trash_timer);
 	/* No need to use dest_trash_lock */
 	list_for_each_entry_safe(dest, nxt, &ipvs->dest_trash, t_list) {
 		list_del(&dest->t_list);
-- 
2.34.1
