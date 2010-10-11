From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] nf_nat: restrict ICMP translation for embedded header
Date: Mon, 11 Oct 2010 11:23:07 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010111103470.3743@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org


 	Skip ICMP translation of embedded protocol header
if NAT bits are not set. Needed for IPVS to see the original
embedded addresses because for IPVS traffic the IPS_SRC_NAT_BIT
and IPS_DST_NAT_BIT bits are not set. It happens when IPVS performs
DNAT for client packets after using nf_conntrack_alter_reply
to expect replies from real server.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

 	I'm not very familiar with this code, so this change
must not be considered as trivial. May be there was a
reason the embedded header to be translated before the NAT
bits are set?

diff -urp net-next-2.6-e548833/linux/net/ipv4/netfilter/nf_nat_core.c linux/net/ipv4/netfilter/nf_nat_core.c
--- net-next-2.6-e548833/linux/net/ipv4/netfilter/nf_nat_core.c	2010-09-10 08:27:33.000000000 +0300
+++ linux/net/ipv4/netfilter/nf_nat_core.c	2010-10-11 10:13:17.945355032 +0300
@@ -458,6 +458,18 @@ int nf_nat_icmp_reply_translation(struct
  			return 0;
  	}

+	if (manip == IP_NAT_MANIP_SRC)
+		statusbit = IPS_SRC_NAT;
+	else
+		statusbit = IPS_DST_NAT;
+
+	/* Invert if this is reply dir. */
+	if (dir == IP_CT_DIR_REPLY)
+		statusbit ^= IPS_NAT_MASK;
+
+	if (!(ct->status & statusbit))
+		return 1;
+
  	pr_debug("icmp_reply_translation: translating error %p manip %u "
  		 "dir %s\n", skb, manip,
  		 dir == IP_CT_DIR_ORIGINAL ? "ORIG" : "REPLY");
@@ -492,20 +504,9 @@ int nf_nat_icmp_reply_translation(struct

  	/* Change outer to look the reply to an incoming packet
  	 * (proto 0 means don't invert per-proto part). */
-	if (manip == IP_NAT_MANIP_SRC)
-		statusbit = IPS_SRC_NAT;
-	else
-		statusbit = IPS_DST_NAT;
-
-	/* Invert if this is reply dir. */
-	if (dir == IP_CT_DIR_REPLY)
-		statusbit ^= IPS_NAT_MASK;
-
-	if (ct->status & statusbit) {
-		nf_ct_invert_tuplepr(&target, &ct->tuplehash[!dir].tuple);
-		if (!manip_pkt(0, skb, 0, &target, manip))
-			return 0;
-	}
+	nf_ct_invert_tuplepr(&target, &ct->tuplehash[!dir].tuple);
+	if (!manip_pkt(0, skb, 0, &target, manip))
+		return 0;

  	return 1;
  }
