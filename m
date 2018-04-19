From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 4/5] netfilter: ipvs: Add configurations of Maglev hashing
Date: Thu, 19 Apr 2018 10:56:13 +0200
Message-ID: <20180419085614.7437-5-horms@verge.net.au>
References: <20180419085614.7437-1-horms@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1524128186; bh=hYXNTyIDluujfZPWPMhqo/8ixuC1DEfTHBCovWh6OQg=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=FtgoQYgtXRDZK1TBSKQYeLCOuoYjBUe2koRpd5/LIRAP1NssbTuLwO2hZd8PN0AQm
         EeBwdI4ZeEBknx+mxX6gSYHC4wGMfzsPgvv1cD3bAAd/MujuTN54BEaYodvConIoJE
         a+fbhvZUrXLUBvlxYY+y5f3PQ561NOncWk7u6CD8=
In-Reply-To: <20180419085614.7437-1-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Inju Song <inju.song@navercorp.com>, Simon Horman <horms@verge.net.au>

From: Inju Song <inju.song@navercorp.com>

To build the maglev hashing scheduler, add some configuration
to Kconfig and Makefile.

 - The compile configurations of MH are added to the Kconfig.

 - The MH build rule is added to the Makefile.

Signed-off-by: Inju Song <inju.song@navercorp.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/Kconfig  | 37 +++++++++++++++++++++++++++++++++++++
 net/netfilter/ipvs/Makefile |  1 +
 2 files changed, 38 insertions(+)

diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index b32fb0dbe237..05dc1b77e466 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -225,6 +225,25 @@ config	IP_VS_SH
 	  If you want to compile it in kernel, say Y. To compile it as a
 	  module, choose M here. If unsure, say N.
=20
+config	IP_VS_MH
+	tristate "maglev hashing scheduling"
+	---help---
+	  The maglev consistent hashing scheduling algorithm provides the
+	  Google's Maglev hashing algorithm as a IPVS scheduler. It assigns
+	  network connections to the servers through looking up a statically
+	  assigned special hash table called the lookup table. Maglev hashing
+	  is to assign a preference list of all the lookup table positions
+	  to each destination.
+
+	  Through this operation, The maglev hashing gives an almost equal
+	  share of the lookup table to each of the destinations and provides
+	  minimal disruption by using the lookup table. When the set of
+	  destinations changes, a connection will likely be sent to the same
+	  destination as it was before.
+
+	  If you want to compile it in kernel, say Y. To compile it as a
+	  module, choose M here. If unsure, say N.
+
 config	IP_VS_SED
 	tristate "shortest expected delay scheduling"
 	---help---
@@ -266,6 +285,24 @@ config IP_VS_SH_TAB_BITS
 	  needs to be large enough to effectively fit all the destinations
 	  multiplied by their respective weights.
=20
+comment 'IPVS MH scheduler'
+
+config IP_VS_MH_TAB_INDEX
+	int "IPVS maglev hashing table index of size (the prime numbers)"
+	range 8 17
+	default 12
+	---help---
+	  The maglev hashing scheduler maps source IPs to destinations
+	  stored in a hash table. This table is assigned by a preference
+	  list of the positions to each destination until all slots in
+	  the table are filled. The index determines the prime for size of
+	  the table as=A0251, 509, 1021, 2039, 4093, 8191, 16381, 32749,
+	  65521 or 131071.=A0When using weights to allow destinations to
+	  receive more connections,=A0the table is assigned an amount
+	  proportional to the weights specified.=A0The table needs to be large
+	  enough to effectively fit all the destinations multiplied by their
+	  respective weights.
+
 comment 'IPVS application helper'
=20
 config	IP_VS_FTP
diff --git a/net/netfilter/ipvs/Makefile b/net/netfilter/ipvs/Makefile
index c552993fa4b9..bfce2677fda2 100644
--- a/net/netfilter/ipvs/Makefile
+++ b/net/netfilter/ipvs/Makefile
@@ -33,6 +33,7 @@ obj-$(CONFIG_IP_VS_LBLC) +=3D ip_vs_lblc.o
 obj-$(CONFIG_IP_VS_LBLCR) +=3D ip_vs_lblcr.o
 obj-$(CONFIG_IP_VS_DH) +=3D ip_vs_dh.o
 obj-$(CONFIG_IP_VS_SH) +=3D ip_vs_sh.o
+obj-$(CONFIG_IP_VS_MH) +=3D ip_vs_mh.o
 obj-$(CONFIG_IP_VS_SED) +=3D ip_vs_sed.o
 obj-$(CONFIG_IP_VS_NQ) +=3D ip_vs_nq.o
=20
--=20
2.11.0

