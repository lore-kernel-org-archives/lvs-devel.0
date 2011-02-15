From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: make "no destination available" message more
 informative
Date: Wed, 16 Feb 2011 07:04:08 +0900
Message-ID: <20110215220407.GN8703@verge.net.au>
References: <1297429272.8485.18.camel@lat1>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1297429272.8485.18.camel@lat1>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick Schaaf <netdev@bof.de>
Cc: lvs-devel@vger.kernel.org

On Fri, Feb 11, 2011 at 02:01:12PM +0100, Patrick Schaaf wrote:
> When IP_VS schedulers do not find a destination, they output a terse
> "WLC: no destination available" message through kernel syslog, which I
> can not only make sense of because syslog puts them in a logfile
> together with keepalived checker results.
> 
> This patch makes the output a bit more informative, by telling you which
> virtual service failed to find a destination.
> 
> Example output:
> 
> kernel: [1539214.552233] IPVS: wlc: TCP 192.168.8.30:22 - no destination
> available
> kernel: [1539299.674418] IPVS: wlc: FWM 22 0x00000016 - no destination
> available
> 
> I have tested the code for IPv4 and FWM services, as you can see from
> the example; I do not have an IPv6 setup to test the third code path
> with.
> 
> To avoid code duplication, I put a new function ip_vs_scheduler_err()
> into ip_vs_sched.c, and use that from the schedulers instead of calling
> IP_VS_ERR_RL directly.
> 
> The patch is against 2.6.36.2, as that's what I have running. It still
> applies with two hunks shifted to 2.6.38-rc4, and builds there without
> warnings.
> 
> Please review and consider for inclusion in upcoming kernels.

Hi Patrick,

Thanks, this looks good to me.
I will apply it with the minor modification noted below.

> diff -pur -X patch.exclude linux-2.6.36.2/include/net/ip_vs.h linux-2.6.36.2-bof/include/net/ip_vs.h
> --- linux-2.6.36.2/include/net/ip_vs.h	2010-12-14 14:22:48.826000001 +0100
> +++ linux-2.6.36.2-bof/include/net/ip_vs.h	2011-02-11 12:27:54.301006127 +0100
> @@ -789,6 +789,7 @@ ip_vs_schedule(struct ip_vs_service *svc
>  extern int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
>  			struct ip_vs_protocol *pp);
>  
> +extern void ip_vs_scheduler_err(struct ip_vs_service *svc, const char *msg);
>  
>  /*
>   *      IPVS control data and functions (from ip_vs_ctl.c)
> diff -pur -X patch.exclude linux-2.6.36.2/net/netfilter/ipvs/ip_vs_lblc.c linux-2.6.36.2-bof/net/netfilter/ipvs/ip_vs_lblc.c
> --- linux-2.6.36.2/net/netfilter/ipvs/ip_vs_lblc.c	2010-12-14 14:20:14.681000001 +0100
> +++ linux-2.6.36.2-bof/net/netfilter/ipvs/ip_vs_lblc.c	2011-02-11 12:28:42.143528395 +0100
> @@ -511,7 +511,7 @@ ip_vs_lblc_schedule(struct ip_vs_service
>  	/* No cache entry or it is invalid, time to schedule */
>  	dest = __ip_vs_lblc_schedule(svc);
>  	if (!dest) {
> -		IP_VS_ERR_RL("LBLC: no destination available\n");
> +		ip_vs_scheduler_err(svc, "no destination available");
>  		return NULL;
>  	}
>  
> diff -pur -X patch.exclude linux-2.6.36.2/net/netfilter/ipvs/ip_vs_lblcr.c linux-2.6.36.2-bof/net/netfilter/ipvs/ip_vs_lblcr.c
> --- linux-2.6.36.2/net/netfilter/ipvs/ip_vs_lblcr.c	2010-12-14 14:20:14.517000000 +0100
> +++ linux-2.6.36.2-bof/net/netfilter/ipvs/ip_vs_lblcr.c	2011-02-11 12:28:42.138528548 +0100
> @@ -694,7 +694,7 @@ ip_vs_lblcr_schedule(struct ip_vs_servic
>  		/* The cache entry is invalid, time to schedule */
>  		dest = __ip_vs_lblcr_schedule(svc);
>  		if (!dest) {
> -			IP_VS_ERR_RL("LBLCR: no destination available\n");
> +			ip_vs_scheduler_err(svc, "no destination available");
>  			read_unlock(&svc->sched_lock);
>  			return NULL;
>  		}
> diff -pur -X patch.exclude linux-2.6.36.2/net/netfilter/ipvs/ip_vs_lc.c linux-2.6.36.2-bof/net/netfilter/ipvs/ip_vs_lc.c
> --- linux-2.6.36.2/net/netfilter/ipvs/ip_vs_lc.c	2010-12-14 14:20:14.100000002 +0100
> +++ linux-2.6.36.2-bof/net/netfilter/ipvs/ip_vs_lc.c	2011-02-11 12:28:42.133528703 +0100
> @@ -70,7 +70,7 @@ ip_vs_lc_schedule(struct ip_vs_service *
>  	}
>  
>  	if (!least)
> -		IP_VS_ERR_RL("LC: no destination available\n");
> +		ip_vs_scheduler_err(svc, "no destination available");
>  	else
>  		IP_VS_DBG_BUF(6, "LC: server %s:%u activeconns %d "
>  			      "inactconns %d\n",
> diff -pur -X patch.exclude linux-2.6.36.2/net/netfilter/ipvs/ip_vs_nq.c linux-2.6.36.2-bof/net/netfilter/ipvs/ip_vs_nq.c
> --- linux-2.6.36.2/net/netfilter/ipvs/ip_vs_nq.c	2010-12-14 14:20:14.134000002 +0100
> +++ linux-2.6.36.2-bof/net/netfilter/ipvs/ip_vs_nq.c	2011-02-11 12:28:42.131528765 +0100
> @@ -99,7 +99,7 @@ ip_vs_nq_schedule(struct ip_vs_service *
>  	}
>  
>  	if (!least) {
> -		IP_VS_ERR_RL("NQ: no destination available\n");
> +		ip_vs_scheduler_err(svc, "no destination available");
>  		return NULL;
>  	}
>  
> diff -pur -X patch.exclude linux-2.6.36.2/net/netfilter/ipvs/ip_vs_rr.c linux-2.6.36.2-bof/net/netfilter/ipvs/ip_vs_rr.c
> --- linux-2.6.36.2/net/netfilter/ipvs/ip_vs_rr.c	2010-12-14 14:20:14.347000001 +0100
> +++ linux-2.6.36.2-bof/net/netfilter/ipvs/ip_vs_rr.c	2011-02-11 12:28:42.145528333 +0100
> @@ -72,7 +72,7 @@ ip_vs_rr_schedule(struct ip_vs_service *
>  		q = q->next;
>  	} while (q != p);
>  	write_unlock(&svc->sched_lock);
> -	IP_VS_ERR_RL("RR: no destination available\n");
> +	ip_vs_scheduler_err(svc, "no destination available");
>  	return NULL;
>  
>    out:
> diff -pur -X patch.exclude linux-2.6.36.2/net/netfilter/ipvs/ip_vs_sched.c linux-2.6.36.2-bof/net/netfilter/ipvs/ip_vs_sched.c
> --- linux-2.6.36.2/net/netfilter/ipvs/ip_vs_sched.c	2010-12-14 14:20:14.210000002 +0100
> +++ linux-2.6.36.2-bof/net/netfilter/ipvs/ip_vs_sched.c	2011-02-11 13:27:02.845477196 +0100
> @@ -29,6 +29,7 @@
>  
>  #include <net/ip_vs.h>
>  
> +EXPORT_SYMBOL(ip_vs_scheduler_err);
>  /*
>   *  IPVS scheduler list
>   */
> @@ -163,6 +164,33 @@ void ip_vs_scheduler_put(struct ip_vs_sc
>  		module_put(scheduler->module);
>  }
>  
> +/*
> + * Common error output helper for schedulers
> + */
> +
> +void ip_vs_scheduler_err(struct ip_vs_service *svc, const char *msg)
> +{
> +	if (svc->fwmark) {
> +		IP_VS_ERR_RL("%s: FWM %u 0x%08X - %s\n",
> +			svc->scheduler->name, svc->fwmark, svc->fwmark, msg);
> +		return;
> +	}
> +#ifdef CONFIG_IP_VS_IPV6
> +	if (svc->af == AF_INET6) {
> +		IP_VS_ERR_RL("%s: %s [%pI6]:%d - %s\n",
> +			svc->scheduler->name,
> +			ip_vs_proto_name(svc->protocol),
> +			&svc->addr.in6, ntohs(svc->port),
> +			msg);
> +		return;
> +	}

I will add "else" here.

> +#endif
> +	IP_VS_ERR_RL("%s: %s %pI4:%d - %s\n",
> +		svc->scheduler->name,
> +		ip_vs_proto_name(svc->protocol),
> +		&svc->addr.ip, ntohs(svc->port),
> +		msg);
> +}
>  
>  /*
>   *  Register a scheduler in the scheduler list
> diff -pur -X patch.exclude linux-2.6.36.2/net/netfilter/ipvs/ip_vs_sed.c linux-2.6.36.2-bof/net/netfilter/ipvs/ip_vs_sed.c
> --- linux-2.6.36.2/net/netfilter/ipvs/ip_vs_sed.c	2010-12-14 14:20:14.182000001 +0100
> +++ linux-2.6.36.2-bof/net/netfilter/ipvs/ip_vs_sed.c	2011-02-11 12:28:42.128528858 +0100
> @@ -87,7 +87,7 @@ ip_vs_sed_schedule(struct ip_vs_service
>  			goto nextstage;
>  		}
>  	}
> -	IP_VS_ERR_RL("SED: no destination available\n");
> +	ip_vs_scheduler_err(svc, "no destination available");
>  	return NULL;
>  
>  	/*
> diff -pur -X patch.exclude linux-2.6.36.2/net/netfilter/ipvs/ip_vs_sh.c linux-2.6.36.2-bof/net/netfilter/ipvs/ip_vs_sh.c
> --- linux-2.6.36.2/net/netfilter/ipvs/ip_vs_sh.c	2010-12-14 14:20:14.530000000 +0100
> +++ linux-2.6.36.2-bof/net/netfilter/ipvs/ip_vs_sh.c	2011-02-11 12:28:42.125528949 +0100
> @@ -223,7 +223,7 @@ ip_vs_sh_schedule(struct ip_vs_service *
>  	    || !(dest->flags & IP_VS_DEST_F_AVAILABLE)
>  	    || atomic_read(&dest->weight) <= 0
>  	    || is_overloaded(dest)) {
> -		IP_VS_ERR_RL("SH: no destination available\n");
> +		ip_vs_scheduler_err(svc, "no destination available");
>  		return NULL;
>  	}
>  
> diff -pur -X patch.exclude linux-2.6.36.2/net/netfilter/ipvs/ip_vs_wlc.c linux-2.6.36.2-bof/net/netfilter/ipvs/ip_vs_wlc.c
> --- linux-2.6.36.2/net/netfilter/ipvs/ip_vs_wlc.c	2010-12-14 14:20:14.256000001 +0100
> +++ linux-2.6.36.2-bof/net/netfilter/ipvs/ip_vs_wlc.c	2011-02-11 12:28:42.148528240 +0100
> @@ -75,7 +75,7 @@ ip_vs_wlc_schedule(struct ip_vs_service
>  			goto nextstage;
>  		}
>  	}
> -	IP_VS_ERR_RL("WLC: no destination available\n");
> +	ip_vs_scheduler_err(svc, "no destination available");
>  	return NULL;
>  
>  	/*
> diff -pur -X patch.exclude linux-2.6.36.2/net/netfilter/ipvs/ip_vs_wrr.c linux-2.6.36.2-bof/net/netfilter/ipvs/ip_vs_wrr.c
> --- linux-2.6.36.2/net/netfilter/ipvs/ip_vs_wrr.c	2010-12-14 14:20:14.180000001 +0100
> +++ linux-2.6.36.2-bof/net/netfilter/ipvs/ip_vs_wrr.c	2011-02-11 12:28:42.151528147 +0100
> @@ -147,8 +147,9 @@ ip_vs_wrr_schedule(struct ip_vs_service
>  
>  			if (mark->cl == mark->cl->next) {
>  				/* no dest entry */
> -				IP_VS_ERR_RL("WRR: no destination available: "
> -					     "no destinations present\n");
> +				ip_vs_scheduler_err(svc,
> +					"no destination available: "
> +					"no destinations present");
>  				dest = NULL;
>  				goto out;
>  			}
> @@ -162,8 +163,8 @@ ip_vs_wrr_schedule(struct ip_vs_service
>  				 */
>  				if (mark->cw == 0) {
>  					mark->cl = &svc->destinations;
> -					IP_VS_ERR_RL("WRR: no destination "
> -						     "available\n");
> +					ip_vs_scheduler_err(svc,
> +						"no destination available");
>  					dest = NULL;
>  					goto out;
>  				}
> @@ -185,8 +186,9 @@ ip_vs_wrr_schedule(struct ip_vs_service
>  			/* back to the start, and no dest is found.
>  			   It is only possible when all dests are OVERLOADED */
>  			dest = NULL;
> -			IP_VS_ERR_RL("WRR: no destination available: "
> -				     "all destinations are overloaded\n");
> +			ip_vs_scheduler_err(svc,
> +				"no destination available: "
> +				"all destinations are overloaded");
>  			goto out;
>  		}
>  	}

