From: Simon Kirby <sim@hostway.ca>
Subject: ip_vs_lblcr logic error causing table flushing
Date: Wed, 4 Nov 2009 16:38:01 -0800
Message-ID: <20091105003801.GA20042@hostway.ca>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>

[ Resent with a reasonable subject and to lvs-devel :) ]

Hello!

I was noticing a significant amount of what seems/seemed to be
destination lists with multiple entries with the lblcr LVS algorithm. 
While tracking it down, I think I stumbled over a mistake.  In
ip_vs_lblcr_full_check(), it appears the time check logic is reversed:

        for (i=0, j=tbl->rover; i<IP_VS_LBLCR_TAB_SIZE; i++) {
                j = (j + 1) & IP_VS_LBLCR_TAB_MASK;

                write_lock(&svc->sched_lock);
                list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
                        if (time_after(en->lastuse+sysctl_ip_vs_lblcr_expiration,
                                       now))
                                continue;
                        
                        ip_vs_lblcr_free(en);
                        atomic_dec(&tbl->entries);
                }
                write_unlock(&svc->sched_lock);
        }

Shouldn't this be "time_before"?  It seems that it currently nukes all
recently-used entries every time this function is called, which seems to
be every 30 minutes, rather than removing the not-recently-used ones.

If my reading is correct, this patch should fix it.  Am I missing
something?

Cheers,

Simon-

diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 715b57f..937743f 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -432,7 +432,7 @@ static inline void ip_vs_lblcr_full_check(struct ip_vs_service *svc)
 
 		write_lock(&svc->sched_lock);
 		list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
-			if (time_after(en->lastuse+sysctl_ip_vs_lblcr_expiration,
+			if (time_before(en->lastuse+sysctl_ip_vs_lblcr_expiration,
 				       now))
 				continue;
 

