Received: from esa4.hc1455-7.c3s2.iphmx.com (esa4.hc1455-7.c3s2.iphmx.com [68.232.139.117])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 770FB29414;
	Wed, 26 Jun 2024 08:13:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=68.232.139.117
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1719389625; cv=none; b=WAii/JOmlESSNJ4mGPMBfTNgcQzc4bR6zMXzo8XlKKqdWxPA4tnrrO7wwepWF3wLTBaGYU0w0oQHAbq5OCSejYImtejUVACfPOta22lJgkZrr4WDStnYaPSNikTJg68Eeo1PxKsO+j/NctFf/lyzpB4GkquZvDd+J02KXbqFvJQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1719389625; c=relaxed/simple;
	bh=fB4wushNe6ZaqPL3frnj3MfEwo4IuC6tye15qy810ZY=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=WFcHjjkdjVh2wHhFYX7I0rirL/XFJ6n7fPW431wjo7kH9UZLBdWzkK/DBX/yb9UmtgotSVvSoYUFIV3x0cz+y6ody402eakRStmHe73zmg3QA3kg498fkhwrZ5Vasm0JMXj2Nxexf+DvK/MkeoCVxRWA91ETy06T//BswW6OhT4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=fujitsu.com; spf=pass smtp.mailfrom=fujitsu.com; dkim=pass (2048-bit key) header.d=fujitsu.com header.i=@fujitsu.com header.b=Bxbi20Y3; arc=none smtp.client-ip=68.232.139.117
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=fujitsu.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=fujitsu.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=fujitsu.com header.i=@fujitsu.com header.b="Bxbi20Y3"
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=fujitsu.com; i=@fujitsu.com; q=dns/txt; s=fj2;
  t=1719389622; x=1750925622;
  h=from:to:cc:subject:date:message-id:mime-version:
   content-transfer-encoding;
  bh=fB4wushNe6ZaqPL3frnj3MfEwo4IuC6tye15qy810ZY=;
  b=Bxbi20Y32L7mlIMPtIR3ds3esPKelBYDMTAdM4Yg2HtiMpvQcgxWd8yE
   WYfFPCKeuupuq4ePhloKV3CT7zem8+LKBnEvj2WjqUWlaY0tvcTGLmXqU
   V9vz1HaX0Ghz7/VIhqIPQeUjQq43ozCAN8aLwhv56d/mamFSjJJ8UoBJz
   dnTCiS/QFdyY9/XOSlrFBiJUT50NkAXHyup2JpRXZ5VmxjippXS/8s8jP
   2HTZmrVqKVj+l1DMToMvY80+3xhV7qrwPIdfFUUoEB+A0NSXsngNZQGP6
   zeVKy2OPs2cR5H3OCwS6IOVVd+8PdDm7XgrtOyaCsm3fTdVP/JRUrsWXb
   A==;
X-IronPort-AV: E=McAfee;i="6700,10204,11114"; a="165088360"
X-IronPort-AV: E=Sophos;i="6.08,266,1712588400"; 
   d="scan'208";a="165088360"
Received: from unknown (HELO oym-r4.gw.nic.fujitsu.com) ([210.162.30.92])
  by esa4.hc1455-7.c3s2.iphmx.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 26 Jun 2024 17:12:28 +0900
Received: from oym-m4.gw.nic.fujitsu.com (oym-nat-oym-m4.gw.nic.fujitsu.com [192.168.87.61])
	by oym-r4.gw.nic.fujitsu.com (Postfix) with ESMTP id 7337AD8011;
	Wed, 26 Jun 2024 17:12:26 +0900 (JST)
Received: from kws-ab4.gw.nic.fujitsu.com (kws-ab4.gw.nic.fujitsu.com [192.51.206.22])
	by oym-m4.gw.nic.fujitsu.com (Postfix) with ESMTP id 31CC4D52D0;
	Wed, 26 Jun 2024 17:12:23 +0900 (JST)
Received: from edo.cn.fujitsu.com (edo.cn.fujitsu.com [10.167.33.5])
	by kws-ab4.gw.nic.fujitsu.com (Postfix) with ESMTP id A896A1EBD8C;
	Wed, 26 Jun 2024 17:12:22 +0900 (JST)
Received: from G08FNSTD200033.g08.fujitsu.local (unknown [10.167.225.189])
	by edo.cn.fujitsu.com (Postfix) with ESMTP id 680CD1A0002;
	Wed, 26 Jun 2024 16:12:21 +0800 (CST)
From: Chen Hanxiao <chenhx.fnst@fujitsu.com>
To: Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@netfilter.org>,
	"David S . Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>
Cc: netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Subject: [PATCH net-next] ipvs: properly dereference pe in ip_vs_add_service
Date: Wed, 26 Jun 2024 16:11:59 +0800
Message-Id: <20240626081159.1405-1-chenhx.fnst@fujitsu.com>
X-Mailer: git-send-email 2.37.1.windows.1
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
X-TM-AS-Product-Ver: IMSS-9.1.0.1417-9.0.0.1002-28482.006
X-TM-AS-User-Approved-Sender: Yes
X-TMASE-Version: IMSS-9.1.0.1417-9.0.1002-28482.006
X-TMASE-Result: 10-1.419900-10.000000
X-TMASE-MatchedRID: 4r2MyAYFTncx4g+7LKrJbJwzEulNiZLqStGAgmKqWuX5V4X/65Dwb+Rg
	EMvCxuZnkLJauoXWknKkXqcpclKhdeBRuAss+FbmEXjPIvKd74BMkOX0UoduueTpBuL72LoPJcL
	HRGvpYJ3GnUCcr382gRU6KGPlAba7lwV2iaAfSWcURSScn+QSXmVV1G+Ck2l7+gtHj7OwNO0HTT
	+SR4FPANwYzzO5tA66zOpSNPQxGoMZ2uv99crag/8Ha6kHC3BZOp2SRaudtzkgyDNZSq3Dn94JA
	OmVdEEOF82ierRtzFTLnV1O7xRVt4aT7FRqp0wPAcQrAfBh69vBRLFeH6OJSCTDD+DBjuEw
X-TMASE-SNAP-Result: 1.821001.0001-0-1-22:0,33:0,34:0-0

Use rcu_dereference_protected to resolve sparse warning:

  net/netfilter/ipvs/ip_vs_ctl.c:1471:27: warning: dereference of noderef expression

Fixes: 39b972231536 ("ipvs: handle connections started by real-servers")
Signed-off-by: Chen Hanxiao <chenhx.fnst@fujitsu.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index b6d0dcf3a5c3..925e2143ba15 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1369,7 +1369,7 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 {
 	int ret = 0;
 	struct ip_vs_scheduler *sched = NULL;
-	struct ip_vs_pe *pe = NULL;
+	struct ip_vs_pe *pe = NULL, *tmp_pe = NULL;
 	struct ip_vs_service *svc = NULL;
 	int ret_hooks = -1;
 
@@ -1468,7 +1468,8 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 		atomic_inc(&ipvs->ftpsvc_counter);
 	else if (svc->port == 0)
 		atomic_inc(&ipvs->nullsvc_counter);
-	if (svc->pe && svc->pe->conn_out)
+	tmp_pe = rcu_dereference_protected(svc->pe, 1);
+	if (tmp_pe && tmp_pe->conn_out)
 		atomic_inc(&ipvs->conn_out_counter);
 
 	/* Count only IPv4 services for old get/setsockopt interface */
-- 
2.39.1

