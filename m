From: Caleb Anthony <caleb.anthony@gmail.com>
Subject: [PATCH] ldirectord: Add the ability to service check Memcached
Date: Thu, 20 Dec 2012 16:34:52 -0700
Message-ID: <CAFVJ3VcOxav65-dwPjHXZuj29KFfZ-ntj0WfZj9k56wMp7zqCA@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:date:message-id:subject:from:to:content-type;
        bh=AGw4JGnZwlkMsSpYGOzZB0up13+8FSn/V0xmuAN8Rgo=;
        b=zJ6OWsa32XlugkzPgrwpJiLHzf/t0bSX+Z6ESl/YtVjgy2vptb2ixCodZwnmu+jH0k
         qHbGLCz0H1dxfx2dt3ofGBe84C0OQ13y1j7CCpHOlZc4KpD4xn7zloI7SWp6ihOj0/4s
         ZIUd0x5qDMPj5GC12yL8KWfzldF8zNWub+2/m22paWZvyWiS3vyeE9IB/5UcjrxFbLz3
         BLyLqsdIrinI3IQJvQxNF1CjeQYPSP3+QrMVYV8vQ2UlGt2JmfuYLfyTYmE7MYUPYJPh
         0ljXKHsuPFi9iNRsOYIN79PScAVhfZ8JGwMJu5aYgTPMkXDHW8I2dYiLSqRUQbKMT8NN
         wT8w==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org

Hello.

In my organization we have multiple Memcached servers that we load
balance with IPVS. I needed the ability to service check them and I
didn't want to settle for the "connect" and "simpletcp" wouldn't work
with the telnet interface or the Memcached protocol. So I added the
ability for ldirectord to natively service check a Memcached instance.

Once this patch is applied, you will need the Memcached Perl module
installed for the service check to function.

http://search.cpan.org/~dormando/Cache-Memcached-1.30/

To configure ldirectord to service check Memcached, set the service
line to memcached.

service = memcached

Additionally, you can configure the key value pair to store in
Memcached by configuring the request line to "key:value".

request = "key:value"

If request is not configured, a default of "ldirectord:ldirectord" will be used.

I'm open to any comments, or suggestions. Also, if you feel that this
feature is beneficial I would appreciate if it was merged into the
mainline.

Thanks.

 --- /usr/sbin/ldirectord	2012-04-27 05:40:43.000000000 -0600
+++ /usr/sbin/ldirectord_memcached	2012-12-20 16:08:16.210085669 -0700
@@ -448,7 +448,7 @@
 On means no checking will take place and real servers will always be
 activated. Default is I<negotiate>.

-B<service = >B<dns> | B<ftp> | B<http> | B<https> | B<http_proxy> |
B<imap> | B<imaps> | B<ldap> | B<mysql> | B<nntp> | B<none> |
B<oracle> | B<pgsql> | B<pop> | B<pops> | B<radius> | B<simpletcp> |
B<sip> | B<smtp> | B<submission>
+B<service = >B<dns> | B<ftp> | B<http> | B<https> | B<http_proxy> |
B<imap> | B<imaps> | B<ldap> | B<memcached> | B<mysql> | B<nntp> |
B<none> | B<oracle> | B<pgsql> | B<pop> | B<pops> | B<radius> |
B<simpletcp> | B<sip> | B<smtp> | B<submission>

 The type of service to monitor when using checktype=negotiate. None denotes
 a service that will not be monitored.
@@ -498,6 +498,8 @@

 =item * Virtual server port is 5060: sip

+=item * Virtual server port is 11211: memcached
+
 =item * Otherwise: none

 =back
@@ -554,6 +556,10 @@
 The data returned is not checked, only that the
 answer is one or more rows.  This is a required setting.

+For a Memcached check, this should be a key value pair in the format:
key:value.
+This key value pair will try and be stored in the specified Memcached instance.
+If not configured, a default key value of ldirectord:ldirectord will be used.
+
 For a simpletcp check, this string is sent verbatim except any occurrences
 of \n are replaced with a new line character.

@@ -570,6 +576,8 @@

 For a MySQL check, the receive setting is not used.

+For a Memcached check, the receive setting is not used.
+
 B<httpmethod = GET> | B<HEAD>

 Sets the HTTP method which should be used to fetch the URI specified in
@@ -1497,6 +1505,7 @@
 							  $1 eq "imaps"	||
 							  $1 eq "ldap"	||
 							  $1 eq "nntp"	||
+							  $1 eq "memcached" ||
 							  $1 eq "mysql"	||
 							  $1 eq "none"	||
 							  $1 eq "oracle"||
@@ -1515,6 +1524,7 @@
 							     "http_proxy, " .
 							     "imap, imaps, " .
 							     "ldap, nntp, "  .
+							     "memcached, " .
 							     "mysql, none, " .
 							     "oracle, "      .
 							     "pop, pops, "   .
@@ -1817,6 +1827,7 @@
 	if ($port eq 3306)	{ return "mysql"; }
 	if ($port eq 5060)	{ return "sip"; }
 	if ($port eq 5432)	{ return "pgsql"; }
+	if ($port eq 11211)	{ return "memcached"; }

 	return "none";
 }
@@ -1848,6 +1859,7 @@
 	if ($service eq "mysql")	{ return 3306; }
 	if ($service eq "sip")		{ return 5060; }
 	if ($service eq "pgsql")	{ return 5432; }
+	if ($service eq "memcached")	{ return 11211; }

 	return undef;
 }
@@ -2729,6 +2741,8 @@
 			$$r{num_connects} = 0 if (check_oracle($v, $r) == $SERVICE_UP);
 		} elsif ($$v{service} eq "simpletcp") {
 			$$r{num_connects} = 0 if (check_simpletcp($v, $r) == $SERVICE_UP);
+		} elsif ($$v{service} eq "memcached") {
+			$$r{num_connects} = 0 if (check_memcached($v, $r) == $SERVICE_UP);
 		} else {
 			$$r{num_connects} = 0 if (check_none($v, $r) == $SERVICE_UP);
 		}
@@ -3640,6 +3654,52 @@
 	return $SERVICE_DOWN;
 }

+sub check_memcached
+{
+	use Cache::Memcached;
+
+	my ($v, $r) = @_;
+	my $port = ld_checkport($v, $r);
+
+	&ld_debug(2, "Checking $$v{service}: server=$$r{server} port=$port
with a connect/select timeout of: $$v{negotiatetimeout}");
+
+	my $memcached = new Cache::Memcached {
+		'servers' => [ $$r{server} . ":" . $port ],
+		'connect_timeout' => $$v{negotiatetimeout},
+		'select_timeout' => $$v{negotiatetimeout},
+	};
+
+	my @key_val = split(":", $$r{request});
+	$key_val[0] =~ s#^/##;
+
+	if (!defined($key_val[0]) or !defined($key_val[1])) {
+		&ld_debug(2, "The request line is not configured correctly, or at all.");
+		&ld_debug(2, "Use the format request = \"key:value\" when using
memcached as the service.");
+		&ld_debug(2, "Using a default key:value of ldirectord:ldirectord");
+
+		$key_val[0] = "ldirectord";
+		$key_val[1] = "ldirectord";
+	}
+
+	&ld_debug(2, "Trying to set key: $key_val[0] value: $key_val[1] in
memcached");
+
+	if ($memcached->set($key_val[0], $key_val[1])) {
+		&ld_debug(2, "Setting key: $key_val[0] value: $key_val[1] in
memcached was successfull");
+
+		$memcached->disconnect_all;
+
+		service_set($v, $r, "up", {do_log => 1});
+		return $SERVICE_UP;
+	}
+
+	&ld_debug(2, "Setting key: $key_val[0] value: $key_val[1] in
memcached failed");
+
+	$memcached->disconnect_all;
+
+	service_set($v, $r, "down", {do_log => 1});
+	return $SERVICE_DOWN;
+}
+
 # check_none
 # Dummy function to check service if service type is none.
 # Just activates the real server
