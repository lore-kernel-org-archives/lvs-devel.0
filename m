From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net 4/4] ipvs: stats should not depend on CPU 0
Date: Fri, 30 Aug 2013 17:58:20 +0900
Message-ID: <20130830085819.GA13017@verge.net.au>
References: <1377848768.12846.122.camel@hawk.mlab.se>
 <alpine.LFD.2.00.1308301029350.1837@ja.ssi.bg>
 <20130830085332.GA10484@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130830085332.GA10484@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>, Hans Schillstrom <hans@schillstrom.com>
Cc: lvs-devel@vger.kernel.org

On Fri, Aug 30, 2013 at 05:53:32PM +0900, Simon Horman wrote:
> On Fri, Aug 30, 2013 at 10:31:57AM +0300, Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Fri, 30 Aug 2013, Simon Horman wrote:
> > 
> > > [ Cc: Hans Schillstrom ]
> > > 
> > > On Wed, Aug 28, 2013 at 07:29:36PM +0300, Julian Anastasov wrote:
> > > > When reading percpu stats we need to properly reset
> > > > the sum when CPU 0 is not present in the possible mask.
> > > 
> > > It seems reasonable to me that this condition could occur,
> > > though I am not aware of a specific case where that is so.
> > > 
> > > Can I confirm that this problem was introduced by
> > > b17fc9963f837ef1 ("IPVS: netns, ip_vs_stats and its procfs")?
> > 
> > 	That is correct, I forgot to track the initial
> > commit, you can freely add such information before
> > applying.
> > 
> > Regards
> > 
> > --
> > Julian Anastasov <ja@ssi.bg>
> > 
> 
> On Fri, Aug 30, 2013 at 09:46:08AM +0200, Hans Schillstrom wrote:
> > 
> > On Wed, 2013-08-28 at 19:29 +0300, Julian Anastasov wrote:
> > > When reading percpu stats we need to properly reset
> > > the sum when CPU 0 is not present in the possible mask.
> > 
> > Not a very common case, but still possible.
> > 
> > > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > 
> > Acked-by: Hans Schillstrom <hans@schillstrom.com>
> 
> 
> Thanks guys, I have queued up the following in the ipvs tree
> along with the rest of this series.

Bother, I messed up the commit-id in the changelog.
The corrected version, which I will queue up, is.

From 77f12c00cd6603e93dcb729aa6dc206cb8bb3a46 Mon Sep 17 00:00:00 2001
From: Julian Anastasov <ja@ssi.bg>
Date: Wed, 28 Aug 2013 19:29:36 +0300
Subject: [PATCH] ipvs: stats should not depend on CPU 0

When reading percpu stats we need to properly reset
the sum when CPU 0 is not present in the possible mask.

This problem was introduced by b17fc9963f837ef1
("IPVS: netns, ip_vs_stats and its procfs").

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Acked-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_est.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 6bee6d0..1425e9a 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -59,12 +59,13 @@ static void ip_vs_read_cpu_stats(struct ip_vs_stats_user *sum,
 				 struct ip_vs_cpu_stats __percpu *stats)
 {
 	int i;
+	bool add = false;
 
 	for_each_possible_cpu(i) {
 		struct ip_vs_cpu_stats *s = per_cpu_ptr(stats, i);
 		unsigned int start;
 		__u64 inbytes, outbytes;
-		if (i) {
+		if (add) {
 			sum->conns += s->ustats.conns;
 			sum->inpkts += s->ustats.inpkts;
 			sum->outpkts += s->ustats.outpkts;
@@ -76,6 +77,7 @@ static void ip_vs_read_cpu_stats(struct ip_vs_stats_user *sum,
 			sum->inbytes += inbytes;
 			sum->outbytes += outbytes;
 		} else {
+			add = true;
 			sum->conns = s->ustats.conns;
 			sum->inpkts = s->ustats.inpkts;
 			sum->outpkts = s->ustats.outpkts;
-- 
1.8.3.2

