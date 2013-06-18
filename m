From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Tue, 18 Jun 2013 23:41:40 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1306182338560.1889@ja.ssi.bg>
References: <20130611083806.GA25531@eldamar.org.uk> <alpine.LFD.2.00.1306112240280.1709@ja.ssi.bg> <20130612141018.GC29327@eldamar.org.uk> <alpine.LFD.2.00.1306122244020.1773@ja.ssi.bg> <20130613141804.GB31356@eldamar.org.uk> <alpine.LFD.2.00.1306132250560.1810@ja.ssi.bg>
 <20130614114711.GB31800@eldamar.org.uk> <alpine.LFD.2.00.1306161054590.1579@ja.ssi.bg> <20130617103532.GB13101@eldamar.org.uk> <alpine.LFD.2.00.1306172236190.1564@ja.ssi.bg> <20130618090810.GB13596@eldamar.org.uk>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130618090810.GB13596@eldamar.org.uk>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Frolkin <avf@eldamar.org.uk>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Tue, 18 Jun 2013, Alexander Frolkin wrote:

> Hi,
> 
> Latest version of ipvsadm patch:

	I don't see problems with this version. If you post
an official patch I'll ack it. Others still have time for
comments.

> diff --git a/ipvsadm.8 b/ipvsadm.8
> index 001ae74..9a9e9b3 100644
> --- a/ipvsadm.8
> +++ b/ipvsadm.8
> @@ -37,7 +37,7 @@ ipvsadm \- Linux Virtual Server administration
>  .SH SYNOPSIS
>  .B ipvsadm -A|E -t|u|f \fIservice-address\fP [-s \fIscheduler\fP]
>  .ti 15
> -.B [-p [\fItimeout\fP]] [-M \fInetmask\fP]
> +.B [-p [\fItimeout\fP]] [-M \fInetmask\fP] [-b \fIsched-flags\fP]
>  .br
>  .B ipvsadm -D -t|u|f \fIservice-address\fP
>  .br
> @@ -248,6 +248,9 @@ addresses.
>  .sp
>  \fBsh\fR - Source Hashing: assigns jobs to servers through looking up
>  a statically assigned hash table by their source IP addresses.
> +This scheduler has two flags: sh-fallback, which enables fallback to a
> +different server if the selected server was unavailable, and sh-port,
> +which adds the source port number to the hash computation.
>  .sp
>  \fBsed\fR - Shortest Expected Delay: assigns an incoming job to the
>  server with the shortest expected delay. The expected delay that the
> @@ -286,6 +289,11 @@ resolve problems with non-persistent cache clusters on the client side.
>  IPv6 netmasks should be specified as a prefix length between 1 and 128.
>  The default prefix length is 128.
>  .TP
> +.B -b, --sched-flags \fIsched-flags\fP
> +Set scheduler flags for this virtual server.  \fIsched-flags\fP is a
> +comma-separated list of flags.  See the scheduler descriptions for
> +valid scheduler flags.
> +.TP
>  .B -r, --real-server \fIserver-address\fP
>  Real server that an associated request for service may be assigned to.
>  The \fIserver-address\fP is the \fIhost\fP address of a real server,
> diff --git a/ipvsadm.c b/ipvsadm.c
> index 0197515..5b8c036 100644
> --- a/ipvsadm.c
> +++ b/ipvsadm.c
> @@ -182,7 +182,8 @@ static const char* cmdnames[] = {
>  #define OPT_EXACT		0x100000
>  #define OPT_ONEPACKET		0x200000
>  #define OPT_PERSISTENCE_ENGINE  0x400000
> -#define NUMBER_OF_OPT		23
> +#define OPT_SCHED_FLAGS		0x800000
> +#define NUMBER_OF_OPT		24
>  
>  static const char* optnames[] = {
>  	"numeric",
> @@ -208,6 +209,7 @@ static const char* optnames[] = {
>  	"exact",
>  	"ops",
>  	"pe",
> +	"sched-flags",
>  };
>  
>  /*
> @@ -220,21 +222,21 @@ static const char* optnames[] = {
>   */
>  static const char commands_v_options[NUMBER_OF_CMD][NUMBER_OF_OPT] =
>  {
> -	/*   -n   -c   svc  -s   -p   -M   -r   fwd  -w   -x   -y   -mc  tot  dmn  -st  -rt  thr  -pc  srt  sid  -ex  ops  -pe */
> -/*ADD*/     {'x', 'x', '+', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', ' '},
> -/*EDIT*/    {'x', 'x', '+', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', ' '},
> -/*DEL*/     {'x', 'x', '+', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
> -/*FLUSH*/   {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
> -/*LIST*/    {' ', '1', '1', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '1', '1', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'x', 'x'},
> -/*ADDSRV*/  {'x', 'x', '+', 'x', 'x', 'x', '+', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
> -/*DELSRV*/  {'x', 'x', '+', 'x', 'x', 'x', '+', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
> -/*EDITSRV*/ {'x', 'x', '+', 'x', 'x', 'x', '+', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
> -/*TIMEOUT*/ {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
> -/*STARTD*/  {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x'},
> -/*STOPD*/   {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x'},
> -/*RESTORE*/ {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
> -/*SAVE*/    {' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
> -/*ZERO*/    {'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
> +	/*   -n   -c   svc  -s   -p   -M   -r   fwd  -w   -x   -y   -mc  tot  dmn  -st  -rt  thr  -pc  srt  sid  -ex  ops  -pe  -b */
> +/*ADD*/     {'x', 'x', '+', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', ' ', ' '},
> +/*EDIT*/    {'x', 'x', '+', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', ' ', ' '},
> +/*DEL*/     {'x', 'x', '+', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
> +/*FLUSH*/   {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
> +/*LIST*/    {' ', '1', '1', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', '1', '1', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'x', 'x', 'x'},
> +/*ADDSRV*/  {'x', 'x', '+', 'x', 'x', 'x', '+', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
> +/*DELSRV*/  {'x', 'x', '+', 'x', 'x', 'x', '+', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
> +/*EDITSRV*/ {'x', 'x', '+', 'x', 'x', 'x', '+', ' ', ' ', ' ', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
> +/*TIMEOUT*/ {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
> +/*STARTD*/  {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x'},
> +/*STOPD*/   {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', ' ', 'x', 'x', 'x', 'x'},
> +/*RESTORE*/ {'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
> +/*SAVE*/    {' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
> +/*ZERO*/    {'x', 'x', ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x'},
>  };
>  
>  /* printing format flags */
> @@ -302,6 +304,7 @@ static int parse_service(char *buf, ipvs_service_t *svc);
>  static int parse_netmask(char *buf, u_int32_t *addr);
>  static int parse_timeout(char *buf, int min, int max);
>  static unsigned int parse_fwmark(char *buf);
> +static unsigned int parse_sched_flags(const char *sched, char *optarg);
>  
>  /* check the options based on the commands_v_options table */
>  static void generic_opt_check(int command, int options);
> @@ -363,7 +366,7 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
>  {
>  	int c, parse;
>  	poptContext context;
> -	char *optarg=NULL;
> +	char *optarg=NULL, sched_flags_arg[128];
>  	struct poptOption options_table[] = {
>  		{ "add-service", 'A', POPT_ARG_NONE, NULL, 'A', NULL, NULL },
>  		{ "edit-service", 'E', POPT_ARG_NONE, NULL, 'E', NULL, NULL },
> @@ -426,9 +429,12 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
>  		{ "ops", 'o', POPT_ARG_NONE, NULL, 'o', NULL, NULL },
>  		{ "pe", '\0', POPT_ARG_STRING, &optarg, TAG_PERSISTENCE_ENGINE,
>  		  NULL, NULL },
> +		{ "sched-flags", 'b', POPT_ARG_STRING, &optarg, 'b', NULL, NULL },
>  		{ NULL, 0, 0, NULL, 0, NULL, NULL }
>  	};
>  
> +	sched_flags_arg[0] = '\0';
> +
>  	context = poptGetContext("ipvsadm", argc, (const char **)argv,
>  				 options_table, 0);
>  
> @@ -656,6 +662,10 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
>  			set_option(options, OPT_PERSISTENCE_ENGINE);
>  			strncpy(ce->svc.pe_name, optarg, IP_VS_PENAME_MAXLEN);
>  			break;
> +		case 'b':
> +			set_option(options, OPT_SCHED_FLAGS);
> +			snprintf(sched_flags_arg, sizeof(sched_flags_arg), "%s", optarg);
> +			break;
>  		default:
>  			fail(2, "invalid option `%s'",
>  			     poptBadOption(context, POPT_BADOPTION_NOALIAS));
> @@ -690,6 +700,14 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
>  	if ((optarg=(char *)poptGetArg(context)))
>  		fail(2, "unexpected argument %s", optarg);
>  
> +	if (sched_flags_arg[0]) {
> +		ce->svc.flags &= ~(IP_VS_SVC_F_SCHED1 |
> +				   IP_VS_SVC_F_SCHED2 |
> +				   IP_VS_SVC_F_SCHED3);
> +		ce->svc.flags |= parse_sched_flags(ce->svc.sched_name,
> +						   sched_flags_arg);
> +	}
> +
>  	poptFreeContext(context);
>  
>  	return 0;
> @@ -989,6 +1007,38 @@ parse_service(char *buf, ipvs_service_t *svc)
>  	return result;
>  }
>  
> +static unsigned int parse_sched_flags(const char *sched, char *optarg)
> +{
> +	unsigned int flags = 0;
> +	char *flag;
> +
> +	sched = (sched && *sched) ? sched : DEF_SCHED;
> +
> +	flag = strtok(optarg, ",");
> +	do {
> +		if (!strcmp(flag, "flag-1")) {
> +			flags |= IP_VS_SVC_F_SCHED1;
> +		} else if (!strcmp(flag, "flag-2")) {
> +			flags |= IP_VS_SVC_F_SCHED2;
> +		} else if (!strcmp(flag, "flag-3")) {
> +			flags |= IP_VS_SVC_F_SCHED3;
> +		} else if (!strcmp(flag, "sh-fallback")) {
> +			flags |= IP_VS_SVC_F_SCHED_SH_FALLBACK;
> +			if (strcmp(sched, "sh"))
> +				fail(2, "incompatible scheduler flag `%s'",
> +				     flag);
> +		} else if (!strcmp(flag, "sh-port")) {
> +			flags |= IP_VS_SVC_F_SCHED_SH_PORT;
> +			if (strcmp(sched, "sh"))
> +				fail(2, "incompatible scheduler flag `%s'",
> +				     flag);
> +		} else {
> +			fail(2, "invalid scheduler flag `%s'", flag);
> +		}
> +	} while ((flag = strtok(NULL, ",")) != NULL);
> +
> +	return flags;
> +}
>  
>  static void
>  generic_opt_check(int command, int options)
> @@ -1070,7 +1120,7 @@ static void usage_exit(const char *program, const int exit_status)
>  	version(stream);
>  	fprintf(stream,
>  		"Usage:\n"
> -		"  %s -A|E -t|u|f service-address [-s scheduler] [-p [timeout]] [-M netmask] [--pe persistence_engine]\n"
> +		"  %s -A|E -t|u|f service-address [-s scheduler] [-p [timeout]] [-M netmask] [--pe persistence_engine] [-b sched-flags]\n"
>  		"  %s -D -t|u|f service-address\n"
>  		"  %s -C\n"
>  		"  %s -R\n"
> @@ -1139,7 +1189,8 @@ static void usage_exit(const char *program, const int exit_status)
>  		"  --nosort                            disable sorting output of service/server entries\n"
>  		"  --sort                              does nothing, for backwards compatibility\n"
>  		"  --ops          -o                   one-packet scheduling\n"
> -		"  --numeric      -n                   numeric output of addresses and ports\n",
> +		"  --numeric      -n                   numeric output of addresses and ports\n"
> +		"  --sched-flags  -b flags             scheduler flags (comma-separated)\n",
>  		DEF_SCHED);
>  
>  	exit(exit_status);
> @@ -1396,6 +1447,32 @@ static void print_largenum(unsigned long long i, unsigned int format)
>  		printf("%8lluT", i / 1000000000000ULL);
>  }
>  
> +static void print_sched_flags(ipvs_service_entry_t *se) {
> +	char flags[64];
> +
> +	flags[0] = '\0';
> +
> +	if (!strcmp(se->sched_name, "sh")) {
> +		if (se->flags & IP_VS_SVC_F_SCHED_SH_FALLBACK)
> +			strcat(flags, "sh-fallback,");
> +		if (se->flags & IP_VS_SVC_F_SCHED_SH_PORT)
> +			strcat(flags, "sh-port,");
> +		if (se->flags & IP_VS_SVC_F_SCHED3)
> +			strcat(flags, "flag-3,");
> +	} else {
> +		if (se->flags & IP_VS_SVC_F_SCHED1)
> +			strcat(flags, "flag-1,");
> +		if (se->flags & IP_VS_SVC_F_SCHED2)
> +			strcat(flags, "flag-2,");
> +		if (se->flags & IP_VS_SVC_F_SCHED3)
> +			strcat(flags, "flag-3,");
> +	}
> +
> +	if (flags[0]) {
> +		flags[strlen(flags)-1] = '\0';
> +		printf("%s", flags);
> +	}
> +}
>  
>  static void print_title(unsigned int format)
>  {
> @@ -1488,6 +1565,12 @@ print_service_entry(ipvs_service_entry_t *se, unsigned int format)
>  			printf(" pe %s", se->pe_name);
>  		if (se->flags & IP_VS_SVC_F_ONEPACKET)
>  			printf(" -o");
> +		if (se->flags & (IP_VS_SVC_F_SCHED1 |
> +				 IP_VS_SVC_F_SCHED2 |
> +				 IP_VS_SVC_F_SCHED3)) {
> +			printf(" -b ");
> +			print_sched_flags(se);
> +		}
>  	} else if (format & FMT_STATS) {
>  		printf("%-33s", svc_name);
>  		print_largenum(se->stats.conns, format);
> @@ -1504,6 +1587,13 @@ print_service_entry(ipvs_service_entry_t *se, unsigned int format)
>  		print_largenum(se->stats.outbps, format);
>  	} else {
>  		printf("%s %s", svc_name, se->sched_name);
> +		if (se->flags & (IP_VS_SVC_F_SCHED1 |
> +				 IP_VS_SVC_F_SCHED2 |
> +				 IP_VS_SVC_F_SCHED3)) {
> +			printf(" (");
> +			print_sched_flags(se);
> +			printf(")");
> +		}
>  		if (se->flags & IP_VS_SVC_F_PERSISTENT) {
>  			printf(" persistent %u", se->timeout);
>  			if (se->af == AF_INET)
> diff --git a/libipvs/ip_vs.h b/libipvs/ip_vs.h
> index 5e1d544..4db14ff 100644
> --- a/libipvs/ip_vs.h
> +++ b/libipvs/ip_vs.h
> @@ -29,6 +29,13 @@
>  #define IP_VS_SVC_F_PERSISTENT	0x0001		/* persistent port */
>  #define IP_VS_SVC_F_HASHED	0x0002		/* hashed entry */
>  #define IP_VS_SVC_F_ONEPACKET	0x0004		/* one-packet scheduling */
> +#define IP_VS_SVC_F_SCHED1	0x0008		/* scheduler flag 1 */
> +#define IP_VS_SVC_F_SCHED2	0x0010		/* scheduler flag 2 */
> +#define IP_VS_SVC_F_SCHED3	0x0020		/* scheduler flag 3 */
> +
> +#define IP_VS_SVC_F_SCHED_SH_FALLBACK	IP_VS_SVC_F_SCHED1 /* SH fallback */
> +#define IP_VS_SVC_F_SCHED_SH_PORT	IP_VS_SVC_F_SCHED2 /* SH use port */
> +
>  
>  /*
>   *      IPVS sync daemon states
> 
> 
> Alex

Regards

--
Julian Anastasov <ja@ssi.bg>
