From: Jakub Kicinski <kuba@kernel.org>
Subject: [PATCH net-next] ipvs: fix type warning in do_div() on 32 bit
Date: Mon, 12 Dec 2022 19:20:37 -0800
Message-ID: <20221213032037.844517-1-kuba@kernel.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1670901641;
        bh=fNJ0HmIL0o/ygNc/5g8Y2/L+rcNUzRLfm5SoXCV5ny4=;
        h=From:To:Cc:Subject:Date:From;
        b=nn8AJtTWF6VS/D+U24ClC9evCfOXHIzOwm3bhhm3vjTtFxOcdR8lzQccO3Bc+kktm
         CluQQZPXo+ud0mBk+YsLzFmUI6RrJu3CEcTkYJsnALoVqfxgb7vpxA5QgkfJidRn6S
         1U06sipvsois9LY/GLZIEWZdeZE0I0JJesEMsaZri2foyOA7ljhs6gFBKDhzwtSvNV
         xhYNGq30C0FF2xeKapXLRceBnA4WkGhfJYTFFlK/Jq1bSdZG9RalU+vJEcFNztfClc
         hxChvPuS7N5MPefEZnWzWlzOOgw2DlypEXMftdMo5YKxk2rv6V2nzSjVjgI0ioEhEf
         6S0RdlBo9h7Gg==
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: davem@davemloft.net
Cc: netdev@vger.kernel.org, edumazet@google.com, pabeni@redhat.com, Jakub Kicinski <kuba@kernel.org>, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, jwiesner@suse.de, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

32 bit platforms without 64bit div generate the following warning:

net/netfilter/ipvs/ip_vs_est.c: In function 'ip_vs_est_calc_limits':
include/asm-generic/div64.h:222:35: warning: comparison of distinct pointer types lacks a cast
  222 |         (void)(((typeof((n)) *)0) == ((uint64_t *)0));  \
      |                                   ^~
net/netfilter/ipvs/ip_vs_est.c:694:17: note: in expansion of macro 'do_div'
  694 |                 do_div(val, loops);
      |                 ^~~~~~
include/asm-generic/div64.h:222:35: warning: comparison of distinct pointer types lacks a cast
  222 |         (void)(((typeof((n)) *)0) == ((uint64_t *)0));  \
      |                                   ^~
net/netfilter/ipvs/ip_vs_est.c:700:33: note: in expansion of macro 'do_div'
  700 |                                 do_div(val, min_est);
      |                                 ^~~~~~

first argument of do_div() should be unsigned. We can't just cast
as do_div() updates it as well, so we need an lval.
Make val unsigned in the first place, all paths check that the value
they assign to this variables are non-negative already.

Fixes: 705dd3444081 ("ipvs: use kthreads for stats estimation")
Signed-off-by: Jakub Kicinski <kuba@kernel.org>
---
CC: horms@verge.net.au
CC: ja@ssi.bg
CC: pablo@netfilter.org
CC: kadlec@netfilter.org
CC: fw@strlen.de
CC: jwiesner@suse.de
CC: lvs-devel@vger.kernel.org
CC: netfilter-devel@vger.kernel.org
CC: coreteam@netfilter.org
---
 net/netfilter/ipvs/ip_vs_est.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index df56073bb282..ce2a1549b304 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -640,9 +640,10 @@ static int ip_vs_est_calc_limits(struct netns_ipvs *ipvs, int *chain_max)
 	int i, loops, ntest;
 	s32 min_est = 0;
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

