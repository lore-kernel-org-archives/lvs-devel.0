From: Zhengchao Shao <shaozhengchao@huawei.com>
Subject: [PATCH net,v2 0/2] fix WARNING when removing file in ipvs
Date: Mon, 31 Oct 2022 20:07:03 +0800
Message-ID: <20221031120705.230059-1-shaozhengchao@huawei.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, davem@davemloft.net, edumazet@google.com, kuba@kernel.org, pabeni@redhat.com
Cc: hans.schillstrom@ericsson.com, ebiederm@xmission.com, weiyongjun1@huawei.com, yuehaibing@huawei.com, shaozhengchao@huawei.com

When using strace for fault injection, some warnings are trigged when
files are removed. This is because the file fails to be created during
the initialization, but the initialization continues normally. Therefore,
a WARNING is reported when the file is removed during the exit.

---
v2: add macro isolation
---
Zhengchao Shao (2):
  ipvs: fix WARNING in __ip_vs_cleanup_batch()
  ipvs: fix WARNING in ip_vs_app_net_cleanup()

 net/netfilter/ipvs/ip_vs_app.c  | 10 ++++++++--
 net/netfilter/ipvs/ip_vs_conn.c | 26 +++++++++++++++++++++-----
 2 files changed, 29 insertions(+), 7 deletions(-)

-- 
2.17.1

