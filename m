From: Julius Volz <juliusv@google.com>
Subject: [PATCHv3 00/24] Add first IPv6 support to IPVS
Date: Tue,  2 Sep 2008 15:50:23 +0200
Message-ID: <1220363423-8618-4-git-send-email-juliusv@google.com>
References: <1220363423-8618-1-git-send-email-juliusv@google.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220363434; bh=/7bBefkHErhxAhT2KX6yggqYhPQ=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References; b=LW5Oo3WK1sk8+jIDzfcCB4iCVZ4diDXM7dmKy7vz
	HXLVQ2P93Erbo5KUh1kIH9I5Dba6ReQjqmlWSyBpy3pY1A==
In-Reply-To: <1220363423-8618-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com

 static struct ip_vs_conn *
 ah_esp_conn_in_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
-	           const struct ip_vs_iphdr *iph, unsigned int proto_off,
-	           int inverse)
+		   const struct ip_vs_iphdr *iph, unsigned int proto_off,
+		   int inverse)
 {
 	struct ip_vs_conn *cp;
 
@@ -79,9 +79,9 @@ ah_esp_conn_in_get(int af, const struct sk_buff *skb, struct ip_vs_protocol *pp,
 static struct ip_vs_conn *
 ah_esp_conn_out_get(int af, const struct sk_buff *skb,
 		    struct ip_vs_protocol *pp,
-	            const struct ip_vs_iphdr *iph,
+		    const struct ip_vs_iphdr *iph,
 		    unsigned int proto_off,
-	            int inverse)
+		    int inverse)
 {
 	struct ip_vs_conn *cp;
 
diff --git a/net/ipv4/ipvs/ip_vs_proto_udp.c b/net/ipv4/ipvs/ip_vs_proto_udp.c
index 9278c0d..16b20c8 100644
--- a/net/ipv4/ipvs/ip_vs_proto_udp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_udp.c
@@ -92,8 +92,9 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		return 0;
 	}
 
-	if ((svc = ip_vs_service_get(af, skb->mark, iph.protocol, &iph.daddr,
-				     uh->dest))) {
+	svc = ip_vs_service_get(af, skb->mark, iph.protocol,
+				&iph.daddr, uh->dest);
+	if (svc) {
 		if (ip_vs_todrop()) {
 			/*
 			 * It seems that we are very loaded.
