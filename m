From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipvs: use u64 to silence do_div warnings
Date: Mon, 12 Dec 2022 21:58:45 +0200
Message-ID: <20221212195845.101844-1-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Jiri Wiesner <jwiesner@suse.de>

Fix the following warning from kernel test robot:

All warnings (new ones prefixed by >>):

   In file included from ./arch/arc/include/generated/asm/div64.h:1,
                    from include/linux/math.h:6,
                    from include/linux/kernel.h:25,
                    from net/netfilter/ipvs/ip_vs_est.c:18:
   net/netfilter/ipvs/ip_vs_est.c: In function 'ip_vs_est_calc_limits':
>> include/asm-generic/div64.h:222:35: warning: comparison of distinct pointer types lacks a cast
     222 |         (void)(((typeof((n)) *)0) == ((uint64_t *)0));  \
         |                                   ^~
   net/netfilter/ipvs/ip_vs_est.c:688:17: note: in expansion of macro 'do_div'
     688 |                 do_div(val, loops);
         |                 ^~~~~~
>> include/asm-generic/div64.h:222:35: warning: comparison of distinct pointer types lacks a cast
     222 |         (void)(((typeof((n)) *)0) == ((uint64_t *)0));  \
         |                                   ^~
   net/netfilter/ipvs/ip_vs_est.c:694:33: note: in expansion of macro 'do_div'
     694 |                                 do_div(val, min_est);
         |                                 ^~~~~~

Reported-by: kernel test robot <lkp@intel.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/ipvs/ip_vs_est.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index df56073bb282..5473328f367f 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -638,11 +638,12 @@ static int ip_vs_est_calc_limits(struct netns_ipvs *ipvs, int *chain_max)
 	struct ip_vs_stats *s;
 	int cache_factor = 4;
 	int i, loops, ntest;
-	s32 min_est = 0;
+	u32 min_est = 0;
 	ktime_t t1, t2;
-	s64 diff, val;
 	int max = 8;
 	int ret = 1;
+	s64 diff;
+	u64 val;
 
 	INIT_HLIST_HEAD(&chain);
 	mutex_lock(&__ip_vs_mutex);
-- 
2.38.1


