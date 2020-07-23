From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 01/26] bpfilter: fix up a sparse annotation
Date: Thu, 23 Jul 2020 08:08:43 +0200
Message-ID: <20200723060908.50081-2-hch@lst.de>
References: <20200723060908.50081-1-hch@lst.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
        References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
        Content-Type:Content-ID:Content-Description;
        bh=F+BrwTbjEUImolj5beS1BIuUXc5PZLOrZP3HablW5rQ=; b=NzYZw+FjLfFD0JRnn0zvrsEGla
        OpCplG7VAlrQMRrrAptI8HlY36sdp/bQUwvI85NfsYGTWTrzqd0OtBgyHoxTz2+6W4uOK8qfoaK9G
        AabbZVEw0A3ckIbqpAejosSfpzclsHm09SqSs1MfIJjEQmvsARHc9VrCnCp93k6HJsEBs752xvDTq
        MEkESJuAraQOrq+EuuSuMQcP8Zlgr0/Cs8uO9VzXB8m9ITyZkg+I7JTS0fyfLD0tWYXg7MBduKZDx
        wLxCjFvBpb2yPtqLFfWnpDKDISyiVskkGGIO0oTHM7QMde4I1Zb4SAKuo6nf88HRBbYNA3r33TDOq
        x96KWjLg==;
In-Reply-To: <20200723060908.50081-1-hch@lst.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>
Cc: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org, bridge@lists.linux-foundation.org, linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-decnet-user@lists.sourceforge.net, linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org, mptcp@lists.01.org, lvs-devel@vger.kernel.org, rds-devel@oss.oracle.com, linux-afs@lists.infradead.org, tipc-discussion@lists.sourceforge.net, linux-x25@vger.kernel.org

The __user doesn't make sense when casting to an integer type, just
switch to a uintptr_t cast which also removes the need for the __force.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 net/bpfilter/bpfilter_kern.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bpfilter/bpfilter_kern.c b/net/bpfilter/bpfilter_kern.c
index 2c31e82cb953af..3bac5820062af1 100644
--- a/net/bpfilter/bpfilter_kern.c
+++ b/net/bpfilter/bpfilter_kern.c
@@ -44,7 +44,7 @@ static int __bpfilter_process_sockopt(struct sock *sk, int optname,
 	req.is_set = is_set;
 	req.pid = current->pid;
 	req.cmd = optname;
-	req.addr = (long __force __user)optval;
+	req.addr = (uintptr_t)optval;
 	req.len = optlen;
 	if (!bpfilter_ops.info.tgid)
 		goto out;
-- 
2.27.0

