From: Yaroslav Bolyukin <iam@lach.pw>
Subject: [PATCH] Remove ipvs v6 dependency on iptables
Date: Sat, 29 Aug 2020 13:50:05 +0500
Message-ID: <20200829085005.24931-1-iam@lach.pw>
References: <e4765a73-e6a1-f5ba-dd8b-7c1ee1e5883d@6wind.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e4765a73-e6a1-f5ba-dd8b-7c1ee1e5883d@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: ja@ssi.bg, Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: iam@lach.pw, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Jakub Kicinski <kuba@kernel.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

This dependency was added as part of commit ecefa32ffda201975
("ipvs: Fix faulty IPv6 extension header handling in IPVS"), because it
had dependency on ipv6_find_hdr, which was located in iptables-specific
code

But it is no longer required after commit e6f890cfde0e74d5b
("ipv6:Move ipv6_find_hdr() out of Netfilter code.")

Also remove ip6tables include from ip_vs

Signed-off-by: Yaroslav Bolyukin <iam@lach.pw>
---
 include/net/ip_vs.h        | 3 ---
 net/netfilter/ipvs/Kconfig | 1 -
 2 files changed, 4 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 9a59a3378..d609e957a 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -25,9 +25,6 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>			/* for struct ipv6hdr */
 #include <net/ipv6.h>
-#if IS_ENABLED(CONFIG_IP_VS_IPV6)
-#include <linux/netfilter_ipv6/ip6_tables.h>
-#endif
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 #include <net/netfilter/nf_conntrack.h>
 #endif
diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index 2c1593089..eb0e329f9 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -29,7 +29,6 @@ if IP_VS
 config	IP_VS_IPV6
 	bool "IPv6 support for IPVS"
 	depends on IPV6 = y || IP_VS = IPV6
-	select IP6_NF_IPTABLES
 	select NF_DEFRAG_IPV6
 	help
 	  Add IPv6 support to IPVS.
-- 
2.28.0

