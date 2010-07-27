From: Wensong Zhang <wensong@linux-vs.org>
Subject: Re: [patch 5/5] ipvsadm: one-packet scheduling
Date: Tue, 27 Jul 2010 13:49:01 +0800
Message-ID: <AANLkTinQNr6mWS4s6Qa1N0adbV7t+LTYOOD=hcz1Wc4T@mail.gmail.com>
References: <20100726080448.476781076@vergenet.net>
	<20100726080646.517901560@vergenet.net>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:sender:received
         :in-reply-to:references:date:x-google-sender-auth:message-id:subject
         :from:to:cc:content-type:content-transfer-encoding;
        bh=bCmh938uzQ+a42T/mrDDx0IqgiRlXfEz/gh7RQOj+AA=;
        b=lQiIV2dxzwDR6HW4PECzx386XHc63PQC0HtWeJWAPdbx7l0sQNkuUiz2yyNKWRWTqX
         cCPcEEH6dhnENbgNKWvf8IIGZMh74P6xXsIaBVyQiYfCFdM2Jr9253LDn273hwfdrLD5
         5NSHyGaWSQih3uPeDgX27JUcCSRTFpHdpygzM=
In-Reply-To: <20100726080646.517901560@vergenet.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Nick Chalk <nick@loadbalancer.org>

Applied, thanks!

On Mon, Jul 26, 2010 at 4:04 PM, Simon Horman <horms@verge.net.au> wrot=
e:
> Allow one-packet scheduling for UDP connections. When the fwmark-base=
d or
> normal virtual service is marked with '-o' or '--ops' options all
> connections are created only to schedule one packet. Useful to schedu=
le UDP
> packets from same client port to different real servers. Recommended =
with
> RR or WRR schedulers (the connections are not visible with ipvsadm -L=
).
>
> The kernel side of this change has already been merged
> and should appear in 2.6.35.
>
> Based on http://www.ssi.bg/~ja/tmp/ops-ipvsadm-1.21-1.diff
> by Julian Anastasov <ja@ssi.bg>
>
> Signed-off-by: Simon Horman <horms@verge.net.au>
>
> Index: trunk/ipvsadm.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- trunk.orig/ipvsadm.c =A0 =A0 =A0 =A02010-07-25 21:01:02.000000000=
 +0900
> +++ trunk/ipvsadm.c =A0 =A0 2010-07-25 21:01:04.000000000 +0900
> @@ -180,7 +180,8 @@ static const char* cmdnames[] =3D {
> =A0#define OPT_NOSORT =A0 =A0 =A0 =A0 =A0 =A0 0x040000
> =A0#define OPT_SYNCID =A0 =A0 =A0 =A0 =A0 =A0 0x080000
> =A0#define OPT_EXACT =A0 =A0 =A0 =A0 =A0 =A0 =A00x100000
> -#define NUMBER_OF_OPT =A0 =A0 =A0 =A0 =A021
> +#define OPT_ONEPACKET =A0 =A0 =A0 =A0 =A00x200000
> +#define NUMBER_OF_OPT =A0 =A0 =A0 =A0 =A022
>
> =A0static const char* optnames[] =3D {
> =A0 =A0 =A0 =A0"numeric",
> @@ -204,6 +205,7 @@ static const char* optnames[] =3D {
> =A0 =A0 =A0 =A0"nosort",
> =A0 =A0 =A0 =A0"syncid",
> =A0 =A0 =A0 =A0"exact",
> + =A0 =A0 =A0 "ops",
> =A0};
>
> =A0/*
> @@ -418,6 +420,7 @@ parse_options(int argc, char **argv, str
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0{ "sort", '\0', POPT_ARG_NONE, NULL, T=
AG_SORT, NULL, NULL },
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0{ "exact", 'X', POPT_ARG_NONE, NULL, '=
X', NULL, NULL },
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0{ "ipv6", '6', POPT_ARG_NONE, NULL, '6=
', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "ops", 'o', POPT_ARG_NONE, NULL, 'o',=
 NULL, NULL },
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0{ NULL, 0, 0, NULL, 0, NULL, NULL }
> =A0 =A0 =A0 =A0};
>
> @@ -520,7 +523,7 @@ parse_options(int argc, char **argv, str
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case 'p':
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_option(options, OP=
T_PERSISTENT);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ce->svc.flags =3D IP_VS=
_SVC_F_PERSISTENT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ce->svc.flags |=3D IP_V=
S_SVC_F_PERSISTENT;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ce->svc.timeout =3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0parse_=
timeout(optarg, 1, MAX_TIMEOUT);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> @@ -640,6 +643,10 @@ parse_options(int argc, char **argv, str
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fail(2=
, "-6 used before -f\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case 'o':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_option(options, OPT=
_ONEPACKET);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ce->svc.flags |=3D IP_V=
S_SVC_F_ONEPACKET;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0default:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fail(2, "invalid optio=
n `%s'",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 poptBadOption=
(context, POPT_BADOPTION_NOALIAS));
> @@ -725,10 +732,15 @@ static int process_options(int argc, cha
> =A0 =A0 =A0 =A0if (ce.cmd =3D=3D CMD_ADD || ce.cmd =3D=3D CMD_EDIT) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Make sure that port zero service is=
 persistent */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!ce.svc.fwmark && !ce.svc.port &&
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (ce.svc.flags !=3D IP_VS_SVC_F_=
PERSISTENT))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !(ce.svc.flags & IP_VS_SVC_F_PE=
RSISTENT))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fail(2, "Zero port spe=
cified "
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "for non-pers=
istent service");
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ce.svc.flags & IP_VS_SVC_F_ONEPACKE=
T &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !ce.svc.fwmark && ce.svc.protoc=
ol !=3D IPPROTO_UDP)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fail(2, "One-Packet Sch=
eduling is only "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"for UDP vir=
tual services");
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Set the default scheduling algorith=
m if not specified */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (strlen(ce.svc.sched_name) =3D=3D 0=
)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0strcpy(ce.svc.sched_na=
me, DEF_SCHED);
> @@ -1116,6 +1128,7 @@ static void usage_exit(const char *progr
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0" =A0--persistent-conn =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 output of persistent connection info\n"
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0" =A0--nosort =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0disable sorting output of service/server=
 entries\n"
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0" =A0--sort =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0does nothing, for backwards compatibili=
ty\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 " =A0--ops =A0 =A0 =A0 =A0 =A0-o =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 one-packet scheduling\n"
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0" =A0--numeric =A0 =A0 =A0-n =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 numeric output of addresses and ports\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DEF_SCHED);
>
> @@ -1448,6 +1461,8 @@ print_service_entry(ipvs_service_entry_t
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0printf(" -M %i", se->netmask);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (se->flags & IP_VS_SVC_F_ONEPACKET)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printf(" ops");
> =A0 =A0 =A0 =A0} else if (format & FMT_STATS) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printf("%-33s", svc_name);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0print_largenum(se->stats.conns, format=
);
> @@ -1475,6 +1490,8 @@ print_service_entry(ipvs_service_entry_t
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (se->af =3D=3D AF_I=
NET6)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (se=
->netmask !=3D 128)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0printf(" mask %i", se->netmask);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (se->flags & IP_VS_S=
VC_F_ONEPACKET)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printf(=
" ops");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0printf("\n");
> Index: trunk/libipvs/ip_vs.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- trunk.orig/libipvs/ip_vs.h =A02010-07-25 20:58:51.000000000 +0900
> +++ trunk/libipvs/ip_vs.h =A0 =A0 =A0 2010-07-25 21:01:04.000000000 +=
0900
> @@ -28,6 +28,7 @@
> =A0*/
> =A0#define IP_VS_SVC_F_PERSISTENT 0x0001 =A0 =A0 =A0 =A0 =A0/* persis=
tent port */
> =A0#define IP_VS_SVC_F_HASHED =A0 =A0 0x0002 =A0 =A0 =A0 =A0 =A0/* ha=
shed entry */
> +#define IP_VS_SVC_F_ONEPACKET =A00x0004 =A0 =A0 =A0 =A0 =A0/* one-pa=
cket scheduling */
>
> =A0/*
> =A0* =A0 =A0 =A0IPVS sync daemon states
> @@ -88,6 +89,7 @@
> =A0#define IP_VS_CONN_F_SEQ_MASK =A00x0600 =A0 =A0 =A0 =A0 =A0/* in/o=
ut sequence mask */
> =A0#define IP_VS_CONN_F_NO_CPORT =A00x0800 =A0 =A0 =A0 =A0 =A0/* no c=
lient port set yet */
> =A0#define IP_VS_CONN_F_TEMPLATE =A00x1000 =A0 =A0 =A0 =A0 =A0/* temp=
late, not connection */
> +#define IP_VS_CONN_F_ONE_PACKET =A0 =A0 =A0 =A00x2000 =A0 =A0 =A0 =A0=
 =A0/* forward only one packet */
>
> =A0#define IP_VS_SCHEDNAME_MAXLEN 16
> =A0#define IP_VS_IFNAME_MAXLEN =A0 =A016
> Index: trunk/ipvsadm.8
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- trunk.orig/ipvsadm.8 =A0 =A0 =A0 =A02010-07-25 21:01:08.000000000=
 +0900
> +++ trunk/ipvsadm.8 =A0 =A0 2010-07-25 21:04:03.000000000 +0900
> @@ -414,6 +414,12 @@ option is only relevant for the -L comma
> =A0.TP
> =A0.B -6, --ipv6
> =A0Use with -f to signify fwmark rule uses IPv6 addresses.
> +.TP
> +.B -o, --ops
> +One-packet scheduling.
> +Used in conjunction with a UDP virtual service or
> +a fwmark virtual service that handles only UDP packets.
> +All connections are created such that they only schedule one packet.
> =A0.SH EXAMPLE 1 - Simple Virtual Service
> =A0The following commands configure a Linux Director to distribute
> =A0incoming requests addressed to port 80 on 207.175.44.110 equally t=
o
>
>
