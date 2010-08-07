From: Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
Subject: [patch][enhancement] ldirectord: IPv6: new directives:
	virtual6, real6, fallback6 (was: Re: ldirectord: a new format of
 ldirectord.conf for IPv6)
Date: Sat, 07 Aug 2010 19:50:10 +0900 (JST)
Message-ID: <20100807.195010.226787800.sohgo@sohgo.dyndns.org>
References: <20100804.001324.112617176.sohgo@sohgo.dyndns.org>
	<20100804010034.GD4469@verge.net.au>
	<20100805.001330.59655583.sohgo@sohgo.dyndns.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
 boundary="--Next_Part(Sat_Aug__7_19_50_10_2010_977)--"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20100805.001330.59655583.sohgo@sohgo.dyndns.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: lvs-devel@vger.kernel.org
Cc: horms@verge.net.au

----Next_Part(Sat_Aug__7_19_50_10_2010_977)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


From: Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
|
> Hi simon,
> 
> From: Simon Horman <horms@verge.net.au>
> |
>> Hi Takeuchi-san,
>> 
>> On Wed, Aug 04, 2010 at 12:13:24AM +0900, Sohgo Takeuchi wrote:
>>> 
>>> Hi simon,
>>> 
>>> From: Simon Horman <horms@verge.net.au>
>>> |
>>> > On Mon, Aug 02, 2010 at 06:35:49PM +0900, Sohgo Takeuchi wrote:
>>> >>     [Candidate 3] Completely separate IPv4 and IPv6 using
>>> >> 	"hoge6" keywords.
>>> >>     
>>> >>     Adding new keywords which denote IPv6. These keywords can
>>> >>     handle IPv6 only and have a name "hoge6".
>>> >> 
>>> >> 	fallback=fallback.example.com
>>> >> 	fallback6=fallback.example.com
>>> >>         virtual=virtual.example.com:daytime
>>> >> 	    real=real1.example.com:daytime gate
>>> >> 	    real=10.10.10.10:daytime gate
>>> >>     	
>>> >> 	virtual6=virtual.example.com:daytime
>>> >> 	    real6=real1.example.com:daytime gate
>>> >> 	    real6=[2001:db8::10]:daytime gate
>>> >> 	    fallback6=localhost:daytime
>>> >> 
>>> >>     This way is very similar to [Candidate 2]. But it is
>>> >>     consistent and easy to read. A demerit is a bit redundant?
>>> > 
>>> > I like candidate 3. Yes, it is redundant, but it is also very clear
>>> > and consistent.
>>> 
>>> Yes.
>>> 
>>> I have implemented [candidate 3]. Now it works good.
>> 
>> Great, once you've finished your testing please post the patch.
> 
> Sure!

I attached a patch to enhance an IPv6 support of ldirectord.

- Added new directives: virtual6, real6, fallback6.
  These are used to specify IPv6 as addresses or hostnames.
  Now cannot specify an IPv6 address in a "virtual" and "real"
  line (This breaks backwards compatibility).
- Supported following checktypes and services.
  checktype: connect, external, external-perl, negotiate, off,
             on, checktimeoutN
  service: dns, nntp, none, simpletcp, sip
- firewall-mark + IPv6 works.

--
Sohgo Takeuchi

----Next_Part(Sat_Aug__7_19_50_10_2010_977)--
Content-Type: Text/X-Patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="ldirectord.v6.patch"

diff -r 322d47183e49 ldirectord/ldirectord.in
--- a/ldirectord/ldirectord.in	Thu Jul 29 15:27:18 2010 +0900
+++ b/ldirectord/ldirectord.in	Sat Aug 07 15:00:58 2010 +0900
@@ -305,7 +305,7 @@
 and run checks against the real servers from them.  This will increase response
 times to changes in real server status in configurations with many virtual
 servers.  This may also use less memory then running many separate instances of
-ldirectord.  Child processes will be automaticly restarted if they die.
+ldirectord.  Child processes will be automatically restarted if they die.
 
 Default: I<no>
 
@@ -692,8 +692,17 @@
 
 =head1 IPv6
 
-IPv6 addresses specified for virtual and real servers should be enclosed by
-brackets ([3ff3:ffff::abcd]:80).
+Directives for IPv6 are virtual6, real6, fallback6.
+IPv6 addresses specified for virtual6, real6, fallback6 and a file
+of maintenance directory should be enclosed by
+brackets ([2001:db8::abcd]:80).
+
+Following checktype and service are supported.
+
+B<checktype: >B<connect> | B<external> | B<external-perl> | B<negotiate> | B<off> | B<on> | B<checktimeout>I<N>
+
+B<service: >B<dns> | B<nntp> | B<none> | B<simpletcp> | B<sip>
+
 
 =head1 FILES
 
@@ -751,6 +760,7 @@
 	    $CONFIG
 	    $DEBUG
 	    $FALLBACK
+	    $FALLBACK6
 	    $FALLBACKCOMMAND
 	    $SUPERVISED
 	    $IPVSADM
@@ -1234,6 +1244,7 @@
 	$EMAILALERTSTATUS = $DAEMON_STATUS_ALL;
 	$FAILURECOUNT     = 1;
 	$FALLBACK         = undef;
+	$FALLBACK6        = undef;
 	$FALLBACKCOMMAND  = undef;
 	$FORKING          = "no";
 	$LDIRLOG          = "/var/log/ldirectord.log";
@@ -1275,8 +1286,9 @@
 		$line++;
 		$linedata = $_;
 		outer_loop:
-		if ($linedata =~ /^virtual\s*=\s*(.*)/) {
-			my $vattr = $1;
+		if ($linedata =~ /^virtual(6)?\s*=\s*(.*)/) {
+			my $af = defined($1) ? AF_INET6 : AF_INET;
+			my $vattr = $2;
 			my $ip_port = undef;
 			my $fwm = undef;
 			my $virtual_id;
@@ -1284,7 +1296,7 @@
 			my $virtual_port;
 			my $fallback_line;
 			my @rsrv_todo;
-			if ($vattr =~ /^(\d+\.\d+\.\d+\.\d+):([0-9A-Za-z-_]+)/) {
+			if ($vattr =~ /^(\d+\.\d+\.\d+\.\d+):([0-9A-Za-z-_]+)/ && $af == AF_INET) {
 				$virtual_id = $ip_port = "$1:$2";
 				$virtual_port = $2;
 			} elsif ($vattr =~ /^([0-9A-Za-z._+-]+):([0-9A-Za-z-_]+)/) {
@@ -1292,7 +1304,9 @@
 				$virtual_port = $2;
 			} elsif ($vattr =~ /^(\d+)/){
 				$virtual_id = $fwm = $1;
-			} elsif ($vattr =~ /^\[([0-9A-Fa-f:]+)\]:(\d+)/) {
+			} elsif ($vattr =~ /^\[([0-9A-Fa-f:]+)\]:([0-9A-Za-z-_]+)/ && $af == AF_INET) {
+				&config_error($line, "cannot specify an IPv6 address here. please use \"virtual6\" instead.");
+			} elsif ($vattr =~ /^\[([0-9A-Fa-f:]+)\]:([0-9A-Za-z-_]+)/ && $af == AF_INET6) {
 				my $v6addr = $1;
 				my $v6port = $2;
 				if (!inet_pton(AF_INET6,$v6addr)) {
@@ -1309,7 +1323,7 @@
 			if ($ip_port) {
 				$vsrv{checktype} = "negotiate";
 				$vsrv{protocol} = "tcp";
-				if ($ip_port =~ /:53$/) {
+				if ($ip_port =~ /:(53|domain)$/) {
 					$vsrv{protocol} = "udp";
 				}
 				$vsrv{port} = $virtual_port;
@@ -1320,6 +1334,7 @@
 				$vsrv{service} = "none";
 				$vsrv{port} = "0";
 			}
+			$vsrv{addressfamily} = $af;
 			$vsrv{real} = \@rsrv;
 			$vsrv{scheduler} = "wrr";
 			$vsrv{checkcommand} = "/bin/true";
@@ -1348,8 +1363,12 @@
 					last;
 				}
 				my $rcmd = $1;
-				if ($rcmd =~ /^real\s*=\s*(.*)/) {
-					push @rsrv_todo, [$1, $line];
+				if ($rcmd =~ /^(real(6)?)\s*=\s*(.*)/) {
+					if ($af == AF_INET  &&   defined($2) ||
+					    $af == AF_INET6 && ! defined($2)) {
+					    &config_error($line, join("", ("cannot specify \"$1\" here. please use \"real" , $af == AF_INET ?  "" : "6" , "\" instead")));
+					}
+					push @rsrv_todo, [$3, $line];
 				} elsif ($rcmd =~ /^request\s*=\s*\"(.*)\"/) {
 					$1 =~ /(.+)/ or &config_error($line, "no request string specified");
 					$vsrv{request} = $1;
@@ -1510,10 +1529,14 @@
 					$1 =~ /\"?([^\"]*)\"?/ or
 					&config_error($line, "invalid virtualhost");
 					$vsrv{virtualhost} = $1;
-				} elsif ($rcmd =~ /^fallback\s*=\s*(.*)/) {    # Allow specification of a virtual-specific fallback host
+				} elsif ($rcmd =~ /^(fallback(6)?)\s*=\s*(.*)/) {    # Allow specification of a virtual-specific fallback host
+					if ($af == AF_INET  &&   defined($2) ||
+					    $af == AF_INET6 && ! defined($2)) {
+					    &config_error($line, join("", ("cannot specify \"$1\" here. please use \"fallback" , $af == AF_INET ?  "" : "6" , "\" instead")));
+					}
 					$fallback_line=$line;
 					$vsrv{fallback} =
-						parse_fallback($line, $1,
+						parse_fallback($line, $3,
 							       \%vsrv);
 				} elsif ($rcmd =~
 				/^fallbackcommand\s*=\s*\"(.*)\"/ or $rcmd =~ /^fallbackcommand\s*=\s*(.*)/) {
@@ -1557,10 +1580,10 @@
 			# for a virtual service has been parsed.
 
 			&_ld_read_config_fallback_resolve($fallback_line,
-				$vsrv{protocol}, $vsrv{fallback});
+				$vsrv{protocol}, $vsrv{fallback}, $af);
 			&_ld_read_config_virtual_resolve($virtual_line, \%vsrv,
-				$ip_port);
-			&_ld_read_config_real_resolve(\%vsrv, \@rsrv_todo);
+				$ip_port, $af);
+			&_ld_read_config_real_resolve(\%vsrv, \@rsrv_todo, $af);
 
 			# Check for duplicate now we have all the
 			# information to generate the id
@@ -1604,12 +1627,17 @@
 			$1 =~ /(\d+)/ && $1 or &config_error($line,
 					"invalid failure count value");
 			$FAILURECOUNT = $1;
-		} elsif ($linedata  =~ /^fallback\s*=\s*(.*)/) {
-			my $tcp = parse_fallback($line, $1, undef);
-			my $udp = parse_fallback($line, $1, undef);
-			&_ld_read_config_fallback_resolve($line, "tcp", $tcp);
-			&_ld_read_config_fallback_resolve($line, "udp", $udp);
-			$FALLBACK = { "tcp" => $tcp, "udp" => $udp };
+		} elsif ($linedata  =~ /^fallback(6)?\s*=\s*(.*)/) {
+			my $af = defined($1) ? AF_INET6 : AF_INET;
+			my $tcp = parse_fallback($line, $2, undef);
+			my $udp = parse_fallback($line, $2, undef);
+			&_ld_read_config_fallback_resolve($line, "tcp", $tcp, $af);
+			&_ld_read_config_fallback_resolve($line, "udp", $udp, $af);
+			if ($af == AF_INET) {
+				$FALLBACK = { "tcp" => $tcp, "udp" => $udp };
+			} else {
+				$FALLBACK6 = { "tcp" => $tcp, "udp" => $udp };
+			}
 		} elsif ($linedata =~ /^fallbackcommand\s*=\s*(.*)/) {
 			$1 =~ /(.+)/ or &config_error($line, "invalid fallback command");
 			$FALLBACKCOMMAND = $1;
@@ -1716,6 +1744,7 @@
 #      vsrv: Virtual Service to resolve server and port of
 #      ip_port: server and port in the form
 #               ip_address|hostname:port|service
+#      af: Address family: AF_INET or AF_INET6
 # post: Take ip_port, resolve it as per ld_gethostservbyname
 #       and set $vsrv->{server} and $vsrv->{port} accordingly.
 #       If $vsrv->{service} is not set, then set according to the value of
@@ -1725,10 +1754,10 @@
 #        on error.
 sub _ld_read_config_virtual_resolve
 {
-	my($line, $vsrv, $ip_port)=(@_);
+	my($line, $vsrv, $ip_port, $af)=(@_);
 
 	if($ip_port){
-		$ip_port=&ld_gethostservbyname($ip_port, $vsrv->{protocol});
+		$ip_port=&ld_gethostservbyname($ip_port, $vsrv->{protocol}, $af);
 		if ($ip_port =~ /(\[[0-9A-Fa-f:]+\]):(\d+)/) {
 			$vsrv->{server} = $1;
 			$vsrv->{port} = $2;
@@ -1835,6 +1864,7 @@
 # pre: line: Line of configuration file fallback server was read from
 #            Used for debugging messages
 #      vsrv: Virtual Service to resolve fallback server of
+#      af: Address family: AF_INET or AF_INET6
 # post: Take $vsrv->{fallback}, resolve it as per ld_gethostservbyname
 #       and set $vsrv->{fallback} to the result
 # return: none
@@ -1842,15 +1872,27 @@
 #	on error.
 sub _ld_read_config_fallback_resolve
 {
-	my($line, $protocol, $fallback)=(@_);
+	my($line, $protocol, $fallback, $af)=(@_);
+
+	my ($ipversion, $ipaddress);
 
 	unless($fallback) {
 		return;
 	}
-
-	$fallback->{server} = &ld_gethostbyname($fallback->{server}) or
-		&config_error($line, "invalid address for fallback server: " .
+	if ($af == AF_INET) {
+	 	$ipversion = "IPv4";
+	}
+	elsif ($af == AF_INET6) {
+	 	$ipversion = "IPv6";
+	}
+	else {
+	 	$ipversion = "IP??($af)";
+	}
+	unless ($ipaddress = &ld_gethostbyname($fallback->{server}, $af)) {
+		&config_error($line, "invalid $ipversion address or could not resolve for fallback server: " .
 			      $fallback->{server});
+	}
+	$fallback->{server} = $ipaddress;
 
 	unless($fallback->{"port"}) {
 		return;
@@ -1871,13 +1913,14 @@
 #                 each list reference is the line read from the
 #                 configuration after "real=". The second element is the
 #                 line number, used for error reporting
+#      af: Address family: AF_INET or AF_INET6
 # post: Run through rsrv_todo and parse real servers
 # return: none
 #	Debugging message will be reported and programme will exit
 #	on error.
 sub _ld_read_config_real_resolve
 {
-	my ($vsrv, $rsrv_todo)=(@_);
+	my ($vsrv, $rsrv_todo, $af)=(@_);
 
 	my $i;
 	my $str;
@@ -1905,7 +1948,7 @@
 			$port="0";
 		}
 		$flags=$6;
-		$resolved_ip1=&ld_gethostbyname($ip1);
+		$resolved_ip1=&ld_gethostbyname($ip1, $af);
 		unless( defined($resolved_ip1) ) {
 			&config_error($line,
 				"invalid address ($ip1) for real server" .
@@ -1920,7 +1963,7 @@
 			}
 		}
 		if ( defined ($ip2) ) {
-			$resolved_ip2=&ld_gethostbyname($ip2);
+			$resolved_ip2=&ld_gethostbyname($ip2, $af);
 			unless( defined ($resolved_ip2) ) {
 				&config_error($line,
 					"invalid address ($ip2) for " .
@@ -1928,7 +1971,7 @@
 					" (could not resolve end host)");
 			}
 			&add_real_server_range($line, $vsrv, $resolved_ip1,
-				$resolved_ip2, $resolved_port, $flags);
+				$resolved_ip2, $resolved_port, $flags, $af);
 		} else {
 			&add_real_server($line, $vsrv, $resolved_ip1,
 				$resolved_port, $flags);
@@ -1946,34 +1989,44 @@
 #      port: Port of real servers
 #      flags: Flags for real servers. Should be of the form
 #             gate|masq|ipip [<weight>] [">I<request>", "<receive>"]
+#      af: Address family: AF_INET or AF_INET6
 # post: real servers are added to virtual server
 # return: none
 #         Debugging message will be reported and programme will exit
 #         on error.
 sub add_real_server_range
 {
-	my ($line, $vsrv, $first, $last, $port, $flags) = (@_);
+	my ($line, $vsrv, $first, $last, $port, $flags, $af) = (@_);
 
 	my (@tmp, $first_i, $last_i, $i, $rsrv);
 
-	if ( ($first_i=&ip_to_int($first)) <0 ) {
-		&config_error($line, "Invalid IP address: $first");
-	}
-	if ( ($last_i=&ip_to_int($last)) <0 ) {
-		&config_error($line, "Invalid IP address: $last");
-	}
-
-	if ($first_i>$last_i) {
-		&config_error($line,
-			"Invalid Range: $first-$last: First value must be " .
-			"greater than or equal to the second value");
-	}
-
-	# A for loop didn't seem to want to work
-	$i=$first_i;
-	while ( $i le $last_i ) {
-		&add_real_server($line, $vsrv, &int_to_ip($i), $port, $flags);
-		$i++;
+	if ($af == AF_INET) {
+		if ( ($first_i=&ip_to_int($first)) <0 ) {
+			&config_error($line, "Invalid IP address: $first");
+		}
+		if ( ($last_i=&ip_to_int($last)) <0 ) {
+			&config_error($line, "Invalid IP address: $last");
+		}
+
+		if ($first_i>$last_i) {
+			&config_error($line,
+				"Invalid Range: $first-$last: First value must be " .
+				"greater than or equal to the second value");
+		}
+
+		# A for loop didn't seem to want to work
+		$i=$first_i;
+		while ( $i le $last_i ) {
+			&add_real_server($line, $vsrv, &int_to_ip($i), $port, $flags);
+			$i++;
+		}
+	}
+	elsif ($af == AF_INET6) {
+		# not supported yet
+		&config_error($line, "Address range for IPv6 is not supported yet");
+	}
+	else {
+		die "address family must be AF_INET or AF_INET6\n";
 	}
 }
 
@@ -1999,7 +2052,6 @@
 	my $new_rsrv;
 	my $rsrv;
 
-	if ($ip =~ /:/) { $ip = "[" . $ip . "]"; }
 	$new_rsrv = {"server"=>$ip, "port"=>$port};
 
 	$flags =~ /(\w+)(.*)/ && ($1 eq "gate" || $1 eq "masq" || $1 eq "ipip")
@@ -2061,16 +2113,27 @@
 {
 	my ($line, $fallback, $vsrv) = (@_);
 
+	my $parse_line;
 	my $server;
 	my $port;
 	my $fwd;
 
-	$fallback =~ /^\s*([^: 	]+)(:(\S+))?(\s+(\S+))?\s*/ or
-		  &config_error($line, "invalid fallback server: $fallback");
-
-	$server=$1;
-	$port=$3;
-	$fwd=$5;
+	$parse_line = $fallback;
+	if ($parse_line =~ /(\S+)(\s+(\S+))?\s*$/) {
+		# get "ip:port" and a forwarding method
+		$fwd = $3;
+		$parse_line = $1;
+	}
+	if ($parse_line =~ /(:(\d+|[A-Za-z0-9-_]+))?$/) {
+		# get host and port
+		$port=$2;
+		
+		$parse_line =~ s/(:(\d+|[A-Za-z0-9-_]+))?$//;
+		$server = $parse_line;
+	}
+	unless(defined($server)) {
+		&config_error($line, "invalid fallback server: $fallback");
+	}
 
 	if (not defined($port) and defined($vsrv)) {
 		$port = $vsrv->{"port"};
@@ -2140,7 +2203,7 @@
 		} elsif ($$v{protocol} eq "fwm") {
 			$$v{proto} = "-f";
 		}
-		$$v{flags} = "$$v{proto} " .  &get_virtual($v) . " ";
+		$$v{flags} = "$$v{proto} " .  &get_virtual_option($v) . " ";
 		$$v{flags} .= "-s $$v{scheduler} " if defined ($$v{scheduler});
 		if (defined $$v{persistent}) {
 			$$v{flags} .= "-p $$v{persistent} ";
@@ -2957,6 +3020,7 @@
 sub check_nntp
 {
 	use IO::Socket;
+	use IO::Socket::INET6;
 	use IO::Select;
 	my ($v, $r) = @_;
 	my $sock;
@@ -2967,7 +3031,7 @@
 
 	&ld_debug(2, "Checking nntp server=$$r{server} port=$port");
 
-	unless ($sock = IO::Socket::INET->new(PeerAddr => $$r{server},
+	unless ($sock = IO::Socket::INET6->new(PeerAddr => $$r{server},
 		PeerPort => $port, Proto => 'tcp',
 		TimeOut => $$v{negotiatetimeout})) {
 		service_set($v, $r, "down", {do_log => 1});
@@ -3271,9 +3335,7 @@
 			die("Socket Connect Failed");
 		}
 
-		my $sip_sockaddr = getsockname($sock);
-		my ($sip_s_port, $sip_s_addr) = sockaddr_in($sip_sockaddr);
-		my $sip_s_addr_str = inet_ntoa($sip_s_addr);
+		my ($sip_s_addr_str, $sip_s_port) = &ld_get_addrport($sock);
 
 		&ld_debug(3, "Connected from $sip_s_addr_str:$sip_s_port to " .
 			$$r{server} . ":$sip_d_port");
@@ -3365,9 +3427,7 @@
 			die("Socket Connect Failed");
 		}
 
-		my $s_sockaddr = getsockname($sock);
-		my ($s_port, $s_addr) = sockaddr_in($s_sockaddr);
-		my $s_addr_str = inet_ntoa($s_addr);
+		my ($s_addr_str, $s_port) = &ld_get_addrport($sock);
 
 		&ld_debug(3, "Connected from $s_addr_str:$s_port to " .
 			$$r{server} . ":$d_port");
@@ -3462,6 +3522,7 @@
 	my $query;
 	my $rr;
 	my $request;
+	my $server;
 	my ($v,$r) = @_;
 	{
 		# Net::DNS makes unguarded calls to eval
@@ -3477,6 +3538,8 @@
 
 	$$r{"request"} =~ m/^\/?(.*)/;
 	$request=$1;
+	
+	$server = &ld_strip_brackets($$r{server});
 
 	&ld_debug(2, "Checking dns: request=\"$request\" receive=\""
 		. $$r{"receive"} . "\"\n");
@@ -3485,7 +3548,7 @@
 		local $SIG{'__DIE__'} = "DEFAULT";
 		local $SIG{'ALRM'} = sub { die "timeout\n"; };
 		alarm($$v{negotiatetimeout});
-		$res->nameservers($$r{server});
+		$res->nameservers($server);
 		if ($$v{"protocol"} eq "tcp") {
 			$res->usevc(1);
 		}
@@ -3722,7 +3785,7 @@
 		return;
 	}
 
-	$ipvsadm_args = "$$v{proto} " . $virtual_str . " -r $rservice";
+	$ipvsadm_args = "$$v{proto} " . &get_virtual_option($v) . " -r $rservice";
 	$log_args = "$tag server: $rservice ";
 	if(defined($old_rservice)) {
 		$log_args .= "mapped from $old_rservice "
@@ -3782,7 +3845,7 @@
 	my $ipvsadm_args;
 	my $log_args;
 
-	$ipvsadm_args = "$$v{proto} " . &get_virtual($v)
+	$ipvsadm_args = "$$v{proto} " . &get_virtual_option($v)
 			. " -r $rservice $rforw -w $rwght";
 	$log_args = "$tag server: $rservice "
 		    . "(" #. scalar(%{$v->{real_status}})
@@ -4019,19 +4082,30 @@
 {
 	my ($virtual) = (@_);
 
+	my($global_fallback_ptr);	# fallback pointer
+	my $ipv6p = $virtual->{server} =~ /[\[\]]/ ? 1 : 0;
+
 	if( defined $virtual->{"fallback"} ) {
 		return($virtual->{"fallback"});
-	} elsif ( not defined($FALLBACK) ) {
+	} elsif ( not defined($FALLBACK) and not $ipv6p ) {
 		return undef;
+	} elsif ( not defined($FALLBACK6) and $ipv6p ) {
+		return undef;
+	}
+
+	if ($ipv6p) {	# IPv6
+		$global_fallback_ptr = $FALLBACK6;
+	} else {
+		$global_fallback_ptr = $FALLBACK;
 	}
 
 	# If the global fallback has a port, it can be used as is
-	if (defined($FALLBACK->{$virtual->{"protocol"}}->{"port"})) {
-		return $FALLBACK->{$virtual->{"protocol"}};
+	if (defined($global_fallback_ptr->{$virtual->{"protocol"}}->{"port"})) {
+		return $global_fallback_ptr->{$virtual->{"protocol"}};
 	}
 
 	# Else create an anonymous fallback
-	my %anon_fallback = %{$FALLBACK->{$virtual->{"protocol"}}};
+	my %anon_fallback = %{$global_fallback_ptr->{$virtual->{"protocol"}}};
 	$anon_fallback{"port"} = $virtual->{"port"};
 
 	return \%anon_fallback;
@@ -4065,7 +4139,7 @@
 	my $log_arg = "Purged real server ($tag): $rservice (" .
 		      &get_virtual($v) . ")";
 
-	&system_wrapper("$IPVSADM -d $v->{proto} " . &get_virtual($v) .
+	&system_wrapper("$IPVSADM -d $v->{proto} " . &get_virtual_option($v) .
 			" -r $rservice");
 	&ld_log($log_arg);
 	&ld_emailalert_send($log_arg, $v, $rservice, 0);
@@ -4085,7 +4159,7 @@
 {
 	my ($v, $tag) = (@_);
 
-	&system_wrapper("$IPVSADM -D $v->{proto} " .  &get_virtual($v));
+	&system_wrapper("$IPVSADM -D $v->{proto} " .  &get_virtual_option($v));
 	&ld_log("Purged virtual server ($tag): " .  &get_virtual($v));
 }
 
@@ -4620,6 +4694,26 @@
 	}
 }
 
+# get_virtual_option
+# Get the ipvsadm option corresponding to a virtual service
+# pre: nv: virtual to get the service for
+# post: none
+# return: fwmark of service if it is a fwm service
+#         fwmark of service + "-6" if it is a fwm service and the address family is AF_INET6
+#         ip_address:port otherwise
+sub get_virtual_option
+{
+	my ($nv) = (@_);
+
+	my ($cmdline) = &get_virtual($nv);
+
+	if ($nv->{"protocol"} eq "fwm" && $nv->{addressfamily} == AF_INET6) {
+		$cmdline .=  " -6";
+	}
+	
+	return $cmdline;
+}
+
 # get_real_id_str
 # Get an id string for a real server
 # pre: r: Real service.
@@ -4755,6 +4849,7 @@
 	my ($iaddr, $paddr, $pro, $result, $pf);
 	local *SOCK;
 
+	$remote = &ld_strip_brackets($remote);
 	if (inet_pton(AF_INET6,$remote)) {
 		$iaddr = inet_pton(AF_INET6,$remote);
 		$paddr = pack_sockaddr_in6($port, $iaddr);
@@ -4886,23 +4981,29 @@
 # Wrapper to gethostbyname. Look up the/an IP address of a hostname
 # If an IP address is given is it returned
 # pre: name: Hostname of IP address to lookup
+#      af: Address Family: AF_INET etc..
 # post: gethostbyname is called to find an IP address for $name
 #       This is converted to a string
 # return: IP address
 #         undef on error
 sub ld_gethostbyname
 {
-	my ($name)=(@_);
+	my ($name, $af)=(@_);
 
 	if ($name =~ /\[(.*)\]/) {
 		$name = $1;
 	}
-	my @host = getaddrinfo($name,0);
+	my @host = getaddrinfo($name, 0, $af);
 	if (!defined($host[3])) {
 		return undef;
 	}
 	my @ret = getnameinfo($host[3], NI_NUMERICHOST | NI_NUMERICSERV);
-	return $ret[0];
+	if ($host[0] == AF_INET6) {
+		return "[$ret[0]]";
+	}
+	else {
+		return $ret[0];
+	}
 }
 
 # ld_gethostbyaddr
@@ -4916,6 +5017,7 @@
 {
 	my ($ip)=(@_);
 
+	$ip = &ld_strip_brackets($ip);
 	my @host = getaddrinfo($ip,0);
 	if (!defined($host[3])) {
 		return undef;
@@ -4953,27 +5055,24 @@
 # form ip_address|hostname[:port|servicename] return ip_address[:port]
 # pre: hostserv: Servver of the form ip_address|hostname[:port|servicename]
 #      protocol: Protocol for service. Should be either "tcp" or "udp"
+#      af: Address Family: AF_INET etc..
 # post: lookups performed as per ld_getservbyname and ld_gethostbyname
 # return: ip_address[:port]
 #         undef on error
 sub ld_gethostservbyname{
-	my ($hostserv, $protocol) = (@_);
+	my ($hostserv, $protocol, $af) = (@_);
 
 	my $ip;
 	my $port;
-
-	if ($hostserv =~ /(\[[0-9A-Fa-f:]+\])(:(\d+|[A-Za-z0-9-_]+))?/) {
-		$ip=$1;
-		$port=$3;
+	
+	if ($hostserv =~ /(:(\d+|[A-Za-z0-9-_]+))?$/) {
+		$port = $2;
+		$ip = $hostserv;
+		$ip =~ s/(:(\d+|[A-Za-z0-9-_]+))?$//;
 	} else {
-		$hostserv =~
-		/(\d+\.\d+\.\d+\.\d+|[A-Za-z0-9.-]+)(:(\d+|[A-Za-z0-9-_]+))?/
-		or return(undef);
-		$ip=$1;
-		$port=$3;
-
-		$ip=&ld_gethostbyname($ip)  or return(undef);
-	}
+		$ip = $hostserv;
+	}
+	$ip=&ld_gethostbyname($ip, $af)  or return(undef);
 
 	if(defined($port)){
 		$port=&ld_getservbyname($port, $protocol);
@@ -5027,3 +5126,45 @@
 {
 	return ld_find_cmd_path($_[0], $ENV{'PATH'}, $_[1]);
 }
+
+# ld_get_addrport
+# Get address string and port number from a given socket.
+# pre: socket
+# return: (address, port)
+#         undef if cannot get
+sub ld_get_addrport
+{
+	my($sock) = @_;
+
+	my ($s_addr_str, $s_port, $s_addr, $len);
+
+	my $s_sockaddr = getsockname($sock);
+	$len = length($s_sockaddr);
+	if ($len == 28) {	# IPv6
+		($s_port, $s_addr) = unpack_sockaddr_in6($s_sockaddr);
+		$s_addr_str = inet_ntop(AF_INET6, $s_addr);
+		$s_addr_str = "[$s_addr_str]";
+	}
+	elsif ($len == 16) {	# IPv4
+		($s_port, $s_addr) = unpack_sockaddr_in($s_sockaddr);
+		$s_addr_str = inet_ntop(AF_INET, $s_addr);
+	}
+	else {
+		die "unexpected length of sockaddr\n";
+	}
+
+	return ($s_addr_str, $s_port);
+}
+
+# ld_strip_brackets
+# Strip brackets in the string
+# pre: string
+# return: string
+sub ld_strip_brackets
+{
+	my($str) = @_;
+
+	$str =~ s/[\[\]]//g;
+
+	return $str;
+}

----Next_Part(Sat_Aug__7_19_50_10_2010_977)----
