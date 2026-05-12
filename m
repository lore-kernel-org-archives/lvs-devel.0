Received: from Chamillionaire.breakpoint.cc (Chamillionaire.breakpoint.cc [91.216.245.30])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 68A1738AC7E;
	Tue, 12 May 2026 18:30:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=91.216.245.30
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778610607; cv=none; b=pSRwfWJd3qP94hudDT2uAeh+Y9awp/6u7IM727XiW0l4UVfJxFAEPc5rQWsi9I9D65lcNVDPETbDEFYAaG7vMufeCorGjxgRhMwPk4zyGuvYOnv9OcoH+9Ce9iuZOTCypL0mwtTVngeOSwBwqKvgzm/lB+b7eRRvr+pqDNzke6E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778610607; c=relaxed/simple;
	bh=zajSxBKigkT3xJDwQAxK7boZO1bj6b19cCo9nh/rY0E=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=hzNTDIMzk6cBPsnebInBIwOPfGCMc6mvjH3yKuM3RDNjItSZM5jOTQzA7IYTNJhEgKE6XHDqyQTO1+KcLcpuaXvBE2ityxB9WiYtbSYLfgYNHwaMNdkNtpvk3u4NiIm+OAC2t53pxUSWvUg51GTVslStJ/jifLULdJF05DLGYjM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=strlen.de; spf=pass smtp.mailfrom=Chamillionaire.breakpoint.cc; arc=none smtp.client-ip=91.216.245.30
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=strlen.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=Chamillionaire.breakpoint.cc
Received: by Chamillionaire.breakpoint.cc (Postfix, from userid 1003)
	id D6C1660D66; Tue, 12 May 2026 20:29:58 +0200 (CEST)
From: Florian Westphal <fw@strlen.de>
To: <netfilter-devel@vger.kernel.org>
Cc: lvs-devel@vger.kernel.org,
	ja@ssi.bg,
	Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next v2] netfilter: add option for GCOV profiling
Date: Tue, 12 May 2026 20:29:46 +0200
Message-ID: <20260512182946.32687-1-fw@strlen.de>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Similar to a few other subsystems: add a new config toggle to
enable netfilter gcov profiling in netfilter, including ebtables,
arptables and so on.

ipset and ipvs gain their own, dedicated toggles.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 v2: add dedicated toggles for ipvs and ipset;
 I am currently not collecting profile data for these two.

 If you prefer to keep them under single switch thats fine,
 just lmk.

 net/bridge/netfilter/Makefile | 4 ++++
 net/ipv4/netfilter/Makefile   | 4 ++++
 net/ipv6/netfilter/Makefile   | 4 ++++
 net/netfilter/Kconfig         | 8 ++++++++
 net/netfilter/Makefile        | 4 ++++
 net/netfilter/ipset/Kconfig   | 9 +++++++++
 net/netfilter/ipset/Makefile  | 3 +++
 net/netfilter/ipvs/Kconfig    | 9 +++++++++
 net/netfilter/ipvs/Makefile   | 3 +++
 9 files changed, 48 insertions(+)

diff --git a/net/bridge/netfilter/Makefile b/net/bridge/netfilter/Makefile
index b9a1303da977..af0c903aa4ac 100644
--- a/net/bridge/netfilter/Makefile
+++ b/net/bridge/netfilter/Makefile
@@ -38,3 +38,7 @@ obj-$(CONFIG_BRIDGE_EBT_SNAT) += ebt_snat.o
 # watchers
 obj-$(CONFIG_BRIDGE_EBT_LOG) += ebt_log.o
 obj-$(CONFIG_BRIDGE_EBT_NFLOG) += ebt_nflog.o
+
+ifdef CONFIG_GCOV_PROFILE_NETFILTER
+GCOV_PROFILE := y
+endif
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 85502d4dfbb4..dbfb1c4739a8 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -51,3 +51,7 @@ obj-$(CONFIG_IP_NF_ARP_MANGLE) += arpt_mangle.o
 obj-$(CONFIG_IP_NF_ARPFILTER) += arptable_filter.o
 
 obj-$(CONFIG_NF_DUP_IPV4) += nf_dup_ipv4.o
+
+ifdef CONFIG_GCOV_PROFILE_NETFILTER
+GCOV_PROFILE := y
+endif
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index 66ce6fa5b2f5..72902d8005ad 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -43,3 +43,7 @@ obj-$(CONFIG_IP6_NF_MATCH_SRH) += ip6t_srh.o
 obj-$(CONFIG_IP6_NF_TARGET_NPT) += ip6t_NPT.o
 obj-$(CONFIG_IP6_NF_TARGET_REJECT) += ip6t_REJECT.o
 obj-$(CONFIG_IP6_NF_TARGET_SYNPROXY) += ip6t_SYNPROXY.o
+
+ifdef CONFIG_GCOV_PROFILE_NETFILTER
+GCOV_PROFILE := y
+endif
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 682c675125fc..f71ff98eb5d0 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -1648,6 +1648,14 @@ config NETFILTER_XT_MATCH_U32
 
 endif # NETFILTER_XTABLES
 
+config GCOV_PROFILE_NETFILTER
+	bool "Enable GCOV profiling for netfilter"
+	depends on GCOV_KERNEL
+	help
+	  Enable GCOV profiling for netfilter to check which functions/lines
+	  are executed.
+
+	  If unsure, say N.
 endmenu
 
 source "net/netfilter/ipset/Kconfig"
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 6bfc250e474f..f0751ca302c6 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -240,3 +240,7 @@ obj-$(CONFIG_IP_VS) += ipvs/
 
 # lwtunnel
 obj-$(CONFIG_LWTUNNEL) += nf_hooks_lwtunnel.o
+
+ifdef CONFIG_GCOV_PROFILE_NETFILTER
+GCOV_PROFILE := y
+endif
diff --git a/net/netfilter/ipset/Kconfig b/net/netfilter/ipset/Kconfig
index b1ea054bb82c..6c4d54758106 100644
--- a/net/netfilter/ipset/Kconfig
+++ b/net/netfilter/ipset/Kconfig
@@ -175,4 +175,13 @@ config IP_SET_LIST_SET
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
+config GCOV_PROFILE_IPSET
+	bool "Enable GCOV profiling for ipset"
+	depends on GCOV_KERNEL
+	help
+	  Enable GCOV profiling for ipset to check which functions/lines
+	  are executed.
+
+	  If unsure, say N.
+
 endif # IP_SET
diff --git a/net/netfilter/ipset/Makefile b/net/netfilter/ipset/Makefile
index a445a6bf4f11..4f48df5406cd 100644
--- a/net/netfilter/ipset/Makefile
+++ b/net/netfilter/ipset/Makefile
@@ -29,3 +29,6 @@ obj-$(CONFIG_IP_SET_HASH_NETPORTNET) += ip_set_hash_netportnet.o
 
 # list types
 obj-$(CONFIG_IP_SET_LIST_SET) += ip_set_list_set.o
+ifdef CONFIG_GCOV_PROFILE_IPSET
+GCOV_PROFILE := y
+endif
diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index c203252e856d..7724cb44e6de 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -349,4 +349,13 @@ config	IP_VS_PE_SIP
 	help
 	  Allow persistence based on the SIP Call-ID
 
+config GCOV_PROFILE_IPVS
+	bool "Enable GCOV profiling for IPVS"
+	depends on GCOV_KERNEL
+	help
+	  Enable GCOV profiling for IPVS to check which functions/lines
+	  are executed.
+
+	  If unsure, say N.
+
 endif # IP_VS
diff --git a/net/netfilter/ipvs/Makefile b/net/netfilter/ipvs/Makefile
index bb5d8125c82a..8e4cc67ad39d 100644
--- a/net/netfilter/ipvs/Makefile
+++ b/net/netfilter/ipvs/Makefile
@@ -43,3 +43,6 @@ obj-$(CONFIG_IP_VS_FTP) += ip_vs_ftp.o
 
 # IPVS connection template retrievers
 obj-$(CONFIG_IP_VS_PE_SIP) += ip_vs_pe_sip.o
+ifdef CONFIG_GCOV_PROFILE_IPVS
+GCOV_PROFILE := y
+endif
-- 
2.53.0

