From: Marco Angaroni <marcoangaroni@gmail.com>
Subject: [PATCH] ipvs: don't alter conntrack in OPS mode
Date: Sat, 09 Apr 2016 12:29:37 +0200
Message-ID: <5708d991.r1jCsWGFPjkzsrJu%marcoangaroni@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=date:from:to:subject:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=U7Io5wrFGi/PWfM6/UiFKEyYSifZFFwbYVqWyx5uYvk=;
        b=Gxpi/6UITNIMrTm+qhboW8Dzgw3L8qAfYWJywLDVf9YrrM1Zb+Db2vloFXUDbVpyLu
         sc/KfNJ6qTb1/2qhIK4bynnfAPP2BJFQgj1BKbVBhTrGKQpXKPPHjCcUNxCrFnvgYtMj
         fmcgPpE4G5d6/M4YSQZwd1OKs4GX9wTJyr6x1OUtXfMXIowjGhnK3vV+BxwcZZcVU9NL
         Bjha9+knL3GArQeFN+iObEdcuwttElLp+VdDJPiGG+cIOU/lioACOwVRA1jN/K+cyTEt
         m71OsAxB8ygLmPflNRGZiLFPJsjlS7XkwivXAYmtCZrYWQ4cWS8y56uJTAm64cus9sMx
         OwYg==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org

Subject: [PATCH] ipvs: don't alter conntrack in OPS mode

When using OPS mode in conjunction with SIP persistent-engine, packets
originating from the same ip-address/port could be balanced to different
real servers, and (to properly handle SIP responses) OPS connections 
are created in the in-out direction too, where ip_vs_update_conntrack()
is called to modify the reply tuple.

As a result, there can be collision of conntrack tuples, causing random
packet drops, as explained below:

conntrack1: orig=CIP->VIP  , reply=RIP1->CIP
conntrack2: orig=RIP2->CIP , reply=CIP->VIP

Tuple CIP->VIP is both in orig of conntrack1 and reply of conntrack2.
The collision triggers packet drop inside nf_conntrack processing.

In addition, the current implementation deletes the conntrack object at
every expire of an OPS connection (once every forwarded packet), to have
it recreated from scratch at next packet traversing IPVS.

Since in OPS mode, by definition, we don't expect any associated 
response, the choices implemented in this patch are:
a) don't call nf_conntrack_alter_reply() for OPS connections inside
   ip_vs_update_conntrack().
b) don't delete the conntrack object at OPS connection expire.

The result is that created conntrack objects for each tuple CIP->VIP,
RIP-N->CIP, etc. are left in UNREPLIED state and not modified by IPVS
OPS connection management. This eliminates packet drops and leaves
a single conntrack object for each tuple packets are sent from.

Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>
---
 net/netfilter/ipvs/ip_vs_conn.c | 3 ++-
 net/netfilter/ipvs/ip_vs_nfct.c | 4 ++++
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index dd75d41..292365f 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -836,7 +836,8 @@ static void ip_vs_conn_expire(unsigned long data)
 		if (cp->control)
 			ip_vs_control_del(cp);
 
-		if (cp->flags & IP_VS_CONN_F_NFCT) {
+		if ((cp->flags & IP_VS_CONN_F_NFCT) &&
+		    !(cp->flags & IP_VS_CONN_F_ONE_PACKET)) {
 			/* Do not access conntracks during subsys cleanup
 			 * because nf_conntrack_find_get can not be used after
 			 * conntrack cleanup for the net.
diff --git a/net/netfilter/ipvs/ip_vs_nfct.c b/net/netfilter/ipvs/ip_vs_nfct.c
index 30434fb..f04fd8d 100644
--- a/net/netfilter/ipvs/ip_vs_nfct.c
+++ b/net/netfilter/ipvs/ip_vs_nfct.c
@@ -93,6 +93,10 @@ ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp, int outin)
 	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
 		return;
 
+	/* Never alter conntrack for OPS conns (no reply is expected) */
+	if (cp->flags & IP_VS_CONN_F_ONE_PACKET)
+		return;
+
 	/* Alter reply only in original direction */
 	if (CTINFO2DIR(ctinfo) != IP_CT_DIR_ORIGINAL)
 		return;
-- 
1.8.3.1

