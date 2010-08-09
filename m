From: Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
Subject: [patch][bug] ldirectord: a port number mismatch of imaps and pops
Date: Mon, 09 Aug 2010 16:31:44 +0900 (JST)
Message-ID: <20100809.163144.112602013.sohgo@sohgo.dyndns.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org
Cc: horms@verge.net.au


diff -r 0d8eac1c6061 ldirectord/ldirectord.in
--- a/ldirectord/ldirectord.in	Fri Aug 06 13:24:32 2010 +0200
+++ b/ldirectord/ldirectord.in	Mon Aug 09 16:20:32 2010 +0900
@@ -1764,8 +1764,8 @@
 	if ($port eq 143)	{ return "imap"; }
 	if ($port eq 389)	{ return "ldap"; }
 	if ($port eq 443)	{ return "https"; }
-	if ($port eq 993)	{ return "pops"; }
-	if ($port eq 995)	{ return "imaps"; }
+	if ($port eq 993)	{ return "imaps"; }
+	if ($port eq 995)	{ return "pops"; }
 	if ($port eq 1521)	{ return "oracle"; }
 	if ($port eq 1812)	{ return "radius"; }
 	if ($port eq 3128)	{ return "http_proxy"; }

