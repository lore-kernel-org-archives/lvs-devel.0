From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 03/26] bpfilter: reject kernel addresses
Date: Thu, 23 Jul 2020 08:08:45 +0200
Message-ID: <20200723060908.50081-4-hch@lst.de>
References: <20200723060908.50081-1-hch@lst.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-can-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
        References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
        Content-Type:Content-ID:Content-Description;
        bh=gCUb2KALoHVqEKu8rEH+C8lWt+ULTZIwW5IcTvAPZOE=; b=ATPIX3sYRFhC7WaiE9BzREZuc5
        cG3sYs1eD725v8winTFEqlUitrKu3d6dcE2QNeb9tLQS/xlmm+Lwc0xkgmGNIgb7JCD4ezErd4DBn
        9p9aTwTzEYw6D+be9JrRR3QEczOkzAWwyArehyn1eSvNMr3ISxeuRa3IuGi295j1EfVowQZ2UjQ6Z
        wd/YxGdW+I/jDCW8g89M+AqOLZGJjGXcpB6wuML4/ZE+SDzzAPZHP5kRGWH+QfxuKxtAkaxPtP+/f
        DwmcusSufm/WG/k6lNStK4mo9aHpGpQgKtHqEHIsnJOzGYTQzluUkSiXxr4PmmMJafDnLDnRNxnsh
        i+hp3mvg==;
In-Reply-To: <20200723060908.50081-1-hch@lst.de>
Sender: linux-can-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>
Cc: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org, bridge@lists.linux-foundation.org, linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-decnet-user@lists.sourceforge.net, linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org, mptcp@lists.01.org, lvs-devel@vger.kernel.org, rds-devel@oss.oracle.com, linux-afs@lists.infradead.org, tipc-discussion@lists.sourceforge.net, linux-x25@vger.kernel.org

The bpfilter user mode helper processes the optval address using
process_vm_readv.  Don't send it kernel addresses fed under
set_fs(KERNEL_DS) as that won't work.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 net/bpfilter/bpfilter_kern.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/bpfilter/bpfilter_kern.c b/net/bpfilter/bpfilter_kern.c
index 78d561f2c54da7..00540457e5f4d3 100644
--- a/net/bpfilter/bpfilter_kern.c
+++ b/net/bpfilter/bpfilter_kern.c
@@ -70,6 +70,10 @@ static int bpfilter_process_sockopt(struct sock *sk, int optname,
 		.addr		= (uintptr_t)optval,
 		.len		= optlen,
 	};
+	if (uaccess_kernel()) {
+		pr_err("kernel access not supported\n");
+		return -EFAULT;
+	}
 	return bpfilter_send_req(&req);
 }
 
-- 
2.27.0

