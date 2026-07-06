Received: from azure-sdnproxy.icoremail.net (azure-sdnproxy.icoremail.net [13.76.78.106])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 8F1D027EFE9;
	Mon,  6 Jul 2026 10:17:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=13.76.78.106
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783333038; cv=none; b=m2egHoBuS3J3cnfWC6jcuMQr9zYnDs69ynrfal5dKc+h6BOIBStGePhT0DYUEgKRnhUZ9Wbl10EAeI2S03swvSu+gEwkO9PDziqhXg4pOEkAJRW3ujeUD3h8qXUFILnNjvYtHgktm/fwVq6w10qMOak2Gmq9GcaTigQxvbc43sE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783333038; c=relaxed/simple;
	bh=p+si7ZsHjIMJ1PEOiQoKrg9He0a297zC3FGaqIu/EKw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=YfPzx7HKo1d80+NvhhB9jVh2sz9jw2wivZK+nRzxE+r6CiZYsPt4X9fBuyraMXA/3tTZGiXYNOng8jN43/At/P/bS1QPzq5231HdPVVTH5DWYeDqQwYuoIg+PyEXHvufdeIjojTeoxp+MlmqN1fgnFotNr5btw2VY5Q39D6caQ0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn; dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b=VTXK7oOv; arc=none smtp.client-ip=13.76.78.106
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b="VTXK7oOv"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=mails.tsinghua.edu.cn; s=dkim; h=Received:From:To:Cc:Subject:
	Date:Message-ID:In-Reply-To:References:MIME-Version:
	Content-Transfer-Encoding; bh=WGOYNbLeYd80tonmLqfKBMz1uAVyPNhwQe
	rZgJCcNHg=; b=VTXK7oOvM4W7C3crCBBgzmO4fT8BZkcsm1pXRgIPmP05+nB298
	mttIltCI1B/tg001RYnE+SZweqC9d0413wv/k6gD8gfQwjhFAI+U4zcb+hI3pnhv
	C55yjDYswmipsEb+CFWiXMV4jxNYNUTuOgJ5X5VSqsaMuDfJORgO0Jm6U=
Received: from localhost.localdomain (unknown [101.5.13.242])
	by web4 (Coremail) with SMTP id ywQGZQD3CJ6GgEtq_fjIAg--.37800S5;
	Mon, 06 Jul 2026 18:16:53 +0800 (CST)
From: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
To: netdev@vger.kernel.org
Cc: coreteam@netfilter.org,
	davem@davemloft.net,
	edumazet@google.com,
	fengxw06@126.com,
	fw@strlen.de,
	horms@verge.net.au,
	ja@ssi.bg,
	kuba@kernel.org,
	linux-kernel@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	pabeni@redhat.com,
	pablo@netfilter.org,
	phil@nwl.cc,
	qli01@tsinghua.edu.cn,
	stable@vger.kernel.org,
	wangao@seu.edu.cn,
	xuke@tsinghua.edu.cn,
	yangyx22@mails.tsinghua.edu.cn,
	Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
Subject: [PATCH nf v2 3/3] ipvs: use parsed transport offset in SCTP state lookup
Date: Mon,  6 Jul 2026 18:16:24 +0800
Message-ID: <20260706101624.69471-4-zhaoyz24@mails.tsinghua.edu.cn>
X-Mailer: git-send-email 2.46.2
In-Reply-To: <20260706101624.69471-1-zhaoyz24@mails.tsinghua.edu.cn>
References: <20260706101624.69471-1-zhaoyz24@mails.tsinghua.edu.cn>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-CM-TRANSID:ywQGZQD3CJ6GgEtq_fjIAg--.37800S5
X-Coremail-Antispam: 1UD129KBjvJXoWxZry8CF48CF13GrW5Ar1DWrg_yoW5CFyDpa
	90krW3Wry7Jryqqws7Aw18C3y5Gws7W3yagr98tasxA3Z0grn5tF97KrWY9a1FkrWvgry2
	vr90q3y5ZF4kAFJanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUU9G1xkIjI8I6I8E6xAIw20EY4v20xvaj40_Wr0E3s1l8cAvFVAK
	0II2c7xJM28CjxkF64kEwVA0rcxSw2x7M28EF7xvwVC0I7IYx2IY67AKxVW5JVW7JwA2z4
	x0Y4vE2Ix0cI8IcVCY1x0267AKxVW8Jr0_Cr1UM28EF7xvwVC2z280aVAFwI0_GcCE3s1l
	84ACjcxK6I8E87Iv6xkF7I0E14v26rxl6s0DM2vYz4IE04k24VAvwVAKI4IrM2AIxVAIcx
	kEcVAq07x20xvEncxIr21l5I8CrVACY4xI64kE6c02F40Ex7xfMcIj6x8ErcxFaVAv8VW8
	Ww4UJr1UMcvjeVCFs4IE7xkEbVWUJVW8JwACjcxG0xvY0x0EwIxGrwACjI8F5VA0II8E6I
	AqYI8I648v4I1lFIxGxcIEc7CjxVA2Y2ka0xkIwI1lc7CjxVAaw2AFwI0_GFv_Wrylc2xS
	Y4AK67AK6r4DMxAIw28IcxkI7VAKI48JMxAIw28IcVCjz48v1sIEY20_GrWkJr1UJwCFx2
	IqxVCFs4IE7xkEbVWUJVW8JwC20s026c02F40E14v26r1j6r18MI8I3I0E7480Y4vE14v2
	6r106r1rMI8E67AF67kF1VAFwI0_GFv_WrylIxkGc2Ij64vIr41lIxAIcVC0I7IYx2IY67
	AKxVWUJVWUCwCI42IY6xIIjxv20xvEc7CjxVAFwI0_Cr0_Gr1UMIIF0xvE42xK8VAvwI8I
	cIk0rVWUJVWUCwCI42IY6I8E87Iv67AKxVWUJVW8JwCI42IY6I8E87Iv6xkF7I0E14v26r
	4UJVWxJrUvcSsGvfC2KfnxnUUI43ZEXa7VU1Z2-7UUUUU==
X-CM-SenderInfo: 52kd05r2suqzpdlo2hxwvl0wxkxdhvlgxou0/1tbiAgYAAWpLXY1APgAAsK

set_sctp_state() reads the SCTP chunk header again in order to drive the
IPVS SCTP state table. For IPv6 it computes the offset with
sizeof(struct ipv6hdr), while the surrounding IPVS code uses iph.len from
ip_vs_fill_iph_skb(), where ipv6_find_hdr() has already skipped
extension headers and found the real transport header.

This makes the state machine read from the wrong offset for IPv6 SCTP
packets that carry extension headers. For example, an INIT packet with an
8-byte destination options header can be scheduled correctly by
sctp_conn_schedule(), but set_sctp_state() reads the first byte of the
SCTP verification tag as a DATA chunk type. The connection then moves
from NONE to ESTABLISHED instead of INIT1, gets the longer established
timeout, and updates the active/inactive destination counters
incorrectly. This happens even though the SCTP handshake has not
completed.

Use the parsed transport offset passed down from ip_vs_set_state() for
the SCTP chunk-header lookup. For IPv4 and IPv6 packets without
extension headers this preserves the existing offset.

Fixes: 2906f66a5682 ("ipvs: SCTP Trasport Loadbalancing Support")
Cc: stable@vger.kernel.org
Link: https://lore.kernel.org/netdev/20260705123040.35755-1-zhaoyz24@mails.tsinghua.edu.cn/
Reported-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
Reported-by: Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>
Reported-by: Ao Wang <wangao@seu.edu.cn>
Reported-by: Xuewei Feng <fengxw06@126.com>
Reported-by: Qi Li <qli01@tsinghua.edu.cn>
Reported-by: Ke Xu <xuke@tsinghua.edu.cn>
Assisted-by: Claude Code:GLM-5.2
Signed-off-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 394367b7b388..c67317be17df 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -372,20 +372,15 @@ static const char *sctp_state_name(int state)
 
 static inline void
 set_sctp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
-		int direction, const struct sk_buff *skb)
+		int direction, const struct sk_buff *skb,
+		unsigned int iph_len)
 {
 	struct sctp_chunkhdr _sctpch, *sch;
 	unsigned char chunk_type;
 	int event, next_state;
-	int ihl, cofs;
-
-#ifdef CONFIG_IP_VS_IPV6
-	ihl = cp->af == AF_INET ? ip_hdrlen(skb) : sizeof(struct ipv6hdr);
-#else
-	ihl = ip_hdrlen(skb);
-#endif
+	int cofs;
 
-	cofs = ihl + sizeof(struct sctphdr);
+	cofs = iph_len + sizeof(struct sctphdr);
 	sch = skb_header_pointer(skb, cofs, sizeof(_sctpch), &_sctpch);
 	if (sch == NULL)
 		return;
@@ -472,7 +467,7 @@ sctp_state_transition(struct ip_vs_conn *cp, int direction,
 		unsigned int iph_len)
 {
 	spin_lock_bh(&cp->lock);
-	set_sctp_state(pd, cp, direction, skb);
+	set_sctp_state(pd, cp, direction, skb, iph_len);
 	spin_unlock_bh(&cp->lock);
 }
 
-- 
2.34.1

