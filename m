From: Dragos Foianu <dragos.foianu@gmail.com>
Subject: [PATCH] ipvs: fixed style errors in ip_vs_dh
Date: Thu, 11 Jul 2013 22:15:44 +0300
Message-ID: <1373570144-4785-1-git-send-email-dragos.foianu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=from:to:cc:subject:date:message-id:x-mailer;
        bh=Q0Sa1nQaX2qgw5lnlwpFhEKVR5MIyUEFmW4+9CQr/zM=;
        b=SUpG59jgZEfuy44Q15vYqieXtKLkHrGvvPc24t82DtsUm2Jx+7G1r/M02uMba3mblr
         PFYxSYhVJrdNGvtEMWDXF08/4gd/bH21Q+bJHiJamoZc6jUAhgYzWKyygfPc3IhV4nLx
         Oh26EMef0PS4zsF0OsRdm11GhJQxWGubyMew26S0pCyo21j8mQgesD1UyyQBAwUeFwvn
         Ftf7NcfyNdFJ7DIcDeRuWSZ7EwpFSmVdMpcPOhOmHtq+5fGpBIq9UQ/01kNzepZBZmD/
         y1pprWhoohRbOCdJxIehxuwdi9zKTRITSKjNDGY0O4z0w8C4lLJKejpNkpwvw+UJ/gZr
         rb6A==
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: wensong@linux-vs.org
Cc: horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, Dragos Foianu <dragos.foianu@gmail.com>

found with the help of checkpatch.pl

Signed-off-by: Dragos Foianu <dragos.foianu@gmail.com>
---
 net/netfilter/ipvs/ip_vs_dh.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_dh.c b/net/netfilter/ipvs/ip_vs_dh.c
index c3b8454..8ab2fc8 100644
--- a/net/netfilter/ipvs/ip_vs_dh.c
+++ b/net/netfilter/ipvs/ip_vs_dh.c
@@ -110,7 +110,7 @@ ip_vs_dh_reassign(struct ip_vs_dh_state *s, struct ip_vs_service *svc)
 	b = &s->buckets[0];
 	p = &svc->destinations;
 	empty = list_empty(p);
-	for (i=0; i<IP_VS_DH_TAB_SIZE; i++) {
+	for (i = 0; i < IP_VS_DH_TAB_SIZE; i++) {
 		dest = rcu_dereference_protected(b->dest, 1);
 		if (dest)
 			ip_vs_dest_put(dest);
@@ -142,7 +142,7 @@ static void ip_vs_dh_flush(struct ip_vs_dh_state *s)
 	struct ip_vs_dest *dest;
 
 	b = &s->buckets[0];
-	for (i=0; i<IP_VS_DH_TAB_SIZE; i++) {
+	for (i = 0; i < IP_VS_DH_TAB_SIZE; i++) {
 		dest = rcu_dereference_protected(b->dest, 1);
 		if (dest) {
 			ip_vs_dest_put(dest);
@@ -244,8 +244,7 @@ ip_vs_dh_schedule(struct ip_vs_service *svc, const struct sk_buff *skb,
 /*
  *      IPVS DH Scheduler structure
  */
-static struct ip_vs_scheduler ip_vs_dh_scheduler =
-{
+static struct ip_vs_scheduler ip_vs_dh_scheduler = {
 	.name =			"dh",
 	.refcnt =		ATOMIC_INIT(0),
 	.module =		THIS_MODULE,
-- 
1.7.10.4
