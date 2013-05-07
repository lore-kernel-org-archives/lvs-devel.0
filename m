From: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>
Subject: [PATCH] ipvs: Fix reuse connection if real server is dead
Date: Tue,  7 May 2013 23:54:40 +0200
Message-ID: <1367963680-5213-1-git-send-email-grzegorz.lyczba@gmail.com>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=x-received:from:to:cc:subject:date:message-id:x-mailer;
        bh=ADicO2kZbgqc4RMWrB8R+qYszW4sEs1cDXESCxP12iM=;
        b=yF01IceXx0xoBNphVWpcoq/SKEhh/RAnnhY7AiZuHzcVjtki5qOC7TmkXBbNuXybAL
         FklxTcMkgS2QkqvW0TdroIsHlllEecKKqBgwiWjpcFsBAB+T4iXK7cA2gnlM659TsHoX
         zK78sBny73wWeNay6Pzg2nNvjzNFdCJsQJIGh9REmBkcWsXhZ5ciGJXRb6OOeY5dhEJA
         OIlgU8DB02hQYjgnWdeqbgFRm1THotqBWveJvVlXDzPgCSg4SUlc+/aEdd2SOrWlHfXL
         4Z4hYVypWa5xZ0zbr5s18AbWg5BepWqXI4eTMuPeRJ0QItgfzhMI0njgdM6xE4F0X4mC
         ENaw==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org
Cc: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>

Expire cached connection for new TCP connection if real server is down

Signed-off-by: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>
---
 net/netfilter/ipvs/ip_vs_core.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 47edf5a..7c5f083 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1002,6 +1002,17 @@ static inline int is_tcp_reset(const struct sk_buff *skb, int nh_len)
 	return th->rst;
 }
 
+static inline int is_tcp_syn(const struct sk_buff *skb, int nh_len)
+{
+    struct tcphdr _tcph, *th;
+
+    th = skb_header_pointer(skb, nh_len, sizeof(_tcph), &_tcph);
+    if (th == NULL)
+        return 0;
+    return th->syn;
+}
+
+
 /* Handle response packets: rewrite addresses and send away...
  */
 static unsigned int
@@ -1627,6 +1638,15 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	 * Check if the packet belongs to an existing connection entry
 	 */
 	cp = pp->conn_in_get(af, skb, &iph, 0);
+
+	if (likely(cp) && likely(cp->dest) &&
+	    unlikely(!atomic_read(&cp->dest->weight)) &&
+	    iph.protocol == IPPROTO_TCP && is_tcp_syn(skb, iph.len)) {
+		ip_vs_conn_expire_now(cp);
+		__ip_vs_conn_put(cp);
+		cp = NULL;
+	}
+
 	if (unlikely(!cp) && !iph.fragoffs) {
 		/* No (second) fragments need to enter here, as nf_defrag_ipv6
 		 * replayed fragment zero will already have created the cp
-- 
1.7.5.4

