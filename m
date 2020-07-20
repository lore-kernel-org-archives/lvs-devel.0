From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 02/24] bpfilter: fix up a sparse annotation
Date: Mon, 20 Jul 2020 14:47:15 +0200
Message-ID: <20200720124737.118617-3-hch@lst.de>
References: <20200720124737.118617-1-hch@lst.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-crypto-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
        References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
        Content-Type:Content-ID:Content-Description;
        bh=KEtThMnZn1T5ZTjfnNtMK17c9WUSVU4JmbBC5GmCo8k=; b=b3r2mKtIMupzynpcKcbswq0IqO
        x3CWNt0l1PaHzJxn2EcCC+srtF/Mq7HfV7lip1uXJnLFShlYH6QJQY2jSIkrIhnf3sVEJDkDqNjCk
        V9gH3mJH8SwG877l7uoU1FWRwM1GLEq8XtvlkXitbXzib9XAND6UehTN8tWUA9fqsXsKJmKc92eZP
        41LRqgsw0A7LsuqS0rj5uDt0YAbFizVFlTTXyAufbzXcu0u4npMvicFmVcDeqbg1ysEaqfgYRNkAX
        lniUhrynXQcYhppU4L4hxBrdsYQ3Wipg5bJvAirZt9QkqUN7wtobU7Ll7F9/YFeTzKA4LaNkLx22I
        ibp2wKgg==;
In-Reply-To: <20200720124737.118617-1-hch@lst.de>
Sender: linux-crypto-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>
Cc: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org, bridge@lists.linux-foundation.org, linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-decnet-user@lists.sourceforge.net, linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org, mptcp@lists.01.org, lvs-devel@vger.kernel.org, rds-devel@oss.oracle.com, linux-afs@lists.infradead.org, tipc-discussion@lists.sourceforge.net, linux-x25@vger.kernel.org

The __user doesn't make sense when casting to an integer type.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 net/bpfilter/bpfilter_kern.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bpfilter/bpfilter_kern.c b/net/bpfilter/bpfilter_kern.c
index 977e9dad72ca4f..713b4b3d02005d 100644
--- a/net/bpfilter/bpfilter_kern.c
+++ b/net/bpfilter/bpfilter_kern.c
@@ -49,7 +49,7 @@ static int __bpfilter_process_sockopt(struct sock *sk, int optname,
 	req.is_set = is_set;
 	req.pid = current->pid;
 	req.cmd = optname;
-	req.addr = (long __force __user)optval;
+	req.addr = (__force long)optval;
 	req.len = optlen;
 	if (!bpfilter_ops.info.tgid)
 		goto out;
-- 
2.27.0

