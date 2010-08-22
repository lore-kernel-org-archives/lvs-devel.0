From: Simon Horman <horms@verge.net.au>
Subject: [patch v1 01/12] netfilter: nf_conntrack_sip: Allow ct_sip_get_header() to be called with a null ct argument
Date: Sun, 22 Aug 2010 21:44:58 +0900
Message-ID: <20100822124857.010510890@vergenet.net>
References: <20100822124457.339517323@vergenet.net>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=ct_sip_get_header-ct-null.patch
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

Signed-off-by: Simon Horman <horms@verge.net.au>

--- 

The motivation for this is to allow ct_sip_get_header() to be
used by LVS without connection tracking as per subsequent patches.
Index: nf-next-2.6/net/netfilter/nf_conntrack_sip.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/nf_conntrack_sip.c	2010-07-14 20:40:40.000000000 +0900
+++ nf-next-2.6/net/netfilter/nf_conntrack_sip.c	2010-07-14 21:15:06.000000000 +0900
@@ -152,6 +152,9 @@ static int parse_addr(const struct nf_co
 	const char *end;
 	int ret = 0;
 
+	if (!ct)
+		return 0;
+
 	memset(addr, 0, sizeof(*addr));
 	switch (nf_ct_l3num(ct)) {
 	case AF_INET:

