From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvsadm: support for scheduler flags
Date: Wed, 19 Jun 2013 23:05:00 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1306192254500.1823@ja.ssi.bg>
References: <20130619100701.GA20258@eldamar.org.uk>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130619100701.GA20258@eldamar.org.uk>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alexander Frolkin <avf@eldamar.org.uk>
Cc: lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-users@linuxvirtualserver.org


	Hello,

On Wed, 19 Jun 2013, Alexander Frolkin wrote:

> This patch adds support for scheduler flags, necessary to make use of
> the "SH fallback and L4 hashing" kernel patch.
> 
> The flags are set per service (so using -A or -E) using -b <flags> or
> --sched-flags <flags>.  <flags> is a comma-separated list of scheduler
> flags.  The currently supported flags are sh-port, sh-fallback, and
> generic flag-1, flag-2, flag-3 for future-proofing.
> 
> This patch will work with older versions of IPVS, although setting the
> flags will have no effect.
> 
> Signed-off-by: Alexander Frolkin <avf@eldamar.org.uk>

	Change looks correct:

Acked-by: Julian Anastasov <ja@ssi.bg>

	but we forgot some minor issues, see below...

> @@ -426,9 +429,12 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
>  		{ "ops", 'o', POPT_ARG_NONE, NULL, 'o', NULL, NULL },
>  		{ "pe", '\0', POPT_ARG_STRING, &optarg, TAG_PERSISTENCE_ENGINE,
>  		  NULL, NULL },
> +		{ "sched-flags", 'b', POPT_ARG_STRING, &optarg, 'b', NULL, NULL },

	You have to split this long line

> @@ -656,6 +662,10 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
>  			set_option(options, OPT_PERSISTENCE_ENGINE);
>  			strncpy(ce->svc.pe_name, optarg, IP_VS_PENAME_MAXLEN);
>  			break;
> +		case 'b':
> +			set_option(options, OPT_SCHED_FLAGS);
> +			snprintf(sched_flags_arg, sizeof(sched_flags_arg), "%s", optarg);

	This too

> +static void print_sched_flags(ipvs_service_entry_t *se) {

{	<<< start func on new line

	checkpatch.pl shows also this one:

ERROR: spaces required around that '=' (ctx:VxV)
#121: FILE: ipvsadm.c:369:
+       char *optarg=NULL, sched_flags_arg[128];
                    ^
	May be you can send a fixed version to Simon.

Regards

--
Julian Anastasov <ja@ssi.bg>
