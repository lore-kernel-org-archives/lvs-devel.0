Return-Path: <lvs-devel-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A0A1CDB47E
	for <lvs-devel@archiver.kernel.org>; Fri, 13 Oct 2023 20:01:47 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231707AbjJMUBq (ORCPT <rfc822;lvs-devel@archiver.kernel.org>);
        Fri, 13 Oct 2023 16:01:46 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33410 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231596AbjJMUBp (ORCPT
        <rfc822;lvs-devel@vger.kernel.org>); Fri, 13 Oct 2023 16:01:45 -0400
Received: from orbyte.nwl.cc (orbyte.nwl.cc [IPv6:2001:41d0:e:133a::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 90349B7
        for <lvs-devel@vger.kernel.org>; Fri, 13 Oct 2023 13:01:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=nwl.cc;
        s=mail2022; h=Content-Transfer-Encoding:MIME-Version:Message-ID:Date:Subject:
        Cc:To:From:Sender:Reply-To:Content-Type:Content-ID:Content-Description:
        Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:
        In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:List-Subscribe:
        List-Post:List-Owner:List-Archive;
        bh=zXDLb76PDXqdMqLINzEX5dpLOSN1jrNYpcwengtND44=; b=Lim5HBk9ifa5hqUhPGis1KCvHs
        s/Zaz0xDPdBuswPJf5SUKLqKndPLUuNI4RI2dg+9e45UuTUvVpwSVQFakZ5gWMtMYsK4UchMRPurH
        tFHmMs24TBgsXsxRQn210I9I21Qta1E0AviXR8g37s54jBatD7m1rbc64rGPfcrYVauA5FtmWEXD4
        31IAGeAnPDNWMZrg9PQSI26hj/e7gmaTmxoXAEWX8/NP+tsR7gIz1wWoqJDSwSYcjowogEYStpAAk
        CLrAV6aevm5F42DIQH8hOEueHYqesEynIx1Gbj/erruEjnqz4Akn+m1T/ozEy9t77Lj0cmH7mn7JY
        AzJVo36w==;
Received: from localhost ([::1] helo=xic)
        by orbyte.nwl.cc with esmtp (Exim 4.94.2)
        (envelope-from <phil@nwl.cc>)
        id 1qrOLs-00044A-92; Fri, 13 Oct 2023 22:01:40 +0200
From:   Phil Sutter <phil@nwl.cc>
To:     Simon Horman <horms@verge.net.au>
Cc:     Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org
Subject: [PATCH] selftests: netfilter: Avoid hanging ipvs.sh
Date:   Fri, 13 Oct 2023 22:01:36 +0200
Message-ID: <20231013200136.6548-1-phil@nwl.cc>
X-Mailer: git-send-email 2.41.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <lvs-devel.vger.kernel.org>
X-Mailing-List: lvs-devel@vger.kernel.org

If the client can't reach the server, the latter remains listening
forever. Kill it after 3s of waiting.

Fixes: 867d2190799ab ("selftests: netfilter: add ipvs test script")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tools/testing/selftests/netfilter/ipvs.sh | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/tools/testing/selftests/netfilter/ipvs.sh b/tools/testing/selftests/netfilter/ipvs.sh
index c3b8f90c497e0..bc5bda5c13000 100755
--- a/tools/testing/selftests/netfilter/ipvs.sh
+++ b/tools/testing/selftests/netfilter/ipvs.sh
@@ -124,6 +124,10 @@ client_connect() {
 }
 
 verify_data() {
+	waitpid -t 3 "${server_pid}"
+	if [ $? -eq 3 ]; then
+		kill "${server_pid}"
+	fi
 	wait "${server_pid}"
 	cmp "$infile" "$outfile" 2>/dev/null
 }
-- 
2.41.0

