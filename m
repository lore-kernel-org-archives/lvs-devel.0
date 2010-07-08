From: xiaoyu Du <tingsrain@gmail.com>
Subject: [PATCH] lvs sctp protocol handler is incorrectly invoked 
	ip_vs_app_pkt_out
Date: Thu, 8 Jul 2010 09:55:04 +0800
Message-ID: <AANLkTikS9SSVT5soWZYmzxeJkR5vO__cuedk7ZgmTx5y@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:received:date:message-id
         :subject:from:to:cc:content-type;
        bh=f3UAbHMquN1D0gXXG1yjBIgWbAQ0ec5qp0n7aI2L7/c=;
        b=KOv/RdOt48ptaZhtaCbXA0lr/FYMIayVgeFcpuhiL0Rw6RieokibdNPlpAqKdsR6+3
         bgZ7TyKAkLfn/6hHDjb0fhR6irCVBwdrnaxqnemQfZmcUESmde591emRgCa49jsJf+Cm
         nV3EWai2a16YlQA4+L3RRonNGF6wXsG1Ph5RI=
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: wensong@linux-vs.org, horms@verge.net.au

lvs sctp protocol handler is incorrectly invoked ip_vs_app_pkt_out
Since there's no sctp helpers at present, it does the same thing as
ip_vs_app_pkt_in.

Signed-off-by: Xiaoyu Du <tingsrain@gmail.com>

---
 net/netfilter/ipvs/ip_vs_proto_sctp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c
b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index c9a3f7a..db55759 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -173,7 +173,7 @@ sctp_dnat_handler(struct sk_buff *skb,
 			return 0;

 		/* Call application helper if needed */
-		if (!ip_vs_app_pkt_out(cp, skb))
+		if (!ip_vs_app_pkt_in(cp, skb))
 			return 0;
 	}

--
