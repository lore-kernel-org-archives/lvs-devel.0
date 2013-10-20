From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net 3/3] netfilter: nf_conntrack: fix rt6i_gateway checks for H.323 helper
Date: Sun, 20 Oct 2013 15:43:05 +0300
Message-ID: <1382272985-1528-4-git-send-email-ja@ssi.bg>
References: <1382272985-1528-1-git-send-email-ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1382272985-1528-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Now when rt6_nexthop() can return nexthop address we can use it
for proper nexthop comparison of directly connected destinations.
For more information refer to commit bbb5823cf742a7
("netfilter: nf_conntrack: fix rt_gateway checks for H.323 helper").

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/netfilter/nf_conntrack_h323_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index bdebd03..70866d1 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -778,8 +778,8 @@ static int callforward_do_filter(const union nf_inet_addr *src,
 				   flowi6_to_flowi(&fl1), false)) {
 			if (!afinfo->route(&init_net, (struct dst_entry **)&rt2,
 					   flowi6_to_flowi(&fl2), false)) {
-				if (!memcmp(&rt1->rt6i_gateway, &rt2->rt6i_gateway,
-					    sizeof(rt1->rt6i_gateway)) &&
+				if (ipv6_addr_equal(rt6_nexthop(rt1),
+						    rt6_nexthop(rt2)) &&
 				    rt1->dst.dev == rt2->dst.dev)
 					ret = 1;
 				dst_release(&rt2->dst);
-- 
1.8.3.1
