From: Simon Horman <horms@verge.net.au>
Subject: [patch v4 02/12] netfilter: nf_conntrack_sip: Add callid parser
Date: Mon, 04 Oct 2010 18:03:54 +0900
Message-ID: <20101004090818.176047540@akiko.akashicho.tokyo.vergenet.net>
References: <20101004090352.966809749@akiko.akashicho.tokyo.vergenet.net>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline; filename=0002-netfilter-nf_conntrack_sip-Add-callid-parser.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

Signed-off-by: Simon Horman <horms@verge.net.au>
Acked-by: Julian Anastasov <ja@ssi.bg>

--- 

The motivation for this is for it to be used by LVS as per
subsequent patches.

* Patrick McHardy suggested changing word_len to check for the
  next newline or whitespace. But I believe this is incorrect.
  For example '#' would be permitted but it is invalid
  in a word according to RFC3261.


diff --git a/include/linux/netfilter/nf_conntrack_sip.h b/include/linux/netfilter/nf_conntrack_sip.h
index ff8cfbc..0ce91d5 100644
--- a/include/linux/netfilter/nf_conntrack_sip.h
+++ b/include/linux/netfilter/nf_conntrack_sip.h
@@ -89,6 +89,7 @@ enum sip_header_types {
 	SIP_HDR_VIA_TCP,
 	SIP_HDR_EXPIRES,
 	SIP_HDR_CONTENT_LENGTH,
+	SIP_HDR_CALL_ID,
 };
 
 enum sdp_header_types {
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 2fd1ea2..715ce54 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -130,6 +130,44 @@ static int digits_len(const struct nf_conn *ct, const char *dptr,
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
@@ -299,6 +337,7 @@ static const struct sip_header ct_sip_hdrs[] = {
 	[SIP_HDR_VIA_TCP]		= SIP_HDR("Via", "v", "TCP ", epaddr_len),
 	[SIP_HDR_EXPIRES]		= SIP_HDR("Expires", NULL, NULL, digits_len),
 	[SIP_HDR_CONTENT_LENGTH]	= SIP_HDR("Content-Length", "l", NULL, digits_len),
+	[SIP_HDR_CALL_ID]		= SIP_HDR("Call-Id", "i", NULL, callid_len),
 };
 
 static const char *sip_follow_continuation(const char *dptr, const char *limit)
-- 
1.7.1


