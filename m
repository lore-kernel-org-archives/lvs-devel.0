From: Jiri Bohac <jbohac@suse.cz>
Subject: [PATCH v2] ipvs: drop first packet to dead server
Date: Fri, 25 Sep 2015 11:48:20 +0200
Message-ID: <20150925094820.GB5047@midget.suse.cz>
References: <20150925093737.GA5047@midget.suse.cz>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150925093737.GA5047@midget.suse.cz>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

[ original diff was against and older tree, sorry; 
  rediffed against net-next ]

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
index 1fa12ed..8134881 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1785,7 +1785,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 		if (!atomic_read(&cp->n_control))
 			ip_vs_conn_expire_now(cp);
 		__ip_vs_conn_put(cp);
-		cp = NULL;
+		return NF_DROP;
 	}
 
 	if (unlikely(!cp)) {
