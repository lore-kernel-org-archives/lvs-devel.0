From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 4/4] ipvs: correct initial offset of Call-ID header search in SIP persistence engine
Date: Mon,  7 Mar 2016 12:03:34 +0900
Message-ID: <1457319814-8027-5-git-send-email-horms@verge.net.au>
References: <1457319814-8027-1-git-send-email-horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1457319820; bh=N6yfHiXyupRqxXkKZ/1FGkljEJUr+7Tfqp+69UFatjo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=fr6fQdO0koLKghl3O1MJ+NCNHzZAL8qrQRl4IoG6Ms4/dydt+rj0AGKpzBFFF0wll
	 LE+wsezL3+CtxLrpQNaJn8/SjkUbJjJtmf4kePVY5UWm7gbjmUZ80WK0u7kCozz30m
	 8v5ArEHrRQLjN6O12AcnQ4TVycj8niipq7cmgKdQ=
In-Reply-To: <1457319814-8027-1-git-send-email-horms@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Marco Angaroni <marcoangaroni@gmail.com>, Simon Horman <horms@verge.net.au>

From: Marco Angaroni <marcoangaroni@gmail.com>

The IPVS SIP persistence engine is not able to parse the SIP header
"Call-ID" when such header is inserted in the first positions of
the SIP message.

When IPVS is configured with "--pe sip" option, like for example:
ipvsadm -A -u 1.2.3.4:5060 -s rr --pe sip -p 120 -o
some particular messages (see below for details) do not create entries
in the connection template table, which can be listed with:
ipvsadm -Lcn --persistent-conn

Problematic SIP messages are SIP responses having "Call-ID" header
positioned just after message first line:
SIP/2.0 200 OK
[Call-ID header here]
[rest of the headers]

When "Call-ID" header is positioned down (after a few other headers)
it is correctly recognized.

This is due to the data offset used in get_callid function call inside
ip_vs_pe_sip.c file: since dptr already points to the start of the
SIP message, the value of dataoff should be initially 0.
Otherwise the header is searched starting from some bytes after the
first character of the SIP message.

Fixes: 758ff0338722 ("IPVS: sip persistence engine")
Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_pe_sip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
index c4e9ca016a88..0a6eb5c0d9e9 100644
--- a/net/netfilter/ipvs/ip_vs_pe_sip.c
+++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
@@ -88,7 +88,7 @@ ip_vs_sip_fill_param(struct ip_vs_conn_param *p, struct sk_buff *skb)
 	dptr = skb->data + dataoff;
 	datalen = skb->len - dataoff;
 
-	if (get_callid(dptr, dataoff, datalen, &matchoff, &matchlen))
+	if (get_callid(dptr, 0, datalen, &matchoff, &matchlen))
 		return -EINVAL;
 
 	/* N.B: pe_data is only set on success,
-- 
2.1.4

