From: KUWAZAWA Takuya <albatross0@gmail.com>
Subject: [PATCH] ipvs: Fix inappropriate output of procfs
Date: Sun, 15 Oct 2017 20:54:10 +0900
Message-ID: <20171015115406.GA11429@nuc02.localdomain>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=pAIJZggyZ1GMMR69IAi3uJL1JE37Fd2AbeKcA7gFxhg=;
        b=QkgBG1wuc8zSdW+GOshppOX6N9alMQyVZUDvAGhdB8drOEKK2Nu6Vkudk2kUWByDK8
         6gwzdZgkBohwylcq5yCpg7cOoaJpDhhemzkxXxWkbd5zSLAQS7LsW7qLP/LQQAgg9H60
         bGQWhy4yjqRX8yF6OZQzUndXfSH9gFSPNfMQ1xz+tehxOemRzQuxarOHmsXmwTr3ADfu
         YyKJXVaZqOxgzBwWs6nLq+IMdYDKdTjs2MtqyA9fMUA266lVV3D0FlwkC+dZSpfAS6/N
         OAHwC/cEEh46OvkIX39Df33juU1numwsY9vwM0fLAzV6HuS4Qhm06WCyDYM8u3AeJ/2x
         4qwA==
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

Information about ipvs in different network namespace can be seen via procfs.

How to reproduce:

  # ip netns add ns01
  # ip netns add ns02
  # ip netns exec ns01 ip a add dev lo 127.0.0.1/8
  # ip netns exec ns02 ip a add dev lo 127.0.0.1/8
  # ip netns exec ns01 ipvsadm -A -t 10.1.1.1:80
  # ip netns exec ns02 ipvsadm -A -t 10.1.1.2:80

The ipvsadm displays information about its own network namespace only.

  # ip netns exec ns01 ipvsadm -Ln
  IP Virtual Server version 1.2.1 (size=4096)
  Prot LocalAddress:Port Scheduler Flags
    -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
  TCP  10.1.1.1:80 wlc

  # ip netns exec ns02 ipvsadm -Ln
  IP Virtual Server version 1.2.1 (size=4096)
  Prot LocalAddress:Port Scheduler Flags
    -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
  TCP  10.1.1.2:80 wlc

But I can see information about other network namespace via procfs.

  # ip netns exec ns01 cat /proc/net/ip_vs
  IP Virtual Server version 1.2.1 (size=4096)
  Prot LocalAddress:Port Scheduler Flags
    -> RemoteAddress:Port Forward Weight ActiveConn InActConn
  TCP  0A010101:0050 wlc
  TCP  0A010102:0050 wlc

  # ip netns exec ns02 cat /proc/net/ip_vs
  IP Virtual Server version 1.2.1 (size=4096)
  Prot LocalAddress:Port Scheduler Flags
    -> RemoteAddress:Port Forward Weight ActiveConn InActConn
  TCP  0A010102:0050 wlc

Signed-off-by: KUWAZAWA Takuya <albatross0@gmail.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 4f940d7..b3245f9 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -2034,12 +2034,16 @@ static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
 		seq_puts(seq,
 			 "  -> RemoteAddress:Port Forward Weight ActiveConn InActConn\n");
 	} else {
+		struct net *net = seq_file_net(seq);
+		struct netns_ipvs *ipvs = net_ipvs(net);
 		const struct ip_vs_service *svc = v;
 		const struct ip_vs_iter *iter = seq->private;
 		const struct ip_vs_dest *dest;
 		struct ip_vs_scheduler *sched = rcu_dereference(svc->scheduler);
 		char *sched_name = sched ? sched->name : "none";
 
+		if (svc->ipvs != ipvs)
+			return 0;
 		if (iter->table == ip_vs_svc_table) {
 #ifdef CONFIG_IP_VS_IPV6
 			if (svc->af == AF_INET6)
-- 
1.8.3.1

