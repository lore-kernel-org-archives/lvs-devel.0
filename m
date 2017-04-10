From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 1/3] netfilter: ipvs: don't check for presence of nat extension
Date: Mon, 10 Apr 2017 09:58:33 -0700
Message-ID: <1491843515-1627-2-git-send-email-horms@verge.net.au>
References: <1491843515-1627-1-git-send-email-horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1491843523; bh=dGkGa+EQ9z/qbbha5jzdA7uQr29NF/uC1Hoj4pFGqeA=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=REpo7P2z77ncStC9ZXDUUTaGEVKR30oy+mrKCOIC5hpjvFzEQmsznoeISfc3X9S14
         txKe9/wyYS1ZMDT+/8G02+hgFB6RJk1LYgHzCxZ8dnWPLttZQm2ejh+cgX7LWhQRFf
         SoBPZX49vWrrgDbX/6lpX8XfwI60PCoXuUX6smdE=
In-Reply-To: <1491843515-1627-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Florian Westphal <fw@strlen.de>

From: Florian Westphal <fw@strlen.de>

Check for the NAT status bits, they are set once conntrack needs NAT in source or
reply direction, this is slightly faster than nfct_nat() as that has to check the
extension area.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/netfilter/ipvs/ip_vs_ftp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index d30c327bb578..2e2bf7428cd1 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -260,7 +260,7 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		buf_len = strlen(buf);
 
 		ct = nf_ct_get(skb, &ctinfo);
-		if (ct && !nf_ct_is_untracked(ct) && nfct_nat(ct)) {
+		if (ct && !nf_ct_is_untracked(ct) && (ct->status & IPS_NAT_MASK)) {
 			/* If mangling fails this function will return 0
 			 * which will cause the packet to be dropped.
 			 * Mangling can only fail under memory pressure,
-- 
2.7.0.rc3.207.g0ac5344

