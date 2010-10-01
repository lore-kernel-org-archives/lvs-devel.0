From: Simon Horman <horms@verge.net.au>
Subject: [patch v2 01/12] [PATCH 01/12] netfilter: nf_conntrack_sip: Allow ct_sip_get_header() to be called with a null ct argument
Date: Fri, 01 Oct 2010 23:35:18 +0900
Message-ID: <20101001143941.776153478@akiko.akashicho.tokyo.vergenet.net>
References: <20101001143517.645421976@akiko.akashicho.tokyo.vergenet.net>
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline; filename=0001-netfilter-nf_conntrack_sip-Allow-ct_sip_get_header-t.patch
Sender: netfilter-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

Signed-off-by: Simon Horman <horms@verge.net.au>

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 53d8922..2fd1ea2 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -152,6 +152,9 @@ static int parse_addr(const struct nf_conn *ct, const char *cp,
 	const char *end;
 	int ret = 0;
 
+	if (!ct)
+		return 0;
+
 	memset(addr, 0, sizeof(*addr));
 	switch (nf_ct_l3num(ct)) {
 	case AF_INET:
-- 
1.7.1


