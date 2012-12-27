From: Caleb Anthony <caleb.anthony@gmail.com>
Subject: [PATCH] ldirectord: Add the ability to service check HAProxy using
 CSV stats
Date: Thu, 27 Dec 2012 12:03:11 -0700
Message-ID: <CAFVJ3Vdt-zDxaKiZDOhzFERw-sH3cV_yQurvjDXLjdNBrr25FA@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:date:message-id:subject:from:to:cc:content-type;
        bh=FB7Y2gn+jZ40zGsPD5BpZmJtu7U9OrCCFYBUWJgAW4k=;
        b=zSEg9pP+ZLj96NNjnqQrjcBAZbvagg5ax8dLMK4IbOJR6aio7bO6wqqFG3QSLaJxXZ
         +PEF7+MAPc2CstUE2IJ2Te/GXb7pxFKMukd4PHkmacgDpCsdGunZAickm2t+HYRspaVj
         nHrOvwJyKqSqSvyGcpW6rys8IhbEr0Gl1M6VH5HHVsxn5GyaOdBuMoBWdGjRWU4ju+D5
         VegSc35PjfeItlnG+4sWeU/KCmLCIrxyIUfwE3/JfUkK/3UmpIDzcpSUC1jIEuukFqpk
         SRNgSVP5BaNR8VD1yZIXNp2vnoQigya60u8vfTSfIoM8r8/oSNOhq0FDeXM4YKk0arIp
         dlsQ==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>
Cc: haproxy@formilux.org

Hello,

I have multiple HAProxy servers that we load balance with IPVS, and I
wanted the ability to natively health check them using the CSV stats
page, rather than just using the http service check, as this would
require a separate health check configuration and port for each
server/service that we proxy. This configuration quickly gets
unwieldy. I figured that I could use the one single location CSV stats
page to service check all the servers we proxy.

Once this patch is applied, you will need the Text:CSV perl module for
the service check to function.

http://search.cpan.org/~makamaka/Text-CSV-1.21/

To configure ldirectord to service check HAProxy, set the service line
to haproxy, the checkport to the port that the HAProxy stats page is
listening on, the request line to the relative URI for the HAProxy CSV
stats page and finally set the receive line to the proxy, service and
status to check in the CSV output. These three entries correspond to
the "pxname", "svname" and "status" fields respectively (see
documentation link below). Anything that appears in the HAProxy CSV
stats page in those fields can be entered in the receive line.

Here is an example of what the HAProxy CSV stats page looks like for reference:

http://demo.1wt.eu/;csv

And, some documentation on the HAProxy stats page:

http://cbonte.github.com/haproxy-dconv/configuration-1.4.html#9

So a configuration would look as follows:

service = haproxy
checkport = 80
request = "/;csv"
receive = "www,bck,UP"

This would check the stats of the "www" proxy, the "bck" service and
if the status is "UP".

I'm open to any comments, or suggestions. Also, if you feel that this
feature is beneficial I would appreciate if it was merged into the
ldirectord mainline. The CSV stats are very extensive, so this patch
could be expanded in numerous ways if anyone is inclined.

I've also CC'd the HAProxy mailing list in case anyone on that list
uses ldirectord and would find this patch useful.

Thanks.




--- /usr/sbin/ldirectord	2012-04-27 05:40:43.000000000 -0600
+++ /usr/sbin/ldirectord_haproxy	2012-12-27 11:16:44.570384155 -0700
@@ -448,7 +448,7 @@
 On means no checking will take place and real servers will always be
 activated. Default is I<negotiate>.

-B<service = >B<dns> | B<ftp> | B<http> | B<https> | B<http_proxy> |
B<imap> | B<imaps> | B<ldap> | B<mysql> | B<nntp> | B<none> |
B<oracle> | B<pgsql> | B<pop> | B<pops> | B<radius> | B<simpletcp> |
B<sip> | B<smtp> | B<submission>
+B<service = >B<dns> | B<ftp> | B<haproxy> | B<http> | B<https> |
B<http_proxy> | B<imap> | B<imaps> | B<ldap> | B<mysql> | B<nntp> |
B<none> | B<oracle> | B<pgsql> | B<pop> | B<pops> | B<radius> |
B<simpletcp> | B<sip> | B<smtp> | B<submission>

 The type of service to monitor when using checktype=negotiate. None denotes
 a service that will not be monitored.
@@ -535,6 +535,9 @@

 Number of port to monitor. Sometimes check port differs from service port.

+If the service is HAProxy, the checkport must be set to the port that
+HAProxy stats page is listening on.
+
 Default: port specified for each real server

 B<request = ">I<uri to requested object>B<">
@@ -557,6 +560,9 @@
 For a simpletcp check, this string is sent verbatim except any occurrences
 of \n are replaced with a new line character.

+For a HAProxy check, this string should be the relative URI for the HAProxy
+CSV stats page.
+
 B<receive = ">I<regexp to compare>B<">

 If the requested result contains this I<regexp to compare>, the real server
@@ -570,6 +576,11 @@

 For a MySQL check, the receive setting is not used.

+For a HAProxy check, this should be the proxy, service and status to check.
+It should be in the format "proxy,service,status". These correspond to
+the "pxname", "svname" and "status" CSV fields respectively. Anything that
+appears in the HAProxy CSV stats page in those fields can be entered here.
+
 B<httpmethod = GET> | B<HEAD>

 Sets the HTTP method which should be used to fetch the URI specified in
@@ -1490,6 +1501,7 @@
 				} elsif ($rcmd =~ /^service\s*=\s*(.*)/) {
 					$1 =~ /(\w+)/ && ($1 eq "dns"	||
 							  $1 eq "ftp"	||
+							  $1 eq "haproxy" ||
 							  $1 eq "http"	||
 							  $1 eq "https"	||
 							  $1 eq "http_proxy"	||
@@ -1511,6 +1523,7 @@
 					    or &config_error($line,
 							     "service must " .
 							     "be dns, ftp, " .
+							     "haproxy, " .
 							     "http, https, " .
 							     "http_proxy, " .
 							     "imap, imaps, " .
@@ -2729,6 +2742,8 @@
 			$$r{num_connects} = 0 if (check_oracle($v, $r) == $SERVICE_UP);
 		} elsif ($$v{service} eq "simpletcp") {
 			$$r{num_connects} = 0 if (check_simpletcp($v, $r) == $SERVICE_UP);
+		} elsif ($$v{service} eq "haproxy") {
+			$$r{num_connects} = 0 if (check_haproxy($v, $r) == $SERVICE_UP);
 		} else {
 			$$r{num_connects} = 0 if (check_none($v, $r) == $SERVICE_UP);
 		}
@@ -3640,6 +3655,83 @@
 	return $SERVICE_DOWN;
 }

+sub check_haproxy
+{
+	use LWP::Simple;
+	use Text::CSV;
+
+	my ($v, $r) = @_;
+	my $port = $$v{checkport};
+	my @haproxy_fields = split(",", lc($$r{receive}));
+	my $not_found = 0;
+
+	if (!defined($port)) {
+		&ld_debug(2, "The checkport line is not configured and must be set
when using haproxy as the service.");
+		&ld_debug(2, "Configure the port that the haproxy stats page is
listening on to service check proxied servers.");
+
+		service_set($v, $r, "down", {do_log => 1});
+		return $SERVICE_DOWN;
+	}
+
+	if (!defined($haproxy_fields[0]) or !defined($haproxy_fields[1]) or
!defined($haproxy_fields[2])) {
+		&ld_debug(2, "The receive line is not configured correctly, or at all.");
+		&ld_debug(2, "Use the format receive = \"proxy,service,status\"
when using haproxy as the service.");
+
+		service_set($v, $r, "down", {do_log => 1});
+		return $SERVICE_DOWN;
+	}
+
+	&ld_debug(2, "Checking $$v{service} stats at:
http://$$r{server}:$port$$r{request}");
+
+	&ld_debug(2, "Checking proxy: \"$haproxy_fields[0]\" service:
\"$haproxy_fields[1]\" for status: \"$haproxy_fields[2]\"");
+
+	my $csv = Text::CSV->new({
+		binary => 1
+	});
+
+	my $csv_file = get('http://' . $$r{server} . ':' . $port . $$r{request});
+
+	open (CSV, "<", \$csv_file);
+
+	while (<CSV>) {
+		next if ($. == 1);
+
+		if ($csv->parse($_)) {
+			my @columns = $csv->fields();
+
+			@columns = map {lc} @columns;
+
+			if ($columns[0] eq $haproxy_fields[0]) {
+				if ($columns[1] eq $haproxy_fields[1]) {
+					if ($columns[17] eq $haproxy_fields[2]) {
+						&ld_debug(2, "Status of \"$haproxy_fields[2]\" found for proxy:
\"$columns[0]\" and service: \"$columns[1]\"");
+
+						close CSV;
+						service_set($v, $r, "up", {do_log => 1});
+						return $SERVICE_UP;
+					}
+				}
+			}
+		}
+
+		$not_found = 1;
+	}
+
+	close CSV;
+
+	if ($not_found eq 1) {
+		&ld_debug(2, "Proxy: \"$haproxy_fields[0]\" service:
\"$haproxy_fields[1]\" or status: \"$haproxy_fields[2]\" not found.");
+
+	} else {
+		&ld_debug(2, "Unable to retrieve $$v{service} stats at:
http://$$r{server}:$port$$r{request}");
+	}
+
+	&ld_debug(2, "Verify your checkport, request and receive
configuration settings.");
+
+	service_set($v, $r, "down", {do_log => 1});
+	return $SERVICE_DOWN;
+}
+
 # check_none
 # Dummy function to check service if service type is none.
 # Just activates the real server
