From: zhang kai <zhangkaiheb@126.com>
Subject: [PATCH] ipvs: change type of delta and previous_delta in ip_vs_seq.
Date: Tue, 20 Aug 2019 08:37:18 +0800
Message-ID: <20190820003718.GA16620@toolchain>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=126.com;
        s=s110527; h=Date:From:Subject:Message-ID:MIME-Version; bh=HVPsX
        U1SfpWPxXQpzpYv1zzZg0TkfnffyRW+Lv2MLXs=; b=EJO56Y93Nv03SK6KKqTpl
        KMS6Mwz77ay/U2AzlpM95yf5EaBitRIpXOh2e/1Or6+y24sm/56iEIRjkSTz2o+j
        n7tYx0cwds8Yw+ZeG6bm3T39LhvAKuiaENVT1CxcAjlU2mv/Y9PBYR3BRvyeDT2k
        Oyn9v+0HIb9Z5C29DZc2sk=
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, davem@davemloft.net, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

In NAT forwarding mode, Applications may decrease the size of packets,
and TCP sequences will get smaller, so both of variables will be negetive
values in this case.

Signed-off-by: zhang kai <zhangkaiheb@126.com>
---
 include/net/ip_vs.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 3759167f91f5..de7e75063c7c 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -346,8 +346,8 @@ enum ip_vs_sctp_states {
  */
 struct ip_vs_seq {
 	__u32			init_seq;	/* Add delta from this seq */
-	__u32			delta;		/* Delta in sequence numbers */
-	__u32			previous_delta;	/* Delta in sequence numbers
+	__s32			delta;		/* Delta in sequence numbers */
+	__s32			previous_delta;	/* Delta in sequence numbers
 						 * before last resized pkt */
 };
 
-- 
2.17.1

