From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH net-next] ipvs: missing unlock in
 ip_vs_expire_nodest_conn_flush()
Date: Fri, 17 Jul 2020 17:10:29 +0300
Message-ID: <20200717141029.GA21445@mwanda>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : mime-version : content-type; s=corp-2020-01-29;
 bh=Mv5dydH0r53hroQIradq8z6oy8JvVlHpZdHz/hKyd3A=;
 b=0ie1bOU7QvEoU/mGpDVdqzu7MmqJbqPFBT215/ITEkS5khJWLwgZ6tOWk1Yh1u2pzP3p
 UflvG7CDFEfaC+Hmrn/xOoGYNwdqGskK5ZjZGAtatexaB18yM8u3HQPDSl9sm9EyDl5d
 hrUH837hBd6Wvq3GFmNnIyzaFs/Cvoz66CQe5velV1/zir6458ZfkjTGNQCRsSKGw4tX
 737YqQns4WemWhXaRC0bhIsvmpEBt2aEq5O9NcZT+sCZBvNrtmX6hKvaxcpcpitBbmIv
 5WuJCL5MsBL6mHkOZ/CPsNaAmORF5gOPBGiyUV00cFHf39h1mVQcqUVyuwcVyv8o8hgs uA== 
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, Jakub Kicinski <kuba@kernel.org>, Andrew Sy Kim <kim.andrewsy@gmail.com>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, kernel-janitors@vger.kernel.org

We can't return without calling rcu_read_unlock().

Fixes: 04231e52d355 ("ipvs: queue delayed work to expire no destination connections if expire_nodest_conn=1")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 net/netfilter/ipvs/ip_vs_conn.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index a5e9b2d55e57..a90b8eac16ac 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1422,7 +1422,7 @@ void ip_vs_expire_nodest_conn_flush(struct netns_ipvs *ipvs)
 
 		/* netns clean up started, abort delayed work */
 		if (!ipvs->enable)
-			return;
+			break;
 	}
 	rcu_read_unlock();
 }
-- 
2.27.0

