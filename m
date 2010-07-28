From: Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
Subject: [patch][bug][ldirectord] underscore in a servicename
Date: Wed, 28 Jul 2010 22:30:52 +0900 (JST)
Message-ID: <20100728.223052.102572767.sohgo@sohgo.dyndns.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
 boundary="--Next_Part(Wed_Jul_28_22_30_52_2010_482)--"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org
Cc: horms@verge.net.au

----Next_Part(Wed_Jul_28_22_30_52_2010_482)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


Hi,

I found a bug in ldirectord and attach a patch to fix this
problem to this E-mail.

If a underscore is contained in a service-name of
hostname:servicename
(ex. real=realserver.example.com:pipe_server), it leads to a
configuration error.

with best regards,

--
Sohgo Takeuchi

----Next_Part(Wed_Jul_28_22_30_52_2010_482)--
Content-Type: Text/X-Patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="ldirectord.port.patch"

diff -r 6196ecad12c8 ldirectord/ldirectord.in
--- a/ldirectord/ldirectord.in	Wed Jul 28 19:22:48 2010 +0900
+++ b/ldirectord/ldirectord.in	Wed Jul 28 22:20:20 2010 +0900
@@ -1283,9 +1283,9 @@
 			my $virtual_line = $line;
 			my $fallback_line;
 			my @rsrv_todo;
-			if ($vattr =~ /^(\d+\.\d+\.\d+\.\d+):([0-9A-Za-z]+)/) {
+			if ($vattr =~ /^(\d+\.\d+\.\d+\.\d+):([0-9A-Za-z-_]+)/) {
 				$virtual_id = $ip_port = "$1:$2";
-			} elsif ($vattr =~ /^([0-9A-Za-z._+-]+):([0-9A-Za-z]+)/) {
+			} elsif ($vattr =~ /^([0-9A-Za-z._+-]+):([0-9A-Za-z-_]+)/) {
 				$virtual_id = $ip_port = "$1:$2";
 			} elsif ($vattr =~ /^(\d+)/){
 				$virtual_id = $fwm = $1;
@@ -1887,7 +1887,7 @@
 
 	for $i (@$rsrv_todo) {
 		($str, $line)=@$i;
-		$str =~	 /(\d+\.\d+\.\d+\.\d+|[A-Za-z0-9.-]+|\[[0-9A-fa-f:]+\])(->(\d+\.\d+\.\d+\.\d+|[A-Za-z0-9.-]+|\[[0-9A-fa-f:]+\]))?(:(\d+|[A-Za-z0-9-]+))?\s+(.*)/
+		$str =~	 /(\d+\.\d+\.\d+\.\d+|[A-Za-z0-9.-]+|\[[0-9A-fa-f:]+\])(->(\d+\.\d+\.\d+\.\d+|[A-Za-z0-9.-]+|\[[0-9A-fa-f:]+\]))?(:(\d+|[A-Za-z0-9-_]+))?\s+(.*)/
 			or &config_error($line,
 				"invalid address for real server" .
 				" (wrong format)");
@@ -4957,12 +4957,12 @@
 	my $ip;
 	my $port;
 
-	if ($hostserv =~ /(\[[0-9A-Fa-f:]+\])(:(\d+|[A-Za-z0-9-]+))?/) {
+	if ($hostserv =~ /(\[[0-9A-Fa-f:]+\])(:(\d+|[A-Za-z0-9-_]+))?/) {
 		$ip=$1;
 		$port=$3;
 	} else {
 		$hostserv =~
-		/(\d+\.\d+\.\d+\.\d+|[A-Za-z0-9.-]+)(:(\d+|[A-Za-z0-9-]+))?/
+		/(\d+\.\d+\.\d+\.\d+|[A-Za-z0-9.-]+)(:(\d+|[A-Za-z0-9-_]+))?/
 		or return(undef);
 		$ip=$1;
 		$port=$3;

----Next_Part(Wed_Jul_28_22_30_52_2010_482)----
