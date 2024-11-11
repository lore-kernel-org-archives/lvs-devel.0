Received: from mx0a-00007101.pphosted.com (mx0a-00007101.pphosted.com [148.163.135.28])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4303513A258;
	Mon, 11 Nov 2024 06:52:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=148.163.135.28
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1731307945; cv=none; b=AOw74ahlIWGnMgQvwG/e/7eiiH0S7dlmAJdRsbKm9p3MJHOQSPSbi2ppiN9DBBcfb/XCWpnDE4jIayY2oPGhjx1EX4tOPFLqC0oXQSaY2sZSyS19psXnOhUN+HbvwbogdNMUKOi/WT6bsysq4pXaQO0Yeo0Vd9lqCBlErmkFQiU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1731307945; c=relaxed/simple;
	bh=+U9r4++8vWNjOGgBUQp+LAiKwhXMBYkOY0XY8YYEC9E=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=qlu1NWowkQR9IdPaACODCsihZYiOmnV8OjnpnpwEj0LY43du1fr2UjjrAs3xu2c7b7wE0gCWFJNi/y9ukBlXhgN7MZ1zQp7NKIrejX/9HEfsX3uoQrroO5w95CQNTrBU0QMb9zarDESJUQFiNkgefVcxKLpq2eaWN21YSq1EFlU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=illinois.edu; spf=pass smtp.mailfrom=illinois.edu; dkim=pass (2048-bit key) header.d=illinois.edu header.i=@illinois.edu header.b=IC9DwOE0; arc=none smtp.client-ip=148.163.135.28
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=illinois.edu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=illinois.edu
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=illinois.edu header.i=@illinois.edu header.b="IC9DwOE0"
Received: from pps.filterd (m0166255.ppops.net [127.0.0.1])
	by mx0a-00007101.pphosted.com (8.18.1.2/8.18.1.2) with ESMTP id 4AB51htV012128;
	Mon, 11 Nov 2024 06:51:40 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=illinois.edu; h=
	cc:content-transfer-encoding:date:from:message-id:mime-version
	:subject:to; s=campusrelays; bh=G00Djb/CrG1My6IT3+uwf8Xvk9Zx1GAj
	nDsHf77FZaI=; b=IC9DwOE0Ek905R3uX7ynL6WI4sy41z9nZz38I7mDia5SOX2p
	jTyOms47q3dLorFVNEs8Qpt5M4GgM/6Qn7Ru+IH7vWEIF2xk3qaTNR3tPsChVCRi
	f96iF39Lq9jOVEoPX6O9LRCWhK3COxuRYdDHB/vyCpKCsXQTlLEN6kYjmOHJ4d8t
	5KH3I6VhRcFfyQVOzBxqMeDwG/0Kkzh6ja0LPVYzgw1HZVizTLQ8pCcSchc6lWC2
	hJ0MQ/l5DbcnSKi3I3gRk8uPRz6bDeah8DSLZ7qr5q1WDmaR6L5+ZRc4XFvpdVp/
	26sXh/7tuZdpg9lWBcoPqDndCtnplqIiu8Y+Cg==
Received: from pps.reinject (localhost [127.0.0.1])
	by mx0a-00007101.pphosted.com (PPS) with ESMTPS id 42t0dy3632-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 11 Nov 2024 06:51:39 +0000 (GMT)
Received: from m0166255.ppops.net (m0166255.ppops.net [127.0.0.1])
	by pps.reinject (8.18.0.8/8.18.0.8) with ESMTP id 4AB6pd0M003663;
	Mon, 11 Nov 2024 06:51:39 GMT
Received: from localhost.localdomain (oasis.cs.illinois.edu [130.126.137.13])
	by mx0a-00007101.pphosted.com (PPS) with ESMTP id 42t0dy362v-1;
	Mon, 11 Nov 2024 06:51:38 +0000 (GMT)
From: Jinghao Jia <jinghao7@illinois.edu>
To: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@netfilter.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, Nathan Chancellor <nathan@kernel.org>,
        Nick Desaulniers <ndesaulniers@google.com>,
        Bill Wendling <morbo@google.com>,
        Justin Stitt <justinstitt@google.com>, Kees Cook <kees@kernel.org>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org, llvm@lists.linux.dev,
        Jinghao Jia <jinghao7@illinois.edu>, kernel test robot <lkp@intel.com>,
        Ruowen Qin <ruqin@redhat.com>
Subject: [PATCH] ipvs: fix UB due to uninitialized stack access in ip_vs_protocol_init()
Date: Mon, 11 Nov 2024 00:51:05 -0600
Message-ID: <20241111065105.82431-1-jinghao7@illinois.edu>
X-Mailer: git-send-email 2.47.0
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-GUID: ePDWI69DVPRvmLg5drIxgZ6AhaoctuzM
X-Proofpoint-ORIG-GUID: UtEpqJ5p1NH21y5diKtFX63ZyGgD1z6l
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1051,Hydra:6.0.680,FMLib:17.12.62.30
 definitions=2024-10-05_03,2024-10-04_01,2024-09-30_01
X-Spam-Details: rule=cautious_plus_nq_notspam policy=cautious_plus_nq score=0 adultscore=0
 mlxlogscore=999 priorityscore=1501 malwarescore=0 clxscore=1011
 lowpriorityscore=0 bulkscore=0 mlxscore=0 spamscore=0 phishscore=0
 suspectscore=0 impostorscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.19.0-2409260000 definitions=main-2411110057
X-Spam-Score: 0
X-Spam-OrigSender: jinghao7@illinois.edu
X-Spam-Bar: 

Under certain kernel configurations when building with Clang/LLVM, the
compiler does not generate a return or jump as the terminator
instruction for ip_vs_protocol_init(), triggering the following objtool
warning during build time:

  vmlinux.o: warning: objtool: ip_vs_protocol_init() falls through to next function __initstub__kmod_ip_vs_rr__935_123_ip_vs_rr_init6()

At runtime, this either causes an oops when trying to load the ipvs
module or a boot-time panic if ipvs is built-in. This same issue has
been reported by the Intel kernel test robot previously.

Digging deeper into both LLVM and the kernel code reveals this to be a
undefined behavior problem. ip_vs_protocol_init() uses a on-stack buffer
of 64 chars to store the registered protocol names and leaves it
uninitialized after definition. The function calls strnlen() when
concatenating protocol names into the buffer. With CONFIG_FORTIFY_SOURCE
strnlen() performs an extra step to check whether the last byte of the
input char buffer is a null character (commit 3009f891bb9f ("fortify:
Allow strlen() and strnlen() to pass compile-time known lengths")).
This, together with possibly other configurations, cause the following
IR to be generated:

  define hidden i32 @ip_vs_protocol_init() local_unnamed_addr #5 section ".init.text" align 16 !kcfi_type !29 {
    %1 = alloca [64 x i8], align 16
    ...

  14:                                               ; preds = %11
    %15 = getelementptr inbounds i8, ptr %1, i64 63
    %16 = load i8, ptr %15, align 1
    %17 = tail call i1 @llvm.is.constant.i8(i8 %16)
    %18 = icmp eq i8 %16, 0
    %19 = select i1 %17, i1 %18, i1 false
    br i1 %19, label %20, label %23

  20:                                               ; preds = %14
    %21 = call i64 @strlen(ptr noundef nonnull dereferenceable(1) %1) #23
    ...

  23:                                               ; preds = %14, %11, %20
    %24 = call i64 @strnlen(ptr noundef nonnull dereferenceable(1) %1, i64 noundef 64) #24
    ...
  }

The above code calculates the address of the last char in the buffer
(value %15) and then loads from it (value %16). Because the buffer is
never initialized, the LLVM GVN pass marks value %16 as undefined:

  %13 = getelementptr inbounds i8, ptr %1, i64 63
  br i1 undef, label %14, label %17

This gives later passes (SCCP, in particular) to more DCE opportunities
by propagating the undef value further, and eventually removes
everything after the load on the uninitialized stack location:

  define hidden i32 @ip_vs_protocol_init() local_unnamed_addr #0 section ".init.text" align 16 !kcfi_type !11 {
    %1 = alloca [64 x i8], align 16
    ...

  12:                                               ; preds = %11
    %13 = getelementptr inbounds i8, ptr %1, i64 63
    unreachable
  }

In this way, the generated native code will just fall through to the
next function, as LLVM does not generate any code for the unreachable IR
instruction and leaves the function without a terminator.

Zero the on-stack buffer to avoid this possible UB.

Reported-by: kernel test robot <lkp@intel.com>
Closes: https://lore.kernel.org/oe-kbuild-all/202402100205.PWXIz1ZK-lkp@intel.com/
Co-developed-by: Ruowen Qin <ruqin@redhat.com>
Signed-off-by: Ruowen Qin <ruqin@redhat.com>
Signed-off-by: Jinghao Jia <jinghao7@illinois.edu>
---
 net/netfilter/ipvs/ip_vs_proto.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index f100da4ba3bc..a9fd1d3fc2cb 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -340,7 +340,7 @@ void __net_exit ip_vs_protocol_net_cleanup(struct netns_ipvs *ipvs)
 
 int __init ip_vs_protocol_init(void)
 {
-	char protocols[64];
+	char protocols[64] = { 0 };
 #define REGISTER_PROTOCOL(p)			\
 	do {					\
 		register_ip_vs_protocol(p);	\
@@ -348,8 +348,6 @@ int __init ip_vs_protocol_init(void)
 		strcat(protocols, (p)->name);	\
 	} while (0)
 
-	protocols[0] = '\0';
-	protocols[2] = '\0';
 #ifdef CONFIG_IP_VS_PROTO_TCP
 	REGISTER_PROTOCOL(&ip_vs_protocol_tcp);
 #endif
-- 
2.47.0

