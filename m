From: Wensong Zhang <wensong@linux-vs.org>
Subject: Re: [patch 3/5] ipvsadm: Initialise descrip and argDescrip elements 
	of struct poptOption
Date: Tue, 27 Jul 2010 13:37:07 +0800
Message-ID: <AANLkTi=w_XBcPUNg6w9Y4cPuw_ddZqwV=ix3_yZAG5a-@mail.gmail.com>
References: <20100726080448.476781076@vergenet.net>
	<20100726080645.990677532@vergenet.net>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:mime-version:received:sender:received
         :in-reply-to:references:date:x-google-sender-auth:message-id:subject
         :from:to:cc:content-type:content-transfer-encoding;
        bh=hmuYnNEDrDAX6r/MaacUDGacKitz9waY4LP3W9yDeFM=;
        b=UhERLiD7E/+VecjDmug4IJ8QB1AX0UXQArDh14YK3s36SCi5DmORPrGj8OdJnij2cE
         U+Dx1LhgDwuAi3duH2oHHMBxhTKSX5kCrtdkdyghxhqmx4e6SgPhVzj6TsSfoaJTwaUQ
         lziqdjLkAp1Bi+brISxSRxDKvpDJ6VJaHjqxU=
In-Reply-To: <20100726080645.990677532@vergenet.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Nick Chalk <nick@loadbalancer.org>

Applied, thanks!

On Mon, Jul 26, 2010 at 4:04 PM, Simon Horman <horms@verge.net.au> wrot=
e:
> Signed-off-by: Simon Horman <horms@verge.net.au>
>
> Index: trunk/ipvsadm.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- trunk.orig/ipvsadm.c =A0 =A0 =A0 =A02010-07-26 17:00:07.000000000=
 +0900
> +++ trunk/ipvsadm.c =A0 =A0 2010-07-26 17:00:38.000000000 +0900
> @@ -343,52 +343,62 @@ parse_options(int argc, char **argv, str
> =A0 =A0 =A0 =A0poptContext context;
> =A0 =A0 =A0 =A0char *optarg=3DNULL;
> =A0 =A0 =A0 =A0struct poptOption options_table[] =3D {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"add-service", 'A', POPT_ARG_NONE, NUL=
L, 'A'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"edit-service", 'E', POPT_ARG_NONE, NU=
LL, 'E'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"delete-service", 'D', POPT_ARG_NONE, =
NULL, 'D'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"clear", 'C', POPT_ARG_NONE, NULL, 'C'=
},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"list", 'L', POPT_ARG_NONE, NULL, 'L'}=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"list", 'l', POPT_ARG_NONE, NULL, 'l'}=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"zero", 'Z', POPT_ARG_NONE, NULL, 'Z'}=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"add-server", 'a', POPT_ARG_NONE, NULL=
, 'a'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"edit-server", 'e', POPT_ARG_NONE, NUL=
L, 'e'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"delete-server", 'd', POPT_ARG_NONE, N=
ULL, 'd'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"set", '\0', POPT_ARG_NONE, NULL, '4'}=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"help", 'h', POPT_ARG_NONE, NULL, 'h'}=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"version", 'v', POPT_ARG_NONE, NULL, '=
v'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"restore", 'R', POPT_ARG_NONE, NULL, '=
R'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"save", 'S', POPT_ARG_NONE, NULL, 'S'}=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"start-daemon", '\0', POPT_ARG_STRING,=
 &optarg, '1'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"stop-daemon", '\0', POPT_ARG_STRING, =
&optarg, '2'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"tcp-service", 't', POPT_ARG_STRING, &=
optarg, 't'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"udp-service", 'u', POPT_ARG_STRING, &=
optarg, 'u'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"fwmark-service", 'f', POPT_ARG_STRING=
, &optarg, 'f'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"scheduler", 's', POPT_ARG_STRING, &op=
targ, 's'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"persistent", 'p', POPT_ARG_STRING|POP=
T_ARGFLAG_OPTIONAL,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&optarg, 'p'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"netmask", 'M', POPT_ARG_STRING, &opta=
rg, 'M'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"real-server", 'r', POPT_ARG_STRING, &=
optarg, 'r'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"masquerading", 'm', POPT_ARG_NONE, NU=
LL, 'm'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"ipip", 'i', POPT_ARG_NONE, NULL, 'i'}=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"gatewaying", 'g', POPT_ARG_NONE, NULL=
, 'g'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"weight", 'w', POPT_ARG_STRING, &optar=
g, 'w'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"u-threshold", 'x', POPT_ARG_STRING, &=
optarg, 'x'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"l-threshold", 'y', POPT_ARG_STRING, &=
optarg, 'y'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"numeric", 'n', POPT_ARG_NONE, NULL, '=
n'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"connection", 'c', POPT_ARG_NONE, NULL=
, 'c'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"mcast-interface", '\0', POPT_ARG_STRI=
NG, &optarg, '3'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"syncid", '\0', POPT_ARG_STRING, &opta=
rg, 'I'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"timeout", '\0', POPT_ARG_NONE, NULL, =
'5'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"daemon", '\0', POPT_ARG_NONE, NULL, '=
6'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"stats", '\0', POPT_ARG_NONE, NULL, '7=
'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"rate", '\0', POPT_ARG_NONE, NULL, '8'=
},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"thresholds", '\0', POPT_ARG_NONE, NUL=
L, '9'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"persistent-conn", '\0', POPT_ARG_NONE=
, NULL, 'P'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"nosort", '\0', POPT_ARG_NONE, NULL, '=
0'},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"sort", '\0', POPT_ARG_NONE, NULL, 'o'=
},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"exact", 'X', POPT_ARG_NONE, NULL, 'X'=
},
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {"ipv6", '6', POPT_ARG_NONE, NULL, '%'}=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 {NULL, 0, 0, NULL, 0}
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "add-service", 'A', POPT_ARG_NONE, NU=
LL, 'A', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "edit-service", 'E', POPT_ARG_NONE, N=
ULL, 'E', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "delete-service", 'D', POPT_ARG_NONE,=
 NULL, 'D', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "clear", 'C', POPT_ARG_NONE, NULL, 'C=
', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "list", 'L', POPT_ARG_NONE, NULL, 'L'=
, NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "list", 'l', POPT_ARG_NONE, NULL, 'l'=
, NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "zero", 'Z', POPT_ARG_NONE, NULL, 'Z'=
, NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "add-server", 'a', POPT_ARG_NONE, NUL=
L, 'a', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "edit-server", 'e', POPT_ARG_NONE, NU=
LL, 'e', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "delete-server", 'd', POPT_ARG_NONE, =
NULL, 'd', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "set", '\0', POPT_ARG_NONE, NULL, '4'=
, NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "help", 'h', POPT_ARG_NONE, NULL, 'h'=
, NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "version", 'v', POPT_ARG_NONE, NULL, =
'v', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "restore", 'R', POPT_ARG_NONE, NULL, =
'R', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "save", 'S', POPT_ARG_NONE, NULL, 'S'=
, NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "start-daemon", '\0', POPT_ARG_STRING=
, &optarg, '1',
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "stop-daemon", '\0', POPT_ARG_STRING,=
 &optarg, '2',
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "tcp-service", 't', POPT_ARG_STRING, =
&optarg, 't',
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "udp-service", 'u', POPT_ARG_STRING, =
&optarg, 'u',
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "fwmark-service", 'f', POPT_ARG_STRIN=
G, &optarg, 'f',
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "scheduler", 's', POPT_ARG_STRING, &o=
ptarg, 's', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "persistent", 'p', POPT_ARG_STRING|PO=
PT_ARGFLAG_OPTIONAL,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&optarg, 'p', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "netmask", 'M', POPT_ARG_STRING, &opt=
arg, 'M', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "real-server", 'r', POPT_ARG_STRING, =
&optarg, 'r',
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "masquerading", 'm', POPT_ARG_NONE, N=
ULL, 'm', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "ipip", 'i', POPT_ARG_NONE, NULL, 'i'=
, NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "gatewaying", 'g', POPT_ARG_NONE, NUL=
L, 'g', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "weight", 'w', POPT_ARG_STRING, &opta=
rg, 'w', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "u-threshold", 'x', POPT_ARG_STRING, =
&optarg, 'x',
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "l-threshold", 'y', POPT_ARG_STRING, =
&optarg, 'y',
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "numeric", 'n', POPT_ARG_NONE, NULL, =
'n', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "connection", 'c', POPT_ARG_NONE, NUL=
L, 'c', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "mcast-interface", '\0', POPT_ARG_STR=
ING, &optarg, '3',
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "syncid", '\0', POPT_ARG_STRING, &opt=
arg, 'I', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "timeout", '\0', POPT_ARG_NONE, NULL,=
 '5', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "daemon", '\0', POPT_ARG_NONE, NULL, =
'6', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "stats", '\0', POPT_ARG_NONE, NULL, '=
7', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "rate", '\0', POPT_ARG_NONE, NULL, '8=
', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "thresholds", '\0', POPT_ARG_NONE, NU=
LL, '9', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "persistent-conn", '\0', POPT_ARG_NON=
E, NULL, 'P',
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "nosort", '\0', POPT_ARG_NONE, NULL, =
'0', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "sort", '\0', POPT_ARG_NONE, NULL, 'o=
', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "exact", 'X', POPT_ARG_NONE, NULL, 'X=
', NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { "ipv6", '6', POPT_ARG_NONE, NULL, '%'=
, NULL, NULL },
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 { NULL, 0, 0, NULL, 0, NULL, NULL }
> =A0 =A0 =A0 =A0};
>
> =A0 =A0 =A0 =A0context =3D poptGetContext("ipvsadm", argc, (const cha=
r **)argv,
>
>
