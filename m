From: Simon Horman <horms@verge.net.au>
Subject: [patch v1 02/12] netfilter: nf_conntrack_sip: Add callid parser
Date: Sun, 22 Aug 2010 21:44:59 +0900
Message-ID: <20100822124857.353140909@vergenet.net>
References: <20100822124457.339517323@vergenet.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=ct_sip_get_header-callid.patch
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

Signed-off-by: Simon Horman <horms@verge.net.au>

--- 

The motivation for this is for it to be used by LVS as per
subsequent patches.

* Patrick McHardy suggested changing word_len to check for the
  next newline or whitespace. But I believe this is incorrect.
  For example '#' would be permitted but it is invalid
  in a word according to RFC3261.

Index: nf-next-2.6/net/netfilter/nf_conntrack_sip.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/nf_conntrack_sip.c	2010-07-24 21:02:05.000000000 +0900
+++ nf-next-2.6/net/netfilter/nf_conntrack_sip.c	2010-07-25 15:48:53.000000000 +0900
@@ -130,6 +130,44 @@ static int digits_len(const struct nf_co
 	return len;
 }
 
+static int iswordc(const char c)
+{
+	if (isalnum(c) || c == '!' || c == '"' || c == '%' ||
+	    (c >= '(' && c <= '/') || c == ':' || c == '<' || c == '>' ||
+	    c == '?' || (c >= '[' && c <= ']') || c == '_' || c == '`' ||
+	    c == '{' || c == '}' || c == '~')
+		return 1;
+	return 0;
+}
+
+static int word_len(const char *dptr, const char *limit)
+{
+	int len = 0;
+	while (dptr < limit && iswordc(*dptr)) {
+		dptr++;
+		len++;
+	}
+	return len;
+}
+
+static int callid_len(const struct nf_conn *ct, const char *dptr,
+		      const char *limit, int *shift)
+{
+	int len, domain_len;
+
+	len = word_len(dptr, limit);
+	dptr += len;
+	if (!len || dptr == limit || *dptr != '@')
+		return len;
+	dptr++;
+	len++;
+
+	domain_len = word_len(dptr, limit);
+	if (!domain_len)
+		return 0;
+	return len + domain_len;
+}
+
 /* get media type + port length */
 static int media_len(const struct nf_conn *ct, const char *dptr,
 		     const char *limit, int *shift)
@@ -299,6 +337,7 @@ static const struct sip_header ct_sip_hd
 	[SIP_HDR_VIA_TCP]		= SIP_HDR("Via", "v", "TCP ", epaddr_len),
 	[SIP_HDR_EXPIRES]		= SIP_HDR("Expires", NULL, NULL, digits_len),
 	[SIP_HDR_CONTENT_LENGTH]	= SIP_HDR("Content-Length", "l", NULL, digits_len),
+	[SIP_HDR_CALL_ID]		= SIP_HDR("Call-Id", "i", NULL, callid_len),
 };
 
 static const char *sip_follow_continuation(const char *dptr, const char *limit)
Index: nf-next-2.6/include/linux/netfilter/nf_conntrack_sip.h
===================================================================
--- nf-next-2.6.orig/include/linux/netfilter/nf_conntrack_sip.h	2010-07-20 10:24:21.000000000 +0900
+++ nf-next-2.6/include/linux/netfilter/nf_conntrack_sip.h	2010-07-24 21:02:08.000000000 +0900
@@ -89,6 +89,7 @@ enum sip_header_types {
 	SIP_HDR_VIA_TCP,
 	SIP_HDR_EXPIRES,
 	SIP_HDR_CONTENT_LENGTH,
+	SIP_HDR_CALL_ID,
 };
 
 enum sdp_header_types {

