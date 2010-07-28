From: Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
Subject: [patch][bug][ldirectord] a fallback server
	specified in a virtual server section without a port
Date: Wed, 28 Jul 2010 19:51:27 +0900 (JST)
Message-ID: <20100728.195127.48524095.sohgo@sohgo.dyndns.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
 boundary="--Next_Part(Wed_Jul_28_19_51_27_2010_252)--"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org
Cc: horms@verge.net.au

----Next_Part(Wed_Jul_28_19_51_27_2010_252)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


Hi,

This is a first time to post to this ML.

I found a bug in ldirectord and attach a patch to fix this
problem to this E-mail.

The bug is that if a port is omitted in a "fallback" in a
virtual section, the entry is never seen in the virtual server
table even if all real servers are down.

    virtual=10.10.100.1:daytime
	real=10.10.100.2:daytime gate
	fallback=127.0.0.1

A debug message says like this.

    DEBUG2: Running system(/sbin/ipvsadm -a -t 10.10.100.1:13 -r 127.0.0.1: -g -w 1)
    Running system(/sbin/ipvsadm -a -t 10.10.100.1:13 -r 127.0.0.1: -g -w 1)
    illegal real server address[:port] specified
    DEBUG2: system(/sbin/ipvsadm -a -t 10.10.100.1:13 -r 127.0.0.1: -g -w 1) failed:
    system(/sbin/ipvsadm -a -t 10.10.100.1:13 -r 127.0.0.1: -g -w 1) failed:


The problem in the source code is that when a port of "fallback"
is omitted, the port is derived from a port specified in a
"virtual" service (from a behavior of the parse_fallback
function), but the port is used before it is defined.

I tested ldirectord on Ubuntu 10.04 with perl 5.10.1.

with best regards,

--
Sohgo Takeuchi

----Next_Part(Wed_Jul_28_19_51_27_2010_252)--
Content-Type: Text/X-Patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="ldirectord.fallback.patch"

diff -r df0d9559130c ldirectord/ldirectord.in
--- a/ldirectord/ldirectord.in	Mon Jul 26 21:40:53 2010 +1000
+++ b/ldirectord/ldirectord.in	Tue Jul 27 21:07:17 2010 +0900
@@ -1281,12 +1281,15 @@
 			my $fwm = undef;
 			my $virtual_id;
 			my $virtual_line = $line;
+			my $virtual_port;
 			my $fallback_line;
 			my @rsrv_todo;
 			if ($vattr =~ /^(\d+\.\d+\.\d+\.\d+):([0-9A-Za-z]+)/) {
 				$virtual_id = $ip_port = "$1:$2";
+				$virtual_port = $2;
 			} elsif ($vattr =~ /^([0-9A-Za-z._+-]+):([0-9A-Za-z]+)/) {
 				$virtual_id = $ip_port = "$1:$2";
+				$virtual_port = $2;
 			} elsif ($vattr =~ /^(\d+)/){
 				$virtual_id = $fwm = $1;
 			} elsif ($vattr =~ /^\[([0-9A-Fa-f:]+)\]:(\d+)/) {
@@ -1296,6 +1299,7 @@
 					&config_error($line,"invalid ipv6 address for virtual server");
 				}
 				$virtual_id = $ip_port = "[$v6addr]:$v6port";
+				$virtual_port = $v6port;
 			} else {
 				&config_error($line,
 					"invalid address for virtual server");
@@ -1308,6 +1312,7 @@
 				if ($ip_port =~ /:53$/) {
 					$vsrv{protocol} = "udp";
 				}
+				$vsrv{port} = $virtual_port;
 			} else {
 				$vsrv{fwm} = $fwm;
 				$vsrv{checktype} = "negotiate";

----Next_Part(Wed_Jul_28_19_51_27_2010_252)----
