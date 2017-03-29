From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH] net: netfilter: remove unused variable
Date: Wed, 29 Mar 2017 19:08:48 +0530
Message-ID: <20170329133848.GA1336@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=ypA+//v/a5SGLQmIrHZC4stfiuP/OS4YOvJUKdJo4yo=;
        b=eLCgPtrADQ9LXJE2fjaMDobv5ZDW1aHY8//Zg/T5ov5p9lpBtLz2DjoXQKM82kJSg2
         s8UrUuHbB+CHBGiiaucjVEJ41lD2KexvxF7HDl/cIbKn3CtkARVGV5OuGiBjhkYQE5Nt
         OY4xw7ScNPxeQjyhxwHie17XG78xt+xyDmuROSPaEyanBUxRjKR/CouhJYfNAe2Irta6
         skXpQ2b2NMlaXn9W+YaHwEEkRD/x5SPk5XUD3ZoDI3ToEjjIXp5zovNRALWsf/5uZt9l
         OUWg/8bCkSi91XD+fbqAsXVDtEnwc3xtz74CTCf9HILDfK1wVHwiWBGH5cPM/pL2Ba0A
         a6Yw==
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: outreachy-kernel@googlegroups.com
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

This patch uses the following coccinelle script to remove
a variable that was simply used to store the return
value of a function call before returning it:

@@
identifier len,f;
@@

-int len;
 ... when != len
     when strict
-len =
+return
        f(...);
-return len;

Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
---
 net/netfilter/ipvs/ip_vs_ftp.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index d30c327bb578..9e1e682610ef 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -482,11 +482,9 @@ static struct pernet_operations ip_vs_ftp_ops = {
 
 static int __init ip_vs_ftp_init(void)
 {
-	int rv;
 
-	rv = register_pernet_subsys(&ip_vs_ftp_ops);
 	/* rcu_barrier() is called by netns on error */
-	return rv;
+	return register_pernet_subsys(&ip_vs_ftp_ops);
 }
 
 /*
-- 
2.11.0

