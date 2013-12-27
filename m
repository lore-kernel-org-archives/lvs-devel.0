From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next] ipvs: Remove unused variable ret from sync_thread_master()
Date: Fri, 27 Dec 2013 12:46:12 +0900
Message-ID: <1388115972-11861-2-git-send-email-horms@verge.net.au>
References: <1388115972-11861-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1388115972-11861-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Geert Uytterhoeven <geert@linux-m68k.org>, Simon Horman <horms@verge.net.au>

From: Geert Uytterhoeven <geert@linux-m68k.org>

net/netfilter/ipvs/ip_vs_sync.c: In function 'sync_thread_master':
net/netfilter/ipvs/ip_vs_sync.c:1640:8: warning: unused variable 'ret' [-Wunused-variable]

Commit 35a2af94c7ce7130ca292c68b1d27fcfdb648f6b ("sched/wait: Make the
__wait_event*() interface more friendly") changed how the interruption
state is returned. However, sync_thread_master() ignores this state,
now causing a compile warning.

According to Julian Anastasov <ja@ssi.bg>, this behavior is OK:

    "Yes, your patch looks ok to me. In the past we used ssleep() but IPVS
     users were confused why IPVS threads increase the load average. So, we
     switched to _interruptible calls and later the socket polling was
     added."

Document this, as requested by Peter Zijlstra, to avoid precious developers
disappearing in this pitfall in the future.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index f63c238..db80126 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1637,7 +1637,10 @@ static int sync_thread_master(void *data)
 			continue;
 		}
 		while (ip_vs_send_sync_msg(tinfo->sock, sb->mesg) < 0) {
-			int ret = __wait_event_interruptible(*sk_sleep(sk),
+			/* (Ab)use interruptible sleep to avoid increasing
+			 * the load avg.
+			 */
+			__wait_event_interruptible(*sk_sleep(sk),
 						   sock_writeable(sk) ||
 						   kthread_should_stop());
 			if (unlikely(kthread_should_stop()))
-- 
1.8.4

