From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipvs: remove _bh from percpu stats reading
Date: Fri, 4 Mar 2011 12:28:20 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103041226210.1452@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; format="flowed"; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org


 	ip_vs_read_cpu_stats is called only from timer, so
no need for _bh locks.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_est.c linux/net/netfilter/ipvs/ip_vs_est.c
--- lvs-test-2.6-8a80c79/linux/net/netfilter/ipvs/ip_vs_est.c	2011-02-28 19:02:33.000000000 +0200
+++ linux/net/netfilter/ipvs/ip_vs_est.c	2011-03-03 20:51:45.680538006 +0200
@@ -69,10 +69,10 @@ static void ip_vs_read_cpu_stats(struct
  			sum->inpkts += s->ustats.inpkts;
  			sum->outpkts += s->ustats.outpkts;
  			do {
-				start = u64_stats_fetch_begin_bh(&s->syncp);
+				start = u64_stats_fetch_begin(&s->syncp);
  				inbytes = s->ustats.inbytes;
  				outbytes = s->ustats.outbytes;
-			} while (u64_stats_fetch_retry_bh(&s->syncp, start));
+			} while (u64_stats_fetch_retry(&s->syncp, start));
  			sum->inbytes += inbytes;
  			sum->outbytes += outbytes;
  		} else {
@@ -80,10 +80,10 @@ static void ip_vs_read_cpu_stats(struct
  			sum->inpkts = s->ustats.inpkts;
  			sum->outpkts = s->ustats.outpkts;
  			do {
-				start = u64_stats_fetch_begin_bh(&s->syncp);
+				start = u64_stats_fetch_begin(&s->syncp);
  				sum->inbytes = s->ustats.inbytes;
  				sum->outbytes = s->ustats.outbytes;
-			} while (u64_stats_fetch_retry_bh(&s->syncp, start));
+			} while (u64_stats_fetch_retry(&s->syncp, start));
  		}
  	}
  }
