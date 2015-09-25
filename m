From: Jiri Bohac <jbohac@suse.cz>
Subject: [PATCH] ipvs: drop first packet to dead server
Date: Fri, 25 Sep 2015 11:37:38 +0200
Message-ID: <20150925093737.GA5047@midget.suse.cz>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

Since commit dc7b3eb9 (ipvs: Fix reuse connection if real server
is dead), new connections to dead servers are redistributed
immediately to new servers.  The old connection is expired using
ip_vs_conn_expire_now() which sets the connection timer to expire
immediately. 

However, before the timer callback, ip_vs_conn_expire(), is run
to clean the connection's conntrack entry, the new redistributed
connection may already be established and its conntrack removed
instead.

Fix this by dropping the first packet of the new connection
instead, like we do when the destination server is not available.
The timer will have deleted the old conntrack entry long before
the first packet of the new connection is retransmitted.

Signed-off-by: Jiri Bohac <jbohac@suse.cz>


diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index d1d6b82..3f884b8 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1657,7 +1657,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 	    is_new_conn(skb, &iph)) {
 		ip_vs_conn_expire_now(cp);
 		__ip_vs_conn_put(cp);
-		cp = NULL;
+		return NF_DROP;
 	}
 
 	if (unlikely(!cp) && !iph.fragoffs) {

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
