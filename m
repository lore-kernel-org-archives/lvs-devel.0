From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvsadm: support for scheduler flags
Date: Thu, 20 Jun 2013 22:20:28 +0900
Message-ID: <20130620132028.GE24993@verge.net.au>
References: <20130619100701.GA20258@eldamar.org.uk>
 <alpine.LFD.2.00.1306192254500.1823@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1306192254500.1823@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Alexander Frolkin <avf@eldamar.org.uk>, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, netdev@vger.kernel.org, lvs-users@linuxvirtualserver.org

On Wed, Jun 19, 2013 at 11:05:00PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Wed, 19 Jun 2013, Alexander Frolkin wrote:
> 
> > This patch adds support for scheduler flags, necessary to make use of
> > the "SH fallback and L4 hashing" kernel patch.
> > 
> > The flags are set per service (so using -A or -E) using -b <flags> or
> > --sched-flags <flags>.  <flags> is a comma-separated list of scheduler
> > flags.  The currently supported flags are sh-port, sh-fallback, and
> > generic flag-1, flag-2, flag-3 for future-proofing.
> > 
> > This patch will work with older versions of IPVS, although setting the
> > flags will have no effect.
> > 
> > Signed-off-by: Alexander Frolkin <avf@eldamar.org.uk>
> 
> 	Change looks correct:
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	but we forgot some minor issues, see below...
> 
> > @@ -426,9 +429,12 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
> >  		{ "ops", 'o', POPT_ARG_NONE, NULL, 'o', NULL, NULL },
> >  		{ "pe", '\0', POPT_ARG_STRING, &optarg, TAG_PERSISTENCE_ENGINE,
> >  		  NULL, NULL },
> > +		{ "sched-flags", 'b', POPT_ARG_STRING, &optarg, 'b', NULL, NULL },
> 
> 	You have to split this long line
> 
> > @@ -656,6 +662,10 @@ parse_options(int argc, char **argv, struct ipvs_command_entry *ce,
> >  			set_option(options, OPT_PERSISTENCE_ENGINE);
> >  			strncpy(ce->svc.pe_name, optarg, IP_VS_PENAME_MAXLEN);
> >  			break;
> > +		case 'b':
> > +			set_option(options, OPT_SCHED_FLAGS);
> > +			snprintf(sched_flags_arg, sizeof(sched_flags_arg), "%s", optarg);
> 
> 	This too
> 
> > +static void print_sched_flags(ipvs_service_entry_t *se) {
> 
> {	<<< start func on new line
> 
> 	checkpatch.pl shows also this one:
> 
> ERROR: spaces required around that '=' (ctx:VxV)
> #121: FILE: ipvsadm.c:369:
> +       char *optarg=NULL, sched_flags_arg[128];
>                     ^
> 	May be you can send a fixed version to Simon.

Yes, please do.
