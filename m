From: Caleb Anthony <caleb.anthony@gmail.com>
Subject: Re: [PATCH] ldirectord: Allow sending email via external SMTP server
Date: Fri, 8 May 2009 07:38:34 -0600
Message-ID: <33afbbe70905080638u4d6959fdoa4770e86b876c924@mail.gmail.com>
References: <33afbbe70904271254j17e1896fqdb51e88ebd71b2b7@mail.gmail.com>
	 <20090428062636.GB19369@verge.net.au>
	 <33afbbe70904280647x33fafef1w258303ebe4eec313@mail.gmail.com>
	 <20090428151120.GB8377@verge.net.au>
	 <33afbbe70905011242m2423ff3eg4606d7d0ef287387@mail.gmail.com>
	 <20090505124718.GC19402@verge.net.au>
	 <33afbbe70905071309m3cd9e124u95169563460397ce@mail.gmail.com>
	 <20090508002852.GL10892@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:in-reply-to:references
         :date:message-id:subject:from:to:cc:content-type
         :content-transfer-encoding;
        bh=ZWhzqP+rSkiqmzxZpw5s7fDXFSZMvn70DjwYAhFxMfk=;
        b=NUi+iY4c6GWYmleFYyWmsh9N3bUeYsm5jfKoiMkPanzumhQ5BxNtgl4WIwmLht+Cph
         ihPfIbm/F8XjXylA3QhuXaAFTYnmck7BnP/go94gg5WIK8NK5POF3SE+TFB7Dmy1qwuW
         rX/IZun5SEnam/5qmIjCEqK1NkVAHVB0iiWu8=
In-Reply-To: <20090508002852.GL10892@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org

It's fairly well tested. I tried to break it as much as I could -
setting an unreachable SMTP server, setting an invalid SMTP server
address, sending a ton of e-mails with the code by starting, stopping,
adding and removing real servers, etc. I'm going to put it into
production on a few IPVS directors I have here. I can report back in
about a week if you would like.

Also, there needs to be one addition to the ld_emailalert_net_smtp
sub. The ld_emailalert_mail_send sub logs a message in ldirectord.log
once an email is sent: &ld_log("emailalert: $subject");. I meant to
include that same line in ld_emailalert_net_smtp so that each sub
would be as similar as possible.

Could you add that line to ld_emailalert_net_smtp before you commit?

Thanks.

On Thu, May 7, 2009 at 6:28 PM, Simon Horman <horms@verge.net.au> wrote=
:
> On Thu, May 07, 2009 at 02:09:34PM -0600, Caleb Anthony wrote:
>> Attached is a new patch. This one adds two new subs:
>> ld_emailalert_net_smtp and ld_emailalert_mail_send. If an SMTP serve=
r
>> is set in ldirectord.cf, then ld_emailalert_net_smtp will be called
>> and the email will be sent via SMTP. If an SMTP server is not set in
>> ldirectord.cf then ld_emailalert_mail_send will be called and the
>> email will be sent via the Mail::Send methods.
>>
>> Let me know what you think.
>
> Hi Caleb,
>
> That looks pretty good to me. How well tested is it?
>
> I have rediffed it against the current http://hg.linux-ha.org/dev tre=
e.
> The result is below:
>
> Index: dev/ldirectord/ldirectord.in
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- dev.orig/ldirectord/ldirectord.in =A0 2009-05-08 10:21:45.0000000=
00 +1000
> +++ dev/ldirectord/ldirectord.in =A0 =A0 =A0 =A02009-05-08 10:27:02.0=
00000000 +1000
> @@ -248,6 +248,13 @@ If defined in a virtual server section t
> =A0Default: all
>
>
> +B<smtp =3D >I<ip_address|hostname>B<">
> +
> +A valid SMTP server address to use for sending email via SMTP.
> +
> +If defined in a virtual server section then the global value is over=
ridden.
> +
> +
> =A0B<execute =3D ">I<configuration>B<">
>
> =A0Use this directive to start an instance of ldirectord for
> @@ -662,6 +669,7 @@ use vars qw(
> =A0 =A0 =A0 =A0 =A0 =A0$EMAILALERT
> =A0 =A0 =A0 =A0 =A0 =A0$EMAILALERTFREQ
> =A0 =A0 =A0 =A0 =A0 =A0$EMAILALERTSTATUS
> + =A0 =A0 =A0 =A0 =A0 $SMTP
> =A0 =A0 =A0 =A0 =A0 =A0$CLEANSTOP
>
> =A0 =A0 =A0 =A0 =A0 =A0$CALLBACK
> @@ -1422,6 +1430,9 @@ sub read_config
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0($1 eq "yes" || $1 eq "no")
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0or &config_error($line, "cleanstop must be 'yes=
' or 'no'");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0$vsrv{cleanstop} =3D $1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } elsif=
 =A0($rcmd =3D~ /^smtp\s*=3D\s*(.*)/) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 $1 =3D~ /(^([0-9A-Za-z._+-]+))/ or &config_error($line, "inval=
id SMTP server address");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 $vsrv{smtp} =3D $1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else=
 {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0&config_error($line, "Unknown command \"$linedata\"");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -1540,6 +1551,10 @@ sub read_config
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0($1 eq "yes" || $1 eq =
"no")
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0or &config_err=
or($line, "cleanstop must be 'yes' or 'no'");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0$CLEANSTOP =3D $1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } elsif =A0($linedata =A0=3D~ /^smtp\s*=
=3D\s*(.*)/) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 $1 =3D~ /(^([0-9A-Za-z.=
_+-]+))/ or &config_error($line,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 "invalid SMTP server address");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 $SMTP =3D $1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ($linedata =A0=3D~ =
/^timeout\s*=3D\s*(.*)/) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&confi=
g_error($line,
> @@ -4109,14 +4124,13 @@ sub daemon_status_str
> =A0sub ld_emailalert_send
> =A0{
> =A0 =A0 =A0 =A0my ($subject, $v, $rserver, $currenttime) =3D (@_);
> - =A0 =A0 =A0 my $emailmsg;
> - =A0 =A0 =A0 my $emailfh;
> =A0 =A0 =A0 =A0my $status =3D 0;
> =A0 =A0 =A0 =A0my $to_addr;
> =A0 =A0 =A0 =A0my $frequency;
> =A0 =A0 =A0 =A0my $virtual_str;
> =A0 =A0 =A0 =A0my $id;
> =A0 =A0 =A0 =A0my $statusfilter;
> + =A0 =A0 =A0 my $smtp_server;
>
> =A0 =A0 =A0 =A0$frequency =3D defined $v->{emailalertfreq} ? $v->{ema=
ilalert} :
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0$EMAIL=
ALERTFREQ;
> @@ -4143,6 +4157,72 @@ sub ld_emailalert_send
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 $smtp_server =3D defined $v->{smtp} ? $v->{smtp} :
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 $SMTP;
> +
> + =A0 =A0 =A0 if (defined $smtp_server) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 $status =3D &ld_emailalert_net_smtp($sm=
tp_server, $to_addr, $subject);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 $status =3D &ld_emailalert_mail_send($t=
o_addr, $subject);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return($status);
> +}
> +
> +# ld_emailalert_net_smtp
> +# Send email alerts via SMTP server
> +# pre: smtp: SMTP server defined
> +# post: message is emailed if SMTP server is valid and working
> +# return: 0 on success
> +# =A0 =A0 =A0 =A01 on error
> +
> +sub ld_emailalert_net_smtp
> +{
> + =A0 =A0 =A0 my ($smtp_server, $to_addr, $subject) =3D (@_);
> + =A0 =A0 =A0 my $status =3D 0;
> +
> + =A0 =A0 =A0 use Net::SMTP;
> + =A0 =A0 =A0 use Sys::Hostname;
> +
> + =A0 =A0 =A0 my $hostname =3D hostname;
> +
> + =A0 =A0 =A0 my $smtp =3D Net::SMTP->new($smtp_server);
> +
> + =A0 =A0 =A0 if ($smtp) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 $smtp->mail("$ENV{USER}\@$hostname");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 $smtp->to($to_addr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 $smtp->data();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 $smtp->datasend("From: $ENV{USER}\@$hos=
tname\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 $smtp->datasend("To: $to_addr\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 $smtp->datasend("Subject: $subject\n\n"=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 $smtp->datasend("Log-Message: $subject\=
n" .
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "Daemon=
-Status: " .
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &daemon=
_status_str() . "\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 $smtp->dataend();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 $smtp->quit;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 &ld_log("failed to send SMTP email mess=
age\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 $status =3D 1;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return($status);
> +}
> +
> +# ld_emailalert_mail_send
> +# Send email alerts via Mail::Send
> +# pre: smtp: SMTP server not defined
> +# post: message is emailed if one of the Mail::Send methods works
> +# return: 0 on success
> +# =A0 =A0 =A0 =A01 on error
> +
> +sub ld_emailalert_mail_send
> +{
> + =A0 =A0 =A0 my ($to_addr, $subject) =3D (@_);
> + =A0 =A0 =A0 my $emailmsg;
> + =A0 =A0 =A0 my $emailfh;
> + =A0 =A0 =A0 my $status =3D 0;
> +
> =A0 =A0 =A0 =A0use Mail::Send;
>
> =A0 =A0 =A0 =A0&ld_log("emailalert: $subject");
> @@ -4160,7 +4240,6 @@ sub ld_emailalert_send
> =A0 =A0 =A0 =A0return($status);
> =A0}
>
> -
> =A0# ld_emailalert_resend
> =A0# Resend email alerts as neccessary
> =A0# pre: none
>
