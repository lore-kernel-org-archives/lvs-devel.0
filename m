From: Simon Horman <horms@verge.net.au>
Subject: [patch 2/9] IPVS: Remove useless { } block from ip_vs_process_message()
Date: Sun, 24 Oct 2010 00:26:28 +0900
Message-ID: <20101023153019.373931026@joe.akashicho.tokyo.vergenet.net>
References: <20101023152626.811097720@joe.akashicho.tokyo.vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=ip_vs_process_message-indentation.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: lvs-test-2.6/net/netfilter/ipvs/ip_vs_sync.c
===================================================================
--- lvs-test-2.6.orig/net/netfilter/ipvs/ip_vs_sync.c	2010-10-10 11:14:04.000000000 +0900
+++ lvs-test-2.6/net/netfilter/ipvs/ip_vs_sync.c	2010-10-10 11:14:11.000000000 +0900
@@ -381,20 +381,18 @@ static void ip_vs_process_message(const
 			}
 		}
 
-		{
-			if (ip_vs_conn_fill_param_sync(AF_INET, s->protocol,
-					      (union nf_inet_addr *)&s->caddr,
-					      s->cport,
-					      (union nf_inet_addr *)&s->vaddr,
-					      s->vport, &param)) {
-				pr_err("ip_vs_conn_fill_param_sync failed");
-				return;
-			}
-			if (!(flags & IP_VS_CONN_F_TEMPLATE))
-				cp = ip_vs_conn_in_get(&param);
-			else
-				cp = ip_vs_ct_in_get(&param);
+		if (ip_vs_conn_fill_param_sync(AF_INET, s->protocol,
+					       (union nf_inet_addr *)&s->caddr,
+					       s->cport,
+					       (union nf_inet_addr *)&s->vaddr,
+					       s->vport, &param)) {
+			pr_err("ip_vs_conn_fill_param_sync failed");
+			return;
 		}
+		if (!(flags & IP_VS_CONN_F_TEMPLATE))
+			cp = ip_vs_conn_in_get(&param);
+		else
+			cp = ip_vs_ct_in_get(&param);
 		if (!cp) {
 			/*
 			 * Find the appropriate destination for the connection.

