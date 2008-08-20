From: Simon Horman <horms@verge.net.au>
Subject: [patch] ipvsadm: use strtoul to convert ip addresses from hex
Date: Wed, 20 Aug 2008 15:44:16 +1000
Message-ID: <20080820054415.GA31393@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vince Busam <vbusam@google.com>
Cc: Julius Volz <juliusv@google.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

The ip addresses that come out of /proc/net/ip_vs_conn as integers
are in hex not decimal.

Without this change most IP addresses reported as integers end up being
0.0.0.0.

This change is against the development code ipvsadm-1.25-nl-4 from
http://sixpak.org/vince/google/ipvsadm/ . It is not relevant to
ipvsadm-1.24, the current released version.

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: ipvsadm-1.25-nl-4/ipvsadm.c
===================================================================
--- ipvsadm-1.25-nl-4.orig/ipvsadm.c	2008-08-20 15:16:18.000000000 +1000
+++ ipvsadm-1.25-nl-4/ipvsadm.c	2008-08-20 15:16:39.000000000 +1000
@@ -1212,9 +1212,9 @@ static void print_conn(char *buf, unsign
 		inet_pton(AF_INET, temp2, &vaddr.ip);
 		inet_pton(AF_INET, temp3, &daddr.ip);
 	} else {
-		caddr.ip = (__u32) htonl(atoi(temp1));
-		vaddr.ip = (__u32) htonl(atoi(temp2));
-		daddr.ip = (__u32) htonl(atoi(temp3));
+		caddr.ip = (__u32) htonl(strtoul(temp1, NULL, 16));
+		vaddr.ip = (__u32) htonl(strtoul(temp2, NULL, 16));
+		daddr.ip = (__u32) htonl(strtoul(temp3, NULL, 16));
 	}
 
 	if (!(cname = addrport_to_anyname(af, &caddr, cport, proto, format)))
