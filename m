From: Marco Angaroni <marcoangaroni@gmail.com>
Subject: [PATCH] ipvs: correct initial offset of Call-ID header search in
 SIP persistence engine
Date: Sat, 05 Mar 2016 12:10:02 +0100
Message-ID: <56dabe8a.wEnEwnUQ23/U/p/3%marcoangaroni@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=date:from:to:subject:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=z0D/ar9F7FqcTHCf0jOYJ02FKHGiKcwlUlNCEHfvb/o=;
        b=ZBWCULyTtxfhMWdXud6GBIZxLdu+5DxA/jenELSOSaSPyr+kwMlQnMkDWDxjp3hS2F
         /c7qpgQnEEnXxiZJs9B832pL/nMw7cKyVwN3FZRHfu2a69ScsSb++eLMTSOrGIkBKExD
         7xLIMmdOIerrdfa+hUitOg0CkKBRCG+1EXO9TF317fsCu1809Y3tmMYufhMeneRuju2c
         aSefYSY5VKtYJ5aotdApOvERC+uBKUSkTNCVmncu8ArdKMhgFmn6rqQx+UZpiKZ1XJqA
         QFq/HHlho5Og8EOriRnIF1gTNkvSih/RALCivqAovBv0dn2Y4b4U96z19POXmaOwlMk4
         TEug==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org

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
---
 net/netfilter/ipvs/ip_vs_pe_sip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
index 1b8d594..b3e0e5b 100644
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
1.8.3.1

