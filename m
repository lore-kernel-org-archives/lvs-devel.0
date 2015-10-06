From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 01/15] ipv4: Fix ip_local_out_sk by passing the sk into __ip_local_out_sk
Date: Tue,  6 Oct 2015 13:53:01 -0500
Message-ID: <1444157595-28816-1-git-send-email-ebiederm@xmission.com>
References: <878u7fesrg.fsf_-_@x220.int.ebiederm.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <878u7fesrg.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

In the rare case where sk != skb->sk ip_local_out_sk arranges
to call dst->output differently if the skb is queued or not.
This is a bug.

Fix this bug by passing the sk parameter of ip_local_out_sk through
from ip_local_out_sk to __ip_local_out_sk (skipping __ip_local_out).

Fixes: 7026b1ddb6b8d4e6ee33dc2bd06c0ca8746fa7ab
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/ip_output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 911ea739049a..6cb585a05dd1 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -117,7 +117,7 @@ int ip_local_out_sk(struct sock *sk, struct sk_buff *skb)
 {
 	int err;
 
-	err = __ip_local_out(skb);
+	err = __ip_local_out_sk(sk, skb);
 	if (likely(err == 1))
 		err = dst_output(sk, skb);
 
-- 
2.2.1

