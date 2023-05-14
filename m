From: Abhijeet Rastogi <abhijeet.1989@gmail.com>
Subject: [PATCH v2] ipvs: increase ip_vs_conn_tab_bits range for 64BIT
Date: Sun, 14 May 2023 13:40:24 -0700
Message-ID: <20230412-increase_ipvs_conn_tab_bits-v2-1-994c0df018e6@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1684096833; x=1686688833;
        h=cc:to:message-id:content-transfer-encoding:mime-version:subject
         :date:from:from:to:cc:subject:date:message-id:reply-to;
        bh=zwPLcczfHaotQQ5Bh17U80i7Ky8OX0CQkStxEqL6Fgc=;
        b=arhp3JVNanZ3mDqxFjZiB8gxrZ2yc95p3ehPSMQFIs0pBDN4GbhW15bAYkDArYXWxe
         PNRazoUGwkZcqLpQTzdbfWNgij0PHRAnzd64cRaFqsHE+iwK1VV3UMB33oKkJFL3vI7V
         Nj/9qGw2lSCmCIxYcoayNVOK4aQFrp47AfwYIWqXxUNZ0m4Xj5yI1KpQ/5d9Dxf9T6zV
         hWYgREcS4L5Z9Pkapd8Zr0mdgoz7WOJC6wikeSf4VIRhKz3L+K9QfzxzYQig4MXwTpb1
         jGf2NXr7bbPLPgYzbHpv2YYvrgWkUCNGbz+QNuu0nutgKO/mDlJHxiY+I1Hl0SoNIGlI
         wQIQ==
X-Developer-Signature: v=1; a=ed25519-sha256; t=1684096831; l=4400;
 i=abhijeet.1989@gmail.com; s=20230412; h=from:subject:message-id;
 bh=QKVsMjlQX/gTjNeKg6CZJYA0FFD+ARtEhFp33qX1UfA=;
 b=sDfvG6taPYG+iOeJr8xKMiapaAP0Fg4ONAtQiELClNWJMnRmkP3Q2skQOHBpGSL7wsrR+M1YZ
 WxQ2My9Kk2YArg0ZTXCHQZxUctAsIDaldhamEzKBnYNpDguqE6Era3r
X-Developer-Key: i=abhijeet.1989@gmail.com; a=ed25519;
 pk=VinODWUuJys1VAWZP2Uv9slcHekoZvxAp4RY1p5+OfU=
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, Abhijeet Rastogi <abhijeet.1989@gmail.com>

Current range [8, 20] is set purely due to historical reasons
because at the time, ~1M (2^20) was considered sufficient.
With this change, 27 is the upper limit for 64-bit, 20 otherwise.

Previous change regarding this limit is here.

Link: https://lore.kernel.org/all/86eabeb9dd62aebf1e2533926fdd13fed48bab1f.1631289960.git.aclaudi@redhat.com/T/#u

Signed-off-by: Abhijeet Rastogi <abhijeet.1989@gmail.com>
---
The conversation for this started at: 

https://www.spinics.net/lists/netfilter/msg60995.html

The upper limit for algo is any bit size less than 32, so this
change will allow us to set bit size > 20. Today, it is common to have
RAM available to handle greater than 2^20 connections per-host.

Distros like RHEL already allow setting limits higher than 20.
---
Changes in v2:
- Lower the ranges, 27 for 64bit, 20 otherwise
- Link to v1: https://lore.kernel.org/r/20230412-increase_ipvs_conn_tab_bits-v1-1-60a4f9f4c8f2@gmail.com
---
 net/netfilter/ipvs/Kconfig      | 26 +++++++++++++-------------
 net/netfilter/ipvs/ip_vs_conn.c |  4 ++--
 2 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index 271da8447b29..aac5d6bd82e6 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -44,7 +44,8 @@ config	IP_VS_DEBUG
 
 config	IP_VS_TAB_BITS
 	int "IPVS connection table size (the Nth power of 2)"
-	range 8 20
+	range 8 20 if !64BIT
+	range 8 27 if 64BIT
 	default 12
 	help
 	  The IPVS connection hash table uses the chaining scheme to handle
@@ -52,18 +53,17 @@ config	IP_VS_TAB_BITS
 	  reduce conflicts when there are hundreds of thousands of connections
 	  in the hash table.
 
-	  Note the table size must be power of 2. The table size will be the
-	  value of 2 to the your input number power. The number to choose is
-	  from 8 to 20, the default number is 12, which means the table size
-	  is 4096. Don't input the number too small, otherwise you will lose
-	  performance on it. You can adapt the table size yourself, according
-	  to your virtual server application. It is good to set the table size
-	  not far less than the number of connections per second multiplying
-	  average lasting time of connection in the table.  For example, your
-	  virtual server gets 200 connections per second, the connection lasts
-	  for 200 seconds in average in the connection table, the table size
-	  should be not far less than 200x200, it is good to set the table
-	  size 32768 (2**15).
+	  Note the table size must be power of 2. The table size will be the value
+	  of 2 to the your input number power. The number to choose is from 8 to 27
+	  for 64BIT(20 otherwise), the default number is 12, which means the table
+	  size is 4096. Don't input the number too small, otherwise you will lose
+	  performance on it. You can adapt the table size yourself, according to
+	  your virtual server application. It is good to set the table size not far
+	  less than the number of connections per second multiplying average lasting
+	  time of connection in the table.  For example, your virtual server gets
+	  200 connections per second, the connection lasts for 200 seconds in
+	  average in the connection table, the table size should be not far less
+	  than 200x200, it is good to set the table size 32768 (2**15).
 
 	  Another note that each connection occupies 128 bytes effectively and
 	  each hash entry uses 8 bytes, so you can estimate how much memory is
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 13534e02346c..e1b9b52909a5 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1484,8 +1484,8 @@ int __init ip_vs_conn_init(void)
 	int idx;
 
 	/* Compute size and mask */
-	if (ip_vs_conn_tab_bits < 8 || ip_vs_conn_tab_bits > 20) {
-		pr_info("conn_tab_bits not in [8, 20]. Using default value\n");
+	if (ip_vs_conn_tab_bits < 8 || ip_vs_conn_tab_bits > 27) {
+		pr_info("conn_tab_bits not in [8, 27]. Using default value\n");
 		ip_vs_conn_tab_bits = CONFIG_IP_VS_TAB_BITS;
 	}
 	ip_vs_conn_tab_size = 1 << ip_vs_conn_tab_bits;

---
base-commit: 09a9639e56c01c7a00d6c0ca63f4c7c41abe075d
change-id: 20230412-increase_ipvs_conn_tab_bits-4322c90da216

Best regards,
-- 
Abhijeet Rastogi <abhijeet.1989@gmail.com>

