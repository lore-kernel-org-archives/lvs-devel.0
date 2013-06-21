From: Alexander Frolkin <avf@eldamar.org.uk>
Subject: Re: [PATCH] ipvs: SH fallback and L4 hashing
Date: Fri, 21 Jun 2013 09:24:08 +0100
Message-ID: <20130621082408.GB23366@eldamar.org.uk>
References: <20130619095425.GA20145@eldamar.org.uk>
 <alpine.LFD.2.00.1306192239510.1823@ja.ssi.bg>
 <20130620132003.GD24993@verge.net.au>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130620132003.GD24993@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

> I also noticed some fuzz.
> Alexander, could you double-check ipvs-next to make sure
> that I applied the patch correctly?

I diff'ed my local dev branch with upstream, and the only thing I can
see that has any relation to my patches is:

diff --git a/net/netfilter/ipvs/ip_vs_sh.c b/net/netfilter/ipvs/ip_vs_sh.c
index b7e2c5a..f16c027 100644
--- a/net/netfilter/ipvs/ip_vs_sh.c
+++ b/net/netfilter/ipvs/ip_vs_sh.c
@@ -71,8 +71,8 @@ struct ip_vs_sh_bucket {
 #define IP_VS_SH_TAB_MASK               (IP_VS_SH_TAB_SIZE - 1)
 
 struct ip_vs_sh_state {
-       struct ip_vs_sh_bucket          buckets[IP_VS_SH_TAB_SIZE];
        struct rcu_head                 rcu_head;
+       struct ip_vs_sh_bucket          buckets[IP_VS_SH_TAB_SIZE];
 };
 
 /* Helper function to determine if server is unavailable */

Not sure when or why this changed, but maybe it accounts for the fuzz?


Alex
