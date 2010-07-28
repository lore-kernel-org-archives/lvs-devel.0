From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch][bug][ldirectord] underscore in a servicename
Date: Thu, 29 Jul 2010 08:41:19 +0900
Message-ID: <20100728234119.GA4868@verge.net.au>
References: <20100728.223052.102572767.sohgo@sohgo.dyndns.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100728.223052.102572767.sohgo@sohgo.dyndns.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
Cc: lvs-devel@vger.kernel.org

On Wed, Jul 28, 2010 at 10:30:52PM +0900, Sohgo Takeuchi wrote:
> 
> Hi,
> 
> I found a bug in ldirectord and attach a patch to fix this
> problem to this E-mail.
> 
> If a underscore is contained in a service-name of
> hostname:servicename
> (ex. real=realserver.example.com:pipe_server), it leads to a
> configuration error.

Thanks Takeuchi-san, I have applied the change as follows.

http://hg.linux-ha.org/agents/rev/bfcc4e050a07

# HG changeset patch
# User Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
# Date 1280360397 -32400
# Node ID bfcc4e050a07f5e8a9e52010d2072d39e0641964
# Parent  df0d9559130c836c2a1987a6699e4ce49d9a0bfd
Medium: ldirectord: allow underscore in service name

If a underscore is contained in a service-name of hostname:servicename (ex.
real=realserver.example.com:pipe_server), it leads to a configuration
error.

Signed-off-by: Simon Horman <horms@verge.net.au>

diff -r df0d9559130c -r bfcc4e050a07 ldirectord/ldirectord.in
--- a/ldirectord/ldirectord.in	Mon Jul 26 21:40:53 2010 +1000
+++ b/ldirectord/ldirectord.in	Thu Jul 29 08:39:57 2010 +0900
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
