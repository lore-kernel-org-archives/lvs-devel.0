From: support@remsnet.de
Subject: Aw: [lvs-users] [PATCH] ipvsadm: add SCTP support
Date: Thu, 5 Feb 2015 21:55:12 +0100
Message-ID: <trinity-52eb73c8-bae2-44a8-acf1-b85fa331b003-1423169712697@3capp-webde-bs38>
References: <1422693668-25736-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary=sgnirkm-65d7c092-179f-4040-aed6-cb89d063d3ae
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1422693668-25736-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: logan@ubuntu.com, mt@suse.de
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, Simon Horman <horms@verge.net.au>, overcastsky.zhao@gmail.com, formorer@debian.org

--sgnirkm-65d7c092-179f-4040-aed6-cb89d063d3ae
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Dear Julian & Simon ,

Please Include this "ipvsadm: add SCTP support" patch and any outstaning p=
atches=20
at the  https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git .

Please Simon ;
I=C2=B4ts time for new release of ipvsadm .. 2 years passed allready with =
an few important patches added to ipvsadm 1.27.

I can=C2=B4t understand why Debian , Suse , FC / Redhat  and it=C2=B4s clo=
nes Distrubtions still publish the buggy ipvsadm 1.26 .

Today faced again issue on very Highly traffik PRODUCTIVE shop site with D=
ebian 7.8 with IPVS, keepalived and outdated ipvsadm
 due that  - caused an Customer emergency Firecall ..

Please please dear Distribution Maintainers -  UPDATE from the Offial  ipv=
sadm GIT repro .
Thanks.


--
Mit freundlichen Gr=C3=BC=C3=9Fen / Best Regards

Horst Venzke ; PGP NET : 1024G/082F2E6D ;  http://www.remsnet.de

Legal Notice: This transmittal and/or attachments may be privileged or con=
fidential. It is intended solely for the addressee named above. Any review,=
 dissemination, or copying is strictly prohibited. If you received this tra=
nsmittal in error, please notify us immediately by reply and immediately de=
lete this message and all its attachments. Thank you.


> Gesendet: Samstag, 31. Januar 2015 um 09:41 Uhr
> Von: "Julian Anastasov" <ja@ssi.bg>
> An: "Jesper Dangaard Brouer" <brouer@redhat.com>
> Cc: lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, "Simon =
Horman" <horms@verge.net.au>, overcastsky.zhao@gmail.com
> Betreff: [lvs-users] [PATCH] ipvsadm: add SCTP support
>
> SCTP support in kernel is from 2.6.34 but ipvsadm
> restricts users to fwmark-based virtual services.
>=20
> * Add option --sctp-service to specify the virtual service
>=20
> * Update man page to use virtual-service and the new option
>=20
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  ipvsadm.8 |  30 +++++++++++--------
>  ipvsadm.c | 100 +++++++++++++++++++++++++++++++++++++++++++++++++------=
-------
>  2 files changed, 98 insertions(+), 32 deletions(-)
>=20
> diff --git a/ipvsadm.8 b/ipvsadm.8
> index 9a9e9b3..3df3b83 100644
> --- a/ipvsadm.8
> +++ b/ipvsadm.8
> @@ -35,11 +35,11 @@
>  .SH NAME
>  ipvsadm \- Linux Virtual Server administration
>  .SH SYNOPSIS
> -.B ipvsadm -A|E -t|u|f \fIservice-address\fP [-s \fIscheduler\fP]
> +.B ipvsadm -A|E \fIvirtual-service\fP [-s \fIscheduler\fP]
>  .ti 15
>  .B [-p [\fItimeout\fP]] [-M \fInetmask\fP] [-b \fIsched-flags\fP]
>  .br
> -.B ipvsadm -D -t|u|f \fIservice-address\fP
> +.B ipvsadm -D \fIvirtual-service\fP
>  .br
>  .B ipvsadm -C
>  .br
> @@ -47,15 +47,15 @@ ipvsadm \- Linux Virtual Server administration
>  .br
>  .B ipvsadm -S [-n]
>  .br
> -.B ipvsadm -a|e -t|u|f \fIservice-address\fP -r \fIserver-address\fP
> +.B ipvsadm -a|e \fIvirtual-service\fP -r \fIserver-address\fP
>  .ti 15
>  .B [-g|i|m] [-w \fIweight\fP] [-x \fIupper\fP] [-y \fIlower\fP]
>  .br
> -.B ipvsadm -d -t|u|f \fIservice-address\fP -r \fIserver-address\fP
> +.B ipvsadm -d \fIvirtual-service\fP -r \fIserver-address\fP
>  .br
> -.B ipvsadm -L|l [options]
> +.B ipvsadm -L|l [\fIvirtual-service\fP] [options]
>  .br
> -.B ipvsadm -Z [-t|u|f \fIservice-address\fP]
> +.B ipvsadm -Z [\fIvirtual-service\fP]
>  .br
>  .B ipvsadm --set \fItcp\fP \fItcpfin\fP \fIudp\fP
>  .br
> @@ -72,7 +72,7 @@ server table in the Linux kernel. The Linux Virtual Se=
rver can be used
>  to build scalable network services based on a cluster of two or more
>  nodes. The active node of the cluster redirects service requests to a
>  collection of server hosts that will actually perform the
> -services. Supported features include two protocols (TCP and UDP),
> +services. Supported features include three protocols (TCP, UDP and SCTP=
),
>  three packet-forwarding methods (NAT, tunneling, and direct routing),
>  and eight load balancing algorithms (round robin, weighted round
>  robin, least-connection, weighted least-connection, locality-based
> @@ -81,11 +81,11 @@ destination-hashing, and source-hashing).
>  .PP
>  The command has two basic formats for execution:
>  .TP
> -.B ipvsadm \fICOMMAND\fP [\fIprotocol\fP] \fIservice-address\fP
> +.B ipvsadm \fICOMMAND\fP \fIvirtual-service\fP
>  .ti 15
>  .B [\fIscheduling-method\fP] [\fIpersistence options\fP]
>  .TP
> -.B ipvsadm \fIcommand\fP [\fIprotocol\fP] \fIservice-address\fP
> +.B ipvsadm \fIcommand\fP \fIvirtual-service\fP
>  .ti 15
>  .B \fIserver-address\fP [\fIpacket-forwarding-method\fP]
>  .ti 15
> @@ -174,9 +174,8 @@ Stop the connection synchronization daemon.
>  .TP
>  \fB-h, --help\fR
>  Display a description of the command syntax.
> -.SS PARAMETERS
> -The commands above accept or require zero or more of the following
> -parameters.
> +.SS virtual-service
> +Specifies the virtual service based on protocol/addr/port or firewall m=
ark.
>  .TP
>  .B -t, --tcp-service \fIservice-address\fP
>  Use TCP service. The \fIservice-address\fP is of the form
> @@ -191,6 +190,10 @@ wild-card port, that is connections will be accepte=
d to any port.
>  Use UDP service. See the -t|--tcp-service for the description of  the
>  \fIservice-address\fP.
>  .TP
> +.B --sctp-service \fIservice-address\fP
> +Use SCTP service. See the -t|--tcp-service for the description of the
> +\fIservice-address\fP.
> +.TP
>  .B -f, --fwmark-service \fIinteger\fP
>  Use a firewall-mark, an integer value greater than zero, to denote a
>  virtual service instead of an address, port and protocol (UDP or
> @@ -206,6 +209,9 @@ single virtual service. This is useful for both simp=
lifying
>  configuration if a large number of virtual services are required and
>  grouping persistence across what would otherwise be multiple virtual
>  services.
> +.SS PARAMETERS
> +The commands above accept or require zero or more of the following
> +parameters.
>  .TP
>  .B -s, --scheduler \fIscheduling-method\fP
>  \fIscheduling-method\fP  Algorithm for allocating TCP connections and
> diff --git a/ipvsadm.c b/ipvsadm.c
> index a33ecfa..1669634 100644
> --- a/ipvsadm.c
> +++ b/ipvsadm.c
> @@ -287,6 +287,7 @@ enum {
>  	TAG_SORT,
>  	TAG_NO_SORT,
>  	TAG_PERSISTENCE_ENGINE,
> +	TAG_SCTP_SERVICE,
>  };
> =20
>  /* various parsing helpers & parsing functions */
> @@ -359,6 +360,47 @@ int main(int argc, char **argv)
>  	return result;
>  }
> =20
> +static int option_to_protocol(int opt)
> +{
> +	switch (opt) {
> +	case 't':
> +		return IPPROTO_TCP;
> +	case 'u':
> +		return IPPROTO_UDP;
> +	case TAG_SCTP_SERVICE:
> +		return IPPROTO_SCTP;
> +	default:
> +		return IPPROTO_IP;
> +	}
> +}
> +
> +static char *option_from_protocol(int proto)
> +{
> +	switch (proto) {
> +	case IPPROTO_TCP:
> +		return "-t";
> +	case IPPROTO_UDP:
> +		return "-u";
> +	case IPPROTO_SCTP:
> +		return "--sctp-service";
> +	default:
> +		return NULL;
> +	}
> +}
> +
> +static char *protocol_name(int proto)
> +{
> +	switch (proto) {
> +	case IPPROTO_TCP:
> +		return "TCP";
> +	case IPPROTO_UDP:
> +		return "UDP";
> +	case IPPROTO_SCTP:
> +		return "SCTP";
> +	default:
> +		return "?";
> +	}
> +}
> =20
>  static int
>  parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
> @@ -391,6 +433,8 @@ parse_options(int argc, char **argv, struct ipvs_com=
mand_entry *ce,
>  		  NULL, NULL },
>  		{ "udp-service", 'u', POPT_ARG_STRING, &optarg, 'u',
>  		  NULL, NULL },
> +		{ "sctp-service", '\0', POPT_ARG_STRING, &optarg,
> +		  TAG_SCTP_SERVICE, NULL, NULL },
>  		{ "fwmark-service", 'f', POPT_ARG_STRING, &optarg, 'f',
>  		  NULL, NULL },
>  		{ "scheduler", 's', POPT_ARG_STRING, &optarg, 's', NULL, NULL },
> @@ -510,9 +554,9 @@ parse_options(int argc, char **argv, struct ipvs_com=
mand_entry *ce,
>  		switch (c) {
>  		case 't':
>  		case 'u':
> +		case TAG_SCTP_SERVICE:
>  			set_option(options, OPT_SERVICE);
> -			ce->svc.protocol =3D
> -				(c=3D=3D't' ? IPPROTO_TCP : IPPROTO_UDP);
> +			ce->svc.protocol =3D option_to_protocol(c);
>  			parse =3D parse_service(optarg, &ce->svc);
>  			if (!(parse & SERVICE_ADDR))
>  				fail(2, "illegal virtual server "
> @@ -1128,15 +1172,15 @@ static void usage_exit(const char *program, cons=
t int exit_status)
>  	version(stream);
>  	fprintf(stream,
>  		"Usage:\n"
> -		"  %s -A|E -t|u|f service-address [-s scheduler] [-p [timeout]] [-M n=
etmask] [--pe persistence_engine] [-b sched-flags]\n"
> -		"  %s -D -t|u|f service-address\n"
> +		"  %s -A|E virtual-service [-s scheduler] [-p [timeout]] [-M netmask]=
 [--pe persistence_engine] [-b sched-flags]\n"
> +		"  %s -D virtual-service\n"
>  		"  %s -C\n"
>  		"  %s -R\n"
>  		"  %s -S [-n]\n"
> -		"  %s -a|e -t|u|f service-address -r server-address [options]\n"
> -		"  %s -d -t|u|f service-address -r server-address\n"
> -		"  %s -L|l [options]\n"
> -		"  %s -Z [-t|u|f service-address]\n"
> +		"  %s -a|e virtual-service -r server-address [options]\n"
> +		"  %s -d virtual-service -r server-address\n"
> +		"  %s -L|l [virtual-service] [options]\n"
> +		"  %s -Z [virtual-service]\n"
>  		"  %s --set tcp tcpfin udp\n"
>  		"  %s --start-daemon state [--mcast-interface interface] [--syncid si=
d]\n"
>  		"  %s --stop-daemon state\n"
> @@ -1166,10 +1210,15 @@ static void usage_exit(const char *program, cons=
t int exit_status)
>  		);
> =20
>  	fprintf(stream,
> +		"virtual-service:\n"
> +		"  --tcp-service|-t  service-address   service-address is host[:port]=
\n"
> +		"  --udp-service|-u  service-address   service-address is host[:port]=
\n"
> +		"  --sctp-service    service-address   service-address is host[:port]=
\n"
> +		"  --fwmark-service|-f fwmark          fwmark is an integer greater t=
han zero\n"
> +		"\n");
> +
> +	fprintf(stream,
>  		"Options:\n"
> -		"  --tcp-service  -t service-address   service-address is host[:port]=
\n"
> -		"  --udp-service  -u service-address   service-address is host[:port]=
\n"
> -		"  --fwmark-service  -f fwmark         fwmark is an integer greater t=
han zero\n"
>  		"  --ipv6         -6                   fwmark entry uses IPv6\n"
>  		"  --scheduler    -s scheduler         one of " SCHEDULERS ",\n"
>  		"                                      the default scheduler is %s.\n=
"
> @@ -1316,6 +1365,8 @@ static void print_conn(char *buf, unsigned int for=
mat)
>  		proto =3D IPPROTO_TCP;
>  	else if (strcmp(protocol, "UDP") =3D=3D 0)
>  		proto =3D IPPROTO_UDP;
> +	else if (strcmp(protocol, "SCTP") =3D=3D 0)
> +		proto =3D IPPROTO_SCTP;
>  	else
>  		proto =3D 0;
> =20
> @@ -1518,7 +1569,7 @@ static void
>  print_service_entry(ipvs_service_entry_t *se, unsigned int format)
>  {
>  	struct ip_vs_get_dests *d;
> -	char svc_name[64];
> +	char svc_name[1024];
>  	int i;
> =20
>  	if (!(d =3D ipvs_get_dests(se))) {
> @@ -1543,14 +1594,17 @@ print_service_entry(ipvs_service_entry_t *se, un=
signed int format)
>  		if (!(vname =3D addrport_to_anyname(se->af, &se->addr, ntohs(se->port=
),
>  						  se->protocol, format)))
>  			fail(2, "addrport_to_anyname: %s", strerror(errno));
> -		if (format & FMT_RULE)
> -			sprintf(svc_name, "%s %s",
> -				se->protocol=3D=3DIPPROTO_TCP?"-t":"-u",
> -				vname);
> -		else {
> -			sprintf(svc_name, "%s  %s",
> -				se->protocol=3D=3DIPPROTO_TCP?"TCP":"UDP",
> -				vname);
> +		if (format & FMT_RULE) {
> +			char *stype =3D option_from_protocol(se->protocol) ? :
> +				      "--xxx-service";
> +
> +			snprintf(svc_name, sizeof(svc_name), "%s %s",
> +				 stype, vname);
> +		} else {
> +			char *stype =3D protocol_name(se->protocol);
> +
> +			snprintf(svc_name, sizeof(svc_name), "%-4s %s",
> +				 stype, vname);
>  			if (se->af !=3D AF_INET6)
>  				svc_name[33] =3D '\0';
>  		}
> @@ -1806,6 +1860,9 @@ int service_to_port(const char *name, unsigned sho=
rt proto)
>  	else if (proto =3D=3D IPPROTO_UDP
>  		 && (service =3D getservbyname(name, "udp")) !=3D NULL)
>  		return ntohs((unsigned short) service->s_port);
> +	else if (proto =3D=3D IPPROTO_SCTP
> +		 && (service =3D getservbyname(name, "sctp")) !=3D NULL)
> +		return ntohs((unsigned short) service->s_port);
>  	else
>  		return -1;
>  }
> @@ -1821,6 +1878,9 @@ static char * port_to_service(unsigned short port,=
 unsigned short proto)
>  	else if (proto =3D=3D IPPROTO_UDP &&
>  		 (service =3D getservbyport(htons(port), "udp")) !=3D NULL)
>  		return service->s_name;
> +	else if (proto =3D=3D IPPROTO_SCTP &&
> +		 (service =3D getservbyport(htons(port), "sctp")) !=3D NULL)
> +		return service->s_name;
>  	else
>  		return (char *) NULL;
>  }
> --=20
> 1.9.3
>=20
>=20
> _______________________________________________
> Please read the documentation before posting - it's available at:
> http://www.linuxvirtualserver.org/
>=20
> LinuxVirtualServer.org mailing list - lvs-users@LinuxVirtualServer.org
> Send requests to lvs-users-request@LinuxVirtualServer.org
> or go to http://lists.graemef.net/mailman/listinfo/lvs-users
>
--sgnirkm-65d7c092-179f-4040-aed6-cb89d063d3ae
Content-Type: text/x-vcard; charset=utf-8
Content-Disposition: attachment; filename=addressbook.vcf

BEGIN:VCARD
VERSION:2.1
N:Venzke;Horst;;MR;;
FN:Horst  Venzke
ORG:Remsnet Consulting & Internet Services LTD
TITLE:IT Freelancer
TEL;PREF;WORK;VOICE:+49211310548830
TEL;HOME;VOICE:+49211310548830
TEL;PREF;HOME;CELL:+491578-4593592
TEL;WORK;FAX:+49211310548830
TEL;HOME;FAX:+49211310548839
ADR;HOME;ENCODING=QUOTED-PRINTABLE:;;Rather Str. 14;D=C3=BCsseldorf;;40476;Germany
LABEL;HOME;ENCODING=QUOTED-PRINTABLE:Rather Str. 14=0D=0A40476 D=C3=BCsseldorf=0D=0AGermany
ADR;WORK;ENCODING=QUOTED-PRINTABLE:;;Rather Str 14;D=C3=BCsseldorf;;40476;Germany
LABEL;WORK;ENCODING=QUOTED-PRINTABLE:Rather Str 14=0D=0A40476 D=C3=BCsseldorf=0D=0AGermany
BDAY:19660131
EMAIL;HOME;INTERNET:rnsklaus@web.de
EMAIL;WORK;INTERNET:info@remsnet.de
EMAIL;WORK;INTERNET:Horst.Venzke@remsnet.de
URL;PREF;HOME:www.remsnet.de
URL;WORK:www.remsnet.ws
URL;WORK:www.remsnet.org
URL;WORK:www.remsnet.tv
URL;WORK:www.remsnet.de
URL;WORK:www.remsnet.info
END:VCARD

--sgnirkm-65d7c092-179f-4040-aed6-cb89d063d3ae--
