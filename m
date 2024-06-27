Received: from esa4.hc1455-7.c3s2.iphmx.com (esa4.hc1455-7.c3s2.iphmx.com [68.232.139.117])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8F61329CA;
	Thu, 27 Jun 2024 06:15:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=68.232.139.117
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1719468937; cv=none; b=u1qqMych1hpwVUm8axbmC8TxlQ0dEknqND23bchREhTnCXjIeEbaMy+wvAi/NCOUvqwTQyKmb8PNNwN0eWOk0U89vLcOGIrGBd9/+bXNEpL8izYQn6gr63mhg0eRRd0vOce5zd/i7+Njj7j/D+0Z2MDCC5QnSPxDCWjDFnZe66s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1719468937; c=relaxed/simple;
	bh=GkpVVTFN0KHvpOhjp/AH8rx6djov7MXE27F7vwQ/2T0=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=f4bItM9hdXDRz7eYswAMibyfEW0HbkK5+RwB7hbGlcVWbhlJVoa6OshB8yck8ofwkyGX2TGye+c9L0x/R1Pw++IHSS7WIAtXnX4YEvCtvAzLjWpL13+J/aVhNjFRSGyAMmSI+XPU6xxNrbmYvYgdmNbIoTKDzfN6/pt1TIMFO8M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=fujitsu.com; spf=pass smtp.mailfrom=fujitsu.com; dkim=pass (2048-bit key) header.d=fujitsu.com header.i=@fujitsu.com header.b=PFw8359B; arc=none smtp.client-ip=68.232.139.117
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=fujitsu.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=fujitsu.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=fujitsu.com header.i=@fujitsu.com header.b="PFw8359B"
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=fujitsu.com; i=@fujitsu.com; q=dns/txt; s=fj2;
  t=1719468935; x=1751004935;
  h=from:to:cc:subject:date:message-id:mime-version:
   content-transfer-encoding;
  bh=GkpVVTFN0KHvpOhjp/AH8rx6djov7MXE27F7vwQ/2T0=;
  b=PFw8359BjFVQva9MxDFMJZP3c6gUG7BUoia0GT2J0skuz6tUwzEjMLrt
   rk3Gr02d/DdJWkFYiUmOelDIX4auilFXQX3LlmyBOSNnf0Mv4cTPslpdM
   pig96wdtJNrGLbQY58b2IgXLLwQtVW7Wlvc5d4cS2PEu+QQXHr5WptVfz
   a+d3760H4BaXNChbCZR1ol040HcuMRZf61UjPr5jp0z8CFN+cKGoLKN+4
   aPDNOoZ+/OKUK+2rTMDDiBrS5aILvc2Ji0FPcVWBqkJlaVdbA86TCmOgP
   K+RScqLEnbLveJDlfVxJYYkPEKfknNcGY3+IFqFqf9TFxufWnED+W3HH3
   w==;
X-IronPort-AV: E=McAfee;i="6700,10204,11115"; a="165205014"
X-IronPort-AV: E=Sophos;i="6.08,269,1712588400"; 
   d="scan'208";a="165205014"
Received: from unknown (HELO yto-r4.gw.nic.fujitsu.com) ([218.44.52.220])
  by esa4.hc1455-7.c3s2.iphmx.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 27 Jun 2024 15:15:30 +0900
Received: from yto-m2.gw.nic.fujitsu.com (yto-nat-yto-m2.gw.nic.fujitsu.com [192.168.83.65])
	by yto-r4.gw.nic.fujitsu.com (Postfix) with ESMTP id E510FC9442;
	Thu, 27 Jun 2024 15:15:28 +0900 (JST)
Received: from kws-ab3.gw.nic.fujitsu.com (kws-ab3.gw.nic.fujitsu.com [192.51.206.21])
	by yto-m2.gw.nic.fujitsu.com (Postfix) with ESMTP id 2FC3AD5602;
	Thu, 27 Jun 2024 15:15:28 +0900 (JST)
Received: from edo.cn.fujitsu.com (edo.cn.fujitsu.com [10.167.33.5])
	by kws-ab3.gw.nic.fujitsu.com (Postfix) with ESMTP id A8C802007FAEC;
	Thu, 27 Jun 2024 15:15:27 +0900 (JST)
Received: from G08FNSTD200033.g08.fujitsu.local (unknown [10.167.225.189])
	by edo.cn.fujitsu.com (Postfix) with ESMTP id 5D87E1A0002;
	Thu, 27 Jun 2024 14:15:26 +0800 (CST)
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
Subject: [PATCH net-next v2] ipvs: properly dereference pe in ip_vs_add_service
Date: Thu, 27 Jun 2024 14:15:15 +0800
Message-Id: <20240627061515.1477-1-chenhx.fnst@fujitsu.com>
X-Mailer: git-send-email 2.37.1.windows.1
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
X-TM-AS-Product-Ver: IMSS-9.1.0.1417-9.0.0.1002-28484.005
X-TM-AS-User-Approved-Sender: Yes
X-TMASE-Version: IMSS-9.1.0.1417-9.0.1002-28484.005
X-TMASE-Result: 10--0.208100-10.000000
X-TMASE-MatchedRID: 54gb2yeIOXRix5b+joOApO9kW9mxCQvtZUc2QJCkRg1YbPLopoBzQiqY
	vVxU5zXACQeZdSWc34x8b0Yg8mgYgS/7QU2czuUNA9lly13c/gEXivwflisSrJB7/R12+PP70sE
	wJ3QPiJrwiXCg8dzXRhU6KGPlAba7Ed0YyW6tLbmeAiCmPx4NwGmRqNBHmBveVDC1CbuJXmMqtq
	5d3cxkNbh1ZUfF/lyHzTPTbrtCERSk2bGxMZx6asIEUg4xsgYsE5rIyKA4HUyM6tWPrlagCTIsc
	l+iYsQoEbYpM9V5jAJwPsjIBEGzo/8jyjqYHnMRFcUQf3Yp/ridO0/GUi4gFb0fOPzpgdcEKeJ/
	HkAZ8Is=
X-TMASE-SNAP-Result: 1.821001.0001-0-1-22:0,33:0,34:0-0

Use pe directly to resolve sparse warning:

  net/netfilter/ipvs/ip_vs_ctl.c:1471:27: warning: dereference of noderef expression

Fixes: 39b972231536 ("ipvs: handle connections started by real-servers")
Signed-off-by: Chen Hanxiao <chenhx.fnst@fujitsu.com>
---
v2:
	use pe directly.

 net/netfilter/ipvs/ip_vs_ctl.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index b6d0dcf3a5c3..f4384e147ee1 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1459,18 +1459,18 @@ ip_vs_add_service(struct netns_ipvs *ipvs, struct ip_vs_service_user_kern *u,
 	if (ret < 0)
 		goto out_err;
 
-	/* Bind the ct retriever */
-	RCU_INIT_POINTER(svc->pe, pe);
-	pe = NULL;
-
 	/* Update the virtual service counters */
 	if (svc->port == FTPPORT)
 		atomic_inc(&ipvs->ftpsvc_counter);
 	else if (svc->port == 0)
 		atomic_inc(&ipvs->nullsvc_counter);
-	if (svc->pe && svc->pe->conn_out)
+	if (pe && pe->conn_out)
 		atomic_inc(&ipvs->conn_out_counter);
 
+	/* Bind the ct retriever */
+	RCU_INIT_POINTER(svc->pe, pe);
+	pe = NULL;
+
 	/* Count only IPv4 services for old get/setsockopt interface */
 	if (svc->af == AF_INET)
 		ipvs->num_services++;
-- 
2.39.1

