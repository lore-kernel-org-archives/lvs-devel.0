From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvsadm: check if a virtual service exists before
 attempting removal
Date: Sat, 5 Aug 2017 14:33:40 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1708051429130.2093@ja.home.ssi.bg>
References: <20170731123555.10639-1-ema@wikimedia.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20170731123555.10639-1-ema@wikimedia.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Emanuele Rocca <ema@wikimedia.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org


	Hello,

On Mon, 31 Jul 2017, Emanuele Rocca wrote:

> Removing a non-existing service results in a confusing "Memory
> allocation problem" error message:
> 
>         # ipvsadm -D -t example.org:80
>         Memory allocation problem
> 
> Check if the given service exists before attempting removal. Inform the
> user if the service is not defined.
> 
> Signed-off-by: Emanuele Rocca <ema@wikimedia.org>
> ---
>  ipvsadm.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/ipvsadm.c b/ipvsadm.c
> index 1a28d72..f958b11 100644
> --- a/ipvsadm.c
> +++ b/ipvsadm.c
> @@ -942,6 +942,11 @@ static int process_options(int argc, char **argv, int reading_stdin)
>  		break;
>  
>  	case CMD_DEL:
> +		if (!(ipvs_get_service(ce.svc.fwmark, ce.svc.af, ce.svc.protocol,
> +						   ce.svc.addr, ce.svc.port))) {
> +			fprintf(stderr, "No such service\n");
> +			exit(1);
> +		}
>  		result = ipvs_del_service(&ce.svc);

	After some debugging, I think I found the cause for
this problem. It affects all command failures when ipvsadm
is compiled to use libnl, so I'm providing more general patch
to fix this problem. I'll post it soon...

Regards

--
Julian Anastasov <ja@ssi.bg>
