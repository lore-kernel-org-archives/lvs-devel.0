From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 7/9] ipvs: Use min3() in ip_vs_dbg_callid()
Date: Tue, 23 Apr 2013 12:03:58 +0900
Message-ID: <1366686240-23493-8-git-send-email-horms@verge.net.au>
References: <1366686240-23493-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1366686240-23493-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Dan Carpenter <dan.carpenter@oracle.com>, Simon Horman <horms@verge.net.au>

There are two motivations for this:

1. It improves readability to my eyes
2. Using nested min() calls results in a shadowed _min1 variable,
   which is a bit untidy. Sparse complained about this.

I have also replaced (size_t)64 with a variable of type size_t and value 64.
This also improves readability to my eyes.

Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_pe_sip.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
index 00cc024..9a8f421 100644
--- a/net/netfilter/ipvs/ip_vs_pe_sip.c
+++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
@@ -13,7 +13,8 @@ static const char *ip_vs_dbg_callid(char *buf, size_t buf_len,
 				    const char *callid, size_t callid_len,
 				    int *idx)
 {
-	size_t len = min(min(callid_len, (size_t)64), buf_len - *idx - 1);
+	size_t max_len = 64;
+	size_t len = min3(max_len, callid_len, buf_len - *idx - 1);
 	memcpy(buf + *idx, callid, len);
 	buf[*idx+len] = '\0';
 	*idx += len + 1;
-- 
1.8.2.1

