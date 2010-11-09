From: Simon Horman <horms@verge.net.au>
Subject: Re: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence support
Date: Tue, 9 Nov 2010 09:43:37 +0900
Message-ID: <20101109004336.GI6502@verge.net.au>
References: <20101106005614.GA11220@verge.net.au>
 <alpine.LFD.2.00.1011061543130.4009@ja.ssi.bg>
 <20101106143405.GB27212@verge.net.au>
 <alpine.LFD.2.00.1011061959370.5280@ja.ssi.bg>
 <20101108062121.GA17685@verge.net.au>
 <alpine.LFD.2.00.1011081027080.1504@ja.ssi.bg>
 <20101108111600.GA14454@verge.net.au>
 <alpine.LFD.2.00.1011082245360.1690@ja.ssi.bg>
 <20101108214943.GC6502@verge.net.au>
 <alpine.LFD.2.00.1011090056220.2588@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1011090056220.2588@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>

On Tue, Nov 09, 2010 at 01:01:46AM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 9 Nov 2010, Simon Horman wrote:
> 
> >>- backup creates template but there is no PE => cp->pe remains NULL if
> >>	we want to keep conn entry. Option 2 is that we can ignore
> >>	the conn entry if the PE module is not loaded before this step
> >
> >I think that is better to drop the entry as (at least the way PE SIP works)
> >its entirely likely that it could be used by the scheduler to use
> >the wont real server if the pe_data is missing. Or in other words,
> >it is no better than the entry being missing all together.
> 
> 	Agreed.
> 
> >If later we have PE engines that behave differently, and creating
> >templates without pe_data makes sense, we can revisit this.
> >
> >>- svc is added => PE module is loaded (request_module)
> >>
> >>- next sync message comes and we bind cp->dest => if cp->pe
> >>is NULL we should set cp->pe to svc->pe. The problem here is
> >>that svc can be added without PE, then this template will not
> >>work as expected.
> >
> >I'm unsure what you mean by "svc can be added without PE"
> 
> 	-A without --pe [engine] option in backup.

I think that is ok because of the change made
by "IPVS: Only match pe_data created by the same pe".
That is, the template will never match.

From 12933de34a16c6585bd2a388ac0d48ef5c5599fa Mon Sep 17 00:00:00 2001
From: Simon Horman <horms@verge.net.au>
Date: Mon, 8 Nov 2010 20:06:30 +0900
Subject: [PATCH] IPVS: Only match pe_data created by the same pe

Only match persistence engine data if it was
created by the same persistence engine.

Reported-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_conn.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 44df5f0..0e0604c 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -354,7 +354,7 @@ struct ip_vs_conn *ip_vs_ct_in_get(const struct ip_vs_conn_param *p)
 
 	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
 		if (p->pe_data && p->pe->ct_match) {
-			if (p->pe->ct_match(p, cp))
+			if (p->pe == cp->pe && p->pe->ct_match(p, cp))
 				goto out;
 			continue;
 		}
-- 
1.7.1

