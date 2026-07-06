Received: from azure-sdnproxy.icoremail.net (azure-sdnproxy.icoremail.net [13.76.78.106])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id E5DAF35898;
	Mon,  6 Jul 2026 10:17:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=13.76.78.106
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783333033; cv=none; b=Gqn+kMfJ8TdMxk/OZPMU9ycGif4+wCOCLREmYEraBpcQvxnGf8z7DYEClINSAdsHlb/zNSBDcorjOX54fRt2UTVNH3x8lGT7HhLtT9BI5oR1jzFu4lQGYIAsEAtgH4F9oewulePq5p3bg9Ghgxe+LfF6gOHXvvK+FWk/91aHEMo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783333033; c=relaxed/simple;
	bh=EyxWQN/rULz6J3EdcHdyzBD12Jo6pueu2GXlxyec6Ow=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=FSkvFPgYdrkadTqmbX/93C1AHaXcW83c5Uk/u0BHsumz2kk6yxZZ4yh0H+akpio3QKGgUbzTtYd0caH22zlfMh2hsh9Z4WhhRucYNIapy6FhbA5CjaAAsQYMc9Jy2Prelvk2nBjH3Vyurz5nvlEOpTxWSfIIW6LA1sIwX2iThsc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn; dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b=YpKTZp3e; arc=none smtp.client-ip=13.76.78.106
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b="YpKTZp3e"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=mails.tsinghua.edu.cn; s=dkim; h=Received:From:To:Cc:Subject:
	Date:Message-ID:In-Reply-To:References:MIME-Version:
	Content-Transfer-Encoding; bh=SUvTNRvOdGC2QNO9hA+KozN3n852Gj0pbJ
	WXxhLiEG4=; b=YpKTZp3e3IW7xZ+/zTkoNyGz/cBPPq9VyYM5wvaV7y6UULmTPH
	iGyHBOhwRvHeKgP8CF6vPJ7Kp/I1XjSXBPP6JZ/cmLySvJjdtAT1b8+3nW9E+wf7
	c1PAmZqX3R0MdG5wYrKfI0lWiEsqKwXmLE1vuGqhBC1vwd1YabowlgEAE=
Received: from localhost.localdomain (unknown [101.5.13.242])
	by web4 (Coremail) with SMTP id ywQGZQD3CJ6GgEtq_fjIAg--.37800S4;
	Mon, 06 Jul 2026 18:16:45 +0800 (CST)
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
Subject: [PATCH nf v2 2/3] ipvs: use parsed transport offset in TCP state lookup
Date: Mon,  6 Jul 2026 18:16:23 +0800
Message-ID: <20260706101624.69471-3-zhaoyz24@mails.tsinghua.edu.cn>
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
X-CM-TRANSID:ywQGZQD3CJ6GgEtq_fjIAg--.37800S4
X-Coremail-Antispam: 1UD129KBjvJXoW7tw43Cry5WrWfAw1Utw4DCFg_yoW8Zr1fpa
	4fCa4ayrW7GryDAwsrtrWxCw45Gw4DuFyxXrW5try5Z3Z8Xrn5tFnYk39F9FnYv3ykK34x
	AF90v345Ar4DJ37anT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUU9l1xkIjI8I6I8E6xAIw20EY4v20xvaj40_Wr0E3s1l8cAvFVAK
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
	4j6r4UJbIYCTnIWIevJa73UjIFyTuYvjfUza0mUUUUU
X-CM-SenderInfo: 52kd05r2suqzpdlo2hxwvl0wxkxdhvlgxou0/1tbiAgIAAWpLXY1ANAAAsE

TCP state handling reparses the skb to find the TCP header. For IPv6 it
uses sizeof(struct ipv6hdr), while the surrounding IPVS code already
parsed the packet with ip_vs_fill_iph_skb() and has the real
transport-header offset in iph.len.

This makes TCP state handling look at the wrong bytes when an IPv6
packet carries extension headers. Use the parsed transport offset passed
down from ip_vs_set_state() when reading the TCP header.

For IPv4 and for IPv6 packets without extension headers, the passed
offset matches the previous value.

Fixes: 0bbdd42b7efa6 ("IPVS: Extend protocol DNAT/SNAT and state handlers")
Link: https://lore.kernel.org/netdev/20260705125659.37744-1-zhaoyz24@mails.tsinghua.edu.cn/
Reported-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
Reported-by: Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>
Reported-by: Ao Wang <wangao@seu.edu.cn>
Reported-by: Xuewei Feng <fengxw06@126.com>
Reported-by: Qi Li <qli01@tsinghua.edu.cn>
Reported-by: Ke Xu <xuke@tsinghua.edu.cn>
Assisted-by: Claude Code:GLM-5.2
Signed-off-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
---
 net/netfilter/ipvs/ip_vs_proto_tcp.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 2d3f6aeafe52..f86b763efcc4 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -584,13 +584,7 @@ tcp_state_transition(struct ip_vs_conn *cp, int direction,
 {
 	struct tcphdr _tcph, *th;
 
-#ifdef CONFIG_IP_VS_IPV6
-	int ihl = cp->af == AF_INET ? ip_hdrlen(skb) : sizeof(struct ipv6hdr);
-#else
-	int ihl = ip_hdrlen(skb);
-#endif
-
-	th = skb_header_pointer(skb, ihl, sizeof(_tcph), &_tcph);
+	th = skb_header_pointer(skb, iph_len, sizeof(_tcph), &_tcph);
 	if (th == NULL)
 		return;
 
-- 
2.34.1

