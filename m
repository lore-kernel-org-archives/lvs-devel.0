From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 3/3] ipvsadm: Add support for mh scheduler
Date: Sat, 5 Jan 2019 17:30:12 +0200 (EET)
Message-ID: <alpine.LFD.2.21.1901051707290.12072@ja.home.ssi.bg>
References: <1546633614.3577.15.camel@armitage.org.uk>
Reply-To: "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org>
In-Reply-To: <1546633614.3577.15.camel@armitage.org.uk>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <http://lists.graemef.net/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@linuxvirtualserver.org?subject=unsubscribe>
List-Archive: <http://lists.graemef.net/pipermail/lvs-users>
List-Post: <mailto:lvs-users@linuxvirtualserver.org>
List-Help: <mailto:lvs-users-request@linuxvirtualserver.org?subject=help>
List-Subscribe: <http://lists.graemef.net/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@linuxvirtualserver.org?subject=subscribe>
Sender: lvs-users-bounces@linuxvirtualserver.org
Errors-To: lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org
To: Quentin Armitage <quentin@armitage.org.uk>
Cc: lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, Simon Horman <horms@verge.net.au>, Inju Song <inju.song@navercorp.com>, Jesper Dangaard Brouer <brouer@redhat.com>


	Hello,

On Fri, 4 Jan 2019, Quentin Armitage wrote:

> Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>
> ---
>  SCHEDULERS |  2 +-
>  ipvsadm.8  | 10 ++++++++++
>  ipvsadm.c  | 31 +++++++++++++++++++++++++++----
>  3 files changed, 38 insertions(+), 5 deletions(-)
> 
> diff --git a/SCHEDULERS b/SCHEDULERS
> index 187c07d..06d3357 100644
> --- a/SCHEDULERS
> +++ b/SCHEDULERS
> @@ -1 +1 @@
> -rr|wrr|lc|wlc|lblc|lblcr|dh|sh|sed|nq|fo|ovf
> +rr|wrr|lc|wlc|lblc|lblcr|dh|sh|sed|nq|fo|ovf|mh
> diff --git a/ipvsadm.8 b/ipvsadm.8
> index 18b6dc5..f0439dd 100644
> --- a/ipvsadm.8
> +++ b/ipvsadm.8
> @@ -276,6 +276,16 @@ of connections exceeds its weight.
>  server if there is one, instead of waiting for a fast one; if all the
>  servers are busy, it adopts the Shortest Expected Delay policy to
>  assign the job.
> +.sp
> +\fBmh\fR - Maglev Hashing: assigns a preference list of all the lookup
> +table positions to each destination and populate the table with
> +the most-preferred position of destinations. Then it is to select
> +destination with the hash key of source IP address through looking
> +up a the lookup table. This provides consistent hashing with minimal

	We can remove the above "a "...

> +disruption on destination changes and load balancing.
> +This scheduler has two flags: mh-fallback, which enables fallback to a
> +different server if the selected server was unavailable, and mh-port,
> +which adds the source port number to the hash computation.
>  .TP
>  .B -p, --persistent [\fItimeout\fP]
>  Specify that a virtual service is persistent. If this option is
> diff --git a/ipvsadm.c b/ipvsadm.c
> index 7695006..7942908 100644
> --- a/ipvsadm.c
> +++ b/ipvsadm.c
> @@ -270,6 +270,16 @@ static const char commands_v_options[NUMBER_OF_CMD][NUMBER_OF_OPT] =
>  
>  #define CONN_PROC_FILE         "/proc/net/ip_vs_conn"
>  
> +/* Unfortunately include/linux/ip_vs.h doesn't yet define
> + * the following
> + */
> +#ifndef IP_VS_SVC_F_SCHED_MH_FALLBACK
> +#define IP_VS_SVC_F_SCHED_MH_FALLBACK IP_VS_SVC_F_SCHED1
> +#endif
> +#ifndef IP_VS_SVC_F_SCHED_MH_PORT
> +#define IP_VS_SVC_F_SCHED_MH_PORT IP_VS_SVC_F_SCHED2
> +#endif
> +

	Yes, in the kernel, its place should be include/uapi/linux/ip_vs.h
But we should have it also in libipvs/ip_vs.h, not in ipvsadm.c,
IP_VS_SVC_F_SCHED_SH* are already there.

>  struct ipvs_command_entry {
>         int                     cmd;
>         ipvs_service_t          svc;
> @@ -1145,6 +1155,16 @@ static unsigned int parse_sched_flags(const char *sched, char *optarg)
>                         if (strcmp(sched, "sh"))
>                                 fail(2, "incompatible scheduler flag `%s'",
>                                      flag);
> +               } else if (!strcmp(flag, "mh-fallback")) {
> +                       flags |= IP_VS_SVC_F_SCHED_MH_FALLBACK;
> +                       if (strcmp(sched, "mh"))
> +                               fail(2, "incompatible scheduler flag `%s'",
> +                                    flag);
> +               } else if (!strcmp(flag, "mh-port")) {
> +                       flags |= IP_VS_SVC_F_SCHED_MH_PORT;
> +                       if (strcmp(sched, "mh"))
> +                               fail(2, "incompatible scheduler flag `%s'",
> +                                    flag);
>                 } else {
>                         fail(2, "invalid scheduler flag `%s'", flag);
>                 }
> @@ -1589,16 +1609,19 @@ static void print_sched_flags(ipvs_service_entry_t *se)
>                         strcat(flags, "sh-fallback,");
>                 if (se->flags & IP_VS_SVC_F_SCHED_SH_PORT)
>                         strcat(flags, "sh-port,");
> -               if (se->flags & IP_VS_SVC_F_SCHED3)
> -                       strcat(flags, "flag-3,");

	Agreed, flag-3 should not be printed for SH (and MH).

> +       } else if (!strcmp(se->sched_name, "mh")) {
> +               if (se->flags & IP_VS_SVC_F_SCHED_MH_FALLBACK)
> +                       strcat(flags, "mh-fallback,");
> +               if (se->flags & IP_VS_SVC_F_SCHED_MH_PORT)
> +                       strcat(flags, "mh-port,");
>         } else {
>                 if (se->flags & IP_VS_SVC_F_SCHED1)
>                         strcat(flags, "flag-1,");
>                 if (se->flags & IP_VS_SVC_F_SCHED2)
>                         strcat(flags, "flag-2,");
> -               if (se->flags & IP_VS_SVC_F_SCHED3)
> -                       strcat(flags, "flag-3,");

	It should be printed only as generic flag here as before.

>         }

	So, this change below is not needed.

> +       if (se->flags & IP_VS_SVC_F_SCHED3)
> +               strcat(flags, "flag-3,");
>  
>         if (flags[0]) {
>                 flags[strlen(flags)-1] = '\0';

Regards

--
Julian Anastasov <ja@ssi.bg>
