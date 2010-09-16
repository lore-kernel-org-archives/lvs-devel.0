From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 0/3] ipvs: nfct changes
Date: Thu, 16 Sep 2010 23:38:31 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.1009162325250.6847@u.domain.uli>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


	Hello,

	The following patches extend the recent nfct changes
to IPVS:

1. Extend connection flags to 32 bits:
	- needed to add new flags after bit 16
2. Add IP_VS_CONN_F_NFCT and some nfct changes
3. Add snat_reroute flag to optimize CPU for unipath routes

	The patches are against net-next-2.6-e548833 (2010-SEP-10)
and are ready to be applied to net-next if there are no
objections.

Regards

--
Julian Anastasov <ja@ssi.bg>
