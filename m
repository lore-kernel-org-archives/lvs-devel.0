From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 02/16] ipv4: Fix ip_queue_xmit to pass sk into ip_local_out_sk
Date: Wed,  7 Oct 2015 16:48:33 -0500
Message-ID: <1444254527-17833-2-git-send-email-ebiederm@xmission.com>
References: <87bnca4aie.fsf_-_@x220.int.ebiederm.org>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <87bnca4aie.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

After a packet has been encapsulated by a tunnel we should use the
tunnel sockets local multicast loopback flag to control if the
encapsulated packet should be locally loopback back.

Pass sk into ip_local_out_sk so that in the rare case we are dealing
with a tunneled packet whose tunnel destination address is a multicast
address the kernel properly decides to loopback this packet.

In practice I don't think this matters as ip_queue_xmit is used by
tcp, l2tp and sctp none of which I am aware of uses ip level
multicasting as they are all point to point communications protocols.
Let's fix this before someone uses ip_queue_xmit for a tunnel protocol
that does use multicast.

Fixes: aad88724c9d5 ("ipv4: add a sock pointer to dst->output() path.")
Fixes: b0270e91014d ("ipv4: add a sock pointer to ip_queue_xmit()")
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/ip_output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 6cb585a05dd1..1030f48d66e1 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -460,7 +460,7 @@ packet_routed:
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
 
-	res = ip_local_out(skb);
+	res = ip_local_out_sk(sk, skb);
 	rcu_read_unlock();
 	return res;
 
-- 
2.2.1
