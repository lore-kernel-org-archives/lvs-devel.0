From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Mon, 17 Jun 2013 22:48:39 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1306172236190.1564@ja.ssi.bg>
References: <20130607081252.GC11902@eldamar.org.uk> <alpine.LFD.2.00.1306102222380.1773@ja.ssi.bg> <20130611083806.GA25531@eldamar.org.uk> <alpine.LFD.2.00.1306112240280.1709@ja.ssi.bg> <20130612141018.GC29327@eldamar.org.uk> <alpine.LFD.2.00.1306122244020.1773@ja.ssi.bg>
 <20130613141804.GB31356@eldamar.org.uk> <alpine.LFD.2.00.1306132250560.1810@ja.ssi.bg> <20130614114711.GB31800@eldamar.org.uk> <alpine.LFD.2.00.1306161054590.1579@ja.ssi.bg> <20130617103532.GB13101@eldamar.org.uk>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130617103532.GB13101@eldamar.org.uk>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Frolkin <avf@eldamar.org.uk>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Mon, 17 Jun 2013, Alexander Frolkin wrote:

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
> +			strncpy(sched_flags_arg, optarg, sizeof(sched_flags_arg));

	Such strncpy calls are not very safe, they should be
strncpy(dest, src, space - 1); dest[space - 1] = 0;

	Better to use
	snprintf(sched_flags_arg, sizeof(sched_flags_arg), "%s", optarg);

> +			break;

> +static unsigned int parse_sched_flags(const char *sched, char *optarg)
> +{
> +	unsigned int flags = 0;
> +	char *flag;
> +	const char *scheduler = (sched && *sched) ? sched : DEF_SCHED;

	We can reuse 'sched' here, no need for 'scheduler':

	sched = (sched && *sched) ? sched : DEF_SCHED;

Regards

--
Julian Anastasov <ja@ssi.bg>
