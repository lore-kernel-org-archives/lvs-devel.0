Received: from zg8tmtyylji0my4xnjqumte4.icoremail.net (zg8tmtyylji0my4xnjqumte4.icoremail.net [162.243.164.118])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 4BE5C33F8D9;
	Sun,  5 Jul 2026 12:57:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=162.243.164.118
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783256274; cv=none; b=rxQoz1qaruwIwGfUTqFcTQo7Os3W+Q1dWk7mQrDSpY3ziTL3KIFd6jkHaVnYYGEhVbCNZ95Zr91Ko8B9DDuzJG/GQHSsyigAl6ryg6zuE/PA3xWs7Q66jYBEEx07T5LYOAY8HkKJe61JuW5GK8IsUaP7VAcdmIGCYOAaH53Vo7s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783256274; c=relaxed/simple;
	bh=JfeaWhTgfk1VVJFOa8gpsqn7yxCKwJiVtG1OOViNics=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=GTfnvfY6vj48mYni5FVhX44cS4Dv9MZvmxDOlWcT/K0OVq3Ofs8Ck6nuJDkqLYJr4ZlPGFiyfVX9JPLEbc5rYMGSIZ70HAtt3Ycux2rRgHq0A5EPzdQWtCxie+kgtTUwKAIXuvtfHCWwbsU7+QvHfUxpS14wUHHCgSCkMZdvnCY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn; dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b=GnA8Mpap; arc=none smtp.client-ip=162.243.164.118
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b="GnA8Mpap"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=mails.tsinghua.edu.cn; s=dkim; h=Received:From:To:Cc:Subject:
	Date:Message-ID:MIME-Version:Content-Transfer-Encoding; bh=g26Y8
	qEXSEdFe8XAykfZFO9hTc4mjOTVDG3P2EL4Q/U=; b=GnA8MpapEihW+GNu3TKo+
	vv9RiYOQAfRw7e/EFYGUoEoOhNpSYrGZS8EBzPxg2dvI66t68tPrYZAoKwQzkK/L
	TK/QP0uNoCRAyOU+CvmB0257gELyfRz/dV3vO/Y32+NOzJJEvjrY3lBsgNHAMf7b
	Lxrk2kB8LNdRoPPvoTY2Yg=
Received: from localhost.localdomain (unknown [101.5.13.242])
	by web4 (Coremail) with SMTP id ywQGZQBXa6CrVEpq2NvBAg--.23888S2;
	Sun, 05 Jul 2026 20:57:15 +0800 (CST)
From: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
To: netdev@vger.kernel.org
Cc: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	linux-kernel@vger.kernel.org,
	Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>,
	Ao Wang <wangao@seu.edu.cn>,
	Xuewei Feng <fengxw06@126.com>,
	Qi Li <qli01@tsinghua.edu.cn>,
	Ke Xu <xuke@tsinghua.edu.cn>,
	stable@vger.kernel.org
Subject: [PATCH nf] ipvs: skip IPv6 extension headers in TCP state lookup
Date: Sun,  5 Jul 2026 20:56:57 +0800
Message-ID: <20260705125659.37744-1-zhaoyz24@mails.tsinghua.edu.cn>
X-Mailer: git-send-email 2.46.2
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-CM-TRANSID:ywQGZQBXa6CrVEpq2NvBAg--.23888S2
X-Coremail-Antispam: 1UD129KBjvJXoWxJw4xJFW3Xr4kXr1rZw18Xwb_yoW5Xw17pa
	sak3yagryDJr90yws7Jr1xC3y5Grs3CayxWryDta45X3Z8Wrn5tF95K39F9FsYkrWvgw17
	Xr90q345Zr4kA37anT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUU9m1xkIjI8I6I8E6xAIw20EY4v20xvaj40_Wr0E3s1l8cAvFVAK
	0II2c7xJM28CjxkF64kEwVA0rcxSw2x7M28EF7xvwVC0I7IYx2IY67AKxVW5JVW7JwA2z4
	x0Y4vE2Ix0cI8IcVCY1x0267AKxVW8Jr0_Cr1UM28EF7xvwVC2z280aVAFwI0_GcCE3s1l
	84ACjcxK6I8E87Iv6xkF7I0E14v26rxl6s0DM2vYz4IE04k24VAvwVAKI4IrM2AIxVAIcx
	kEcVAq07x20xvEncxIr21l5I8CrVACY4xI64kE6c02F40Ex7xfMcIj6x8ErcxFaVAv8VW8
	Ww4UJr1UMcvjeVCFs4IE7xkEbVWUJVW8JwACjcxG0xvY0x0EwIxGrwACjI8F5VA0II8E6I
	AqYI8I648v4I1lFIxGxcIEc7CjxVA2Y2ka0xkIwI1lc7CjxVAaw2AFwI0_GFv_Wrylc2xS
	Y4AK67AK6ryUMxAIw28IcxkI7VAKI48JMxAIw28IcVCjz48v1sIEY20_GrWkJr1UJwCFx2
	IqxVCFs4IE7xkEbVWUJVW8JwC20s026c02F40E14v26r1j6r18MI8I3I0E7480Y4vE14v2
	6r106r1rMI8E67AF67kF1VAFwI0_GFv_WrylIxkGc2Ij64vIr41lIxAIcVC0I7IYx2IY67
	AKxVWUJVWUCwCI42IY6xIIjxv20xvEc7CjxVAFwI0_Gr0_Cr1lIxAIcVCF04k26cxKx2IY
	s7xG6r1j6r1xMIIF0xvEx4A2jsIE14v26r1j6r4UMIIF0xvEx4A2jsIEc7CjxVAFwI0_Gr
	0_Gr1UYxBIdaVFxhVjvjDU0xZFpf9x0JUG_M-UUUUU=
X-CM-SenderInfo: 52kd05r2suqzpdlo2hxwvl0wxkxdhvlgxou0/1tbiAgETAWpKHF5PtgAAsK

tcp_state_transition() reads the TCP header again in order to drive the
IPVS TCP state table.  For IPv6 it computes the offset with
sizeof(struct ipv6hdr), while the surrounding IPVS code uses iph->len from
ip_vs_fill_iph_skb(), where ipv6_find_hdr() has already skipped extension
headers and found the real transport header.

This makes the state machine read from the wrong offset for IPv6 TCP
packets that carry extension headers.  For example, a SYN packet with an
8-byte destination options header can be scheduled correctly by
tcp_conn_schedule(), but tcp_state_transition() reads a byte from the real
TCP sequence number as the TCP flags.  An attacker can therefore make an
uncompleted SYN move from NONE to ESTABLISHED or CLOSE, changing the
connection timeout and active/inactive destination counters.  In the
ESTABLISHED case, the half-open connection gets the 15 minute established
timeout instead of the shorter SYN_RECV timeout, which can be used for a
remote denial of service against an IPv6 IPVS TCP service.

Use ip_vs_fill_iph_skb() in tcp_state_transition() and read the TCP header
from iph.len, matching tcp_conn_schedule() and the TCP NAT handlers.  For
IPv4 and IPv6 packets without extension headers this preserves the existing
offset.

Fixes: 0bbdd42b7efa ("IPVS: Extend protocol DNAT/SNAT and state handlers")
Cc: stable@vger.kernel.org
Reported-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
Reported-by: Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>
Reported-by: Ao Wang <wangao@seu.edu.cn>
Reported-by: Xuewei Feng <fengxw06@126.com>
Reported-by: Qi Li <qli01@tsinghua.edu.cn>
Reported-by: Ke Xu <xuke@tsinghua.edu.cn>
Assisted-by: Claude-Code:GLM-5.2
Signed-off-by: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
---
 net/netfilter/ipvs/ip_vs_proto_tcp.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 8cc0a8ce6241..6fde2165a8d6 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -581,15 +581,13 @@ tcp_state_transition(struct ip_vs_conn *cp, int direction,
 		     const struct sk_buff *skb,
 		     struct ip_vs_proto_data *pd)
 {
 	struct tcphdr _tcph, *th;
+	struct ip_vs_iphdr iph;
 
-#ifdef CONFIG_IP_VS_IPV6
-	int ihl = cp->af == AF_INET ? ip_hdrlen(skb) : sizeof(struct ipv6hdr);
-#else
-	int ihl = ip_hdrlen(skb);
-#endif
+	if (!ip_vs_fill_iph_skb(cp->af, skb, false, &iph))
+		return;
 
-	th = skb_header_pointer(skb, ihl, sizeof(_tcph), &_tcph);
+	th = skb_header_pointer(skb, iph.len, sizeof(_tcph), &_tcph);
 	if (th == NULL)
 		return;
 
-- 
2.47.3

