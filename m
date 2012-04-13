From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re: [PATCH 1/6] ipvs: timeout tables do not need GFP_ATOMIC 
	allocation
Date: Fri, 13 Apr 2012 22:14:19 +0200 (CEST)
Message-ID: <6dfqp4f.b2278bba6d7c32d57e4d73422014448c@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

Hello
All 6 patches look fine to me, and are all called from process context

>---- Original Message ----
>From: Julian Anastasov <ja@ssi.bg>
>To: "Simon Horman" <horms@verge.net.au>
>Cc: lvs-devel@vger.kernel.org
>Sent: Fri, Apr 13, 2012, 3:49 PM
>Subject: [PATCH 1/6] ipvs: timeout tables do not need GFP_ATOMIC allocation
>
>They are called only on initialization.
>
>Signed-off-by: Julian Anastasov <ja@ssi.bg>

Signed-off-by: Hans Schillstrom <hans@schillstrom.com>

>---
> net/netfilter/ipvs/ip_vs_proto.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
>diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
>index 8531293..f549ff7 100644
>--- a/net/netfilter/ipvs/ip_vs_proto.c
>+++ b/net/netfilter/ipvs/ip_vs_proto.c
>@@ -197,7 +197,7 @@ void ip_vs_protocol_timeout_change(struct netns_ipvs *ipvs, int flags)
> int *
> ip_vs_create_timeout_table(int *table, int size)
> {
>-	return kmemdup(table, size, GFP_ATOMIC);
>+	return kmemdup(table, size, GFP_KERNEL);
> }
> 
> 
>-- 
>1.7.3.4
>
>--
>To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

