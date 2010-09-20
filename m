From: Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
Subject: [patch] ldirectord.cf: added an example config of IPv6
Date: Mon, 20 Sep 2010 15:48:10 +0900 (JST)
Message-ID: <20100920.154810.193691969.sohgo@sohgo.dyndns.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
 boundary="--Next_Part(Mon_Sep_20_15_48_10_2010_631)--"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org
Cc: horms@verge.net.au

----Next_Part(Mon_Sep_20_15_48_10_2010_631)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


Hi,

I attach a patch which adds an IPv6 example to ldirectord.cf

regards,

--
Sohgo Takeuchi

----Next_Part(Mon_Sep_20_15_48_10_2010_631)--
Content-Type: Text/X-Patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="ldirectord.cf.patch"

diff -r 3e8454c17ed3 ldirectord/ldirectord.cf
--- a/ldirectord/ldirectord.cf	Tue Aug 10 12:30:21 2010 +0900
+++ b/ldirectord/ldirectord.cf	Mon Sep 20 15:35:50 2010 +0900
@@ -12,6 +12,7 @@
 checktimeout=3
 checkinterval=1
 #fallback=127.0.0.1:80
+#fallback6=[::1]:80
 autoreload=yes
 #logfile="/var/log/ldirectord.log"
 #logfile="local0"
@@ -311,3 +312,16 @@
 #	service=sip
 #	checktimeout=1
 
+#Sample configuration for an nntp virtual service with IPv6.
+#Fallback setting overides global
+#virtual6=[2001:db8::5]:119
+#	real6=[2001:db8:0:1::4]:119 masq
+#	real6=[2001:db8:0:1::6]:119 masq
+#	fallback6=[::1]:119
+#	service=nntp
+#	scheduler=wlc
+#	#persistent=600
+#	#netmask=255.255.255.255
+#	protocol=tcp
+#	checktype=negotiate
+#	checkport=119

----Next_Part(Mon_Sep_20_15_48_10_2010_631)----
