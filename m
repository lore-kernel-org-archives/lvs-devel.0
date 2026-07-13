Received: from zg8tmtyylji0my4xnjqumte4.icoremail.net (zg8tmtyylji0my4xnjqumte4.icoremail.net [162.243.164.118])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id A0C833F39E9;
	Mon, 13 Jul 2026 11:53:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=162.243.164.118
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783943612; cv=none; b=BhfVA6d+eHRZ6PcvuObzE9mpcLelrhO/4U2pmAenG2I25MqF6hvO2tYQ8jPtdVT2pmJZ282MGYPIsmgcxwWfhYzECoDejWIONrecqLq3rdizMwb8aLLOD6iQF5sNVf6VgPvCF+v+UJ+YNV11wlMV2HTGBSC8mLne9Vv/I34H4rw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783943612; c=relaxed/simple;
	bh=HcC9fbJwHBUodaXK7DZTeCe/9fbTO4P8SJK02Imzqss=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=e2jdWOeseQnC0rXoTR8Vo20fZHTNaffwAU5oFDKFUo8OQH8GV2rXEpjKazjzLn8PQ3Z724P27MODMdE669+XOQruGq33MnYUuc0KpQ4V75x1FxbwmmHitgF82y5FZn90bn8+LYIlpMvTLp3rHeuDJtZFfae5g1NdAd1d+lUsXz4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=lzu.edu.cn; spf=pass smtp.mailfrom=lzu.edu.cn; arc=none smtp.client-ip=162.243.164.118
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=lzu.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lzu.edu.cn
Received: from enjou-Legion-Y7000P-2019 (unknown [123.114.53.210])
	by app1 (Coremail) with SMTP id ygmowAAXOsSU0VRqvicCAQ--.58336S3;
	Mon, 13 Jul 2026 19:53:01 +0800 (CST)
From: Ren Wei <n05ec@lzu.edu.cn>
To: lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Cc: horms@verge.net.au,
	ja@ssi.bg,
	pablo@netfilter.org,
	fw@strlen.de,
	phil@nwl.cc,
	kaber@trash.net,
	nick@loadbalancer.org,
	yuantan098@gmail.com,
	yifanwucs@gmail.com,
	tomapufckgml@gmail.com,
	bird@lzu.edu.cn,
	roxy520tt@gmail.com,
	n05ec@lzu.edu.cn
Subject: [PATCH v2 1/2] ipvs: do not propagate one-packet flag to synced conns
Date: Mon, 13 Jul 2026 19:52:32 +0800
Message-ID: <36c8cc69242426e0bc6b618749052a5943735de3.1783917666.git.roxy520tt@gmail.com>
X-Mailer: git-send-email 2.51.0
In-Reply-To: <cover.1783917666.git.roxy520tt@gmail.com>
References: <cover.1783917666.git.roxy520tt@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-CM-TRANSID:ygmowAAXOsSU0VRqvicCAQ--.58336S3
X-Coremail-Antispam: 1UD129KBjvJXoW7Cw13uF1Utr17Gr1fuF1UGFg_yoW8tw47pF
	W8K393GrW7try5KF1kAFyxurW8WF4kGr429r4DGw1rZa1qqrn8tanakFWYv3W8CFZ0kFWY
	qFs0vw4DCr1UA3DanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUU9S1xkIjI8I6I8E6xAIw20EY4v20xvaj40_Wr0E3s1l1IIY67AE
	w4v_Jr0_Jr4l8cAvFVAK0II2c7xJM28CjxkF64kEwVA0rcxSw2x7M28EF7xvwVC0I7IYx2
	IY67AKxVW5JVW7JwA2z4x0Y4vE2Ix0cI8IcVCY1x0267AKxVWxJVW8Jr1l84ACjcxK6I8E
	87Iv67AKxVW0oVCq3wA2z4x0Y4vEx4A2jsIEc7CjxVAFwI0_GcCE3s1le2I262IYc4CY6c
	8Ij28IcVAaY2xG8wAqx4xG64xvF2IEw4CE5I8CrVC2j2WlYx0E2Ix0cI8IcVAFwI0_Jr0_
	Jr4lYx0Ex4A2jsIE14v26r1j6r4UMcvjeVCFs4IE7xkEbVWUJVW8JwACjcxG0xvY0x0EwI
	xGrwACjI8F5VA0II8E6IAqYI8I648v4I1lFIxGxcIEc7CjxVA2Y2ka0xkIwI1lc7CjxVAa
	w2AFwI0_Jw0_GFyl42xK82IYc2Ij64vIr41l42xK82IY6x8ErcxFaVAv8VW8WwCFx2IqxV
	CFs4IE7xkEbVWUJVW8JwC20s026c02F40E14v26r1j6r18MI8I3I0E7480Y4vE14v26r10
	6r1rMI8E67AF67kF1VAFwI0_Jw0_GFylIxkGc2Ij64vIr41lIxAIcVC0I7IYx2IY67AKxV
	WUJVWUCwCI42IY6xIIjxv20xvEc7CjxVAFwI0_Gr0_Cr1lIxAIcVCF04k26cxKx2IYs7xG
	6r1j6r1xMIIF0xvEx4A2jsIE14v26r1j6r4UMIIF0xvEx4A2jsIEc7CjxVAFwI0_Gr0_Gr
	1UYxBIdaVFxhVjvjDU0xZFpf9x0JUd-B_UUUUU=
X-CM-SenderInfo: zqqvvuo6o23hxhgxhubq/1tbiAQEHCWpUn9kElAAAsm

From: Zhiling Zou <roxy520tt@gmail.com>

Synced connections can be created before their destination exists. When
the destination is later added, ip_vs_bind_dest() copies connection flags
from the destination into cp->flags.

IP_VS_CONN_F_ONE_PACKET connections are not synced. If a synced
connection inherits IP_VS_CONN_F_ONE_PACKET while it is already hashed,
expiry can treat it as a one-packet connection and skip unlinking the
existing conn_tab node, leaving stale hash nodes pointing at a freed
struct ip_vs_conn.

Drop IP_VS_CONN_F_ONE_PACKET from destination flags when binding synced
connections.

Fixes: 26ec037f9841 ("IPVS: one-packet scheduling")
Cc: stable@vger.kernel.org
Reported-by: Yuan Tan <yuantan098@gmail.com>
Reported-by: Yifan Wu <yifanwucs@gmail.com>
Reported-by: Juefei Pu <tomapufckgml@gmail.com>
Reported-by: Xin Liu <bird@lzu.edu.cn>
Suggested-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Zhiling Zou <roxy520tt@gmail.com>
Signed-off-by: Ren Wei <n05ec@lzu.edu.cn>
---
Changes in v2:
- Replace the v1 approach that preserved hash-related flags on late
  destination binding.
- Drop IP_VS_CONN_F_ONE_PACKET from conn_flags for synced connections,
  because one-packet connections are not synchronized.
- Leave forwarding method updates to the follow-up hn1 hashing fix in
  patch 2.
- Add Suggested-by for Julian's review suggestion.

v1 Link: https://lore.kernel.org/all/1b914f41d725bc064c9ba9830dc8169329737270.1782540466.git.roxy520tt@gmail.com/

 net/netfilter/ipvs/ip_vs_conn.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 6ed2622363f0..0682cec5f0a7 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1014,6 +1014,9 @@ ip_vs_bind_dest(struct ip_vs_conn *cp, struct ip_vs_dest *dest)
 	flags = cp->flags;
 	/* Bind with the destination and its corresponding transmitter */
 	if (flags & IP_VS_CONN_F_SYNC) {
+		/* Synced conns are hashed, so they can not get this flag */
+		conn_flags &= ~IP_VS_CONN_F_ONE_PACKET;
+
 		/* if the connection is not template and is created
 		 * by sync, preserve the activity flag.
 		 */
-- 
2.43.0

