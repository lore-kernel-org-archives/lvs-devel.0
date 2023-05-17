From: Abhijeet Rastogi <abhijeet.1989@gmail.com>
Subject: [PATCH v3] ipvs: increase ip_vs_conn_tab_bits range for 64BIT
Date: Tue, 16 May 2023 20:08:49 -0700
Message-ID: <20230412-increase_ipvs_conn_tab_bits-v3-1-c813278f2d24@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1684292932; x=1686884932;
        h=cc:to:message-id:content-transfer-encoding:mime-version:subject
         :date:from:from:to:cc:subject:date:message-id:reply-to;
        bh=DSs+6uB24QK44w9F1naB79VJeaIzF8HJmSESXsE/nfc=;
        b=sWdhsl9bLRMfFle/Ew2+oyVVYeFep7p6znhcv0XovW2V5zQ/vn018/d/bSQNPrshXd
         pBGdBAgdP05ixeHfJFWvaY89/AWxXQ10OOVt+NOlRG5OCOjTfABeEj3QPc077x9xeMaE
         soT6bdiz9StI8vWYWxT3DnqSpx9mYJuZpbz3+n14RBbQI722t5owy5f8mHjnwOQzxfr1
         gb4ddwo9S8TcyvY1I+YYdXz6S0ga4usnbzZd5u38zk36JqFE6teaEfhzCFvu7fP1tnwH
         ZXPZTxO+J9bjUkVfdnzMbsTu5rtMb5Kt55N0hQk+nBRjwv5hY4gN51ZD02D87oPTKov0
         Y+yw==
X-Developer-Signature: v=1; a=ed25519-sha256; t=1684292930; l=4739;
 i=abhijeet.1989@gmail.com; s=20230412; h=from:subject:message-id;
 bh=glVc4Qz3xjraQNFbTXbbfjljYS51KjuZzBy5uGrxquw=;
 b=0ydd7p9fjVpyjPyqJB/1Y+prQR5Q3s7kl1KJ8IzWkM8A7GRfe8IYTxl8Wvm80NsJw7swqWaby
 N9zf6a+SFKvBYc902j6Jn5Na0LvsJze1/3yOk4s8M2YmIl9+zncAgtr
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
Changes in v3:
- Fix text width in Kconfig, now text is 70 columns, excluding tab.
- Link to v2: https://lore.kernel.org/r/20230412-increase_ipvs_conn_tab_bits-v2-1-994c0df018e6@gmail.com

Changes in v2:
- Lower the ranges, 27 for 64bit, 20 otherwise
- Link to v1: https://lore.kernel.org/r/20230412-increase_ipvs_conn_tab_bits-v1-1-60a4f9f4c8f2@gmail.com
---
 net/netfilter/ipvs/Kconfig      | 27 ++++++++++++++-------------
 net/netfilter/ipvs/ip_vs_conn.c |  4 ++--
 2 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index 271da8447b29..2a3017b9c001 100644
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
@@ -54,24 +55,24 @@ config	IP_VS_TAB_BITS
 
 	  Note the table size must be power of 2. The table size will be the
 	  value of 2 to the your input number power. The number to choose is
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
+	  from 8 to 27 for 64BIT(20 otherwise), the default number is 12,
+	  which means the table size is 4096. Don't input the number too
+	  small, otherwise you will lose performance on it. You can adapt the
+	  table size yourself, according to your virtual server application.
+	  It is good to set the table size not far less than the number of
+	  connections per second multiplying average lasting time of
+	  connection in the table.  For example, your virtual server gets 200
+	  connections per second, the connection lasts for 200 seconds in
+	  average in the connection table, the table size should be not far
+	  less than 200x200, it is good to set the table size 32768 (2**15).
 
 	  Another note that each connection occupies 128 bytes effectively and
 	  each hash entry uses 8 bytes, so you can estimate how much memory is
 	  needed for your box.
 
 	  You can overwrite this number setting conn_tab_bits module parameter
-	  or by appending ip_vs.conn_tab_bits=? to the kernel command line
-	  if IP VS was compiled built-in.
+	  or by appending ip_vs.conn_tab_bits=? to the kernel command line if
+	  IP VS was compiled built-in.
 
 comment "IPVS transport protocol load balancing support"
 
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

