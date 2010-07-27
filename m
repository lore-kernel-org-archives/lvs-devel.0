From: Wensong Zhang <wensong@linux-vs.org>
Subject: Re: [patch 4/5] ipvsadm: Use an enum for the val of options that have 
	no short option
Date: Tue, 27 Jul 2010 13:42:51 +0800
Message-ID: <AANLkTi=1pXRDLc6Mzw_iV-V=XYrJe-=_xZM_OP1L682R@mail.gmail.com>
References: <20100726080448.476781076@vergenet.net>
	<20100726080646.244663698@vergenet.net>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:sender:received
         :in-reply-to:references:date:x-google-sender-auth:message-id:subject
         :from:to:cc:content-type:content-transfer-encoding;
        bh=lB33ip295iBlHNO0gjSHJ3KFn366PRtAp+vfBt8tGS8=;
        b=RnTNJiF0Bt87fRHv3veNpFMYCaZsRe2H2xXvurN7j7aTLI+0uexgN0Eu6U7dwcWzjr
         maFPxuQ0Y70wB9Jk5T4vxhNU7SmuXO3Dhb7XOjpXP775AUijDKK+DuYqKPrxtIV9XAc6
         Ok+sqXZAyDmR4bS/wBnd8cg+L962b/IIR1EGE=
In-Reply-To: <20100726080646.244663698@vergenet.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Nick Chalk <nick@loadbalancer.org>

Applied, thanks!

On Mon, Jul 26, 2010 at 4:04 PM, Simon Horman <horms@verge.net.au> wrot=
e:
> I think that this significantly aids in the management of
> these values while leaving all valid shortopts available as 'val' ent=
ries.
>
> Signed-off-by: Simon Horman <horms@verge.net.au>
>
> Index: trunk/ipvsadm.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- trunk.orig/ipvsadm.c =A0 =A0 =A0 =A02010-07-25 21:53:57.000000000=
 +0900
> +++ trunk/ipvsadm.c =A0 =A0 2010-07-25 21:54:41.000000000 +0900
> @@ -264,6 +264,23 @@ struct ipvs_command_entry {
> =A0 =A0 =A0 =A0ipvs_daemon_t =A0 =A0 =A0 =A0 =A0 daemon;
> =A0};
>
> +/* Use values outside ASCII range so that if an option has
> + * a short name it can be used as the tag
> + */
> +enum {
> + =A0 =A0 =A0 TAG_SET =3D 128,
> + =A0 =A0 =A0 TAG_START_DAEMON,
> + =A0 =A0 =A0 TAG_STOP_DAEMON ,
> + =A0 =A0 =A0 TAG_MCAST_INTERFACE,
> + =A0 =A0 =A0 TAG_TIMEOUT,
> + =A0 =A0 =A0 TAG_DAEMON,
> + =A0 =A0 =A0 TAG_STATS,
> + =A0 =A0 =A0 TAG_RATE,
> + =A0 =A0 =A0 TAG_THRESHOLDS,
> + =A0 =A0 =A0 TAG_PERSISTENTCONN,
> + =A0 =A0 =A0 TAG_SORT,
> + =A0 =A0 =A0 TAG_NO_SORT,
> +};
>
> =A0/* various parsing helpers & parsing functions */
> =A0static int str_is_digit(const char *str);
> @@ -353,15 +370,15 @@ parse_options(int argc, char **argv, str
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0{ "add-server", 'a', POPT_ARG_NONE, NU=
LL, 'a', NULL, NULL },
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0{ "edit-server", 'e', POPT_ARG_NONE, N=
ULL, 'e', NULL, NULL },
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0{ "delete-server", 'd', POPT_ARG_NONE,=
 NULL, 'd', NULL, NULL },
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "set", '\0', POPT_ARG_NONE, NULL, '4'=
, NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "set", '\0', POPT_ARG_NONE, NULL, TAG=
_SET, NULL, NULL },
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0{ "help", 'h', POPT_ARG_NONE, NULL, 'h=
', NULL, NULL },
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0{ "version", 'v', POPT_ARG_NONE, NULL,=
 'v', NULL, NULL },
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0{ "restore", 'R', POPT_ARG_NONE, NULL,=
 'R', NULL, NULL },
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0{ "save", 'S', POPT_ARG_NONE, NULL, 'S=
', NULL, NULL },
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "start-daemon", '\0', POPT_ARG_STRING=
, &optarg, '1',
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NULL, NULL },
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "stop-daemon", '\0', POPT_ARG_STRING,=
 &optarg, '2',
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "start-daemon", '\0', POPT_ARG_STRING=
, &optarg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 TAG_START_DAEMON, NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "stop-daemon", '\0', POPT_ARG_STRING,=
 &optarg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 TAG_STOP_DAEMON, NULL, NULL },
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0{ "tcp-service", 't', POPT_ARG_STRING,=
 &optarg, 't',
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NULL, NULL },
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0{ "udp-service", 'u', POPT_ARG_STRING,=
 &optarg, 'u',
> @@ -384,20 +401,23 @@ parse_options(int argc, char **argv, str
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NULL, NULL },
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0{ "numeric", 'n', POPT_ARG_NONE, NULL,=
 'n', NULL, NULL },
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0{ "connection", 'c', POPT_ARG_NONE, NU=
LL, 'c', NULL, NULL },
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "mcast-interface", '\0', POPT_ARG_STR=
ING, &optarg, '3',
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "mcast-interface", '\0', POPT_ARG_STR=
ING, &optarg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 TAG_MCAST_INTERFACE, NULL, NULL },
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0{ "syncid", '\0', POPT_ARG_STRING, &op=
targ, 'I', NULL, NULL },
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "timeout", '\0', POPT_ARG_NONE, NULL,=
 '5', NULL, NULL },
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "daemon", '\0', POPT_ARG_NONE, NULL, =
'6', NULL, NULL },
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "stats", '\0', POPT_ARG_NONE, NULL, '=
7', NULL, NULL },
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "rate", '\0', POPT_ARG_NONE, NULL, '8=
', NULL, NULL },
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "thresholds", '\0', POPT_ARG_NONE, NU=
LL, '9', NULL, NULL },
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "persistent-conn", '\0', POPT_ARG_NON=
E, NULL, 'P',
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "timeout", '\0', POPT_ARG_NONE, NULL,=
 TAG_TIMEOUT,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NULL, NULL },
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "nosort", '\0', POPT_ARG_NONE, NULL, =
'0', NULL, NULL },
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "sort", '\0', POPT_ARG_NONE, NULL, 'o=
', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "daemon", '\0', POPT_ARG_NONE, NULL, =
TAG_DAEMON, NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "stats", '\0', POPT_ARG_NONE, NULL, T=
AG_STATS, NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "rate", '\0', POPT_ARG_NONE, NULL, TA=
G_RATE, NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "thresholds", '\0', POPT_ARG_NONE, NU=
LL,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0TAG_THRESHOLDS, NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "persistent-conn", '\0', POPT_ARG_NON=
E, NULL,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 TAG_PERSISTENTCONN, NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "nosort", '\0', POPT_ARG_NONE, NULL,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0TAG_NO_SORT, NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "sort", '\0', POPT_ARG_NONE, NULL, TA=
G_SORT, NULL, NULL },
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0{ "exact", 'X', POPT_ARG_NONE, NULL, '=
X', NULL, NULL },
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "ipv6", '6', POPT_ARG_NONE, NULL, '%'=
, NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "ipv6", '6', POPT_ARG_NONE, NULL, '6'=
, NULL, NULL },
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0{ NULL, 0, 0, NULL, 0, NULL, NULL }
> =A0 =A0 =A0 =A0};
>
> @@ -436,7 +456,7 @@ parse_options(int argc, char **argv, str
> =A0 =A0 =A0 =A0case 'Z':
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_command(&ce->cmd, CMD_ZERO);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> - =A0 =A0 =A0 case '4':
> + =A0 =A0 =A0 case TAG_SET:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_command(&ce->cmd, CMD_TIMEOUT);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0case 'R':
> @@ -445,7 +465,7 @@ parse_options(int argc, char **argv, str
> =A0 =A0 =A0 =A0case 'S':
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_command(&ce->cmd, CMD_SAVE);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> - =A0 =A0 =A0 case '1':
> + =A0 =A0 =A0 case TAG_START_DAEMON:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_command(&ce->cmd, CMD_STARTDAEMON)=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!strcmp(optarg, "master"))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ce->daemon.state =3D I=
P_VS_STATE_MASTER;
> @@ -453,7 +473,7 @@ parse_options(int argc, char **argv, str
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ce->daemon.state =3D I=
P_VS_STATE_BACKUP;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else fail(2, "illegal start-daemon par=
ameter specified");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> - =A0 =A0 =A0 case '2':
> + =A0 =A0 =A0 case TAG_STOP_DAEMON:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_command(&ce->cmd, CMD_STOPDAEMON);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!strcmp(optarg, "master"))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ce->daemon.state =3D I=
P_VS_STATE_MASTER;
> @@ -568,7 +588,7 @@ parse_options(int argc, char **argv, str
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_option(options, OP=
T_NUMERIC);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*format |=3D FMT_NUMER=
IC;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case '3':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case TAG_MCAST_INTERFACE:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_option(options, OP=
T_MCAST);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0strncpy(ce->daemon.mca=
st_ifn,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0optarg=
, IP_VS_IFNAME_MAXLEN);
> @@ -579,40 +599,40 @@ parse_options(int argc, char **argv, str
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 string_to_num=
ber(optarg, 0, 255)) =3D=3D -1)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fail(2=
, "illegal syncid specified");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case '5':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case TAG_TIMEOUT:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_option(options, OP=
T_TIMEOUT);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case '6':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case TAG_DAEMON:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_option(options, OP=
T_DAEMON);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case '7':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case TAG_STATS:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_option(options, OP=
T_STATS);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*format |=3D FMT_STATS=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case '8':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case TAG_RATE:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_option(options, OP=
T_RATE);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*format |=3D FMT_RATE;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case '9':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case TAG_THRESHOLDS:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_option(options, OP=
T_THRESHOLDS);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*format |=3D FMT_THRES=
HOLDS;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case 'P':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case TAG_PERSISTENTCONN:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_option(options, OP=
T_PERSISTENTCONN);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*format |=3D FMT_PERSI=
STENTCONN;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case '0':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case TAG_NO_SORT:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_option(options, OP=
T_NOSORT =A0);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*format |=3D FMT_NOSOR=
T;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case 'o':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case TAG_SORT:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Sort is the default=
, this is a no-op for compatibility */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case 'X':
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_option(options, OP=
T_EXACT);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*format |=3D FMT_EXACT=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case '%':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case '6':
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ce->svc.fwmark) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ce->sv=
c.af =3D AF_INET6;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ce->sv=
c.netmask =3D 128;
>
>
