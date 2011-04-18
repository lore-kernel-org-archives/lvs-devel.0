From: Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
Subject: [PATCH][ldirectord] fix a bug that IPv6 does not work fine.
Date: Mon, 18 Apr 2011 19:30:14 +0900 (JST)
Message-ID: <20110418.193014.310077122.sohgo@sohgo.dyndns.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org



Hi,

I found that the latest ldirectord did not work fine when using IPv6.
This issue was enbuged in following commits,
	commit f9c76a0f1d6e7c86ac741ed534c6661e22556fc2
	commit f85bdc302541aab3e32994b0d672e60a338a17c8
i.e. when added fixes to allow IPv4 and IPv6 services with same fwmark.
The fixes made same fwmark work good, but broke a behavior of IPv6
services. When I made the fix, my testing was not enough.

Attached patch fixes this problem.
This patch can also be found at https://github.com/sohgo/resource-agents/tree/bugfix-fwmk1

Thank you.

-- sohgo

---
 ldirectord/ldirectord.in |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/ldirectord/ldirectord.in b/ldirectord/ldirectord.in
index af55fda..646d687 100644
--- a/ldirectord/ldirectord.in
+++ b/ldirectord/ldirectord.in
@@ -2457,7 +2457,12 @@ sub get_real_service_str
 {
 	my ($v) = (@_);
 
-	return &get_virtual($v) . " "  . $v->{protocol} . ($v->{addressfamily} == AF_INET6 ? "6" : "");
+	if ($v->{"protocol"} eq "fwm") {
+		return &get_virtual($v) . " "  . $v->{protocol} . ($v->{addressfamily} == AF_INET6 ? "6" : "");
+	}
+	else {
+		return &get_virtual($v) . " "  . $v->{protocol};
+	}
 }
 
 sub ld_start
@@ -4119,7 +4124,7 @@ sub fallback_find
 	my ($virtual) = (@_);
 
 	my($global_fallback_ptr);	# fallback pointer
-	my $ipv6p = $virtual->{server} =~ /[\[\]]/ ? 1 : 0;
+	my $ipv6p = ($virtual->{addressfamily} == AF_INET6) ? 1 : 0;
 
 	if( defined $virtual->{"fallback"} ) {
 		return($virtual->{"fallback"});
@@ -4819,7 +4824,12 @@ sub get_virtual_id_str {
 	my ($v) = (@_);
 
-	return $v->{"protocol"} . ($v->{addressfamily} == AF_INET6?"6":"") . ":" .  &get_virtual($v);
+	if ($v->{"protocol"} eq "fwm") {
+		return $v->{"protocol"} . ($v->{addressfamily} == AF_INET6?"6":"") . ":" .  &get_virtual($v);
+	}
+	else {
+		return $v->{"protocol"} . ":" .  &get_virtual($v);
+	}
 }
 
 # get_forward_flag

