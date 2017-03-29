From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH v2] net: netfilter: remove unused variable
Date: Wed, 29 Mar 2017 20:27:52 +0530
Message-ID: <20170329145752.GA2756@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=3XQN62EmkyX8Ldsf00IjOVt9RVQiL/EJtBFvd7+JkWM=;
        b=GF6pqpW3P55fuLjC6a3LaZ+SmHZ5zStFw8qhx2k9Pn43uetmdcTtyWZx93oPM25moz
         h3ip2qT1HTeoSJSPmDLiH5tHdc1zcN5VzNN8+YngLPB294BdW85876S04EZpPbqHYmu3
         nsDEdsJXM+Wr1b4M/2x6+1JaxX88HQlvSA7GL9nVoD7nodENq3bNsLZfSXny8f/5jiPG
         +B+ETsxcmKiejGgm+fUHMzGYI+lnNqa/582EAkYKT0JXpmdYbppXI+gQ5kyg9frCf+Qg
         1SBad5GYYgFon8fYq7YDRFJ7f0dVpp233H7QhjovlO8A1DGUo58diqEPA3h88wTSEs0R
         diwA==
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
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
changes in v2
   - remove extra blank line.

 net/netfilter/ipvs/ip_vs_ftp.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index d30c327bb578..c93c93762354 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -482,11 +482,8 @@ static struct pernet_operations ip_vs_ftp_ops = {
 
 static int __init ip_vs_ftp_init(void)
 {
-	int rv;
-
-	rv = register_pernet_subsys(&ip_vs_ftp_ops);
 	/* rcu_barrier() is called by netns on error */
-	return rv;
+	return register_pernet_subsys(&ip_vs_ftp_ops);
 }
 
 /*
-- 
2.11.0

