From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re: [PATCH] ipvs: remove _bh from percpu stats reading
Date: Fri, 4 Mar 2011 11:49:20 +0100 (CET)
Message-ID: <6pi9527.f8813213bcf5a7751d239b025883cce1@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

>---- Original Message ----
>From: Julian Anastasov <ja@ssi.bg>
>To: "Simon Horman" <horms@verge.net.au>
>Cc: lvs-devel@vger.kernel.org
>Sent: Fri, Mar 4, 2011, 11:24 AM
>Subject: [PATCH] ipvs: remove _bh from percpu stats reading
>
>ip_vs_read_cpu_stats is called only from timer, so
>no need for _bh locks.

oops, I know who did this from the begining :-)

>
>Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>

>---
>
>diff -urp lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_est.c linux/net/netfilter/ipvs/ip_vs_est.c
>--- lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_est.c	2011-02-28 19:02:33.000000000 +0200
>+++ linux/net/netfilter/ipvs/ip_vs_est.c	2011-03-03 20:51:45.680538006 +0200
>@@ -69,10 +69,10 @@ static void ip_vs_read_cpu_stats(struct
>  			sum->inpkts += s->ustats.inpkts;
>  			sum->outpkts += s->ustats.outpkts;
>  			do {
>-				start = u64_stats_fetch_begin_bh(&s->syncp);
>+				start = u64_stats_fetch_begin(&s->syncp);
>  				inbytes = s->ustats.inbytes;
>  				outbytes = s->ustats.outbytes;
>-			} while (u64_stats_fetch_retry_bh(&s->syncp, start));
>+			} while (u64_stats_fetch_retry(&s->syncp, start));
>  			sum->inbytes += inbytes;
>  			sum->outbytes += outbytes;
>  		} else {
>@@ -80,10 +80,10 @@ static void ip_vs_read_cpu_stats(struct
>  			sum->inpkts = s->ustats.inpkts;
>  			sum->outpkts = s->ustats.outpkts;
>  			do {
>-				start = u64_stats_fetch_begin_bh(&s->syncp);
>+				start = u64_stats_fetch_begin(&s->syncp);
>  				sum->inbytes = s->ustats.inbytes;
>  				sum->outbytes = s->ustats.outbytes;
>-			} while (u64_stats_fetch_retry_bh(&s->syncp, start));
>+			} while (u64_stats_fetch_retry(&s->syncp, start));
>  		}
>  	}
>  }
>--
>To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

