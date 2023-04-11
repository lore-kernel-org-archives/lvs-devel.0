From: Simon Horman <horms@kernel.org>
Subject: [PATCH nf-next v2 2/4] ipvs: Consistently use array_size() in
 ip_vs_conn_init()
Date: Tue, 11 Apr 2023 09:10:40 +0200
Message-ID: <20230409-ipvs-cleanup-v2-2-204cd17da708@kernel.org>
References: <20230409-ipvs-cleanup-v2-0-204cd17da708@kernel.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1681197053;
        bh=MCcu2L3rtcfTV+OZljKLRwOcSdgy7kjk2D3O8GnMt4s=;
        h=From:Date:Subject:References:In-Reply-To:To:Cc:From;
        b=uih8j8Xibt5ZIW9rOv4ApSnJC434b/7Q39A6DJF9HYTM34gKgqiDpX2IgNa6Akaxp
         w9WX1uuGTBlZ7TjUa0apjlkJqIOapsQ+AtcCBFDkgwNa0cnPYB4X4wOEbS5SJdApSi
         Cj+kGWhtx3L5iiOtkILAO8wU7dbVG5On1ZKD/6OFkgntI9CpX71eaTzAxT3uZYuKJ4
         56r7cJJCPfMso1XY8YDqyBlvs9DUwbfg+Q+kuVsCJ8NpjXxtV/gZr1eBKNIG+IGJcP
         0QbDw1e8VJNOgscydiv01YJKwui2AcphZUbW1a2rNdI3pGcikt7lE+iY6Fk+UHGxDF
         G6MzwYpwWXxtw==
In-Reply-To: <20230409-ipvs-cleanup-v2-0-204cd17da708@kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, David Ahern <dsahern@kernel.org>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

Consistently use array_size() to calculate the size of ip_vs_conn_tab
in bytes.

Flagged by Coccinelle:
 WARNING: array_size is already used (line 1498) to compute the same size

No functional change intended.
Compile tested only.

Signed-off-by: Simon Horman <horms@kernel.org>
---
v2
* Retain division by 1024, which was lost in v1
---
 net/netfilter/ipvs/ip_vs_conn.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 13534e02346c..84d273a84dc8 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1481,6 +1481,7 @@ void __net_exit ip_vs_conn_net_cleanup(struct netns_ipvs *ipvs)
 
 int __init ip_vs_conn_init(void)
 {
+	size_t tab_array_size;
 	int idx;
 
 	/* Compute size and mask */
@@ -1494,8 +1495,9 @@ int __init ip_vs_conn_init(void)
 	/*
 	 * Allocate the connection hash table and initialize its list heads
 	 */
-	ip_vs_conn_tab = vmalloc(array_size(ip_vs_conn_tab_size,
-					    sizeof(*ip_vs_conn_tab)));
+	tab_array_size = array_size(ip_vs_conn_tab_size,
+				    sizeof(*ip_vs_conn_tab));
+	ip_vs_conn_tab = vmalloc(tab_array_size);
 	if (!ip_vs_conn_tab)
 		return -ENOMEM;
 
@@ -1508,10 +1510,8 @@ int __init ip_vs_conn_init(void)
 		return -ENOMEM;
 	}
 
-	pr_info("Connection hash table configured "
-		"(size=%d, memory=%ldKbytes)\n",
-		ip_vs_conn_tab_size,
-		(long)(ip_vs_conn_tab_size*sizeof(*ip_vs_conn_tab))/1024);
+	pr_info("Connection hash table configured (size=%d, memory=%zdKbytes)\n",
+		ip_vs_conn_tab_size / 1024, tab_array_size);
 	IP_VS_DBG(0, "Each connection entry needs %zd bytes at least\n",
 		  sizeof(struct ip_vs_conn));
 

-- 
2.30.2

