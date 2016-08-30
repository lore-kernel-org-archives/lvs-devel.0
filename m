From: Marco Angaroni <marcoangaroni@gmail.com>
Subject: [PATCH 2/2] netfilter: correct allowed characters in
 Call-ID SIP header
Date: Tue, 30 Aug 2016 18:48:24 +0200
Message-ID: <20160830164824._3CVoDOGb%marcoangaroni@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=date:from:to:subject:message-id:user-agent;
        bh=bDzF3QJARu1jFAJBcJ5l0WV19vonKEC27Tqlc4g28ZM=;
        b=EbKKd5adQdxdLwRPzA56o5y0+Aqx+xrVhTobTKPzAaNQ4Ec6S59Sxtw0N9NUJGrnOc
         BWnuZgIpLIrzxeqnfoY0fYM7B+nKNGyeL56rabTpcOxn4v/hsjXLuC6TxMNfA5FZn5l5
         R9sTSUa0TeAvR8pAbHKCIDY3bmbEsxL03lm9c0PfHJrP9W9F1DxvIVNmAjNOA/c1NUoB
         OMyCh9d46HMk7MmzVqUn8jrDetJYVlj7NhZxcG3TSyPmzW/W5t3rvEy/vi4hW534ehxl
         ZFpn0rEml8tlQvqALkfFnyX9fcsg0y2NtvsOLMvaNE8Dhl3TRy1G2lkLKWzzYORi3U7h
         odwQ==
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

Current parsing methods for SIP header Call-ID do not check correctly all
characters allowed by RFC 3261. In particular "," character is allowed 
instead of "'" character. As a result Call-ID headers like the following
are discarded by IPVS SIP persistence engine.

Call-ID: -.!%*_+`'~()<>:\"/[]?{}

Above example is composed using all non-alphanumeric characters listed
in RFC 3261 for Call-ID header syntax.

Proposed fix is in nf_conntrack_sip module; function iswordc() checks this
range: (c >= '(' && c <= '/') which includes these characters: ()*+,-./
They are all allowed except ",". Instead "'" is not included in the list.

Below is an extract of relevant SIP ABNF syntax.

Call-ID  =  ( "Call-ID" / "i" ) HCOLON callid
callid   =  word [ "@" word ]

HCOLON  =  *( SP / HTAB ) ":" SWS
SWS     =  [LWS] ; sep whitespace
LWS     =  [*WSP CRLF] 1*WSP ; linear whitespace
WSP     =  SP / HTAB
word    =  1*(alphanum / "-" / "." / "!" / "%" / "*" /
           "_" / "+" / "`" / "'" / "~" /
           "(" / ")" / "<" / ">" /
           ":" / "\" / DQUOTE /
           "/" / "[" / "]" / "?" /
           "{" / "}" )

Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>
---
 net/netfilter/nf_conntrack_sip.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 4acd60e..8971109 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -83,9 +83,10 @@ static int digits_len(const struct nf_conn *ct, const char *dptr,
 static int iswordc(const char c)
 {
 	if (isalnum(c) || c == '!' || c == '"' || c == '%' ||
-	    (c >= '(' && c <= '/') || c == ':' || c == '<' || c == '>' ||
+	    (c >= '(' && c <= '+') || c == ':' || c == '<' || c == '>' ||
 	    c == '?' || (c >= '[' && c <= ']') || c == '_' || c == '`' ||
-	    c == '{' || c == '}' || c == '~')
+	    c == '{' || c == '}' || c == '~' || (c >= '-' && c <= '/') ||
+	    c == '\'')
 		return 1;
 	return 0;
 }
-- 
1.8.3.1

