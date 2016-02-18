From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 1/2] netfilter: ipvs: Remove noisy debug print from ip_vs_del_service
Date: Thu, 18 Feb 2016 09:28:41 +0900
Message-ID: <1455755322-19972-2-git-send-email-horms@verge.net.au>
References: <1455755322-19972-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1455755340; bh=oNF5RVh9vO0wof7izK3aLyexJNGBdfL79q30N6qAy5o=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=XSFsQpu3VgZF15p1VOicidtB+Wed+D3Kot+5RFcO7XwNlse0gKpL+0s9bomXt1gwk
	 eZCAtDKthGk2OS/Oupxg/15hKIs0IkvOreS7Xm7V/GQjPhtIHmL5ZDdnsEF0X01XGL
	 oDYKqbUlHhVLu5xMls8w/eEuQrbi6/cecUWzmbuo=
In-Reply-To: <1455755322-19972-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Yannick Brosseau <scientist@fb.com>, Simon Horman <horms@verge.net.au>

From: Yannick Brosseau <scientist@fb.com>

This have been there for a long time, but does not seem to add value

Signed-off-by: Yannick Brosseau <scientist@fb.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index e7c1b052c2a3..daf4cb746974 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1376,8 +1376,6 @@ static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup)
 	struct ip_vs_pe *old_pe;
 	struct netns_ipvs *ipvs = svc->ipvs;
 
-	pr_info("%s: enter\n", __func__);
-
 	/* Count only IPv4 services for old get/setsockopt interface */
 	if (svc->af == AF_INET)
 		ipvs->num_services--;
-- 
2.1.4

