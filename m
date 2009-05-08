From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ldirectord: Allow sending email via external SMTP
	server
Date: Fri, 8 May 2009 10:28:52 +1000
Message-ID: <20090508002852.GL10892@verge.net.au>
References: <33afbbe70904271254j17e1896fqdb51e88ebd71b2b7@mail.gmail.com> <20090428062636.GB19369@verge.net.au> <33afbbe70904280647x33fafef1w258303ebe4eec313@mail.gmail.com> <20090428151120.GB8377@verge.net.au> <33afbbe70905011242m2423ff3eg4606d7d0ef287387@mail.gmail.com> <20090505124718.GC19402@verge.net.au> <33afbbe70905071309m3cd9e124u95169563460397ce@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <33afbbe70905071309m3cd9e124u95169563460397ce@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Caleb Anthony <caleb.anthony@gmail.com>
Cc: lvs-devel@vger.kernel.org

On Thu, May 07, 2009 at 02:09:34PM -0600, Caleb Anthony wrote:
> Attached is a new patch. This one adds two new subs:
> ld_emailalert_net_smtp and ld_emailalert_mail_send. If an SMTP server
> is set in ldirectord.cf, then ld_emailalert_net_smtp will be called
> and the email will be sent via SMTP. If an SMTP server is not set in
> ldirectord.cf then ld_emailalert_mail_send will be called and the
> email will be sent via the Mail::Send methods.
> 
> Let me know what you think.

Hi Caleb,

That looks pretty good to me. How well tested is it?

I have rediffed it against the current http://hg.linux-ha.org/dev tree.
The result is below:

Index: dev/ldirectord/ldirectord.in
===================================================================
--- dev.orig/ldirectord/ldirectord.in	2009-05-08 10:21:45.000000000 +1000
+++ dev/ldirectord/ldirectord.in	2009-05-08 10:27:02.000000000 +1000
@@ -248,6 +248,13 @@ If defined in a virtual server section t
 Default: all
 
 
+B<smtp = >I<ip_address|hostname>B<">
+
+A valid SMTP server address to use for sending email via SMTP.
+
+If defined in a virtual server section then the global value is overridden.
+
+
 B<execute = ">I<configuration>B<">
 
 Use this directive to start an instance of ldirectord for
@@ -662,6 +669,7 @@ use vars qw(
 	    $EMAILALERT
 	    $EMAILALERTFREQ
 	    $EMAILALERTSTATUS
+	    $SMTP
 	    $CLEANSTOP
 
 	    $CALLBACK
@@ -1422,6 +1430,9 @@ sub read_config
 					($1 eq "yes" || $1 eq "no")
 						or &config_error($line, "cleanstop must be 'yes' or 'no'");
 					$vsrv{cleanstop} = $1;
+				} elsif  ($rcmd =~ /^smtp\s*=\s*(.*)/) {
+					$1 =~ /(^([0-9A-Za-z._+-]+))/ or &config_error($line, "invalid SMTP server address");
+					$vsrv{smtp} = $1;
 				} else {
 					&config_error($line, "Unknown command \"$linedata\"");
 				}
@@ -1540,6 +1551,10 @@ sub read_config
 			($1 eq "yes" || $1 eq "no")
 			    or &config_error($line, "cleanstop must be 'yes' or 'no'");
 			$CLEANSTOP = $1;
+		} elsif  ($linedata  =~ /^smtp\s*=\s*(.*)/) {
+			$1 =~ /(^([0-9A-Za-z._+-]+))/ or &config_error($line,
+					"invalid SMTP server address");
+			$SMTP = $1;
 		} else {
 			if ($linedata  =~ /^timeout\s*=\s*(.*)/) {
 				&config_error($line, 
@@ -4109,14 +4124,13 @@ sub daemon_status_str
 sub ld_emailalert_send
 {
 	my ($subject, $v, $rserver, $currenttime) = (@_);
-	my $emailmsg;
-	my $emailfh;
 	my $status = 0;
 	my $to_addr;
 	my $frequency;
 	my $virtual_str;
 	my $id;
 	my $statusfilter;
+	my $smtp_server;
 
 	$frequency = defined $v->{emailalertfreq} ? $v->{emailalert} :
 				$EMAILALERTFREQ;
@@ -4143,6 +4157,72 @@ sub ld_emailalert_send
 		return 0;
 	}
 
+	$smtp_server = defined $v->{smtp} ? $v->{smtp} :
+				$SMTP;
+
+	if (defined $smtp_server) {
+		$status = &ld_emailalert_net_smtp($smtp_server, $to_addr, $subject);
+	}
+	else {
+		$status = &ld_emailalert_mail_send($to_addr, $subject);
+	}
+
+	return($status);
+}
+
+# ld_emailalert_net_smtp
+# Send email alerts via SMTP server
+# pre: smtp: SMTP server defined
+# post: message is emailed if SMTP server is valid and working
+# return: 0 on success
+#	  1 on error
+
+sub ld_emailalert_net_smtp
+{
+	my ($smtp_server, $to_addr, $subject) = (@_);
+	my $status = 0;
+
+	use Net::SMTP;
+	use Sys::Hostname;
+
+	my $hostname = hostname;
+
+	my $smtp = Net::SMTP->new($smtp_server);
+
+	if ($smtp) {
+		$smtp->mail("$ENV{USER}\@$hostname");
+		$smtp->to($to_addr);
+		$smtp->data();
+		$smtp->datasend("From: $ENV{USER}\@$hostname\n");
+		$smtp->datasend("To: $to_addr\n");
+		$smtp->datasend("Subject: $subject\n\n");
+		$smtp->datasend("Log-Message: $subject\n" .
+				"Daemon-Status: " .
+				&daemon_status_str() . "\n");
+		$smtp->dataend();
+		$smtp->quit;
+	} else {
+		&ld_log("failed to send SMTP email message\n");
+		$status = 1;
+	}
+
+	return($status);
+}
+
+# ld_emailalert_mail_send
+# Send email alerts via Mail::Send
+# pre: smtp: SMTP server not defined
+# post: message is emailed if one of the Mail::Send methods works
+# return: 0 on success
+#	  1 on error
+
+sub ld_emailalert_mail_send
+{
+	my ($to_addr, $subject) = (@_);
+	my $emailmsg;
+	my $emailfh;
+	my $status = 0;
+
 	use Mail::Send;
 
 	&ld_log("emailalert: $subject");
@@ -4160,7 +4240,6 @@ sub ld_emailalert_send
 	return($status);
 }
 
