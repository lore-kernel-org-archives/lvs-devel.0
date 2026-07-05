Received: from azure-sdnproxy.icoremail.net (azure-sdnproxy.icoremail.net [52.175.55.52])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id EA5DA25B08C;
	Sun,  5 Jul 2026 12:31:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=52.175.55.52
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783254699; cv=none; b=WDyy4/PkWdy9miJmjwyQ72JdYlTBc5ysKct3JE1OXxBeoJKJhif6kn378d4XzbPpHs0fAsPqG3kAmwKvApwtqCkLd7NMUBED9+28ElUh9q3iOB7wGXNU5KTwRMd8ZWejlTXYkf5dvC+QDeKkzGRfFnRZtDRqYowuvEwXi4msWN8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783254699; c=relaxed/simple;
	bh=PD2knw/u6d9AXJI/6yKiVENXur5UNuHjYtpY4e2et5Q=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=d3YA1qNc4XsZ2dE4p01L6vtk4xJ0+Wlr0UBesmq3RtvZdLvOXr49vABrw+DjA4Cc+1/+cZDM1k8Bf/G1kB0LJ7NL0fut2xP3+p660msliHSOaTDUbojyHSIUqnYcrQ0kw5Hhg7QsMCtsVigvcaFyl2A6J4VG0XJD4Id5+xyKWBQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn; dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b=frG/a/5T; arc=none smtp.client-ip=52.175.55.52
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b="frG/a/5T"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=mails.tsinghua.edu.cn; s=dkim; h=Received:From:To:Cc:Subject:
	Date:Message-ID:MIME-Version:Content-Transfer-Encoding; bh=gG+XU
	53ywe7NdIH9kWaQJFygNnvfcfysdEfINdlwKn8=; b=frG/a/5T2e7eqe8lbn1h/
	6Kpcni6rwHS9VagGpBf/+a3VuEbKHLW0msEB7sxms8xP/WxgaFPCqxc7zS2Q9m3R
	c+0J0NW6z4Y9TjRFAdQ7ue7VxCOvkQleEl/8HzPYPoXn74x1TAKMLYlrpCrNw7dn
	fpDu59k5S2rctNkTq+9d60=
Received: from localhost.localdomain (unknown [101.5.13.242])
	by web2 (Coremail) with SMTP id yQQGZQAXwpR4Tkpq7Yi_Ag--.12581S2;
	Sun, 05 Jul 2026 20:30:49 +0800 (CST)
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
Subject: [PATCH nf] ipvs: skip IPv6 extension headers in SCTP state lookup
Date: Sun,  5 Jul 2026 20:30:38 +0800
Message-ID: <20260705123040.35755-1-zhaoyz24@mails.tsinghua.edu.cn>
X-Mailer: git-send-email 2.46.2
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-CM-TRANSID:yQQGZQAXwpR4Tkpq7Yi_Ag--.12581S2
X-Coremail-Antispam: 1UD129KBjvJXoWxZry8ArW7Ar1rZF1DZF15CFg_yoW5XF4xpa
	90krWS9FW7Jryqvws7AryxC3y5Gws3Way7Wry8ta43Z3Z0grn5tFy0y3ya93Z8urWvg342
	qr9Iq34UZF4kJFJanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUU9v1xkIjI8I6I8E6xAIw20EY4v20xvaj40_Wr0E3s1l8cAvFVAK
	0II2c7xJM28CjxkF64kEwVA0rcxSw2x7M28EF7xvwVC0I7IYx2IY67AKxVW5JVW7JwA2z4
	x0Y4vE2Ix0cI8IcVCY1x0267AKxVWxJVW8Jr1l84ACjcxK6I8E87Iv67AKxVW0oVCq3wA2
	z4x0Y4vEx4A2jsIEc7CjxVAFwI0_GcCE3s1lnxkEFVAIw20F6cxK64vIFxWle2I262IYc4
	CY6c8Ij28IcVAaY2xG8wAqx4xG64xvF2IEw4CE5I8CrVC2j2WlYx0E74AGY7Cv6cx26r4r
	Kr1UJr1lOx8S6xCaFVCjc4AY6r1j6r4UM4x0Y48IcxkI7VAKI48JM4x0x7Aq67IIx4CEVc
	8vx2IErcIFxwACI402YVCY1x02628vn2kIc2xKxwCY1x0262kKe7AKxVW8ZVWrXwCY02Av
	z4vE14v_Xr1l42xK82IYc2Ij64vIr41l42xK82IY6x8ErcxFaVAv8VW8Ww4UJr1UMxC20s
	026xCaFVCjc4AY6r1j6r4UMI8I3I0E5I8CrVAFwI0_Jr0_Jr4lx2IqxVCjr7xvwVAFwI0_
	JrI_JrWlx4CE17CEb7AF67AKxVW8ZVWrXwCIc40Y0x0EwIxGrwCI42IY6xIIjxv20xvE14
	v26r1j6r1xMIIF0xvE2Ix0cI8IcVCY1x0267AKxVW8JVWxJwCI42IY6xAIw20EY4v20xva
	j40_Jr0_JF4lIxAIcVC2z280aVAFwI0_Jr0_Gr1lIxAIcVC2z280aVCY1x0267AKxVW8JV
	W8JrUvcSsGvfC2KfnxnUUI43ZEXa7VU1eWlPUUUUU==
X-CM-SenderInfo: 52kd05r2suqzpdlo2hxwvl0wxkxdhvlgxou0/1tbiAgITAWpKHF5IggAAs6

set_sctp_state() reads the SCTP chunk header again in order to drive the
IPVS SCTP state table.  For IPv6 it computes the offset with
sizeof(struct ipv6hdr), while the surrounding IPVS code uses iph->len from
ip_vs_fill_iph_skb(), where ipv6_find_hdr() has already skipped extension
headers and found the real transport header.

This makes the state machine read from the wrong offset for IPv6 SCTP
packets that carry extension headers.  For example, an INIT packet with an
8-byte destination options header can be scheduled correctly by
sctp_conn_schedule(), but set_sctp_state() reads the first byte of the SCTP
verification tag as a DATA chunk type.  The connection then moves from NONE
to ESTABLISHED instead of INIT1, gets the longer established timeout, and
updates the active/inactive destination counters incorrectly.  This happens
even though the SCTP handshake has not completed.

Use ip_vs_fill_iph_skb() in set_sctp_state() and base the chunk-header
offset on iph.len, matching sctp_conn_schedule() and the SCTP NAT handlers.
For IPv4 and IPv6 packets without extension headers this preserves the
existing offset.

Fixes: 2906f66a5682 ("ipvs: SCTP Trasport Loadbalancing Support")
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
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 63c78a1f3918..6e0fc23be305 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -375,17 +375,15 @@ set_sctp_state(struct ip_vs_proto_data *pd, struct ip_vs_conn *cp,
 		int direction, const struct sk_buff *skb)
 {
 	struct sctp_chunkhdr _sctpch, *sch;
 	unsigned char chunk_type;
+	struct ip_vs_iphdr iph;
 	int event, next_state;
-	int ihl, cofs;
+	int cofs;
 
-#ifdef CONFIG_IP_VS_IPV6
-	ihl = cp->af == AF_INET ? ip_hdrlen(skb) : sizeof(struct ipv6hdr);
-#else
-	ihl = ip_hdrlen(skb);
-#endif
+	if (!ip_vs_fill_iph_skb(cp->af, skb, false, &iph))
+		return;
 
-	cofs = ihl + sizeof(struct sctphdr);
+	cofs = iph.len + sizeof(struct sctphdr);
 	sch = skb_header_pointer(skb, cofs, sizeof(_sctpch), &_sctpch);
 	if (sch == NULL)
 		return;
-- 
2.47.3

