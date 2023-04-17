From: Simon Horman <horms@kernel.org>
Subject: [PATCH nf-next v3 2/4] ipvs: Consistently use array_size() in
 ip_vs_conn_init()
Date: Mon, 17 Apr 2023 17:10:46 +0200
Message-ID: <20230409-ipvs-cleanup-v3-2-5149ea34b0b9@kernel.org>
References: <20230409-ipvs-cleanup-v3-0-5149ea34b0b9@kernel.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1681744285;
        bh=jO4SH5SYNICEVsSAgMcpOLdT5eYDNjxqRtRYykVAw9k=;
        h=From:Date:Subject:References:In-Reply-To:To:Cc:From;
        b=Xa8XIpFrXoflrJBQKG7si4QG+0+RGUdY/4Ko5Z41kDhHwhPE2skB8OCOMXsC3R0st
         hrN9wcf2uokQC/+eaP5Xt3j9/zzCO9Om6XZm1Bbe1YEm74QvOfm0V0qRFGDTGoZhvn
         mImIMqsCoaKKlae40Rjexr+/KI+j+9MESb4pbiCSknd6svf2itMNfN//eAh7bWjjo2
         NRObpOgXCqgCPaMYn8G8XTkGfs3NPHHe4RXmYqCUcBX1HIL3MeX4gFNr+lQ35MjTm/
         ebZamN4OEoyFT6f/srItZ66jOLcqaGwoUTfR4M87xWypmCR/PZwibDL+3W+J6jYjC6
         2h4A6BCartadQ==
In-Reply-To: <20230409-ipvs-cleanup-v3-0-5149ea34b0b9@kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, David Ahern <dsahern@kernel.org>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, Horatiu Vultur <horatiu.vultur@microchip.com>

Consistently use array_size() to calculate the size of ip_vs_conn_tab
in bytes.

Flagged by Coccinelle:
 WARNING: array_size is already used (line 1498) to compute the same size

No functional change intended.
Compile tested only.

Signed-off-by: Simon Horman <horms@kernel.org>
Reviewed-by: Horatiu Vultur <horatiu.vultur@microchip.com>
---
v3
- Correct division by 1024. It was applied to the wrong variable in v2.
- Add Horatiu's Reviewed-by tag
v2
- Retain division by 1024, which was lost in v1
---
 net/netfilter/ipvs/ip_vs_conn.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 13534e02346c..928e64653837 100644
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
+		ip_vs_conn_tab_size, tab_array_size / 1024);
 	IP_VS_DBG(0, "Each connection entry needs %zd bytes at least\n",
 		  sizeof(struct ip_vs_conn));
 

-- 
2.30.2

