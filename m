From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 12/16] ppp: Cache net in pptp_xmit
Date: Wed,  7 Oct 2015 16:48:43 -0500
Message-ID: <1444254527-17833-12-git-send-email-ebiederm@xmission.com>
References: <87bnca4aie.fsf_-_@x220.int.ebiederm.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <87bnca4aie.fsf_-_@x220.int.ebiederm.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org

Compute net and store it in a variable in pptp_xmit, so that the value
can be reused the next time it is needed.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ppp/pptp.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index 6bef7be10671..5243ab6ed4d4 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -169,6 +169,7 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 {
 	struct sock *sk = (struct sock *) chan->private;
 	struct pppox_sock *po = pppox_sk(sk);
+	struct net *net = sock_net(sk);
 	struct pptp_opt *opt = &po->proto.pptp;
 	struct pptp_gre_header *hdr;
 	unsigned int header_len = sizeof(*hdr);
@@ -187,7 +188,7 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	if (sk_pppox(po)->sk_state & PPPOX_DEAD)
 		goto tx_error;
 
-	rt = ip_route_output_ports(sock_net(sk), &fl4, NULL,
+	rt = ip_route_output_ports(net, &fl4, NULL,
 				   opt->dst_addr.sin_addr.s_addr,
 				   opt->src_addr.sin_addr.s_addr,
 				   0, 0, IPPROTO_GRE,
@@ -279,7 +280,7 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	nf_reset(skb);
 
 	skb->ip_summed = CHECKSUM_NONE;
-	ip_select_ident(sock_net(sk), skb, NULL);
+	ip_select_ident(net, skb, NULL);
 	ip_send_check(iph);
 
 	ip_local_out(skb->sk, skb);
-- 
2.2.1

