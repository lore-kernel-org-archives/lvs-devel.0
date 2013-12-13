From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH] ipvs: avoid oops in nf_ct_seqadj_set when called from
	ip_vs_ftp helper
Date: Fri, 13 Dec 2013 22:37:48 +0100
Message-ID: <20131213214023.14478.74738.stgit@dragon>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Pablo Neira Ayuso <pablo@netfilter.org>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>

The IPVS FTP helper ip_vs_ftp can trigger an OOPS in nf_ct_seqadj_set,
after commit 41d73ec053d2 (netfilter: nf_conntrack: make sequence
number adjustments usuable without NAT).

We can avoid the oops in nf_ct_seqadj_set() by in ip_vs_ftp_out()
instead of calling nf_nat_mangle_tcp_packet() we simply call
__nf_nat_mangle_tcp_packet() with a "false" last parameter, which
indicate not invoking the seqadj code.

After this fix, I've tested that FTP over IPVS, with module ip_vs_ftp
loaded, works for both passive and active FTP.

Fixes: 41d73ec053d2 (netfilter: nf_conntrack: make sequence number adjustments usuable without NAT)
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
I'm uncertain if this is the correct fix.  Perhaps the ip_vs_ftp
helper need to allocate/init the seqadj extension instead?

 net/netfilter/ipvs/ip_vs_ftp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 77c1732..b8f9573 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -268,10 +268,10 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 			 * packet.
 			 */
 			rcu_read_lock();
-			ret = nf_nat_mangle_tcp_packet(skb, ct, ctinfo,
+			ret = __nf_nat_mangle_tcp_packet(skb, ct, ctinfo,
 						       iph->ihl * 4,
 						       start-data, end-start,
-						       buf, buf_len);
+						       buf, buf_len, false);
 			rcu_read_unlock();
 			if (ret) {
 				ip_vs_nfct_expect_related(skb, ct, n_cp,
